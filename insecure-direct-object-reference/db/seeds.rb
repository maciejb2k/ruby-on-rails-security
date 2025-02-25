# Tworzenie użytkowników
user1 = User.create!(email: 'maciek@example.com', password: 'password')
user2 = User.create!(email: 'tomek@example.com', password: 'password')

# Zadania dla Maćka
Task.create!(title: '[Maciek] Przygotowanie prezentacji', description: 'Przygotuj slajdy na prezentację dotyczącą wyników kwartalnych.', user: user1)
Task.create!(title: '[Maciek] Zakupy spożywcze', description: 'Kup chleb, mleko, jajka i warzywa na obiad.', user: user1)
Task.create!(title: '[Maciek] Umówienie wizyty u dentysty', description: 'Zadzwonić do gabinetu i ustalić termin wizyty.', user: user1)
Task.create!(title: '[Maciek] Opracowanie raportu', description: 'Przygotować szczegółowy raport dotyczący wyników sprzedaży za ostatni miesiąc.', user: user1)
Task.create!(title: '[Maciek] Przegląd samochodu', description: 'Umów przegląd techniczny samochodu na najbliższy tydzień.', user: user1)

# Zadania dla Tomka
Task.create!(title: '[Tomek] Przygotowanie planu treningowego', description: 'Stworzyć tygodniowy plan treningów siłowych i cardio.', user: user2)
Task.create!(title: '[Tomek] Opłacenie rachunków', description: 'Zapłacić za prąd, gaz i internet do 10. dnia miesiąca.', user: user2)
Task.create!(title: '[Tomek] Projekt strony internetowej', description: 'Rozpocząć pracę nad stroną portfolio i zaplanować sekcje.', user: user2)
Task.create!(title: '[Tomek] Wizyta u mechanika', description: 'Sprawdzić, dlaczego kontrolka silnika się świeci i wymienić olej.', user: user2)
Task.create!(title: '[Tomek] Rezerwacja stolika', description: 'Zarezerwować stolik w restauracji na sobotni wieczór.', user: user2)

puts 'Baza danych została zasilona przykładowymi danymi!'
