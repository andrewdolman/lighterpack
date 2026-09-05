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

COPY --chown=node:node package.json package-lock.json ./
RUN npm ci --omit=dev

COPY --chown=node:node --from=build /app/public/dist ./public/dist
COPY --chown=node:node --from=build /app/app.js ./app.js
COPY --chown=node:node --from=build /app/server ./server
COPY --chown=node:node --from=build /app/config ./config
COPY --chown=node:node --from=build /app/templates ./templates
COPY --chown=node:node --from=build /app/public ./public

EXPOSE 3000
CMD ["node", "app.js"]