# 1. Wstęp
## 1.1 Cyberbezpieczeństwo
## 1.2 Ruby on Rails

# 2. Zagadnienia ważne dla bezpieczeństwa aplikacji

# 3. Podatności i luki bezpieczeństwa w Ruby on Rails według OWASP TOP 10

## 3.1 A01:2021-Broken Access Control

### 3.1.1 Mass Assignment
Podatność umożliwia przypisanie nieautoryzowanych wartości do atrybutów modelu poprzez masowe przypisanie danych wejściowych. Przykład: użytkownik zmienia swoje uprawnienia, przesyłając parametr `admin: true`.

### 3.1.2 Insecure Direct Object References (IDOR)
Pozwala użytkownikowi na dostęp do zasobów innych osób przez manipulację identyfikatorami w URL. Przykład: odczyt zamówienia innego użytkownika pod adresem `/orders/1`.

### 3.1.3 Local File Inclusion (LFI)
Podatność umożliwia załadowanie nieautoryzowanych plików lokalnych przez manipulację wejściem. Przykład: odczyt zawartości `/etc/passwd` poprzez złośliwy parametr.

### 3.1.4 Object-Level Authorization
Brak weryfikacji uprawnień na poziomie obiektów pozwala na nieautoryzowaną edycję danych. Przykład: użytkownik edytuje profil innej osoby.

## 3.2 A02:2021-Cryptographic Failures

### 3.2.1 Weak Encoding for Password
Podatność polega na przechowywaniu haseł w formie słabo zabezpieczonej, np. przy użyciu algorytmu MD5, co ułatwia ich złamanie.

### 3.2.2 Use of Hard-coded Cryptographic Key
Występuje, gdy klucz kryptograficzny jest zapisany w kodzie źródłowym. Przykład: `SECRET_KEY="static_key"`.

### 3.2.3 Cleartext Transmission of Sensitive Information
Dane, takie jak loginy, są przesyłane w formacie niezaszyfrowanym, co umożliwia ich przechwycenie. Przykład: użycie HTTP zamiast HTTPS.

## 3.3 A03:2021-Injection

### 3.3.1 Remote Code Execution (RCE)
Polega na możliwości wykonania złośliwego kodu przesłanego przez użytkownika. Przykład: wykorzystanie funkcji `eval` z wejściem użytkownika.

### 3.3.2 Cross-Site Scripting (XSS)
Pozwala na wstrzyknięcie złośliwego kodu JavaScript, który wykonuje się w przeglądarce ofiary. Przykład: `alert('XSS');` w polu formularza.

### 3.3.3 Cross-Site Request Forgery (CSRF)
Polega na wykonaniu akcji na koncie zalogowanego użytkownika bez jego wiedzy. Przykład: ukryty formularz dokonujący przelewu.

### 3.3.4 SQL Injection (SQLi)
Pozwala na modyfikację zapytania SQL przez złośliwe dane wejściowe. Przykład: `'; DROP TABLE users; --`.

## 3.4 A04:2021-Insecure Design

### 3.4.1 Open Redirect
Podatność pozwala na przekierowanie użytkownika na niebezpieczną stronę. Przykład: `/redirect?url=http://malicious.com`.

### 3.4.2 Regex Denial of Service (ReDoS)
Występuje, gdy aplikacja używa skomplikowanych wyrażeń regularnych, które powodują zużycie zasobów. Przykład: `^(a+)+$`.

### 3.4.3 Login Rate Limiting
Brak ograniczenia liczby prób logowania umożliwia ataki brute force. Przykład: wielokrotne zgadywanie hasła.

## 3.5 A05:2021-Security Misconfiguration

### 3.5.1 Token / Cookie Misconfiguration
Niepoprawne ustawienia ciasteczek, takie jak brak flag `HttpOnly` lub `Secure`, narażają na ich przechwycenie.

### 3.5.2 DDoS
Ataki na aplikację wykorzystują brak ograniczenia liczby żądań. Przykład: przeciążenie serwera dużą liczbą zapytań.

### 3.5.3 TLS Force / HSTS
Brak wymuszenia HTTPS umożliwia ataki typu Man-in-the-Middle. Przykład: przesyłanie danych przez HTTP.

### 3.5.4 Debug Mode
Tryb debugowania ujawnia poufne informacje aplikacji w środowisku produkcyjnym. Przykład: pełne ścieżki plików.

## 3.6 A06:2021-Vulnerable and Outdated Components

### 3.6.1 Static Analysis on CI/CD
Podatność występuje przy braku analizy kodu w celu wykrycia znanych podatności w bibliotekach. Przykład: przestarzałe zależności.

## 3.7 A09:2021-Security Logging and Monitoring Failures

### 3.7.1 Password Logging
Logowanie haseł użytkowników do plików logów naraża je na nieautoryzowany dostęp.

### 3.7.2 Logging Sensitive Information
Zapis wrażliwych danych, takich jak tokeny lub dane kart płatniczych, do logów może prowadzić do ich wykorzystania.

### 3.7.3 No Log to User
Brak logowania działań użytkownika uniemożliwia wykrywanie prób włamań.

## 3.8 A10:2021-Server-Side Request Forgery

### 3.8.1 Server-Side Request Forgery (SSRF)
Podatność pozwala na wykonanie żądań do wewnętrznych zasobów aplikacji. Przykład: manipulacja parametrem określającym URL.

# 4. Podsumowanie i wnioski
