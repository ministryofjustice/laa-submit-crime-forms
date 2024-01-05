FROM ruby:3.2.2-alpine3.18 AS base
LABEL maintainer="Non-standard magistrates' court payment team"

# temp fix to security issue in base image: ruby:3.2.2-alpine3.18
RUN apk update && apk upgrade --no-cache libcrypto3 libssl3

# dependencies required both at runtime and build time
RUN apk add --update \
  build-base \
  postgresql-dev \
  gcompat \
  tzdata \
  yarn \
  clamav-clamdscan && \
  apk del clamav-daemon freshclam

# Alpine does not have a glibc, and this is needed for dart-sass
# Refer to: https://github.com/sgerrand/alpine-pkg-glibc
ARG GLIBC_VERSION=2.34-r0
RUN wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub
RUN wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/$GLIBC_VERSION/glibc-$GLIBC_VERSION.apk
RUN apk add --force-overwrite glibc-$GLIBC_VERSION.apk

FROM base AS dependencies

# system dependencies required to build some gems
RUN apk add --update \
  git

COPY Gemfile Gemfile.lock .ruby-version package.json yarn.lock ./
COPY ./gems ./gems

RUN bundle config set frozen 'true' && \
  bundle config set without test:development && \
  bundle config build.nokogiri --use-system-libraries && \
  bundle install --jobs 5 --retry 3

RUN yarn install --frozen-lockfile --ignore-scripts

FROM base

# add non-root user and group with alpine first available uid, 1000

RUN addgroup -g 1000 -S appgroup && \
  adduser -u 1000 -S appuser -G appgroup

# create some required directories
RUN mkdir -p /usr/src/app && \
  mkdir -p /usr/src/app/log && \
  mkdir -p /usr/src/app/tmp && \
  mkdir -p /usr/src/app/tmp/pids

WORKDIR /usr/src/app

# copy over gems from the dependencies stage
COPY --from=dependencies /usr/local/bundle/ /usr/local/bundle/

# copy over npm packages from the dependencies stage
COPY --from=dependencies /node_modules/ node_modules/

# copy over the remaning files and code
COPY . .

# Some ENV variables need to be present by the time
# the assets pipeline run, but doesn't matter their value.
RUN SECRET_KEY_BASE=needed_for_assets_precompile \
  RAILS_ENV=production \
  ENV=production \
  rails assets:precompile --trace

# non-root user should own these directories
RUN chown -R appuser:appgroup /usr/src/app
RUN chown -R appuser:appgroup log tmp db
RUN chmod +x run.sh

# Download RDS certificates bundle -- needed for SSL verification
# We set the path to the bundle in the ENV, and use it in `/config/database.yml`
#
ENV RDS_COMBINED_CA_BUNDLE /usr/src/app/config/rds-combined-ca-bundle.pem
ADD https://s3.amazonaws.com/rds-downloads/rds-combined-ca-bundle.pem $RDS_COMBINED_CA_BUNDLE
RUN chmod +r $RDS_COMBINED_CA_BUNDLE

ARG APP_BRANCH_NAME
ENV APP_BRANCH_NAME ${APP_BRANCH_NAME}

ARG APP_BUILD_DATE
ENV APP_BUILD_DATE ${APP_BUILD_DATE}

ARG APP_BUILD_TAG
ENV APP_BUILD_TAG ${APP_BUILD_TAG}

ARG APP_GIT_COMMIT
ENV APP_GIT_COMMIT ${APP_GIT_COMMIT}

# switch to non-root user
ENV APPUID 1000
USER $APPUID

ENV PORT 3000
EXPOSE $PORT

ENTRYPOINT ["./run.sh"]
#CMD tail -f /dev/null\
