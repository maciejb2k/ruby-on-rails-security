# Login Rate Limit

Aplikacja dla tego przykładu znajduje się w katalogu `rails-security-lab/insecure-design`.

https://github.com/maciejb2k/ruby-on-rails-security/tree/main/insecure-design

## Opis

**Login Rate Limiting** - dotyczy braku odpowiedniego ograniczenia liczby prób logowania w aplikacji. Bez takiego zabezpieczenia atakujący może przeprowadzać ataki typu brute force (próbując zgadnąć hasło metodą prób i błędów) lub credential stuffing (wykorzystując wyciekłe dane logowania z innych serwisów).

Ruby on Rails w wersji 7.2 wprowadził natywną funkcję `rate_limit`, pozwalającą na łatwą implementację ograniczeń dotyczących liczby żądań. We wcześniejszych wersjach wymagane było użycie dodatkowego gema, np. `Rack Attack`.

## Przykład

Jeżeli w aplikacji znajduje się formularz logowania, który nie posiada żadnego ograniczenia liczby prób logowania. Użytkownik może wykonywać nieograniczoną liczbę prób wpisania loginu i hasła.

![](./screenshots/login-form.png)

Brak rate limiting to zagrożenie nie tylko dla logowania. W aplikacji mogą istnieć inne kluczowe akcje, które powinny być chronione:

- **Resetowanie hasła** – Atakujący może masowo wysyłać żądania resetowania hasła, co może skutkować spamowaniem e-maili użytkowników lub blokowaniem dostępu do konta poprzez atak typu account lockout.
- **Weryfikacja kodów OTP** – Bez limitu prób atakujący może brute-force’ować sześciocyfrowe kody 2FA, co może doprowadzić do przejęcia konta użytkownika.
- **Rejestracja użytkownika** – Masowe żądania rejestracji mogą doprowadzić do tworzenia tysięcy fałszywych kont, co obciąży system i może być wykorzystane do działań spamerskich.
- **Sprawdzanie dostępności nazwy użytkownika** – Pozwala atakującym na enumerację istniejących kont użytkowników w systemie, co ułatwia ataki credential stuffing.
- **Zadania wymagające dużej ilości zasobów** – Atakujący może generować dużą liczbę żądań, prowadząc do nadmiernego wykorzystania zasobów serwera i potencjalnego ataku DoS.

## Skutki

Brak rate limiting prowadzi do wielu zagrożeń:
- **Atak brute-force na hasło** – atakujący może wielokrotnie próbować różnych haseł do konta.
- **Credential stuffing** – sprawdzanie skradzionych loginów i haseł w celu uzyskania dostępu do konta.
- **Przepełnienie skrzynki e-mail resetami hasła** – użytkownicy mogą być zasypywani mailami z resetem hasła.
- **Przejęcie konta przez brute-force OTP** – jeśli aplikacja korzysta z 2FA, kod może zostać odgadnięty poprzez wielokrotne próby.
- **Atak DoS (Denial of Service)** – nadmierna liczba żądań może doprowadzić do obciążenia serwera i zatrzymania aplikacji.
- **Masowe rejestracje fałszywych kont** – może to zaszkodzić reputacji aplikacji oraz doprowadzić do jej niewłaściwego wykorzystania.
- **Enumeration ataku na użytkowników** – sprawdzanie, czy dany email/login jest już używany w systemie.

## Zalecenia

## Ruby on Rails 7.2+

Ruby on Rails od wersji `7.2` wprowadził natywną funkcję `rate_limit`, która pozwala na łatwe ograniczenie liczby żądań do określonego endpointu.

Implementacja Rate Limiting w kontrolerze logowania w przykładowej aplikacji:
```ruby
class SessionsController < ApplicationController
  rate_limit to: 5, within: 1.minute, with: -> { redirect_to rate_limited_path }, only: %i[create]

  ...
end
```

Jak działa `rate_limit`?
- `to: 5` – określa maksymalną liczbę żądań (5 prób logowania).
- `within: 1.minute` – limit obowiązuje w ciągu jednej minuty.
- `with: -> { redirect_to rate_limited_path }` – przekierowanie użytkownika na stronę ostrzegającą.
- `only: %i[create]` – dotyczy tylko akcji `create`, czy wysłania formularza logowania.

Jeżeli w naszej przykładowej aplikacji spróbujemy się wielokrotnie zalogować, to po przekroczeniu 5 prób w ciągu minuty użytkownik zostanie przekierowany na stronę `rate_limited_path`.

![](./screenshots/rate-limit.png)

## Ruby on Rails < 7.2

Dla starszych wersji Rails (przed 7.2) zalecane jest użycie gema **Rack Attack**, który pozwala na wdrożenie rate limiting poprzez konfigurację w middleware.

Jest to elastyczne rozwiązanie, które umożliwia ograniczanie żądań na podstawie adresu IP, nagłówków lub innych parametrów. Rack Attack może być używany nie tylko do zabezpieczenia logowania, ale także do ochrony innych kluczowych endpointów, np. resetowania hasła czy weryfikacji OTP.

```ruby
class Rack::Attack
  throttle("logins/ip", limit: 5, period: 1.minute) do |req|
    req.ip if req.path == "/login" && req.post?
  end
end
```