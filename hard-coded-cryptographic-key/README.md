# Use of Hard-Coded Cryptographic Key

## Opis

Podatność polega na **przechowywaniu sekretnych kluczy kryptograficznych bezpośrednio w kodzie źródłowym**.

W aplikacjach webowych takie klucze są wykorzystywane do podpisywania i szyfrowania danych, np. ciasteczek sesji czy tokenów uwierzytelniających. Jeśli klucz wycieknie (np. przez publiczne repozytorium), atakujący może generować fałszywe żądania i przejmować sesje użytkowników.

## Przykład

### 1. Użycie hardcoded klucza w bibliotece Devise do uwierzytelniania użytkowników

**Devise** to popularna biblioteka do uwierzytelniania użytkowników w aplikacjach **Ruby on Rails**, oferująca gotowe moduły do obsługi logowania, rejestracji, resetowania haseł i wielu innych funkcji związanych z zarządzaniem sesją użytkownika.

Devise wymaga zdefiniowania **tajnego klucza** `Devise.secret_key` w pliku konfiguracyjnym `config/initializers/devise.rb`.

Devise wykorzystuje `Devise.secret_key` do:
- **Podpisywania ciasteczek sesji użytkownika**
- **Generowania tokenów autoryzacyjnych (reset hasła, potwierdzenie konta itp.)**
- **Zapewnienia integralności sesji i mechanizmu "remember me"**


Załóżmy, że w podatnej aplikacji `Devise.secret_key` jest hardcoded w pliku `config/initializers/devise.rb`:
```ruby
Devise.setup do |config|
  config.secret_key = "hardcoded_devise_secret_1234567890abcdef"
end
```

Jeśli klucz zostanie **ujawniony**, atakujący może wygenerować **własne poprawnie podpisane ciasteczka sesji** i przejąć konta użytkowników.

## Skutki

1. Wyciek sekretnych kluczy kryptograficznych w Ruby on Rails może prowadzić do naruszenia poufności, integralności i autoryzacji w aplikacji. Atakujący mogą generować fałszywe tokeny sesji, podpisywać własne żądania, odszyfrowywać przechowywane dane oraz uzyskiwać nieautoryzowany dostęp do kont użytkowników i systemów zewnętrznych.
2. W przypadku wycieku kluczy używanych do szyfrowania danych wrażliwych, takich jak hasła czy informacje finansowe, możliwe jest ich odszyfrowanie i dalsze wykorzystanie.
3. Jeśli sekrety zostaną upublicznione, np. w repozytorium kodu, aplikacja staje się natychmiastowym celem ataków i może dojść do pełnego przejęcia systemu.

## Zalecenia

### 1. Bezpieczne przechowywanie kluczy

Klucze powininy być pobierany dynamicznie, co eliminuje ryzyko jego przypadkowego ujawnienia w repozytorium.
Sekretne klucze w aplikacji Ruby on Rails nie powinny być przechowywane w kodzie źródłowym.

Zamiast tego należy korzystać z mechanizmów zarządzania sekretami, takich jak **Rails Credentials** (`config/credentials.yml.enc`) lub **zmienne środowiskowe**.

Przykład użycia **Rails Credentials**:
```ruby
Devise.setup do |config|
  config.secret_key = Rails.application.credentials.devise_secret_key
end
```

Przykład użycia zmiennych środowiskowych:
```ruby
Devise.setup do |config|
  config.secret_key = ENV["DEVISE_SECRET_KEY"]
end
```

### 2. Rotacja kluczy i zarządzanie sesjami

Aplikacja powinna implementować **regularną rotację kluczy kryptograficznych**, co minimalizuje skutki ewentualnego wycieku. Klucze wykorzystywane do podpisywania ciasteczek sesji oraz tokenów uwierzytelniających powinny być zmieniane okresowo, a w przypadku ich kompromitacji wszystkie aktywne sesje użytkowników powinny zostać unieważnione.

### 3. Zarządzanie zmiennymi środowiskowymi

W przypadku używania zmiennych środowiskowych, klucze powinny być przechowywane poza kodem aplikacji i zarządzane przez system konfiguracji środowiskowej, np. w pliku .env lub bezpośrednio w konfiguracji serwera.

### 4. Monitorowanie i wykrywanie wycieków

W celu wykrywania i zapobiegania przypadkowemu ujawnieniu sekretów w repozytoriach Git warto stosować narzędzia do skanowania kodu pod kątem wrażliwych danych, takie jak GitLeaks lub TruffleHog.