FROM node:24-alpine

# Enable pnpm via corepack
RUN corepack enable && corepack prepare pnpm@10.29.3 --activate

WORKDIR /app

# Install dependencies (cached layer - only re-runs when lockfile changes)
COPY package.json pnpm-lock.yaml* ./
RUN pnpm install --frozen-lockfile || pnpm install

# Copy project files
COPY . .

EXPOSE 3000

CMD ["pnpm", "dev"]