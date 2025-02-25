# Ruby on Rails Security

Ten projekt, będący moją pracą magisterską z informatyki na Uniwersytecie Rzeszowskim, przedstawia dobre praktyki bezpieczeństwa w aplikacjach Ruby on Rails zgodnie z listą OWASP Top 10 z 2021 roku.

---

## Przegląd projektu

Projekt jest zorganizowany jako monorepozytorium, które ma na celu demonstrowanie typowych podatności bezpieczeństwa w aplikacjach Ruby on Rails oraz przedstawianie sposobów ich eliminacji.

To repozytorium zawiera praktyczne, skonteneryzowane przykłady podatnych aplikacji wraz z bezpiecznymi implementacjami.

Każdy projekt w repozytorium koncentruje się na konkretnej podatności bezpieczeństwa, oferując:
- **Demonstrowanie podatności**: Pokazanie, co się dzieje, gdy środki bezpieczeństwa nie są wdrożone.
- **Analizę wpływu**: Zrozumienie konsekwencji podatności.
- **Bezpieczną implementację**: Sposoby łagodzenia lub zapobiegania podatnościom.

---

## Podsumowanie projektu

## 3.1 A01:2021-Broken Access Control

### 3.1.1 Mass Assignment
- Przykład: https://github.com/maciejb2k/ruby-on-rails-security/tree/main/mass-assignment

### 3.1.2 Insecure Direct Object References (IDOR)
- Przykład: https://github.com/maciejb2k/ruby-on-rails-security/tree/main/insecure-direct-object-reference

### 3.1.3 Local File Inclusion (LFI)
- Przykład: -

### 3.1.4 Object Access Middleware
- Przykład: -

## 3.2 A02:2021-Cryptographic Failures
- Przykład: -

### 3.2.1 Weak Encoding for Password
- Przykład: -

### 3.2.2 Use of Hard-Coded Cryptographic Key
- Przykład: -

### 3.2.3 Cleartext Transmission of Sensitive Information
- Przykład: -

## 3.3 A03:2021-Injection
- Przykład: -

### 3.3.1 Remote Code Execution (RCE)
- Przykład: -

### 3.3.2 Cross-Site Scripting (XSS)
- Przykład: -

### 3.3.3 Cross-Site Request Forgery (CSRF)
- Przykład: -

### 3.3.4 SQL Injection (SQLi)
- Przykład: -

## 3.4 A04:2021-Insecure Design
- Przykład: -

### 3.4.1 Open Redirect
- Przykład: -

### 3.4.2 Regex Denial of Service (ReDoS)
- Przykład: -

### 3.4.3 Login Rate Limiting
- Przykład: -

## 3.5 A05:2021-Security Misconfiguration
- Przykład: -

### 3.5.1 Token / Cookie Misconfiguration
- Przykład: -

### 3.5.2 XML DDoS
- Przykład: -

### 3.5.3 TLS Force / HSTS
- Przykład: -

### 3.5.4 Debug Mode
- Przykład: -

## 3.6 A06:2021-Vulnerable and Outdated Components
- Przykład: -

### 3.6.1 Static Analysis on CI/CD
- Przykład: -

## 3.7 A09:2021-Security Logging and Monitoring Failures
- Przykład: -

### 3.7.1 Enable Logging
- Przykład: -

### 3.7.2 Logging Sensitive Information
- Przykład: -

### 3.7.3 No Log to User
- Przykład: -

## 3.8 A10:2021-Server-Side Request Forgery
- Przykład: -

---

## Tworzenie nowej aplikacji Rails

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
