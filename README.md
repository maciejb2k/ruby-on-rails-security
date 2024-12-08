# Ruby on Rails Security

This project, which is a part of a Master's Degree in Computer Science at the University of Rzeszów, explores security practices in Ruby on Rails applications.

---

## Project Summary

Right it's only available in Polish in the [SUMMARY.md](./SUMMARY.md) file.

---

## Project Overview

This project is structured as a monorepository designed to demonstrate common security vulnerabilities in Ruby on Rails applications and provide guidance on how to address them.

This repository contains practical, Dockerized examples of vulnerable applications alongside secure implementations.

Each project in the repository focuses on a specific security vulnerability, providing:
1. **Demonstration of the vulnerability**: What happens when security measures are not in place.
2. **Impact analysis**: Understanding the consequences of the vulnerability.
3. **Secure implementation**: How to mitigate or prevent the vulnerability.

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
