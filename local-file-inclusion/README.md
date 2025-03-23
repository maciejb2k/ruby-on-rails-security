# Local File Inclusion (LFI)

Uruchomienie przykładowej aplikacji dla tej podatności:

```bash
# Aby uruchomić aplikację, wykonaj następującą komendę:
docker compose up -d

# Zatrzymanie aplikacji odbywa się za pomocą:
docker compose down

# W celu rozpoczęcia pracy od nowa (usunięcia wszystkich danych) użyj:
docker compose restart
```

## Opis

Local File Inclusion (LFI) to podatność umożliwiająca atakującemu wczytanie lokalnych plików serwera poprzez manipulację niebezpiecznym wejściem użytkownika. W kontekście Ruby on Rails (RoR) występuje, gdy aplikacja dynamicznie ładuje pliki na podstawie niezabezpieczonych parametrów wejściowych, np. poprzez `render`, `send_file` lub `File.read`.

Konsekwencje ataku:
- Odczytanie plików systemowych (np. `/etc/passwd`, plików konfiguracyjnych Rails).
- Wyciek poufnych informacji (np. kluczy API, danych użytkowników).
- Możliwość eskalacji ataku do Remote Code Execution (RCE), jeśli aplikacja umożliwia wczytywanie plików z zawartością kodu.

## Przykład

W przygotowanej aplikacji, istnieją raporty finansowe do pobrania przez użytkownika.

![LFI](./screenshots/download-reports.png)

Po kliknięciu w Download, aplikacja wczytuje plik lokalnie z serwera i umożliwia pobranie go przez użytkownika.

Link do pobrania pliku wygląda następująco:
```
http://localhost:3000/reports/unsafe_download?file=financial_report_q1.pdf
```

Tak wygląda kontroler odpowiedzialny za pobieranie plików:

```ruby
# app/controllers/reports_controller.rb

class ReportsController < ApplicationController
  REPORTS_DIR = Rails.root.join('downloads', 'reports').freeze

  def index
    @files = Dir.children(REPORTS_DIR).sort
  end

  ...

  def unsafe_download
    file = params[:file]
    send_file REPORTS_DIR.join(file)
  end

  ...
end
```

Mamy tutaj do czynienia z bardzo poważną podatnością, w której nie sprawdzamy, jaki plik lokalnie chce pobrac nasz użytkownik i umożliwiamy mu w takim wypadku pobranie dowolnego pliku z naszego serwera.

Jeżeli atakujący ręcznie zmodyfikuje parametr `file` w linku, np. na `../../.env`, to aplikacja pozwoli użytkownikowi pobrać plik `.env` z serwera ze wszystkimi kluczami API, hasłami, itp.
```
http://localhost:3000/reports/unsafe_download?file=../../.env
```

Jeżeli atakujący zna strukturę plików na serwerze, to może próbować wczytać różne pliki, np. `/etc/passwd`, `/etc/hosts`, itp.
```
http://localhost:3000/reports/unsafe_download?file=../../../../etc/passwd
http://localhost:3000/reports/unsafe_download?file=../../../../etc/hosts
```

Rozwiązaniem problemu jest sprawdzenie, czy użytkownik próbuje pobrać plik z dozwolonego katalogu, np. `reports`, w naszym przypadku kod może sprawdzać, czy plik który chcemy pobrać, faktycznie znajduje się w katalogu `reports`.

Kluczem jest to, aby filtrować parametry wejściowe, które mogą być wykorzystane do wczytywania plików lokalnych.
```ruby
class ReportsController < ApplicationController
  REPORTS_DIR = Rails.root.join('downloads', 'reports').freeze

  ...

  def safe_download
    file = params[:file]
    file_path = REPORTS_DIR.join(file)

    is_valid_file = File.exist?(file_path) && File.dirname(file_path) == REPORTS_DIR.to_s

    if is_valid_file
      send_file file_path
    else
      render plain: 'Access Denied', status: :forbidden
    end
  end
end
```

Gdy z zabezpieczonego już endpointu użytkownik spróbuje pobrać plik z innego katalogu, niż `reports`, to aplikacja zwróci błąd `403 Forbidden`.
```
http://localhost:3000/reports/safe_download?file=../../.env
```

![Access Denied](./screenshots/access-denied.png)

Oczywiście raporty finansowe są nadal dostępne do pobrania:
```
http://localhost:3000/reports/safe_download?file=financial_report_q1.pdf
```

## Skutki

- **Odczyt wrażliwych plików z serwera** – np. plików konfiguracyjnych, danych środowiskowych (`.env`), haseł, kluczy API.
- **Wyciek danych systemowych** – np. `/etc/passwd`, co może ułatwić dalsze etapy ataku.
- **Możliwość eskalacji ataku** – w skrajnych przypadkach LFI może prowadzić do Remote Code Execution (RCE) przy połączeniu z innymi podatnościami.

## Zalecenia

- **Walidacja i sanityzacja parametrów** – zawsze sprawdzaj ścieżkę dostępu, ograniczając możliwość wychodzenia poza dozwolone katalogi.
- **Korzystanie z pełnych ścieżek bezwzględnych** – unikaj dynamicznego budowania ścieżek na podstawie danych wejściowych bez walidacji.
- **Unikanie bezpośredniego użycia `send_file` z parametrami użytkownika** – stosuj whitelisty plików lub katalogów.
- **Zaimplementowanie mechanizmów logowania i monitoringu** – wykrywaj podejrzane próby dostępu do niedozwolonych lokalizacji (np. `../` w parametrach).
