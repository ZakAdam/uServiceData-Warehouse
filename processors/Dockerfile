# Dockerfile

FROM ruby:3.2.2

WORKDIR /code
COPY . /code
RUN bundle update
RUN bundle install

EXPOSE 4567

CMD ["bundle", "exec", "rackup", "--host", "0.0.0.0", "-p", "4567"]