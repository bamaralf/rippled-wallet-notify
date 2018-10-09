FROM ruby:2.5.1-slim
WORKDIR /usr/src/app
COPY Gemfile Gemfile.lock ./
RUN bundle install
COPY . .
CMD ["ruby", "./main.rb"]