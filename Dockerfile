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

ENV NODE_ENV production

RUN addgroup -g 1001 -S nodejs
RUN adduser -S nextjs -u 1001

RUN apk add --no-cache \
  chromium \
  nss \
  freetype \
  harfbuzz \
  ca-certificates \
  ttf-freefont 

USER nextjs

WORKDIR /app
VOLUME /app/storage
COPY --from=build /app/dist/ /app/

CMD ["node", "index.js"]
