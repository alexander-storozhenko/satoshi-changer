FROM ruby:3.2.2

WORKDIR /hodl/test-backend

COPY . .
RUN gem install specific_install
RUN gem specific_install -l https://github.com/sbounmy/bitcoin-ruby.git -b master

RUN bundle install