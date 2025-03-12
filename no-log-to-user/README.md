# No Log To User

## Opis

Bezpieczeństwo aplikacji webowych wymaga, aby szczegóły błędów nie były ujawniane użytkownikom końcowym. Wycieki informacji o wyjątkach, ścieżkach systemowych czy strukturze aplikacji mogą pomóc potencjalnym atakującym w znalezieniu luk w zabezpieczeniach. Ruby on Rails domyślnie wyświetla pełne komunikaty błędów w środowisku deweloperskim, ale na produkcji powinno to być wyłączone.

Dobrą praktyką jest logowanie błędów w systemie monitorowania wyjątków, ale bez ich wyświetlania użytkownikom. W wielu przypadkach nie trzeba ręcznie obsługiwać wyjątków – np. gdy żądany zasób nie istnieje, Rails automatycznie zwraca 404 Not Found, a przy błędach serwera 500 Internal Server Error.

## Przykład

W środowisku deweloperskim Rails domyślnie wyświetla pełne strony błędów, zawierające szczegóły wyjątku, stack trace oraz podgląd kodu w miejscu, w którym wystąpił problem. Jest to przydatne dla programistów, ale niebezpieczne na produkcji, ponieważ ujawnia wewnętrzne szczegóły aplikacji.

Zachowanie to kontroluje konfiguracja w pliku `config/environments/development.rb`:

```ruby
config.consider_all_requests_local = true
```

W efekcie, gdy w aplikacji wystąpi błąd, użytkownik w środowisku deweloperskim zobaczy pełny komunikat o błędzie.

![500 Internal Server Error](./screenshots/exception.png)

W środowisku produkcyjnym (`config/environments/production.rb`) powinno to być ustawione na false, aby użytkownicy nie mieli dostępu do wewnętrznych informacji o aplikacji:

```ruby
config.consider_all_requests_local = false
```

Dzięki temu zamiast szczegółowego stack trace użytkownik zobaczy charakterystyczną ogólną stronę błędu z kodem HTTP 500.

![500 Internal Server Error](./screenshots/error.png)

## Skutki

Ujawnianie szczegółów błędów na produkcji może prowadzić do poważnych zagrożeń bezpieczeństwa i negatywnie wpływać na doświadczenie użytkowników:

Głównym skutkiem jest **wyciek informacji o systemie** – stack trace i komunikaty błędów mogą ujawniać informacje o strukturze bazy danych, katalogach serwera, bibliotekach i frameworkach, co ułatwia atakującym znalezienie podatności.

Dodatkowo prezentowanie użytkownikowi nieobsłużonych technicznych komunikatów błędów wygląda nieprofesjonalnie i obniża zaufanie do systemu.

## Zalecenia

### Nie ujawniaj szczegółów błędów na produkcji

Na produkcji aplikacja nie powinna wyświetlać szczegółowych komunikatów błędów. W pliku `config/environments/production.rb` należy upewnić się, że opcja `consider_all_requests_local` jest wyłączona. Domyślnie Rails ustawia ją na `false`, ale warto się upewnić:

```ruby
config.consider_all_requests_local = true
```

### Poprawnie obsługuj wyjątki w aplikacji

W aplikacjach typu API i GraphQL kluczowe jest zwracanie poprawnych kodów HTTP i jasnych komunikatów błędów. Rails domyślnie obsługuje wiele wyjątków, np. brak zasobu (ActiveRecord::RecordNotFound) zwróci 404 Not Found, więc nie ma potrzeby ręcznej obsługi takich błędów.

Natomiast w przypadku autoryzacji, np. przy użyciu Pundit, warto zwrócić odpowiedni status HTTP zamiast domyślnego błędu. Można też napisać własny handler do wyjątków i wywoływać go w API, co zapewni spójny system zwracania błędów i odpowiednich statusów HTTP.

Przykład obsługi błędów w kontrolerze dla API:

```ruby
class Api::BaseController < ApplicationController
  include ApiException::Handler

  rescue_from Pundit::NotAuthorizedError do |_exception|
    render json: { error: "You are not authorized to perform this action" }, status: :forbidden
  end
end
```

### Logowanie wyjątków do zewnętrznego systemu (np. Sentry)

Chociaż wyjątki na produkcji są zapisywane w logach, samo ich logowanie może nie wystarczać do skutecznego monitorowania problemów. Korzystanie z dedykowanych narzędzi, takich jak Sentry, pozwala na bieżąco śledzić błędy, analizować ich częstotliwość i szybciej na nie reagować.

Sentry to popularne narzędzie do monitorowania błędów, które automatycznie przechwytuje wyjątki i dostarcza szczegółowe informacje na ich temat. Jest dostępne jako open-source do samodzielnego hostowania lub jako płatna usługa w chmurze, która oferuje dodatkowe funkcjonalności, takie jak integracje z systemami powiadomień (Slack, e-mail) czy priorytetyzację błędów.

Jeśli dany błąd zacznie gwałtownie się powtarzać, Sentry umożliwi natychmiastowe wykrycie eskalacji problemu, co przyspieszy jego diagnozę i naprawę. Dodatkowo, powiadomienia o błędach mogą być automatycznie wysyłane do odpowiednich osób w zespole, bez ujawniania szczegółów technicznych użytkownikom końcowym.

Samo rejestrowanie błędów w logach serwera nie zawsze jest wystarczające – warto przesyłać je do systemu monitorowania, takiego jak Sentry, który pozwala na lepszą kontrolę i analizę incydentów.

Konfiguracja Sentry w Rails `config/initializers/sentry.rb`, która domyślnie będzie wysyłać wszystkie wyjątki do Sentry:
```ruby
Sentry.init do |config|
  config.dsn = ENV['SENTRY_DSN']
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]
  config.send_default_pii = true
end
```

Sentry będzie automatycznie przechwytywać wszystkie wyjątki, ale można też ręcznie raportować błędy w kodzie, w przypadku gdy chcemy obsłużyć wyjątek, ale mimo obsłużenia zaraportować go do Sentry:

```ruby
begin
  # Kod mogący generować wyjątek
  risky_operation
rescue => e
  Sentry.capture_exception(e)
end
```
