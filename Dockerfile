# Build stage: needs devDependencies for vite.
FROM node:22-bookworm AS build

RUN mkdir -p /app && chown node:node /app
WORKDIR /app
USER node

COPY --chown=node:node package.json package-lock.json ./
RUN npm ci

COPY --chown=node:node . .
RUN npm run build

# Runtime stage: production deps only. app.js imports vite dynamically and
# only when environment !== production, so it is not needed here.
FROM node:22-bookworm-slim

RUN mkdir -p /app && chown node:node /app
WORKDIR /app
USER node

COPY --chown=node:node --from=build /app ./
RUN rm -rf node_modules && npm ci --omit=dev

EXPOSE 3000
CMD ["node", "app.js"]