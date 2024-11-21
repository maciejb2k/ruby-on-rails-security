#!/bin/bash

# rails new sqli --skip-action-mailer --skip-action-mailbox --skip-action-text --skip-active-job --skip-active-storage --skip-action-cable --skip-jbuilder --skip-test --skip-system-test --skip-rubocop --database=postgresql -c tailwind

if [ -z "$1" ]; then
  echo "Usage: $0 <app_name>"
  exit 1
fi

APP_NAME=$1

cd $APP_NAME

cat <<EOF > docker-compose.yml
services:
  db:
    image: postgres:16
    environment:
      POSTGRES_USERNAME: postgres
      POSTGRES_PASSWORD: postgres
    ports:
      - "5432:5432"
    volumes:
      - postgres-data:/var/lib/postgresql/data

volumes:
  postgres-data:
EOF

cat <<EOF > .env
DATABASE_URL=postgresql://postgres:postgres@localhost:5432
EOF

echo "gem 'dotenv-rails'" >> Gemfile
bundle install
