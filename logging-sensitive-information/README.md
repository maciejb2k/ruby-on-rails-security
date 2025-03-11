# Logging sensitive information

Aplikacja dla tego przykładu znajduje się w katalogu `rails-security-lab/insecure-design`.

https://github.com/maciejb2k/ruby-on-rails-security/tree/main/insecure-design

## Opis

Niewłaściwe logowanie wrażliwych danych może prowadzić do ich niekontrolowanego ujawnienia i naruszenia bezpieczeństwa aplikacji. W kontekście Ruby on Rails problemem jest rejestrowanie poufnych informacji użytkowników, takich jak hasła, tokeny API czy numery kart kredytowych, które mogą trafić do logów serwera i stać się łatwym celem dla atakujących.

Domyślnie Rails oferuje mechanizmy ochrony przed logowaniem poufnych danych, np. poprzez konfigurację `filter_parameters` oraz `filter_attributes` w Active Record. Jednak niewłaściwa konfiguracja lub jej brak może prowadzić do tego, że dane te zostaną zapisane w logach serwera, skąd mogą zostać odczytane przez atakujących, ciekawskich pracowników lub wysłane do zewnętrznych systemów monitorowania.

## Przykład

W aplikacji Rails domyślnie istnieje od razu skonfigurowany mechanizm filtracji wrażliwych danych przed zapisaniem ich do logów. W `config/initializers/filter_parameters.rb` znajduje się następujący kod:

```ruby
Rails.application.config.filter_parameters += %i[
  passw email secret token _key crypt salt certificate otp ssn
]
```

Ta konfiguracja sprawia, że jeżeli w logach aplikacji pojawi się parametr pokrywający się częściowo z jednym z powyższych słów kluczowych, to zostanie on zastąpiony przez słowo `[FILTERED]`. Dzięki temu w logach nie pojawią się wrażliwe dane, które mogłyby zostać wykorzystane przez atakujących.

Przykładowo, jeżeli użytkownik będzie logował się w aplikacji, to przy włączonym logowaniu zostaną wyświetlone przekazane parametry do kontrolera, ale wykluczone zostaną te, które skonfigurowano jako wrażliwe:

![](./screenshots/logs.png)

Te same zasady dotyczą podczas korzystania z konsoli railsowej, która jest interaktywnym REPL-em z kontekstem aplikacji. W konsoli również nie zostaną wyświetlone wrażliwe dane, które zostały przekazane jako parametry.

![](./screenshots/console.png)

Dodatkowo, na poziomie modelu ActiveRecord można okreslić, które atrybuty mają być filtrowane przed zapisaniem do bazy danych. Dla przykładu w modelu `User` można dodać:

```ruby
class User < ApplicationRecord
  self.filter_attributes += [:secret, :token]
end
```

Jednak jeśli aplikacja nie stosuje tych mechanizmów lub loguje pełne żądania i obiekty bez filtracji, dane te mogą trafić do logów i stać się łatwym celem dla atakujących. Jeżeli użytkownik świadomie wyłączy filtrowanie tych parametrów w konfiguracji, to w logach pojawią się pełne dane, w tym wrażliwe informacje, tak jak na poniższym zrzucie ekranu:

![](./screenshots/logs-off.png)

## Skutki

Jeżeli aplikacja loguje wrażliwe dane, to może to prowadzić do różnych problemów związanych z bezpieczeństwem i prywatnością użytkowników:
- **Ułatwienie pracy atakującym** – Logi są często przechowywane w postaci tekstowej, co sprawia, że przejęcie serwera przez atakującego umożliwia łatwe przeszukiwanie plików logów w celu znalezienia wrażliwych danych.
- **Ryzyko wycieku danych przez pracowników** – Ciekawscy administratorzy lub programiści mogą nieświadomie przeglądać logi zawierające dane użytkowników, co może prowadzić do naruszenia polityk prywatności.
- **Przekazywanie wrażliwych danych do zewnętrznych usług** – Aplikacje często korzystają z narzędzi do monitorowania i raportowania błędów (np. AppSignal, New Relic, Sentry). Jeśli logi zawierają poufne informacje, mogą one trafić na zewnętrzne serwery, naruszając regulacje o ochronie danych osobowych.
- **Nieumyślne ujawnienie danych** – Jeśli logi zawierają wrażliwe informacje, mogą one przypadkowo zostać ujawnione podczas prezentacji na spotkaniu biznesowym, pracy zespołowej czy debugowania na żywo, co może prowadzić do naruszenia prywatności użytkowników lub ujawnienia kluczowych danych firmowych osobom niepowołanym.

## Zalecenia

### Konfiguracja filtracji wrażliwych danych

Rails domyślnie oferuje mechanizm `filter_parameters` na poziomie globalnym oraz `filter_attributes`, który zapobiega zapisywaniu poufnych informacji w logach.

Należy upewnić się, że konfiguracja ta jest poprawnie ustawiona i na bieżąco uzupełniana o nowe wrażliwe pola wraz z rozwojem aplikacji. Przykładowo, jeśli aplikacja zacznie obsługiwać nowe typy tokenów lub kluczy API, powinny one zostać dodane do tej listy, aby uniknąć ich przypadkowego ujawnienia.

### Logowanie tylko niezbędnych informacji

Należy unikać logowania pełnych żądań HTTP, obiektów ActiveRecord czy innych struktur danych, które mogą zbędne zawierać wrażliwe informacje. W logach powinny znaleźć się tylko niezbędne informacje diagnostyczne do debugowania i monitorowania aplikacji, takie jak informacje o błędach, wyjątkach czy zdarzeniach systemowych.