## TLS Force / HSTS


## Opis

Cleartext Transmission of Sensitive Information (Przesyłanie wrażliwych informacji w postaci jawnej) to poważna luka w zabezpieczeniach aplikacji webowych, w której poufne dane użytkowników są przesyłane bez odpowiedniego szyfrowania. Taka sytuacja występuje najczęściej, gdy aplikacja używa protokołu HTTP zamiast HTTPS, a także gdy przesyła tokeny sesyjne, hasła lub inne krytyczne informacje w jawnym tekście w nagłówkach, plikach cookie lub parametrach URL.

Podczas transmisji dane mogą być przechwycone przez atakujących, co prowadzi do poważnych konsekwencji, takich jak kradzież tożsamości, przejęcie konta lub naruszenie prywatności użytkowników. Jednym z kluczowych mechanizmów ochrony przed tego typu zagrożeniami jest HTTP Strict Transport Security (HSTS), który zapewnia, że cała komunikacja między przeglądarką a serwerem odbywa się wyłącznie przez szyfrowane połączenia HTTPS.

## Przykłady

Najczęstsze błędy prowadzące do podatności:
- **Brak wymuszania HTTPS** – aplikacja pozwala na połączenia HTTP, przez co dane mogą być przechwycone przez atakującego (np. MITM – Man-in-the-Middle Attack). Aby temu zapobiec, należy włączyć HSTS, co zagwarantuje, że przeglądarka automatycznie przekieruje wszystkie żądania na HTTPS i zablokuje niezaszyfrowane połączenia.
- **Przesyłanie wrażliwych danych w URL** – hasła, tokeny sesyjne lub inne dane są przekazywane w parametrach URL, które mogą być logowane lub przechwytywane.
- **Brak użycia Secure i HttpOnly dla cookies** – sesje użytkowników mogą być wykradzione, jeśli przeglądarka pozwala na ich dostęp z poziomu JavaScript lub przesyła je przez HTTP.
- **Brak szyfrowania danych przed transmisją** – poufne informacje, takie jak numery kart kredytowych, są przesyłane w postaci jawnej w treści żądania lub odpowiedzi.
- **Nieprawidłowa konfiguracja proxy i serwerów aplikacji** – aplikacja może pozwalać na przekazywanie danych przez niezaufane serwery, które nie zapewniają ochrony TLS.

## Skutki

1. **Atak Man-in-the-Middle (MITM)**
   - Atakujący może przechwycić hasło użytkownika i użyć go do przejęcia konta.
   - Narzędzia typu Wireshark pozwalają na sniffowanie ruchu HTTP i wyciąganie poufnych danych.
   - Mechanizm HSTS skutecznie chroni przed atakami SSL Stripping, które mogą pozwolić atakującym na wymuszenie niezabezpieczonego połączenia HTTP.
2. **Przechwycenie sesji użytkownika**
   - Jeśli sesja użytkownika jest przesyłana w jawnym tekście, atakujący może ukraść identyfikator sesji i przejąć jego konto.
3. **Wycieki wrażliwych informacji w logach serwera**
   - Jeśli aplikacja zapisuje adresy URL w logach, a te zawierają hasła lub tokeny, to dane mogą zostać nieumyślnie ujawnione.

## Zalecenia

### Wymuszanie HTTPS w aplikacji Rails

Najważniejszym krokiem jest wymuszenie szyfrowanej transmisji poprzez protokół TLS. Można to zrobić za pomocą opcji `config.force_ssl = true`, która automatycznie:
- Przekierowuje wszystkie żądania HTTP na HTTPS.
- Ustawia flagę secure dla ciasteczek.
- Dodaje nagłówek HSTS do odpowiedzi serwera.

```ruby
# config/environments/production.rb
Rails.application.configure do
  config.force_ssl = true
end
```

### Konfiguracja zabezpieczeń dla cookies

Aby zabezpieczyć sesje użytkowników, należy wymusić bezpieczne ustawienia dla cookies:

```ruby
Rails.application.config.session_store :cookie_store,
  key: '_secure_app',
  secure: Rails.env.production?,
  httponly: true,
  same_site: :strict
```

Opcja `secure: true` zapewnia, że cookie będzie przesyłane tylko przez HTTPS, a httponly: true uniemożliwia jego odczytanie przez JavaScript.

### Usunięcie wrażliwych danych z URL

Nie należy przesyłać poufnych informacji jako parametry w adresach URL:
```
https://example.com/reset_password?token=12345
```

Zamiast tego należy używać wrażliwych danych np. tokenów w nagłówkach HTTP lub w ciele żądania:
```
headers['Authorization'] = "Bearer #{token}"
```

### HTTP Strict Transport Security (HSTS)

HSTS to mechanizm bezpieczeństwa wymuszający korzystanie wyłącznie z szyfrowanych połączeń HTTPS. Chroni przed atakami typu SSL Stripping oraz Man-in-the-Middle poprzez automatyczne przekierowanie wszystkich żądań HTTP na HTTPS.

Nagłówek HSTS wygląda następująco:

```
Strict-Transport-Security: max-age=31536000; includeSubDomains; preload
```

Ruby on Rails domyślnie obsługuje HSTS poprzez opcję `config.force_ssl`. Włączenie tej opcji automatycznie dodaje nagłówek HSTS do odpowiedzi serwera.

Domyślnie Rails ustawia nagłówek HSTS z czasem trwania wynoszącym 2 lata oraz bez opcji `includeSubDomains` i `preload`. Aby dostosować te ustawienia, można skonfigurować middleware:

Przykład konfiguracji:

```ruby
Rails.application.config.ssl_options = {
  hsts: { expires: 1.year.to_i, subdomains: true, preload: true }
}
```

Najlepsze praktyki przy wdrażaniu HSTS
- Testowanie z krótkim czasem trwania (`max-age`) przed pełnym wdrożeniem.
- Zapewnienie pełnego wsparcia HTTPS dla wszystkich zasobów i subdomen.
- Regularne monitorowanie certyfikatów SSL/TLS.