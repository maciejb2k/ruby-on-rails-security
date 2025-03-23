# Object Level Authorization (OLA)

Aplikacja dla tego przykładu znajduje się w katalogu `rails-security-lab/broken-access-control`.

https://github.com/maciejb2k/ruby-on-rails-security/tree/main/broken-access-control

## Przykład

Przyjrzyjmy się przykładowej aplikacji `broken-access-control`. Aplikacja ta pozwala na zarządzanie zadaniami. Użytkownik może zalogować się do aplikacji, dodać nowe zadanie, edytować zadanie, usunąć zadanie oraz zobaczyć listę zadań.

![](./screenshots/login-empty.png)

Analogicznie jak w przypadku podatności IDOR, mamy te same poczatkowe kroki postępowania.

Po zalogowaniu się jako użytkownik `maciek@example.com`, możemy zobaczyć liste jego wszystkich zadań:

![](./screenshots/maciek-tasks.png)

Gdy wejdziemy w szczegóły zadania, widzimy, że należy ono na pewno do zalogowanego użytkownika i ma ono `id=1`.

![](./screenshots/maciek-show-task.png)

Co gdybyśmy spróbowali zmienić `id` zadania w adresie URL na `6`?

![](./screenshots/maciek-show-tomek-task-url.png)

Modyfikując adres URL, jesteśmy w stanie zobaczyć zadanie należące do użytkownika `tomek@example.com`.

W przeciwieństwie do IDOR, zamiast zawężać bezpośrednio zakres zwracanych wyników w kontrolerze, czytelniejszym i bezpieczniejszym rozwiązaniem jest sprawdzanie uprawnień na poziomie obiektu.

We frameworku Ruby on Rails wykorzystuje się do tego problemu gotowe narzędzia do autoryzacji, najlpopularniejszym z nich jest `Pundit`. W celu zabezpieczenia aplikacji, po zainstalowaniu tej paczki, należy dodać odpowiednią weryfikację dostępu za pomocą klasy polisy.

Przykład takiej polisy dla modelu `Task`:

```ruby
class TaskPolicy < ApplicationPolicy
  def show?
    task.user == user
  end

  def edit?
    task.user == user
  end

  def update?
    task.user == user
  end

  def destroy?
    task.user == user
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope.where(user: user)
    end
  end
end
```

W naszej aplikacji w kontrolerze akcje są zabezpieczone właśnie za pomocą tej polisy, która jest wywoływana w kontrolerze:

```ruby
class TasksController < ApplicationController
  ...

  def secure_show_pundit
    authorize @task, :show?

    render :show
  end

  ...
end
```

Przykład w jaki sposób są zabezpieczone inne akcje w kontrolerze za pomocą polisy:
```ruby
class TasksController < ApplicationController
  ...

  def index
    @tasks = policy_scope(Task)
  end

  def edit
    authorize @task

    render :edit
  end

  def update
    authorize @task

    if @task.update(task_params)
      redirect_to @task, notice: 'Task was successfully updated.', status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @task

    @task.destroy!
    redirect_to tasks_url, notice: 'Task was successfully destroyed.', status: :see_other
  end

  ...
end
```

Gdybyśmy spróbowali teraz wejść na stronę zadania, za pomoca bezpiecznej już metody `secure_show_pundit`, dostalibyśmy błąd `403 Forbidden`:

![](./screenshots/maciek-show-task-pundit.png)

Dodatkowo, gdy użytkownik `maciek@example.com` chce usunąć swój zasób, to może to bez problemu zrobić:

![](./screenshots/maciek-destroy-own.png)

Gdyby chciał usunąć zasób należący do użytkownika `tomek@example.com`, do którego uzyskał dostęp przez podatność IDOR w metodzie show, to nie bedzie w stanie wykonać żadnej innej akcji poza wyświetleniem, bo całą reszta akcji zabroniona jest przez polisę.

### Domyślna polityka "deny"

Ruby on Rails jako framework nie narzuca domyślnej autoryzacji metod w kontrolerach – jeżeli programista nie zaimplementuje mechanizmu autoryzacji, akcje będą wykonywane bez ograniczeń.

W przypadku biblioteki `Pundit`, której używamy w tej aplikacji, domyślnie każda metoda w polisie musi być jawnie zdefiniowana.

Jeśli wywołamy `authorize @task` w kontrolerze dla danej akcji (np. `show`) i w klasie polisy `TaskPolicy` nie będzie metody` show?`, Pundit podniesie wyjątek `Pundit::NotDefinedError`, co w praktyce oznacza brak dostępu do tej akcji.

Co więcej, sam fakt niewywołania `authorize` w kontrolerze nie powoduje automatycznego blokowania dostępu – dlatego dobrą praktyką jest stosowanie mechanizmów sprawdzających, czy autoryzacja została wywołana w każdej akcji, np.:

```ruby
class ApplicationController < ActionController::Base
  include Pundit

  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index
end
```

## Zalecenia

- **Stosowanie `Pundit` lub innego narzędzia do autoryzacji** w celu wymuszania kontroli dostępu na poziomie obiektów.
- **Zasada "domyślnie zabroń" (deny by default)** - wdrożenie `verify_authorized` i `verify_policy_scoped` na poziomie bazowego kontrolera (np. ApplicationController), by wymusić autoryzację we wszystkich akcjach.
- **Unikanie ręcznego sprawdzania uprawnień w kontrolerach** – lepiej stosować dedykowane klasy polis, co zwiększa czytelność i ułatwia utrzymanie kodu.
- **Testowanie scenariuszy dostępu** – regularne testowanie aplikacji pod kątem nieautoryzowanego dostępu (w tym prób manipulacji parametrami URL).
