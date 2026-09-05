# Self-hosting image for the LighterPack fork.
# Upstream's docker/Dockerfile is left untouched — this is the one that gets built.

FROM node:18-bullseye

# The dependency tree is webpack 4-era and fails on modern OpenSSL with
# ERR_OSSL_EVP_UNSUPPORTED. Node 18 still honours the legacy provider flag.
ENV NODE_OPTIONS=--openssl-legacy-provider

# Deliberately NOT setting NODE_ENV=production:
#   1. npm ci would skip devDependencies, dropping webpack-cli and breaking `npm run build`
#   2. app.js requires webpack-dev-server unconditionally at line 2, before any environment
#      check, so a dev-pruned install crashes at startup with MODULE_NOT_FOUND

RUN mkdir -p /app && chown node:node /app
WORKDIR /app
USER node

# Dependencies first so this layer caches across source-only changes.
COPY --chown=node:node package.json package-lock.json ./
RUN npm ci

COPY --chown=node:node . .

# Emits hashed bundles into public/dist, which is gitignored and built here instead.
RUN npm run build

EXPOSE 3000
CMD ["node", "app.js"]