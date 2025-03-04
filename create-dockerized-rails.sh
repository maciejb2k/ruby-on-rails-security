#!/bin/bash

read -p "Enter project name: " PROJECT_NAME
read -p "Enter Ruby version (e.g., 3.3.5): " RUBY_VERSION
read -p "Enter Rails version (e.g., 7.2): " RAILS_VERSION

if [[ -z "$PROJECT_NAME" || -z "$RUBY_VERSION" || -z "$RAILS_VERSION" ]]; then
  echo "Error: All inputs are required. Aborting."
  exit 1
fi

mkdir "$PROJECT_NAME"
cd "$PROJECT_NAME" || exit

echo "Creating Rails application with Rails version $RAILS_VERSION..."
docker run --rm \
  -e UID=$(id -u) \
  -e GID=$(id -g) \
  -v $(pwd):/app \
  -w /app \
  ruby:${RUBY_VERSION} \
  bash -c "
    addgroup --gid \$GID appuser && \
    adduser --uid \$UID --gid \$GID --disabled-password --gecos '' appuser && \
    su appuser -c 'gem install rails -v $RAILS_VERSION && rails new . --skip-action-mailer --skip-action-mailbox --skip-action-text --skip-active-job --skip-active-storage --skip-action-cable --skip-jbuilder --skip-test --skip-system-test --skip-rubocop --css tailwind --database=postgresql'
  "

cat <<EOF > Dockerfile
# Base Ruby image
FROM ruby:${RUBY_VERSION}

# Install dependencies
RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libpq-dev \
    nodejs \
    yarn \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Arguments for user ID and group ID
ARG UID=1000
ARG GID=1000

# Set environment variables for UID and GID
ENV UID=\${UID}
ENV GID=\${GID}

# Create a group and user with the provided UID and GID
RUN groupadd -g \$GID appuser && useradd -m -u \$UID -g \$GID appuser

# Switch to the created user
USER appuser

# Set Bundler to install gems in the home directory
ENV BUNDLE_PATH=/home/appuser/.bundle
ENV BUNDLE_HOME=/home/appuser/.bundle
ENV GEM_HOME=/home/appuser/.bundle
ENV PATH=\$GEM_HOME/bin:\$PATH

# Install Bundler
RUN gem install bundler

# Switch back to root to copy files with appropriate permissions
USER root

# Copy Gemfile and Gemfile.lock
COPY Gemfile Gemfile.lock ./

# Change ownership of application files to the created user
RUN chown -R appuser:appuser /app

# Switch back to the app user
USER appuser

# Install dependencies
RUN bundle install

# Copy the rest of the application code
COPY . .

# Default command
CMD bash -c "rm -f tmp/pids/server.pid && bin/rails s -p 3000 -b '0.0.0.0'"
EOF

cat <<EOF > docker-compose.yml
services:
  app:
    build: .
    ports:
      - "3000:3000"
    volumes:
      - .:/app
    environment:
      - DATABASE_URL=\${DATABASE_URL}
      - UID=\${UID:-1000}
      - GID=\${GID:-1000}
    depends_on:
      - db
    stdin_open: true
    tty: true
    command: bash -c "bin/rails db:create && bin/rails db:migrate && bin/rails db:schema:load && bin/rails db:seed && rm -f tmp/pids/server.pid && bin/dev"

  db:
    image: postgres:16
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    ports:
      - "5432:5432"
    volumes:
      - postgres-data:/var/lib/postgresql/data

volumes:
  postgres-data:
EOF

cat <<EOF > .env
DATABASE_URL=postgresql://postgres:postgres@db:5432
EOF

cat <<EOF > Procfile.dev
web: bin/rails server -p 3000 -b '0.0.0.0'
css: bin/rails tailwindcss:watch
EOF

cat <<EOF > .gitignore
# Ignore bundler config.
/.bundle

# Ignore all logfiles and tempfiles.
/log/*
/tmp/*
!/log/.keep
!/tmp/.keep

# Ignore pidfiles, but keep the directory.
/tmp/pids/*
!/tmp/pids/
!/tmp/pids/.keep

# Ignore storage (uploaded files in development and any SQLite databases).
/storage/*
!/storage/.keep
/tmp/storage/*
!/tmp/storage/
!/tmp/storage/.keep

/public/assets

# Ignore master key for decrypting credentials and more.
/config/master.key

/app/assets/builds/*
!/app/assets/builds/.keep
EOF

echo "Building Docker image..."
docker compose build app

echo "Removing .git directory..."
rm -rf .git/

mkdir screenshots

cat <<EOF > README.md
# $PROJECT_NAME

## Opis

## Przykład

## Skutki

## Zalecenia
EOF

echo "Rails project setup complete!"
echo "Navigate to the project directory ($PROJECT_NAME) to start development."
