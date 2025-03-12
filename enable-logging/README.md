# Enable Logging

Aplikacja dla tego przykładu znajduje się w katalogu `rails-security-lab/insecure-design`.

https://github.com/maciejb2k/ruby-on-rails-security/tree/main/insecure-design

## Opis

Logowanie w aplikacjach webowych jest kluczowym elementem monitorowania bezpieczeństwa i wykrywania incydentów. W kontekście Ruby on Rails framework domyślnie oferuje mechanizmy logowania, ale ich poprawna konfiguracja i świadome wykorzystanie są niezbędne, aby zapewnić odpowiedni poziom bezpieczeństwa i diagnostyki.

Dobrze skonfigurowane logowanie pomaga w:
- wykrywaniu podejrzanych działań,
- analizowaniu prób nieautoryzowanego dostępu,
- śledzeniu kluczowych zmian w systemie,
- debugowaniu błędów aplikacji i infrastruktury.

Nieprawidłowa konfiguracja logów może prowadzić do ukrywania istotnych zdarzeń lub przeciwnie – nadmiernego logowania, które utrudnia analizę i może nawet stanowić zagrożenie bezpieczeństwa (np. poprzez logowanie wrażliwych danych).

## Przykład

### Domyślne logowanie w Ruby on Rails
Rails domyślnie tworzy logi dla każdego środowiska aplikacji i zapisuje je w katalogu `log/`. Każde środowisko ma swój własny plik logów.
- **Development** – `log/development.log`
- **Production** – `log/production.log`
- **Test** – `log/test.log`

### Środowiska w Rails (`RAILS_ENV`)

Rails wykorzystuje zmienną środowiskową `RAILS_ENV`, aby określić, w jakim trybie działa aplikacja. Domyślnie dostępne są trzy środowiska:
- **Development** – środowisko programistyczne, gdzie włączone są szczegółowe logi (debug), automatyczne przeładowywanie kodu i szczegółowe komunikaty błędów.
- **Production** – środowisko produkcyjne, zoptymalizowane pod kątem wydajności i bezpieczeństwa. Logi są bardziej ograniczone (info lub warn), a błędy nie są wyświetlane użytkownikom.
- **Test** – środowisko używane do testów automatycznych. Logowanie jest minimalne, a baza danych często resetowana między testami.

Aktualne środowisko można sprawdzić w konsoli Rails:
```
rails console
Rails.env
```

Aby uruchomić aplikację w konkretnym środowisku:
```
RAILS_ENV=production rails server
```

### Konfiguracja logowania
Rails umożliwia konfigurację logowania globalnie w config/application.rb, a następnie dostosowanie jej dla każdego środowiska w plikach config/environments/*.rb.

Globalna konfiguracja (`config/application.rb`):
```ruby
module MyApp
  class Application < Rails::Application
    config.log_level = :info
  end
end
```

Konfiguracja dla środowiska (`config/environments/production.rb`):
```ruby
Rails.application.configure do
  ...
  config.log_level = :warn
  config.logger = ActiveSupport::Logger.new("log/production.log", 10, 50.megabytes)
  ...
end
```

Rails w produkcji domyślnie ogranicza logowanie, aby nie przechowywać zbędnych informacji, które mogłyby spowolnić aplikację lub ujawnić wrażliwe dane.

## Skutki

Brak odpowiedniego logowania może prowadzić do:
- **Trudności w wykrywaniu ataków** – Brak zapisów o podejrzanych logowaniach czy zmianach w systemie uniemożliwia skuteczną analizę incydentów.
- **Problematycznego debugowania** – Bez logów trudno jest analizować awarie aplikacji i problemy użytkowników.
- **Braku śladu w post-mortem security incidents** – Jeśli aplikacja zostanie zaatakowana, brak logów może uniemożliwić określenie wektora ataku i skali zagrożenia.
- **Nieprzestrzegania regulacji prawnych** – W niektórych jurysdykcjach wymaga się rejestrowania działań użytkowników, zwłaszcza w systemach finansowych czy medycznych.

## Zalecenia

### Logowanie powinno być zawsze włączone i dostosowane do środowiska

W aplikacji Rails logowanie jest domyślnie aktywne, jednak jego poziom powinien być odpowiednio skonfigurowany w zależności od środowiska:
- **Development** – poziom `debug`, aby rejestrować szczegółowe informacje przydatne w trakcie programowania.
- **Production** – poziom `info` lub `warn`, aby ograniczyć liczbę nieistotnych logów.
- **Test** – poziom `warn` lub `error`, aby unikać zbędnego obciążenia logami w testach automatycznych.

Przykładowa konfiguracja dla środowiska produkcyjnego w `config/environments/production.rb`:

```ruby
Rails.application.configure do
  config.log_level = :warn
end
```

### Zarządzanie logami w przypadku deploymentu na VPS

W przypadku klasycznego wdrożenia na serwerze VPS (np. Phusion Passenger + Capistrano) logi są zapisywane w plikach (`log/production.log`). Aby zapobiec ich nadmiernemu rozrastaniu się, należy:

Skonfigurować rotację logów, aby stare logi były usuwane lub kompresowane:
```ruby
config.logger = ActiveSupport::Logger.new("log/production.log", 10, 100.megabytes)
```

Powyższa konfiguracja oznacza:
- `10` – przechowywanie maksymalnie 10 plików logów,
- `100.megabytes` – maksymalny rozmiar pojedynczego pliku.

Dodatkowo można skonfigurować systemowy mechanizm logrotate `(/etc/logrotate.d/myapp`). To zapewni codzienną rotację logów, ich kompresję oraz przechowywanie skonfigurowaną ilość ostatnich plików.

### Logowanie w przypadku deployu na klastrze Kubernetes

W środowisku Kubernetes, aplikacja działa w stateless podach, co oznacza, że pliki logów przechowywane na dysku mogą zostać utracone po restarcie poda, zatem logi nie powinny być przechowywane na lokalnym dysku, ponieważ pody mogą być restartowane lub usuwane. Zamiast tego:

Logi powinny być wysyłane na STDOUT, aby mogły być zbierane przez Kubernetes:
```ruby
Rails.application.configure do
  config.logger = Logger.new(STDOUT)
  config.log_level = :info
end
```

Dodatkowo, do centralnego zbierania logów warto używać zewnętrznego zcenteralizowanego systemu np. **ELK Stack** (Elasticsearch, Logstash, Kibana), które umożliwia analizę logów w czasie rzeczywistym. Alternatywnie można używać **DataDog** jako komercyjnego rozwiązania SaaS.

### Logowanie kluczowych zdarzeń w systemie

Logowanie istotnych operacji, takich jak próby logowania, zmiany uprawnień użytkowników czy inne krytyczne akcje, jest kluczowe dla bezpieczeństwa aplikacji. Pozwala ono śledzić podejrzaną aktywność, ułatwia analizę incydentów i może stanowić dowód w razie naruszenia systemu. W szczególności warto rejestrować zarówno udane, jak i nieudane próby logowania, co pozwala identyfikować ataki brute-force i nieautoryzowane dostępy.

W aplikacjach korzystających z Devise można dodać logowanie prób logowania w kontrolerze sesji:
```ruby
class Users::SessionsController < Devise::SessionsController
  def create
    user = User.find_by(email: params[:user][:email])
    Rails.logger.info "Login attempt: #{params[:user][:email]} - #{user&.valid_password?(params[:user][:password]) ? 'Success' : 'Failure'} from #{request.remote_ip}"
    super
  end
end
```

### Logowanie zmian w kluczowych modelach

Monitorowanie zmian w istotnych modelach, takich jak konta użytkowników, zamówienia czy ustawienia systemowe, pozwala kontrolować, kto i kiedy dokonał modyfikacji. Jest to szczególnie przydatne w systemach wymagających audytu oraz śledzenia edycji wrażliwych danych.

W Ruby on Rails do tego celu doskonale nadaje się PaperTrail, który automatycznie zapisuje historię zmian w modelach i pozwala na ich późniejsze przywracanie. Aby go użyć, wystarczy dodać do modelu:

```ruby
class User < ApplicationRecord
  has_paper_trail
end
```