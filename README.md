# Ruby on Rails Security

To repozytorium stanowi część mojej pracy magisterskiej z Informatyki na Uniwersytecie Rzeszowskim i koncentruje się na bezpieczeństwie aplikacji webowych w Ruby on Rails zgodnie z listą OWASP Top 10 (2021).

Projekt jest zorganizowany jako monorepozytorium zawierające serię małych aplikacji Rails, z których każda demonstruje konkretną podatność bezpieczeństwa.

Każda aplikacja przedstawia podatność w praktyce, pokazując, jak może zostać wykorzystana oraz jakie są jej konsekwencje. Następnie prezentuje poprawną, bezpieczną implementację, wraz z omówieniem technik zabezpieczeń i najlepszych praktyk.

---

🚧 To repozytorium jest wciąż rozwijane – regularnie dodawane są nowe przykłady!

🌍 Obecnie jest dostępne tylko po polsku, ale w przyszłości pojawi się wersja angielska.

---

## Spis omawianych podatności według OWASP Top 10 (2021)

Większość aplikacji w przykładach jest stworzona w oparciu o `Ruby on Rails 7.2` oraz `Ruby 3.3.5`.

### 3.1 A01:2021 - Broken Access Control

| Nazwa Podatności | Opis podatności | Aplikacja z przykładem | Link |
| - | - | - | - |
| Mass Assignment | ✅ | ✅ | [GitHub](https://github.com/maciejb2k/ruby-on-rails-security/tree/main/mass-assignment) |
| Insecure Direct Object References (IDOR) | ✅ | ✅ | [GitHub](https://github.com/maciejb2k/ruby-on-rails-security/tree/main/insecure-direct-object-reference) |
| Local File Inclusion (LFI) | ✅ | ✅ | [GitHub](https://github.com/maciejb2k/ruby-on-rails-security/tree/main/local-file-inclusion) |
| Object Level Authorization (OLA) | ✅ | ✅ | [GitHub](https://github.com/maciejb2k/ruby-on-rails-security/tree/main/object-level-authorization) |

### 3.2 A02:2021 - Cryptographic Failures

| Nazwa Podatności | Opis podatności | Aplikacja z przykładem | Link |
| - | - | - | - |
| Weak Encoding for Password | ✅ | ❌ | [GitHub](https://github.com/maciejb2k/ruby-on-rails-security/tree/main/weak-encoding-for-password) |
| Use of Hard-Coded Cryptographic Key | ✅ | ❌ | [GitHub](https://github.com/maciejb2k/ruby-on-rails-security/tree/main/hard-coded-cryptographic-key) |
| Cleartext Transmission of Sensitive Information | ✅ | ❌ | [GitHub](https://github.com/maciejb2k/ruby-on-rails-security/tree/main/cleartext-transmission-of-sensitive-information) |

### 3.3 A03:2021 - Injection

| Nazwa Podatności | Opis podatności | Aplikacja z przykładem | Link |
| - | - | - | - |
| Remote Code Execution (RCE) | ✅ | ✅ | [GitHub](https://github.com/maciejb2k/ruby-on-rails-security/tree/main/remote-code-execution) |
| Cross-Site Scripting (XSS) | ✅ | ✅ | [GitHub](https://github.com/maciejb2k/ruby-on-rails-security/tree/main/cross-site-scripting) |
| Cross-Site Request Forgery (CSRF) | ✅ | ✅ | [GitHub](https://github.com/maciejb2k/ruby-on-rails-security/tree/main/cross-site-request-forgery) |
| SQL Injection (SQLi) | ✅ | ✅ | [GitHub](https://github.com/maciejb2k/ruby-on-rails-security/tree/main/sql-injection) |

### 3.4 A04:2021 - Insecure Design

| Nazwa Podatności | Opis podatności | Aplikacja z przykładem | Link |
| - | - | - | - |
| Open Redirect | ✅ | ✅ | [GitHub](https://github.com/maciejb2k/ruby-on-rails-security/tree/main/open-redirect) |
| Regex Denial of Service (ReDoS) | ✅ | ❌ | [GitHub](https://github.com/maciejb2k/ruby-on-rails-security/tree/main/regex-dos) |
| Login Rate Limiting | ✅ | ✅ | [GitHub](https://github.com/maciejb2k/ruby-on-rails-security/tree/main/login-rate-limiting) |

### 3.5 A05:2021 - Security Misconfiguration

| Nazwa Podatności | Opis podatności | Aplikacja z przykładem | Link |
| - | - | - | - |
| Token / Cookie Misconfiguration | ✅ | ✅ | [GitHub](https://github.com/maciejb2k/ruby-on-rails-security/tree/main/token-cookie-misconfiguration) |
| XML XXE | ✅ | ❌ | [GitHub](https://github.com/maciejb2k/ruby-on-rails-security/tree/main/xml-xxe) |
| TLS Force / HSTS | ✅ | ❌ | [GitHub](https://github.com/maciejb2k/ruby-on-rails-security/tree/main/tls-force-hsts) |
| Debug Mode | ✅ | ❌ | [GitHub](https://github.com/maciejb2k/ruby-on-rails-security/tree/main/debug-mode) |

### 3.6 A06:2021 - Vulnerable and Outdated Components

| Nazwa Podatności | Opis podatności | Aplikacja z przykładem | Link |
| - | - | - | - |
| Static Analysis on CI/CD on GitHub | ✅ | ✅ | - |

### 3.7 A09:2021 - Security Logging and Monitoring Failures

| Nazwa Podatności | Opis podatności | Aplikacja z przykładem | Link |
| - | - | - | - |
| Enable Logging | ✅ | ❌ | [GitHub](https://github.com/maciejb2k/ruby-on-rails-security/tree/main/enable-logging) |
| Logging Sensitive Information | ✅ | ✅ | [GitHub](https://github.com/maciejb2k/ruby-on-rails-security/tree/main/logging-sensitive-information) |
| No Log to User | ✅ | ❌ | [GitHub](https://github.com/maciejb2k/ruby-on-rails-security/tree/main/no-log-to-user) |

### 3.8 A10:2021 - Server-Side Request Forgery

| Nazwa Podatności | Opis podatności | Aplikacja z przykładem | Link |
| - | - | - | - |
| Server-Side Request Forgery | ✅ | ✅ | [GitHub](https://github.com/maciejb2k/ruby-on-rails-security/tree/main/server-side-request-forgery) |

## Tworzenie nowej aplikacji Rails

W celu ułatwienia tworzenia nowych aplikacji Rails, skrypt `create-rails-app.sh` automatyzuje proces tworzenia nowego projektu, instalacji wymaganych gemów, automatycznego resetowania i seedowania bazy, konfiguracji kontenerów Docker oraz uruchomienia serwera.

Aby utworzyć nową aplikację Rails, uruchom skrypt `./create-rails-app.sh` w katalogu głównym.
```bash
chmod +x create-rails-app.sh
./create-rails-app.sh
```

Następnie przejdź do nowego projektu i uruchom serwer Rails:
```bash
cd <project-name>
docker compose up -d --remove-orphans
```

Aby przebudować kontenery, użyj:
```bash
docker compose down
docker compose up -d --remove-orphans --build
```

Aby uzyskać dostęp do kontenera z aplikacją Rails:
```bash
cd <project-name>
docker compose exec -it app bash
```

Aby uzyskać dostęp do powłoki PSQL:
```bash
cd <project-name>
docker compose exec -it db psql -U postgres
```

Aby zrestartować aplikację (usuwając wszystkie dane), użyj:
```bash
docker compose restart
```

Aby zatrzymać kontenery, użyj:
```bash
docker compose down
```
