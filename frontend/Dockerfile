# --- Base Stage ---
# Use an official Node.js runtime as a parent image
FROM node:20-alpine AS base

# Set working directory
WORKDIR /app

# Copy package.json and package-lock.json (or yarn.lock)
COPY package*.json ./

# --- Dependencies Stage ---
FROM base AS deps
# Install dependencies
RUN npm install

# --- Development Stage ---
FROM deps AS dev
# Copy the rest of the application code
COPY . .
# Expose port and start the development server
EXPOSE 3000
CMD ["npm", "run", "dev"]


# --- Production Build Stage ---
FROM deps AS builder
# Accept build arguments for Next.js environment variables
ARG NEXT_PUBLIC_API_URL
ARG NEXT_PUBLIC_BASE_PATH
ENV NEXT_PUBLIC_API_URL=$NEXT_PUBLIC_API_URL
ENV NEXT_PUBLIC_BASE_PATH=$NEXT_PUBLIC_BASE_PATH

# Copy the rest of the application code
COPY . .
# Build the Next.js app for production
RUN npm run build

# --- Production Stage ---
FROM base AS prod
# Copy the complete built application from builder
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/package.json .
COPY --from=builder /app/package-lock.json .
COPY --from=builder /app/next.config.ts .
COPY --from=builder /app/node_modules ./node_modules

# Expose port and start the production server
EXPOSE 3000
CMD ["npm", "start"] 