# Ruby on Rails Security

---

📄 **Download the original Master’s thesis in Computer Science (Polish)**: [Thesis.docx](./2025_IIstInfSR_117780_p.docx)

🌍 The thesis was originally written in Polish as part of my M.Sc. studies in Computer Science (following a B.Eng.). This repository contains the English translation, adapted to be developer-friendly.

---

This repository is part of my master’s thesis in Computer Science at the University of Rzeszów. The thesis itself serves both as academic research and as a practical **developer’s guide** to security in Ruby on Rails applications, structured around the OWASP Top 10 (2021).

The project is organized as a monorepo containing a series of small Rails applications, each of which demonstrates a specific security vulnerability.

Each application illustrates the vulnerability in practice — showing how it can be exploited, what the consequences are, and then how to implement a secure fix along with recommended protection techniques and best practices.


---

## Covered Vulnerabilities (OWASP Top 10:2021)

Most examples are built using **Ruby on Rails 7.2** and **Ruby 3.3.5**.

### 3.1 A01:2021 - Broken Access Control

| Vulnerability                            | Description | Example App | Link                                                                                                     |
| ---------------------------------------- | ----------- | ----------- | -------------------------------------------------------------------------------------------------------- |
| Mass Assignment                          | ✅           | ✅           | [GitHub](https://github.com/maciejb2k/ruby-on-rails-security/tree/main/mass-assignment)                  |
| Insecure Direct Object References (IDOR) | ✅           | ✅           | [GitHub](https://github.com/maciejb2k/ruby-on-rails-security/tree/main/insecure-direct-object-reference) |
| Local File Inclusion (LFI)               | ✅           | ✅           | [GitHub](https://github.com/maciejb2k/ruby-on-rails-security/tree/main/local-file-inclusion)             |
| Object Level Authorization (OLA)         | ✅           | ✅           | [GitHub](https://github.com/maciejb2k/ruby-on-rails-security/tree/main/object-level-authorization)       |

### 3.2 A02:2021 - Cryptographic Failures

| Vulnerability                                   | Description | Example App | Link                                                                                                                 |
| ----------------------------------------------- | ----------- | ----------- | -------------------------------------------------------------------------------------------------------------------- |
| Weak Encoding for Password                      | ✅           | ❌           | [GitHub](https://github.com/maciejb2k/ruby-on-rails-security/tree/main/weak-encoding-for-password)                   |
| Use of Hard-Coded Cryptographic Key             | ✅           | ❌           | [GitHub](https://github.com/maciejb2k/ruby-on-rails-security/tree/main/hard-coded-cryptographic-key)                 |
| Cleartext Transmission of Sensitive Information | ✅           | ❌           | [GitHub](https://github.com/maciejb2k/ruby-on-rails-security/tree/main/cleartext-transmission-sensitive-information) |

### 3.3 A03:2021 - Injection

| Vulnerability                     | Description | Example App | Link                                                                                               |
| --------------------------------- | ----------- | ----------- | -------------------------------------------------------------------------------------------------- |
| Remote Code Execution (RCE)       | ✅           | ✅           | [GitHub](https://github.com/maciejb2k/ruby-on-rails-security/tree/main/remote-code-execution)      |
| Cross-Site Scripting (XSS)        | ✅           | ✅           | [GitHub](https://github.com/maciejb2k/ruby-on-rails-security/tree/main/cross-site-scripting)       |
| Cross-Site Request Forgery (CSRF) | ✅           | ✅           | [GitHub](https://github.com/maciejb2k/ruby-on-rails-security/tree/main/cross-site-request-forgery) |
| SQL Injection (SQLi)              | ✅           | ✅           | [GitHub](https://github.com/maciejb2k/ruby-on-rails-security/tree/main/sql-injection)              |

### 3.4 A04:2021 - Insecure Design

| Vulnerability                   | Description | Example App | Link                                                                                        |
| ------------------------------- | ----------- | ----------- | ------------------------------------------------------------------------------------------- |
| Open Redirect                   | ✅           | ✅           | [GitHub](https://github.com/maciejb2k/ruby-on-rails-security/tree/main/open-redirect)       |
| Regex Denial of Service (ReDoS) | ✅           | ❌           | [GitHub](https://github.com/maciejb2k/ruby-on-rails-security/tree/main/regex-dos)           |
| Login Rate Limiting             | ✅           | ✅           | [GitHub](https://github.com/maciejb2k/ruby-on-rails-security/tree/main/login-rate-limiting) |

### 3.5 A05:2021 - Security Misconfiguration

| Vulnerability                   | Description | Example App | Link                                                                                                  |
| ------------------------------- | ----------- | ----------- | ----------------------------------------------------------------------------------------------------- |
| Token / Cookie Misconfiguration | ✅           | ✅           | [GitHub](https://github.com/maciejb2k/ruby-on-rails-security/tree/main/token-cookie-misconfiguration) |
| XML XXE                         | ✅           | ❌           | [GitHub](https://github.com/maciejb2k/ruby-on-rails-security/tree/main/xml-xxe)                       |
| TLS Force / HSTS                | ✅           | ❌           | [GitHub](https://github.com/maciejb2k/ruby-on-rails-security/tree/main/tls-force-hsts)                |
| Debug Mode                      | ✅           | ❌           | [GitHub](https://github.com/maciejb2k/ruby-on-rails-security/tree/main/debug-mode)                    |

<!-- ### 3.6 A06:2021 - Vulnerable and Outdated Components

| Vulnerability | Description | Example App | Link |
| - | - | - | - |
| Static Analysis on CI/CD on GitHub | ✅ | ✅ | - | -->

### 3.7 A09:2021 - Security Logging and Monitoring Failures

| Vulnerability                 | Description | Example App | Link                                                                                                  |
| ----------------------------- | ----------- | ----------- | ----------------------------------------------------------------------------------------------------- |
| Enable Logging                | ✅           | ❌           | [GitHub](https://github.com/maciejb2k/ruby-on-rails-security/tree/main/enable-logging)                |
| Logging Sensitive Information | ✅           | ✅           | [GitHub](https://github.com/maciejb2k/ruby-on-rails-security/tree/main/logging-sensitive-information) |
| No Log to User                | ✅           | ❌           | [GitHub](https://github.com/maciejb2k/ruby-on-rails-security/tree/main/no-log-to-user)                |

### 3.8 A10:2021 - Server-Side Request Forgery

| Vulnerability               | Description | Example App | Link                                                                                                |
| --------------------------- | ----------- | ----------- | --------------------------------------------------------------------------------------------------- |
| Server-Side Request Forgery | ✅           | ✅           | [GitHub](https://github.com/maciejb2k/ruby-on-rails-security/tree/main/server-side-request-forgery) |

---

## Creating a New Rails Application

To simplify the process of adding new Rails apps, the script `create-rails-app.sh` automates the setup. It handles project initialization, gem installation, database reset & seeding, Docker container configuration, and server startup.

To create a new Rails app, run:

```bash
chmod +x create-rails-app.sh
./create-rails-app.sh
```

Then enter the new project and start the Rails server:

```bash
cd <project-name>
docker compose up -d --remove-orphans
```

Rebuild containers if needed:

```bash
docker compose down
docker compose up -d --remove-orphans --build
```

Access the Rails app container:

```bash
cd <project-name>
docker compose exec -it app bash
```

Access PostgreSQL shell:

```bash
cd <project-name>
docker compose exec -it db psql -U postgres
```

Restart the application (removes all data):

```bash
docker compose restart
```

Stop containers:

```bash
docker compose down
```
