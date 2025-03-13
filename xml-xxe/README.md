# XML External Entity (XXE) Processing

Źródło: https://www.stackhawk.com/blog/rails-xml-external-entities-xxe-guide-examples-and-prevention/

## Opis

XML External Entity (XXE) to rodzaj ataku, który wykorzystuje lukę w parserach XML. Polega na tym, że parser XML domyślnie umożliwia definiowanie zewnętrznych encji (ang. external entities), które mogą być ładowane z zewnętrznych zasobów, takich jak pliki lokalne lub zdalne adresy URL. W kontekście aplikacji Ruby on Rails, jeśli aplikacja parsuje dokumenty XML dostarczane przez użytkownika bez odpowiednich zabezpieczeń, atakujący może wykorzystać tę właściwość do uzyskania dostępu do poufnych danych znajdujących się na serwerze.

## Przykład

Rozważmy następujący przykład nieszkodliwego dokumentu XML:

```xml
<?xml version="1.0" encoding="ISO-8859-1"?>
<username>Jan</username>
```

Atakujący może jednak zmodyfikować ten dokument, dodając definicję zewnętrznej encji w nagłówku `DOCTYPE`, co pozwala na odczytanie zawartości wrażliwego pliku znajdującego się na serwerze:

```xml
<?xml version="1.0" encoding="ISO-8859-1"?>
<!DOCTYPE foo [
  <!ENTITY xxe SYSTEM "file:///secrets.yml">
]>
<username>&xxe;</username>
```

W wyniku tego ataku parser XML załaduje zawartość pliku secrets.yml i zwróci ją użytkownikowi, co może prowadzić do ujawnienia poufnych danych.

## Skutki

Ataki XXE mogą mieć poważne konsekwencje dla aplikacji Ruby on Rails:
- Ujawnienie poufnych informacji przechowywanych na serwerze (np. hasła, klucze API, dane konfiguracyjne).
- Możliwość przeprowadzenia ataków typu Denial-of-Service (DoS), gdy zewnętrzne encje wskazują na zasoby generujące nieskończone lub bardzo duże ilości danych.
- W skrajnych przypadkach atakujący może uzyskać pełną kontrolę nad serwerem.

## Zalecenia

### Jeżeli nie musisz, to nie parsuj dokumentów XML

Jeśli to możliwe, zrezygnuj z wczytywania XML w ogóle – często istnieją alternatywy, takie jak JSON, które w mniejszym stopniu narażają aplikację na ataki XXE.

### Wykorzystaj domyślny parser

Domyślnie Ruby on Rails korzysta z biblioteki **REXML**, która jest bezpieczna i nie obsługuje domyślnie zewnętrznych encji. Jeśli nie masz specyficznych wymagań dotyczących parsowania XML, najlepiej pozostać przy tej bibliotece.

### Wyłącz obsługę zewnętrznych encji

Jeśli konieczne jest użycie innego parsera niż **REXML** (np. **LibXML**), upewnij się, że obsługa zewnętrznych encji jest wyłączona. Możesz to zrobić dodając poniższy kod w pliku inicjalizacyjnym aplikacji:

```ruby
require 'xml'
require 'libxml'

# Zmiana backendu ActiveSupport XML z REXML na LibXML
ActiveSupport::XmlMini.backend = 'LibXML'

# Wyłączenie obsługi external entities
LibXML::XML.class_eval do
  def self.default_substitute_entities
    XML.default_substitute_entities = false
  end
end
```

Możesz także zastosować podejście polegające na ręcznym sprawdzaniu dokumentów XML przed ich parsowaniem i odrzucaniu tych zawierających potencjalnie niebezpieczne definicje:

```ruby
raise StandardError.new("Potencjalny atak XXE") if file.include?("<!ENTITY")
```
