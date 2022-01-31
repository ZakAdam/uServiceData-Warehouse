# Dockerfile

FROM ruby:3.0.1

WORKDIR /code
COPY . /code
RUN bundle install

CMD ["ruby", "heureka_reviews_downloader.rb"]