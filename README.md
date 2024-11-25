# Ruby on Rails Security

This project, developed by Maciej Biel as part of a Master's Degree in Computer Science at the University of Rzeszów, explores security practices in Ruby on Rails applications.

---

## Practical Guide to Secure Ruby on Rails Applications

Welcome to the **Ruby on Rails Security**, a monorepository designed to demonstrate common security vulnerabilities in Ruby on Rails applications and provide guidance on how to address them. This repository contains practical, Dockerized examples of vulnerable applications alongside secure implementations.

Each project in the repository focuses on a specific security vulnerability, providing:
1. **Demonstration of the vulnerability**: What happens when security measures are not in place.
2. **Impact analysis**: Understanding the consequences of the vulnerability.
3. **Secure implementation**: How to mitigate or prevent the vulnerability.

Let me know if you'd like to refine or expand any sections!

---

## Project Outline

Security vulnerabilities are organized into OWASP categories:

### 1. **A01: Broken Access Control**

#### **Mass Assignment**
- **Description:** Exploiting default object attributes assignment in Rails to modify sensitive fields not intended for user control.
- **Examples:**
  1. In a rental platform, users can create listings for their properties. The backend has a `Listing` model where one of the attributes, `is_featured`, determines if the listing is promoted. A malicious user inspects the web form submission, modifies the payload, and sets `is_featured` to `true`, making their listing promoted without authorization.

#### **Insecure Direct Object References (IDOR)**
- **Description:** Directly accessing objects through identifiers (e.g., `/orders/123`) without verifying user ownership.
- **Examples:**
  1. In an e-commerce platform, users can view their order details using a URL like `/orders/123`. A malicious user changes the URL to `/orders/124` to access another customer’s order details, exposing personal data such as shipping address and items purchased.

#### **Object-Level Authorization**
- **Description:** Failing to enforce per-object permissions at the controller or model level.
- **Examples:**
  1. In a task management application, a user can edit their tasks. A malicious user intercepts the edit request, modifies the `task_id` in the payload, and successfully updates another user’s task because the system only checks if the task exists, not if it belongs to the current user.

### 2. **A03: Injection**

#### **Remote Code Execution (RCE)**
- **Description:** Arbitrary code execution through unsafe user input in dynamic Ruby methods.
- **Examples:**
  1. In a dashboard application, administrators can upload custom scripts for analytics processing. A malicious user gains admin access and uploads a script that spawns a reverse shell, giving them control over the server.

#### **SQL Injection**
- **Description:** Crafting SQL queries through user input, bypassing sanitization.
- **Examples:**
  1. In a blogging platform, users can search for articles by title. A malicious user enters a specially crafted search string that drops a database table, resulting in loss of data or unauthorized access to sensitive information.

#### **Cross-Site Scripting (XSS)**
- **Description:** Injecting malicious scripts into web pages viewed by other users.
- **Examples:**
  1. In a customer feedback form, a user submits a feedback message containing a `<script>` tag. When the admin views the feedback in the management dashboard, the script executes, stealing the admin’s session cookie and granting the attacker access to administrative privileges.

### 3. **A04: Insecure Design**

#### **Open Redirect**
- **Description:** Redirecting users to malicious sites via unvalidated URLs.
- **Examples:**
  1. In a payment processing system, after making a payment, users are redirected to a success page. A malicious user intercepts the redirect URL and modifies it to send other users to a phishing site, tricking them into entering sensitive information.

#### **Cross-Site Request Forgery (CSRF)**
- **Description:** Exploiting authenticated sessions by tricking users into submitting malicious requests.
- **Examples:**
  1. In a social media application, users can delete their accounts by clicking a "Delete Account" button. A malicious user crafts a fake "Win a prize" link that triggers the account deletion request in the background when clicked, causing unsuspecting users to lose their accounts.

#### **Regular Expression DoS (ReDoS)**
- **Description:** Overloading regex matching with crafted patterns to cause high CPU usage.
- **Examples:**
  1. In a web application’s user registration form, the username field is validated against a complex regex pattern. An attacker submits an extremely long and malicious string designed to exploit the regex, causing the application to slow down significantly, impacting availability.

#### **Login Rate Limiting**
- **Description:** Absence of brute-force protection mechanisms in login endpoints.
- **Examples:**
  1. In a financial application, a malicious user writes a script to try thousands of username and password combinations against the login endpoint. Since there’s no rate limiting, the attacker successfully brute-forces access to several accounts.

### 4. **A05: Security Misconfiguration**

#### **Token / Cookie Misconfiguration**
- **Description:** Storing sensitive data in non-secure cookies or exposing tokens unintentionally.
- **Examples:**
  1. A banking application stores session tokens in client-side cookies without enabling the `HttpOnly` or `Secure` flags. An attacker intercepts a user’s network traffic, retrieves the token, and uses it to hijack the user’s session.

#### **TLS Enforcement / HSTS**
- **Description:** Failing to enforce HTTPS or configure HSTS headers correctly.
- **Examples:**
  1. A healthcare application allows users to log in over HTTP. An attacker intercepts credentials during login using a man-in-the-middle attack. Additionally, the absence of HSTS allows users to accidentally access the site over an insecure connection.

### 5. **A09: Security Logging and Monitoring Failures**

#### **Password Logging**
- **Description:** Logging sensitive user credentials or tokens in server logs.
- **Examples:**
  1. In a customer support portal, user passwords are included in the logs when a login attempt fails. An internal system admin accidentally exposes the logs during troubleshooting, leaking sensitive user information.

### 6. **CI / CD Security**

#### **Static Analysis**
- **Description:** Lack of static code analysis in CI/CD pipelines to detect vulnerabilities early.
- **Examples:**
  1. A software company’s CI pipeline does not include tools to scan for known vulnerabilities. During a routine deployment, a vulnerable dependency is pushed to production, allowing an attacker to exploit a deserialization vulnerability, gaining unauthorized access to the system.

---

## Creating new Rails Applications

To create a new Rails application, run the `./create-rails-app.sh` script in the root directory.
```bash
chmod +x create-rails-app.sh
./create-rails-app.sh
```

Then navigate to the new project, e.g., `cd mass-assignment`, and run the Rails server:
```bash
docker compose up --up --remove-orphans --build
```

To stop the containers, use:
```bash
docker compose down
```