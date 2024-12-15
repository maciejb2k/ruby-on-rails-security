# Ruby on Rails Security

This project, which is a part of a Master's Degree in Computer Science at the University of Rzeszów, explores security practices in Ruby on Rails applications, according to the OWASP Top 10 list from 2021.

---

## Project Overview

This project is structured as a monorepository designed to demonstrate common security vulnerabilities in Ruby on Rails applications and provide guidance on how to address them.

This repository contains practical, Dockerized examples of vulnerable applications alongside secure implementations.

Each project in the repository focuses on a specific security vulnerability, providing:
1. **Demonstration of the vulnerability**: What happens when security measures are not in place.
2. **Impact analysis**: Understanding the consequences of the vulnerability.
3. **Secure implementation**: How to mitigate or prevent the vulnerability.

---

## Project Summary

## 3.1 A01:2021-Broken Access Control

### 3.1.1 Mass Assignment
- Example: https://github.com/maciejb2k/ruby-on-rails-security/tree/main/mass-assignment

### 3.1.2 Insecure Direct Object References (IDOR)
- Example: -

### 3.1.3 Local File Inclusion (LFI)
- Example: -

### 3.1.4 Object Access Middleware
- Example: -

## 3.2 A02:2021-Cryptographic Failures

### 3.2.1 Weak Encoding for Password
- Example: -

### 3.2.2 Use of Hard-Coded Cryptographic Key
- Example: -

### 3.2.3 Cleartext Transmission of Sensitive Information
- Example: -

## 3.3 A03:2021-Injection

### 3.3.1 Remote Code Execution (RCE)
- Example: -

### 3.3.2 Cross-Site Scripting (XSS)
- Example: -

### 3.3.3 Cross-Site Request Forgery (CSRF)
- Example: -

### 3.3.4 SQL Injection (SQLi)
- Example: -

## 3.4 A04:2021-Insecure Design

### 3.4.1 Open Redirect
- Example: -

### 3.4.2 Regex Denial of Service (ReDoS)
- Example: -

### 3.4.3 Login Rate Limiting
- Example: -

## 3.5 A05:2021-Security Misconfiguration

### 3.5.1 Token / Cookie Misconfiguration
- Example: -

### 3.5.2 XML DDoS
- Example: -

### 3.5.3 TLS Force / HSTS
- Example: -

### 3.5.4 Debug Mode
- Example: -

## 3.6 A06:2021-Vulnerable and Outdated Components

### 3.6.1 Static Analysis on CI/CD
- Example: -

## 3.7 A09:2021-Security Logging and Monitoring Failures

### 3.7.1 Password Logging
- Example: -

### 3.7.2 Logging Sensitive Information
- Example: -

### 3.7.3 No Log to User
- Example: -

## 3.8 A10:2021-Server-Side Request Forgery

### 3.8.1 Server-Side Request Forgery (SSRF)
- Example: -

---

## Creating a new Rails applications

To create a new Rails application, run the `./create-rails-app.sh` script in the root directory.
```bash
chmod +x create-rails-app.sh
./create-rails-app.sh
```

Then navigate to the new project and run the Rails server:
```bash
cd <project-name>
docker compose up -d --remove-orphans
```

To rebuild the containers, use:
```bash
docker compose down
docker compose up -d --remove-orphans --build
```

To access the container with Rails app:
```bash
cd <project-name>
docker compose exec -it app bash
```

To access PSQL shell:
```bash
cd <project-name>
docker compose exec -it db psql -U postgres
```

To restart the application (remove all data), use:
```bash
docker compose restart
```

To stop the containers, use:
```bash
docker compose down
```
