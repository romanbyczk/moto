# ============================================================================
# Stage 1: Base
# ============================================================================
FROM node:24-alpine AS base

RUN corepack enable && corepack prepare pnpm@10.29.3 --activate

WORKDIR /app

COPY package.json pnpm-lock.yaml* ./

# ============================================================================
# Stage 2: Development target
# ============================================================================
FROM base AS development

RUN pnpm install --frozen-lockfile

COPY . .

EXPOSE 3000

CMD ["pnpm", "dev"]

# ============================================================================
# Stage 3: Build (intermediate - produces standalone output)
# ============================================================================
FROM base AS build

RUN pnpm install --frozen-lockfile

COPY . .

ARG API_URL
ENV API_URL=${API_URL}

RUN pnpm build

# ============================================================================
# Stage 4: Production target (minimal runner image)
# ============================================================================
FROM node:24-alpine AS production

WORKDIR /app

RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nextjs

COPY --from=build --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=build --chown=nextjs:nodejs /app/.next/static ./.next/static
COPY --from=build --chown=nextjs:nodejs /app/public ./public

USER nextjs

EXPOSE 3000

ENV PORT=3000 \
    HOSTNAME="0.0.0.0" \
    NODE_ENV=production

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost:3000/ || exit 1

CMD ["node", "server.js"]
