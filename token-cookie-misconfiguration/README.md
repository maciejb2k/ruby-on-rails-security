# Token / Cookie Misconfiguration

Aplikacja dla tego przykładu znajduje się w katalogu `broken-access-control`.

https://github.com/maciejb2k/ruby-on-rails-security/tree/main/broken-access-control

## Opis

Niewłaściwa konfiguracja tokenów i ciasteczek (cookies) w aplikacjach webowych może prowadzić do szeregu problemów związanych z bezpieczeństwem, takich jak przechwycenie sesji użytkownika, ataki CSRF (Cross-Site Request Forgery), XSS (Cross-Site Scripting) czy nieautoryzowany dostęp do wrażliwych danych.

Sesja w aplikacji webowej to mechanizm przechowywania danych użytkownika między kolejnymi żądaniami HTTP

W aplikacjach opartych na Ruby on Rails sesje mogą być przechowywane na różne sposoby:
- `CookieStore` (domyślny) – przechowuje sesję w zaszyfrowanym ciasteczku po stronie klienta.
- `CacheStore` – sesja przechowywana w pamięci podręcznej, np. w `Memcached` lub `Redis`.
- `ActiveRecordStore` – sesja przechowywana w bazie danych np. `PostgreSQL`.
- `MemCacheStore` – sesja w Memcached, podobnie jak CacheStore.

Kluczowa różnica między `CookieStore`, a `CacheStore`, `MemCacheStore` lub `ActiveRecordStore` polega na tym, że w `CookieStore` cała zawartość sesji jest przechowywana po stronie klienta, natomiast w pozostałych przechowywany jest jedynie identyfikator sesji, a jej zawartość pozostaje po stronie serwera.

## Przykład

### Analiza sesji użytkownika w przeglądarce

Jako przykład przyjrzyjmy się aplikacji z mechanizmem uwierzytelniania wykorzystującym bibliotekę Devise i domyślne ustawienia w Ruby on Rails.

![](./screenshots/login-empty.png)

Po zalogowaniu gdy przyjrzymy się ciasteczkom w narzedziach developerskim możemy zaobserwować przesłane ciasteczka:

![](./screenshots/session-cookie.png)

Co możemy zaobserwować:
- Railsy domyślnie używają `CookieStore`, co oznacza, że cała sesja użytkownika znajduje się w przeglądarce.
- Ciasteczko ma nazwę `_app_session`, a jego wartość jest zaszyfrowana i podpisana za pomocą klucza `SECRET_KEY_BASE`.
- Flaga `HttpOnly` jest domyślnie włączona – ciasteczko nie jest dostępne dla JavaScriptu.
- Flaga `SameSite=Lax` ogranicza ataki CSRF.
- Brakuje flagi `Secure`, co oznacza, że ciasteczko może być przesyłane po HTTP i narażone na atak MITM.

W Ruby on Rails ciasteczka domyślnie są **podpisane** (signed) i **zaszyfrowane** (encrypted):
- **Signed cookies** - zapewniają, że dane w ciasteczku nie zostały zmienione przez użytkownika, ponieważ są podpisane kluczem SECRET_KEY_BASE. Jednak ich treść jest widoczna dla użytkownika i może być odczytana.
- **Encrypted cookies** - dodatkowo szyfrują zawartość, więc użytkownik nie może zobaczyć danych nawet po ich przechwyceniu.

## Skutki

Przykład błędnie skonfigurowanego ciasteczka:

```ruby
Rails.application.config.session_store :cookie_store,
  key: '_app_session',
  secure: false,   # NIEBEZPIECZNE: ciasteczko wysyłane po HTTP
  httponly: false, # NIEBEZPIECZNE: podatność na XSS
  same_site: :none # NIEBEZPIECZNE: możliwość CSRF
```

Źle skonfigurowane ciasteczka i sesje mogą prowadzić do różnych ataków:
1. **Przechwycenie sesji** (Session Hijacking):
   - Jeśli brakuje flagi `Secure`, ciasteczko sesji może zostać przechwycone w niezabezpieczonej sieci (atak MITM).
   - Przykład ataku MITM: jeśli użytkownik korzysta z HTTP zamiast HTTPS, atakujący w tej samej sieci może przechwycić ciasteczko.

2. **Ataki XSS** (Cross-Site Scripting):
   - Jeśli brakuje `HttpOnly`, złośliwy JavaScript może wykraść sesję:

     ```js
     console.log(document.cookie);
     ```

3. **Ataki CSRF** (Cross-Site Request Forgery):
   - Jeśli `SameSite` jest ustawione na `None`, a `Secure` jest wyłączone, ciasteczko może być wykorzystane w ataku CSRF.

4. Nieautoryzowany dostęp do wrażliwych danych:
   - Przechowywanie wrażliwych danych w ciasteczkach bez szyfrowania może doprowadzić do ich wykradzenia.

## Zalecenia

### Poprawne skonfigurowanie ciasteczek sesji

Domyślnie w Ruby on Rails konfiguracja sesji nie jest jawnie określona, ponieważ korzysta z domyślnych, ukrytych wartości. Jeśli chcemy zmienić te ustawienia, musimy ręcznie dodać odpowiednie wpisy w plikach konfiguracyjnych dla wybranego środowiska (`config/environments/development.rb` lub `config/environments/production.rb`), pamiętając o podaniu pełnych i poprawnych parametrów.

#### Opis flag ciasteczek

Aby zapewnić bezpieczeństwo sesji, ciasteczka powinny być odpowiednio skonfigurowane:

- `Expires` – określa czas wygaśnięcia ciasteczka. Brak tej opcji oznacza, że wygasa po zamknięciu przeglądarki.
- `Domain` – definiuje, dla jakiej domeny ciasteczko jest dostępne. Jeśli nie jest ustawione, dotyczy tylko bieżącej domeny.
- `Path` – ogranicza ciasteczko do konkretnej ścieżki (np. /admin oznacza dostępność tylko dla /admin/*).
- `SameSite` – ogranicza wysyłanie ciasteczek w żądaniach cross-site, aby zapobiec atakom CSRF:
  - `Strict` – ciasteczko wysyłane tylko w obrębie tej samej domeny.
  - `Lax` (domyślnie w Rails) – ciasteczko wysyłane w żądaniach GET, ale nie w POST/PUT/DELETE.
  - `None` – ciasteczko wysyłane zawsze, ale wymaga Secure: true.
- `Secure` – ciasteczko wysyłane tylko przez HTTPS, chroni przed przechwyceniem sesji.
- `HttpOnly` – blokuje dostęp do ciasteczka przez JavaScript, zapobiega atakom XSS.

#### Poprawna konfiguracja

Ustaw flagę `Secure` – wymuś używanie HTTPS na produkcji:

```ruby
Rails.application.config.session_store :cookie_store, key: '_app_session', secure: Rails.env.production?
```

Włącz `HttpOnly`, aby zapobiec atakom XSS:

```ruby
Rails.application.config.session_store :cookie_store, key: '_app_session', httponly: true
```

Ogranicz wysyłanie ciasteczek między domenami (`SameSite`: `Lax` lub `Strict`):

```ruby
Rails.application.config.session_store :cookie_store, key: '_app_session', same_site: :lax
```

Rozważ przechowywanie sesji w bazie (`ActiveRecordStore`), jeśli aplikacja wymaga większej kontroli:

```ruby
Rails.application.config.session_store :active_record_store, key: '_app_session'
```

Ogranicz czas życia sesji, aby unieważnić sesję po określonym czasie:

```ruby
Rails.application.config.session_store :cookie_store, key: '_app_session', expire_after: 14.days
```

Przykład pełnej poprawnej konfiguracji:

```ruby
Rails.application.config.session_store :cookie_store,
  key: '_app_session',
  secure: Rails.env.production?,
  httponly: true,
  same_site: :lax,
  expire_after: 14.days
```

### Przechowywanie sesji w przeglądarce lub w bazie danych

W `CookieStore` cała sesja użytkownika jest przechowywana w przeglądarce, co ma pewne ograniczenia:

- Brak możliwości unieważnienia pojedynczej sesji – użytkownik pozostaje zalogowany, dopóki ciasteczko nie wygaśnie.
- Ograniczenie rozmiaru – ciasteczko może mieć maksymalnie 4 KB.
- Zależność od `SECRET_KEY_BASE`:
  - Jeśli klucz zostanie ujawniony, atakujący może odszyfrować i modyfikować ciasteczka.
  - Zmiana `SECRET_KEY_BASE` powoduje unieważnienie sesji wszystkich użytkowników.

W `CacheStore` lub `ActiveRecordStore` sesja jest przechowywana po stronie serwera, a w ciasteczku znajduje się jedynie identyfikator sesji. Oznacza to, że:
- Można unieważnić pojedynczą sesję bez konieczności wylogowania wszystkich użytkowników.
- Brak ograniczenia rozmiaru sesji – w przeciwieństwie do `CookieStore`, gdzie limit wynosi 4 KB.
- Identyfikator sesji jest generowany losowo i nie jest zależny od `SECRET_KEY_BASE`. Przeglądarka otrzymuje tylko ten identyfikator.
- Wymagana jest osobna baza danych do przechowywania sesji, np. `Redis` lub `PostgreSQL`.
- Sesje nie są automatycznie usuwane – konieczne jest ich regularne czyszczenie, aby uniknąć nadmiernego zużycia pamięci.
- Wraz ze wzrostem liczby użytkowników sesje będą zajmować coraz więcej miejsca, co wymaga monitorowania i zarządzania przestrzenią.
- Jeśli cache zostanie wyczyszczony (np. restart `Redis`), wszystkie sesje zostaną utracone i użytkownicy zostaną wylogowani.

Zaleca się rozpoczęcie od `CookieStore`, a w zależności od potrzeb i skali aplikacji rozważyć przechowywanie sesji po stronie serwera za pomocą `CacheStore` lub `ActiveRecordStore`, zapewniając odpowiednie zarządzanie sesjami w bazie.danych.

### Flaga `SameSite=Strict` i jej ograniczenia

Flaga `SameSite=Strict` zapobiega wysyłaniu ciasteczek w żądaniach cross-site, co skutecznie chroni przed atakami CSRF. Jednak jej zastosowanie może powodować problemy z funkcjonalnością aplikacji w scenariuszach wymagających komunikacji między domenami, takich jak OAuth.

W przypadku przepływu OAuth użytkownik jest przekierowywany między domenami (np. od dostawcy autoryzacji do aplikacji). Jeśli ciasteczko zawiera flagę `SameSite=Strict`, przeglądarka nie wyśle go po powrocie do aplikacji, co uniemożliwi zakończenie procesu logowania

W takim przypadku zalecane jest korzystanie z `SameSite=Lax`, które pozwala na wysyłanie ciasteczek w żądaniach GET wynikających z nawigacji użytkownika.