# Usage:
#
#   build image
#     docker build --platform linux/amd64 -t test/fig .
#
#   run container
#     docker run --rm -it --entrypoint bash <image-id>
#
#   attach to a running container
#     docker container attach <container-id>
#
#   sanity check chrome:
#     google-chrome --no-sandbox --disable-gpu --disable-setuid-sandbox --headless=new --remote-debugging-port=9222 --disable-features=Dbus
#     java --version
#     clj --version
#     cat /etc/os-release (Ubuntu)
#
#   run tests
#     clojure -M:test-ci

ARG NODE_VERSION=21
ARG CLJ_VERSION=1.12.0.1517
ARG APP_DIR=/app

# ------------------------------------------------------------------------------
# Final Image
# ------------------------------------------------------------------------------
FROM eclipse-temurin:21

ARG NODE_VERSION
ARG CLJ_VERSION
ARG APP_DIR

# install node
RUN apt-get update \
  && curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - \
  && apt-get install -y \
  nodejs \
  wget \
  gnupg \
  libgtk-3-0 \
  libdbus-glib-1-2 \
  libxt6 \
  bzip2 \
  file

# install clojure cli
RUN curl -O "https://download.clojure.org/install/linux-install-${CLJ_VERSION}.sh" \
    && chmod +x "linux-install-${CLJ_VERSION}.sh" \
    && bash "./linux-install-${CLJ_VERSION}.sh" \
    && rm -rf "linux-install-${CLJ_VERSION}.sh" \
    && clojure --version

# install chrome
RUN wget --no-verbose -O /usr/src/google-chrome-stable_current_amd64.deb http://dl.google.com/linux/chrome/deb/pool/main/g/google-chrome-stable/google-chrome-stable_133.0.6943.53-1_amd64.deb
RUN apt-get update
RUN apt-get install -f -y /usr/src/google-chrome-stable_current_amd64.deb

WORKDIR ${APP_DIR}

# cache deps - js
COPY ./package.json ./package.json
RUN npm install

# cache deps - watchful - cljs
COPY ./deps.edn ./deps.edn
RUN clojure -P -M:test-ci

# copy src code - app
COPY ./src/                   ./src/
COPY ./test/                  ./test/
COPY ./resources/             ./resources/
COPY ./test.headless.cljs.edn ./test.headless.cljs.edn

EXPOSE 9001
