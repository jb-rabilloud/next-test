FROM node:12.16.1-buster-slim as builder

ARG NEXT_REVALIDATION_PERIOD \ 
    APM_SERVER

ENV NODE_ENV=production

COPY .env env-creation.sh /tmp/
RUN chmod +x /tmp/env-creation.sh

RUN mkdir /app && chown -R node:node /app
WORKDIR /app
USER node

COPY --chown=node:node package.json yarn.lock next-env.d.ts tsconfig.json .npmrc .babelrc tailwind.config.js postcss.config.js next.config.js ./
RUN yarn install --production --silent --network-timeout 1000000 && yarn cache clean --force
COPY --chown=node:node public/ ./public
COPY --chown=node:node src/ ./src
RUN mkdir -p public/assets/navHeader/css && \
    cp -R node_modules/@transverse/nav-header/dist/data/* public/assets/navHeader && \
    cp node_modules/@transverse/nav-header/dist/index.cjs.css public/assets/navHeader/css/nav-header.css && \
    mkdir -p public/assets/footer/css && \
    cp -R node_modules/@transverse/footer/dist/data/* public/assets/footer && \
    cp node_modules/@transverse/footer/dist/index.cjs.css public/assets/footer/css/footer.css && \
    npx next telemetry disable && \
    yarn build

EXPOSE 5000
ENTRYPOINT /tmp/env-creation.sh && cp /tmp/env-config.js /app/public/ && cat /app/public/env-config.js && yarn start
