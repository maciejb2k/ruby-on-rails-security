# 5.5.4 Debug Mode

## 5.5.4.1 Description

Unlike some other frameworks (e.g., Symfony or Django), **Ruby on Rails does not provide a dedicated “debug mode.”** Instead, Rails relies on **environments** that control how much diagnostic information is exposed and how the app behaves:

* **Development** — rich error pages and developer tooling.
* **Test** — optimized for automated tests, limited interactive debugging.
* **Production** — tuned for performance and security; hides detailed error messages.

Because there is no standalone debug switch, the main risk is **accidentally exposing sensitive internals** by misconfiguring environments or leaving diagnostic tooling enabled in production.

Rails projects often use development-only gems (e.g., `better_errors`, `rack-mini-profiler`, `bullet`) that surface stack traces, SQL queries, and N+1 warnings directly in the browser. These are extremely helpful locally, but **must never be enabled in production**.

---

## 5.5.4.2 Example

Ensure development-only gems are restricted to the appropriate group in your `Gemfile` so they are not available in production.

<!-- Figure 114: Development-only gems declared in Gemfile -->
![alt text](image.png)

---

## 5.5.4.3 Risks

* **Information disclosure** — exposing stack traces, environment details, SQL queries, or file paths helps attackers map the system.
* **Security bypass via diagnostics** — some tools reveal internal endpoints or configurations that should remain private.
* **Leaking secrets in logs** — verbose debug logging can inadvertently capture tokens, credentials, or PII if not curated.

---

## 5.5.4.4 Mitigations

* **Scope debugging gems to development only.** Confirm they are not loaded in production.
* **Harden production environment.**

  * Disable detailed exception pages for users.
  * Keep logs at an appropriate level and scrub secrets.
* **Use staging for troubleshooting.** When production-like debugging is needed, replicate issues in a separate, protected environment rather than enabling debugging on live systems.
* **Review CI/CD configs.** Ensure environment variables, bundler groups, and Rails env are set correctly during deploys.

---
