# 1. Wstęp
## 1.1 Cyberbezpieczeństwo
## 1.2 Ruby on Rails

# 2. Zagadnienia ważne dla bezpieczeństwa aplikacji

# 3. Podatności i luki bezpieczeństwa w Ruby on Rails według OWASP TOP 10

## 3.1 A01:2021-Broken Access Control

### 3.1.1 Mass Assignment
- Opis: Podatność umożliwia przypisanie nieautoryzowanych wartości do atrybutów modelu poprzez masowe przypisanie danych wejściowych. Przykład: użytkownik zmienia swoje uprawnienia, przesyłając parametr `admin: true`.
- Przykład: https://github.com/maciejb2k/ruby-on-rails-security/tree/main/mass-assignment

### 3.1.2 Insecure Direct Object References (IDOR)
- Opis: Pozwala użytkownikowi na dostęp do zasobów innych osób przez manipulację identyfikatorami w URL. Przykład: odczyt zamówienia innego użytkownika pod adresem `/orders/1`.
- Przykład: -

### 3.1.3 Local File Inclusion (LFI)
- Opis: Podatność umożliwia załadowanie nieautoryzowanych plików lokalnych przez manipulację wejściem. Przykład: odczyt zawartości `/etc/passwd` poprzez złośliwy parametr.
- Przykład: -

### 3.1.4 Object-Level Authorization
- Opis: Brak weryfikacji uprawnień na poziomie obiektów pozwala na nieautoryzowaną edycję danych. Przykład: użytkownik edytuje profil innej osoby.
- Przykład: -

## 3.2 A02:2021-Cryptographic Failures

### 3.2.1 Weak Encoding for Password
- Opis: Podatność polega na przechowywaniu haseł w formie słabo zabezpieczonej, np. przy użyciu algorytmu MD5, co ułatwia ich złamanie.
- Przykład: -

### 3.2.2 Use of Hard-coded Cryptographic Key
- Opis: Występuje, gdy klucz kryptograficzny jest zapisany w kodzie źródłowym. Przykład: `SECRET_KEY="static_key"`.
- Przykład: -

### 3.2.3 Cleartext Transmission of Sensitive Information
- Opis: Dane, takie jak loginy, są przesyłane w formacie niezaszyfrowanym, co umożliwia ich przechwycenie. Przykład: użycie HTTP zamiast HTTPS.
- Przykład: -

## 3.3 A03:2021-Injection

### 3.3.1 Remote Code Execution (RCE)
- Opis: Polega na możliwości wykonania złośliwego kodu przesłanego przez użytkownika. Przykład: wykorzystanie funkcji `eval` z wejściem użytkownika.
- Przykład: -

### 3.3.2 Cross-Site Scripting (XSS)
- Opis: Pozwala na wstrzyknięcie złośliwego kodu JavaScript, który wykonuje się w przeglądarce ofiary. Przykład: `alert('XSS');` w polu formularza.
- Przykład: -

### 3.3.3 Cross-Site Request Forgery (CSRF)
- Opis: Polega na wykonaniu akcji na koncie zalogowanego użytkownika bez jego wiedzy. Przykład: ukryty formularz dokonujący przelewu.
- Przykład: -

### 3.3.4 SQL Injection (SQLi)
- Opis: Pozwala na modyfikację zapytania SQL przez złośliwe dane wejściowe. Przykład: `'; DROP TABLE users; --`.
- Przykład: -

## 3.4 A04:2021-Insecure Design

### 3.4.1 Open Redirect
- Opis: Podatność pozwala na przekierowanie użytkownika na niebezpieczną stronę. Przykład: `/redirect?url=http://malicious.com`.
- Przykład: -

### 3.4.2 Regex Denial of Service (ReDoS)
- Opis: Występuje, gdy aplikacja używa skomplikowanych wyrażeń regularnych, które powodują zużycie zasobów. Przykład: `^(a+)+$`.
- Przykład: -

### 3.4.3 Login Rate Limiting
- Opis: Brak ograniczenia liczby prób logowania umożliwia ataki brute force. Przykład: wielokrotne zgadywanie hasła.
- Przykład: -

## 3.5 A05:2021-Security Misconfiguration

### 3.5.1 Token / Cookie Misconfiguration
- Opis: Niepoprawne ustawienia ciasteczek, takie jak brak flag `HttpOnly` lub `Secure`, narażają na ich przechwycenie.
- Przykład: -

### 3.5.2 DDoS
- Opis: Ataki na aplikację wykorzystują brak ograniczenia liczby żądań. Przykład: przeciążenie serwera dużą liczbą zapytań.
- Przykład: -

### 3.5.3 TLS Force / HSTS
- Opis: Brak wymuszenia HTTPS umożliwia ataki typu Man-in-the-Middle. Przykład: przesyłanie danych przez HTTP.
- Przykład: -

### 3.5.4 Debug Mode
- Opis: Tryb debugowania ujawnia poufne informacje aplikacji w środowisku produkcyjnym. Przykład: pełne ścieżki plików.
- Przykład: -

## 3.6 A06:2021-Vulnerable and Outdated Components

### 3.6.1 Static Analysis on CI/CD
- Opis: Podatność występuje przy braku analizy kodu w celu wykrycia znanych podatności w bibliotekach. Przykład: przestarzałe zależności.
- Przykład: -

## 3.7 A09:2021-Security Logging and Monitoring Failures

### 3.7.1 Password Logging
- Opis: Logowanie haseł użytkowników do plików logów naraża je na nieautoryzowany dostęp.
- Przykład: -

### 3.7.2 Logging Sensitive Information
- Opis: Zapis wrażliwych danych, takich jak tokeny lub dane kart płatniczych, do logów może prowadzić do ich wykorzystania.
- Przykład: -

### 3.7.3 No Log to User
- Opis: Brak logowania działań użytkownika uniemożliwia wykrywanie prób włamań.
- Przykład: -

## 3.8 A10:2021-Server-Side Request Forgery

### 3.8.1 Server-Side Request Forgery (SSRF)
- Opis: Podatność pozwala na wykonanie żądań do wewnętrznych zasobów aplikacji. Przykład: manipulacja parametrem określającym URL.
- Przykład: -

# 4. Podsumowanie i wnioski
