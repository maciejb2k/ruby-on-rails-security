# Cleartext Transmission of Sensitive Information

## Opis

Cleartext Transmission of Sensitive Information (Przesyłanie wrażliwych informacji w postaci jawnej) to poważna luka w zabezpieczeniach aplikacji webowych, w której poufne dane użytkowników są przesyłane bez odpowiedniego szyfrowania. 

Taka sytuacja występuje najczęściej, gdy aplikacja używa protokołu HTTP zamiast HTTPS, a także gdy przesyła tokeny sesyjne, hasła lub inne krytyczne informacje w jawnym tekście w nagłówkach, plikach cookie lub parametrach URL.

Podczas transmisji dane mogą być przechwycone przez atakujących, co prowadzi do poważnych konsekwencji, takich jak kradzież tożsamości, przejęcie konta lub naruszenie prywatności użytkowników.

## Przykłady

Najczęstsze błędy prowadzące do podatności:
1. **Brak wymuszania HTTPS** – aplikacja pozwala na połączenia HTTP, przez co dane mogą być przechwycone przez atakującego (np. MITM – Man-in-the-Middle Attack).
2. **Przesyłanie wrażliwych danych w URL** – hasła, tokeny sesyjne lub inne dane są przekazywane w parametrach URL, które mogą być logowane lub przechwytywane.
3. **Brak użycia Secure i HttpOnly dla cookie**s – sesje użytkowników mogą być wykradzione, jeśli przeglądarka pozwala na ich dostęp z poziomu JavaScript lub przesyła je przez HTTP.
4. **Brak szyfrowania danych przed transmisją** – poufne informacje, takie jak numery kart kredytowych, są przesyłane w postaci jawnej w treści żądania lub odpowiedzi.
5. **Nieprawidłowa konfiguracja proxy i serwerów aplikacji** – aplikacja może pozwalać na przekazywanie danych przez niezaufane serwery, które nie zapewniają ochrony TLS.

## Skutki

1. **Atak Man-in-the-Middle (MITM)**
   - Atakujący może przechwycić hasło użytkownika i użyć go do przejęcia konta.
   - Narzędzia typu Wireshark pozwalają na sniffowanie ruchu HTTP i wyciąganie poufnych danych.
2. **Przechwycenie sesji użytkownika**
   - Jeśli sesja użytkownika jest przesyłana w jawnym tekście, atakujący może ukraść identyfikator sesji i przejąć jego konto.
3. **Wycieki wrażliwych informacji w logach serwera**
   - Jeśli aplikacja zapisuje adresy URL w logach, a te zawierają hasła lub tokeny, to dane mogą zostać nieumyślnie ujawnione.

## Zalecenia

### 1. Wymuszanie HTTPS w aplikacji Rails

Najważniejszym krokiem jest wymuszenie szyfrowanej transmisji poprzez protokół TLS. Można to zrobić, ustawiając opcję `config.force_ssl = true` w pliku konfiguracyjnym:

```ruby
# config/environments/production.rb
config.force_ssl = true
```

Dzięki temu wszystkie żądania HTTP będą automatycznie przekierowywane na HTTPS.

### 2. Konfiguracja zabezpieczeń dla cookies

Aby zabezpieczyć sesje użytkowników, należy wymusić bezpieczne ustawienia dla cookies:

```ruby
Rails.application.config.session_store :cookie_store, key: '_secure_app',
  secure: Rails.env.production?, httponly: true
```

Opcja `secure: true` zapewnia, że cookie będzie przesyłane tylko przez HTTPS, a httponly: true uniemożliwia jego odczytanie przez JavaScript.

### 3. Usunięcie wrażliwych danych z URL

Nie należy przesyłać poufnych informacji jako parametry w adresach URL:
```
https://example.com/reset_password?token=12345
```

Zamiast tego należy używać tokenów w nagłówkach HTTP lub w ciele żądania:
```
headers['Authorization'] = "Bearer #{token}"
```
