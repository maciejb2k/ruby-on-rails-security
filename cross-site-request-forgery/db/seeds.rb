SafeArticle.create!([
                      { title: 'Bezpieczeństwo w Rails',
                        content: 'Rails domyślnie chroni aplikacje przed atakami CSRF, używając tokenów autentyczności.' },
                      { title: 'Ochrona przed CSRF',
                        content: 'Formularze Rails automatycznie dołączają tokeny CSRF, które są weryfikowane po stronie serwera.' },
                      { title: 'Dobre praktyki bezpieczeństwa',
                        content: 'Należy unikać używania skip_before_action :verify_authenticity_token, aby zapobiegać atakom CSRF.' }
                    ])
