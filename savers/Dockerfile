FROM ruby:3.2.2

RUN apt-get update \
&& apt-get install -y --no-install-recommends \
  libxml2-dev \
  libxslt-dev \
  nodejs \
  libffi-dev \
  libc-dev \
  file \
  imagemagick \
  git \
  tzdata \
  && rm -rf /var/cache/apk/*

RUN curl -o- -L https://yarnpkg.com/install.sh | bash

WORKDIR /app
COPY . /app/

ENV BUNDLE_PATH /gems
RUN $HOME/.yarn/bin/yarn install
RUN bundle install

ENTRYPOINT ["bin/rails"]
CMD ["s", "-b", "0.0.0.0"]

EXPOSE 3000