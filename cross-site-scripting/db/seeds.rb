# Tworzenie postów
post1 = Post.create!(
  title: "Pierwszy post",
  content: "To jest pierwszy przykładowy post. Możesz tutaj zostawiać komentarze."
)

post2 = Post.create!(
  title: "Drugi post",
  content: "To jest drugi post. Rails są świetnym frameworkiem!"
)

post3 = Post.create!(
  title: "Trzeci post",
  content: "Ostatni post w tej przykładowej aplikacji."
)

# Dodawanie komentarzy do postów
post1.comments.create!(
  nickname: "Janek",
  content: "Świetny artykuł! Dzięki!"
)

post1.comments.create!(
  nickname: "Haker",
  content: "<script>alert('XSS atak!');</script>" # Atak XSS
)

post2.comments.create!(
  nickname: "Kasia",
  content: "Super wpis! Czekam na więcej."
)

post3.comments.create!(
  nickname: "Anonim",
  content: "Bardzo ciekawy temat, warto się zagłębić."
)

puts "✅ Dodano 3 posty i kilka komentarzy, w tym XSS w pierwszym poście!"