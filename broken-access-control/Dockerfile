# Base Ruby image
FROM ruby:3.3.5

# Install dependencies
RUN apt-get update -qq && apt-get install -y     build-essential     libpq-dev     nodejs     yarn     && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Arguments for user ID and group ID
ARG UID=1000
ARG GID=1000

# Set environment variables for UID and GID
ENV UID=${UID}
ENV GID=${GID}

# Create a group and user with the provided UID and GID
RUN groupadd -g $GID appuser && useradd -m -u $UID -g $GID appuser

# Switch to the created user
USER appuser

# Set Bundler to install gems in the home directory
ENV BUNDLE_PATH=/home/appuser/.bundle
ENV BUNDLE_HOME=/home/appuser/.bundle
ENV GEM_HOME=/home/appuser/.bundle
ENV PATH=$GEM_HOME/bin:$PATH

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
