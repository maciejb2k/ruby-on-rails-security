# Cleartext Transmission of Sensitive Information

## Opis

Podatność odnosi się do przesyłania danych w postaci niezaszyfrowanej (plaintext) pomiędzy backendową aplikacją Rails a innymi serwisami i systemami. Problem ten nie dotyczy wyłącznie komunikacji z przeglądarką użytkownika (gdzie stosuje się HTTPS), ale również wewnętrznych połączeń między serwisami w infrastrukturze (np. połączenia z bazą danych, kolejkami, usługami SMTP, API zewnętrznych dostawców itp.).

Brak szyfrowania lub niepoprawna konfiguracja TLS/SSL w takich połączeniach naraża aplikację na ryzyko przechwycenia wrażliwych danych (credentials, tokenów, informacji użytkowników) przez osoby trzecie, zwłaszcza w środowiskach o złożonej infrastrukturze (chmura publiczna, Kubernetes, sieci VPC).

Typowe przypadki obejmują brak wymuszenia szyfrowania dla połączeń z PostgreSQL, Redisem, brokerami wiadomości (np. RabbitMQ), czy klientami HTTP integrującymi się z zewnętrznymi API.

## Przyklady

### PostgreSQL

W Ruby on Rails można skonfigurowąc połączenie do bazy danych albo w pliku `config/database.yml` lub przekazać connection string jako zmienna środowiskowa `DATABASE_URL`.

Przykład niepoprawnej konfiguracji (brak TLS) dla connection string do bazy danych. W tej sytuacji połączenie działa po TCP bez szyfrowania.
```
DATABASE_URL=postgres://myapp_user:password@myapp-db.internal:5432/myapp_production
```

Aby wymusić szyfrowanie połączenia z bazą danych PostgreSQL, Rails udostępnia parametr `sslmode` w connection string.

Jeżeli serwer PostgreSQL jest skonfigurowany w taki sposób, aby akceptować wyłącznie połączenia szyfrowane, a aplikacja próbuje nawiązać połączenie bez TLS, połączenie zostanie odrzucone, co zapewnia podstawowy poziom bezpieczeństwa.

Opcja `sslmode=require`:
  - Zapewnia szyfrowanie komunikacji za pomocą TLS, jednak bez weryfikacji certyfikatu serwera.
  - Chroni przed podsłuchem (szyfrowanie), lecz nie przed atakami typu Man-in-the-Middle (brak potwierdzenia tożsamości serwera).
  - Serwer PostgreSQL musi mieć włączoną obsługę TLS (`ssl = on` w `postgresql.conf`).

Przykład:
```
DATABASE_URL=postgres://myapp_user:password@myapp-db.internal:5432/myapp_production?sslmode=require
```

Opcja `sslmode=verify-full`:
  - Zapewnia pełne szyfrowanie i weryfikację tożsamości serwera (TLS + walidacja certyfikatu).
  - Rails (lub klient PostgreSQL) musi posiadać certyfikat root CA, aby zweryfikować certyfikat serwera.
  - Chroni zarówno przed podsłuchem, jak i przed atakami MitM.
  - Wymaga poprawnej konfiguracji certyfikatu po stronie PostgreSQL (np. certyfikat wystawiony przez Let's Encrypt lub wewnętrzne CA).

Przykład:
```
DATABASE_URL=postgres://myapp_user:password@myapp-db.internal:5432/myapp_production?sslmode=verify-full&sslrootcert=config/certs/ca.crt
```

Większość zarządzanych usług PostgreSQL (Amazon RDS, DigitalOcean, Heroku) wymusza użycie połączenia szyfrowanego i dostarcza odpowiedni certyfikat CA do weryfikacji.

### Redis

Redis to jedna z najpopularniejszych baz typu key-value, wykorzystywana w aplikacjach Rails m.in. jako magazyn sesji, system kolejek (Sidekiq) oraz w komunikacji WebSocket (ActionCable).

#### Połączenie nieszyfrowane (redis://)

Redis w podstawowej konfiguracji działa bez szyfrowania. Dane, w tym poświadczenia i przesyłane wartości, są transmitowane w otwartym tekście (plaintext).

Przykładowy URL połączenia dla zmiennej środowiskowej `REDIS_URL`:

```
redis://redis.internal:6379/0
```

Przykładowa konfiguracja klienta:

```ruby
Redis.new(url: ENV["REDIS_URL"])
```

Tego typu połączenie stosuje się wyłącznie w środowiskach lokalnych lub wewnętrznych sieciach, gdzie nie występuje ryzyko przechwycenia ruchu.

#### Połączenie szyfrowane bez weryfikacji certyfikatu (rediss:// + VERIFY_NONE)

Redis wspiera połączenia szyfrowane TLS poprzez protokół `rediss://`, co zapewnia poufność danych w tranzycie.
Brak weryfikacji certyfikatu serwera oznacza, że klient akceptuje dowolny certyfikat, bez sprawdzania jego tożsamości.

Przykładowy URL połączenia dla zmiennej środowiskowej `REDIS_URL`:
```
rediss://redis.internal:6379/0
```

Przykładowa konfiguracja klienta:
```ruby
Redis.new(url: ENV["REDIS_URL"], ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE })
```

Taka opcja często stosowana jest przy połączeniach do usług chmurowych (np. Redis na Heroku), które używają certyfikatów self-signed lub własnych CA nieznanych klientowi.

Zapewnia szyfrowanie danych, ale nie chroni przed atakiem typu Man-in-the-Middle (MITM).

#### Połączenie szyfrowane z weryfikacją certyfikatu (rediss:// + VERIFY_PEER + CA)

Najbezpieczniejszy wariant, w którym Redis serwer używa certyfikatu podpisanego przez zaufane CA, a klient Redis weryfikuje ten certyfikat podczas zestawiania połączenia.

Przykładowa konfiguracja klienta:
```ruby
Redis.new(url: 'rediss://...', ssl_params: { ca_file: '/path/ca.crt', verify_mode: OpenSSL::SSL::VERIFY_PEER })
```

Zapewnia zarówno szyfrowanie danych, jak i potwierdzenie tożsamości serwera Redis. Certyfikaty mogą być wygenerowane samodzielnie (własne CA) lub wydane przez zewnętrzne, zaufane urzędy certyfikacji.

### SMTP
Częstym błędem jest brak wymuszenia szyfrowania komunikacji SMTP w środowiskach wewnętrznych (np. sieciach firmowych lub klastrach Kubernetes), gdzie wykorzystywane są własne serwery pocztowe (np. Postfix, Exim) bez odpowiednio skonfigurowanego TLS/STARTTLS.

#### Połączenie nieszyfrowane (brak STARTTLS)

Domyślnie w Ruby on Rails konfiguracja ActionMailer może zostać ustawiona w taki sposób, aby nie wymuszać szyfrowania przy połączeniu z serwerem SMTP. Tego typu ustawienia bywają stosowane w wewnętrznych systemach legacy lub w środowiskach deweloperskich.

```ruby
config.action_mailer.smtp_settings = {
  address: "smtp.internal",
  port: 25,
  user_name: ENV["SMTP_USER"],
  password: ENV["SMTP_PASSWORD"],
  authentication: :plain,
  enable_starttls_auto: false # brak STARTTLS
}
```

W powyższym przykładzie połączenie SMTP jest realizowane bez jakiejkolwiek formy szyfrowania, co oznacza, że dane uwierzytelniające oraz treść wiadomości e-mail są przesyłane w postaci niezaszyfrowanej.

#### Połączenie szyfrowane z wymuszeniem STARTTLS

Aby zapewnić bezpieczeństwo połączenia SMTP, należy wymusić szyfrowanie za pomocą protokołu STARTTLS. Rails udostępnia opcję enable_starttls_auto: true, która powoduje, że klient SMTP negocjuje bezpieczne połączenie TLS przed wysłaniem jakichkolwiek danych wrażliwych.

```ruby
config.action_mailer.smtp_settings = {
  address: "smtp.internal",
  port: 587,
  user_name: ENV["SMTP_USER"],
  password: ENV["SMTP_PASSWORD"],
  authentication: :plain,
  enable_starttls_auto: true # STARTTLS wymuszony
}
```

Jeżeli wewnętrzny serwer SMTP wspiera również bezpośrednie połączenia TLS (SMTPS na porcie 465), Rails oferuje opcję `ssl: true`. W obu przypadkach komunikacja jest chroniona za pomocą TLS i nie jest transmitowana w postaci niezaszyfrowanej.

### Integracje API

W środowiskach z mikroserwisami lub aplikacjach rozproszonych często stosuje się klientów HTTP do komunikacji pomiędzy usługami (np. API Gateway, worker, inny backend).

**Faraday** to popularna biblioteka HTTP w ekosystemie Ruby, często wykorzystywana do realizacji żądań HTTP w aplikacjach Rails.

#### Przykład - brak HTTPS w połączeniu wewnętrznym

Połączenie HTTP bez TLS pomiędzy usługami:

```ruby
conn = Faraday.new(url: 'http://users-service.internal:3000')
response = conn.get('/api/v1/users/1')
```

W przypadku środowisk takich jak Kubernetes lub chmury publiczne brak TLS może oznaczać narażenie wrażliwych danych w sieci VPC.

#### Połączenie HTTPS z weryfikacją certyfikatu

Poprawna konfiguracja połączenia HTTPS z opcją weryfikacji certyfikatu:

```ruby
conn = Faraday.new(url: 'https://users-service.internal:3000', ssl: { ca_file: '/path/to/ca.crt', verify: true })
response = conn.get('/api/v1/users/1')
```

## Skutki

- **Przejęcie danych uwierzytelniających** – brak szyfrowania w komunikacji pomiędzy aplikacją Rails a innymi usługami (baza danych, Redis, SMTP, API) może prowadzić do przechwycenia poświadczeń (hasła, tokeny API, klucze sesyjne) przez osoby nieuprawnione w sieci.
- **Ujawnienie wrażliwych danych użytkowników** – dane osobowe, treści e-maili, numery telefonów lub inne informacje przesyłane w otwartym tekście mogą zostać odczytane i wykorzystane w sposób nieautoryzowany.
- **Podatność na ataki Man-in-the-Middle (MitM)** – brak weryfikacji certyfikatu serwera (np. sslmode=require bez verify-full, VERIFY_NONE w Redisie) umożliwia atakującemu podszycie się pod docelowy serwis i przejęcie ruchu.
- **Złamanie zgodności z regulacjami** – wiele regulacji branżowych i prawnych (np. RODO, PCI-DSS) wymaga stosowania szyfrowania transmisji danych w systemach produkcyjnych. Brak TLS może skutkować naruszeniem przepisów i karami.

## Zalecenia

- **Stosuj szyfrowanie TLS** – we wszystkich połączeniach między aplikacją Rails a innymi usługami (bazy danych, kolejki, serwery SMTP, API zewnętrzne i wewnętrzne) należy stosować szyfrowanie TLS, szczególnie w środowiskach produkcyjnych. W środowiskach deweloperskich TLS może być opcjonalny, o ile nie są przetwarzane dane wrażliwe.
- **Wymuszaj weryfikację certyfikatów** – zawsze konfiguruj klientów Rails do weryfikowania certyfikatów serwerów (`sslmode=verify-full` w PostgreSQL, `VERIFY_PEER` w Redis, `enable_starttls_auto: true` w SMTP), aby zapobiegać atakom typu Man-in-the-Middle.
- **Wykorzystuj usługi zarządzane** – korzystaj z zarządzanych usług chmurowych (np. Amazon RDS, Google Cloud SQL, Heroku Redis), które domyślnie wymuszają szyfrowanie transmisji i dostarczają odpowiednie certyfikaty do weryfikacji.
- **Audytuj konfigurację zmiennych środowiskowych** – regularnie przeglądaj wartości zmiennych środowiskowych (np. `DATABASE_URL`, `REDIS_URL`, `SMTP_URL`) pod kątem wymuszenia TLS (np. stosowanie `rediss://` zamiast `redis://`).