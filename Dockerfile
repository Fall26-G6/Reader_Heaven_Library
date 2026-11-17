# ---------- Stage 1: Builder ----------
# Node image used only to build the site (pinned tag, no :latest)
FROM node:22-alpine AS builder

# Set working directory inside the container
WORKDIR /app

# Copy dependency files first so Docker can cache the npm ci layer
COPY package*.json ./

# Install exact dependency versions from package-lock.json
RUN npm ci

# Copy the source files and styles
COPY src/ ./src/
COPY styles/ ./styles/

# Build the static site into /app/dist
RUN npm run build

# ---------- Stage 2: Runtime ----------
# Small Nginx image to serve the built files
FROM nginx:1.27-alpine

# Copy only the built output from the builder stage
COPY --from=builder /app/dist /usr/share/nginx/html

# Document that Nginx listens on port 80
EXPOSE 80

# Run Nginx in the foreground so the container stays alive
CMD ["nginx", "-g", "daemon off;"]