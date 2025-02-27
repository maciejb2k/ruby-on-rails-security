# Weak Encoding for Password

## Opis

Słabe kodowanie haseł to poważna luka bezpieczeństwa, polegająca na niepoprawnym przechowywaniu lub haszowaniu haseł użytkowników. Może to prowadzić do łatwego odzyskania haseł przez atakujących, co naraża użytkowników i aplikacje na poważne konsekwencje.

Najczęstsze błędy w tej kategorii:
1. Przechowywanie haseł w postaci jawnego tekstu - Brak jakiejkolwiek formy haszowania lub szyfrowania.
2. Używanie przestarzałych algorytmów haszujących - MD5, SHA-1 czy nawet SHA-256 nie są odporne na ataki brute-force i tęczowe tablice.
3. Brak soli w haszowaniu haseł - Powoduje podatność na ataki oparte na precomputed hashes.
4. Zbyt niska iteracja funkcji haszującej - Przykładowo, PBKDF2 czy bcrypt zbyt niską liczbą iteracji może nie być skuteczny wobec nowoczesnego sprzętu.
5. Niepoprawne wymuszanie polityki haseł - Brak wymogu silnych haseł prowadzi do używania łatwych do złamania fraz przez użytkowników.

## Przykład

### 1. Przechowywanie haseł w postaci jawnego tekstu

Kod zapisuje hasło bezpośrednio w bazie danych:

```ruby
user.password = params[:password]
user.save
```

Jeśli baza danych wycieknie, atakujący uzyskują dostęp do wszystkich haseł.

### 2. Używanie przestarzałego algorytmu MD5 do haszowania

```ruby
def hash_password
  if self.password.present?
    self.password = Digest::MD5.hexdigest(password)
  end
end
```

MD5 jest podatny na ataki tęczowych tablic i brute-force, co sprawia, że hasła mogą być łatwo odczytane.

### 3. Brak wymuszenia silnych haseł

```ruby
validates :password, length: { within: 6..40 }
```

Brak wymogu wielkich i małych liter, cyfr czy znaków specjalnych prowadzi do słabych haseł (np. „password123”).

## Skutki

1. **Naruszenie prywatności użytkowników** - Jeśli baza danych wycieknie, hasła przechowywane w jawnej postaci mogą być odczytane przez atakujących.
2. **Ataki brute-force i dictionary attacks** - Słabe haszowanie umożliwia szybkie odczytanie haseł.
3. **Reputacja i konsekwencje prawne** - Wyciek danych użytkowników może prowadzić do sankcji prawnych i utraty zaufania klientów.
4. **Reużycie haseł w innych serwisach** - Użytkownicy często używają tych samych haseł w wielu miejscach, co prowadzi do łatwego przejęcia ich kont w innych systemach.

## Zalecenia

### 1. Używanie sprawdzonych gemów do uwierzytelniania (np. Devise)

Devise to jedno z najpopularniejszych rozwiązań do autoryzacji w Ruby on Rails. Oferuje gotowe mechanizmy uwierzytelniania, w tym obsługę sesji, resetowania haseł, a także wsparcie dla dwuetapowej weryfikacji (2FA).

Domyślnie używa bcrypt do przechowywania haseł, co zapewnia wysoki poziom bezpieczeństwa. Korzystanie z Devise minimalizuje ryzyko błędów wynikających z własnej implementacji mechanizmów logowania.

```ruby
gem install devise
```

### 2. Stosowanie `has_secure_password`

Dla prostszych aplikacji, które nie wymagają zaawansowanych funkcji Devise, warto skorzystać z natywnej funkcji Rails – has_secure_password.

Zapewnia ona mechanizmy szyfrowania haseł przy użyciu `bcrypt` oraz wbudowaną walidację obecności hasła. Wymaga dodania pola `password_digest` w tabeli użytkowników i automatycznie obsługuje proces uwierzytelniania.

```ruby
class User < ApplicationRecord
  has_secure_password
end
```

### 3. Wymuszanie silnych polityk haseł

Zabezpieczenie haseł przed atakami siłowymi wymaga określenia minimalnej długości oraz wymuszania użycia różnych typów znaków. Hasła powinny mieć co najmniej 12 znaków, zawierać wielkie i małe litery, cyfry oraz znaki specjalne. Dzięki temu są odporniejsze na ataki słownikowe i brute-force.

```ruby
validates :password,
  length: { minimum: 12 },
  format: {
    with: /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]/,
    message: "must include uppercase, lowercase, number and special character"
  }
```

### 4. Regularne aktualizacje gemów i Rails

Nieaktualne biblioteki często zawierają znane luki w zabezpieczeniach, które mogą być wykorzystane przez atakujących. Regularne aktualizowanie Rails i gemów eliminuje te zagrożenia i zapewnia dostęp do najnowszych poprawek. Zaleca się cykliczne sprawdzanie przestarzałych wersji i ich aktualizację.

```ruby
bundle outdated
bundle update
```

### 5. Rozważenie użycia Argon2 zamiast bcrypt

Bcrypt jest domyślnym wyborem do przechowywania haseł, jednak Argon2 oferuje jeszcze lepszą ochronę przed atakami GPU i ASIC. Algorytm ten jest rekomendowany przez ekspertów ze względu na odporność na ataki oparte na dedykowanym sprzęcie oraz możliwość konfiguracji parametrów wpływających na czas obliczeń. Jego wdrożenie w Ruby wymaga odpowiedniego gema.

```ruby
gem install argon2
```
