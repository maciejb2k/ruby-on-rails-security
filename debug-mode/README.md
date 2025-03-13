# Debug Mode

## Opis

W Ruby on Rails nie istnieje dedykowany tryb "debug mode", jak ma to miejsce w innych frameworkach, takich jak Symfony czy Django. Zamiast tego Rails wykorzystuje różne środowiska pracy (environments), które wpływają na sposób działania aplikacji oraz poziom ujawnianych informacji diagnostycznych.

Domyślnie Rails obsługuje trzy główne środowiska:
- **`development`** – przeznaczone do programowania, z obszernymi komunikatami błędów oraz narzędziami debugowania,
- **`test`** – używane do automatycznych testów, bez pełnej obsługi debugowania,
- **`production`** – zoptymalizowane pod kątem bezpieczeństwa i wydajności, bez szczegółowych komunikatów błędów.

Ponieważ Rails nie posiada dedykowanego trybu debugowania, zagrożenia związane z nadmiernym ujawnianiem informacji wynikają głównie z niewłaściwej konfiguracji środowiska i niepoprawnego użycia narzędzi diagnostycznych w środowisku produkcyjnym.

## Przykłady i zalecenia

### Ograniczenie narzędzi debugowania do środowiska development

Niektóre wtyczki i narzędzia debugowania powinny być dostępne tylko w środowisku `development`. Ich obecność w production może stanowić poważne zagrożenie bezpieczeństwa.

Przykład: `web-console`

Rails domyślnie zawiera wtyczkę `web-console`, która umożliwia uruchamianie sesji REPL (IRB) bezpośrednio w przeglądarce w kontekście aktualnej aplikacji. Dzięki temu można wykonywać kod Ruby i debugować aplikację w czasie rzeczywistym.

Powinna być dostępna wyłącznie w `development`, ponieważ jej obecność w production może stanowić krytyczne zagrożenie.

Niebezpieczna konfiguracja:

```ruby
gem 'web-console'
```

Prawidłowa konfiguracja:

```ruby
gem 'web-console', group: :development
```

Dzięki temu `web-console` nie będzie dostępne w środowisku produkcyjnym.

### Uruchomienie aplikacji w niewłaściwym środowisku

Jeśli aplikacja Rails działa w środowisku `development` na serwerze produkcyjnym, może to prowadzić do ujawniania pełnych komunikatów błędów oraz logowania wrażliwych danych, tak jak zostało to opisane w [tym rozdziale](https://github.com/maciejb2k/ruby-on-rails-security/tree/main/no-log-to-user).

Można to sprawdzić poleceniem:

```shell
echo $RAILS_ENV
```

Prawidłowa konfiguracja na produkcji powinna wymuszać środowisko `production`:

```bash
RAILS_ENV=production
```