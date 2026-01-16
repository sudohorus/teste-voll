FROM ruby:3.3.5

RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libpq-dev \
    nodejs \
    yarn


WORKDIR /app

RUN gem install bundler -v 4.0.2

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

CMD ["bash", "-c", "rm -f tmp/pids/server.pid && rails db:migrate && rails db:seed && rails s -b 0.0.0.0"]


