FROM node:slim as build

ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true

WORKDIR /app
COPY . /app/
RUN yarn install \
  && yarn run build \
  && rm -rf node_modules \
  && yarn install --production \
  && mv node_modules dist/


FROM node:alpine

ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
  PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

RUN apk add --no-cache \
  chromium \
  nss \
  freetype \
  harfbuzz \
  ca-certificates \
  ttf-freefont 

# Tell Puppeteer to skip installing Chrome. We'll be using the installed package.
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
  PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

WORKDIR /app
VOLUME /app/storage
COPY --from=build --chown=pptruser:pptruser /app/dist/ /app/

STOPSIGNAL SIGINT

USER pptruser

CMD node index.js
