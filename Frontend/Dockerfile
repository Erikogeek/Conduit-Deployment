# Stage 1: Build the Angular application
FROM node:20 AS build

WORKDIR /app

# Copy the package files (package.json, package-lock.json, ...)
COPY package*.json ./

# Install all dependencies from package-lock.json
RUN npm ci

# Copy the application source code
COPY . .

# Build the Angular application.
# The result will be stored in dist/angular-conduit/
RUN npm run build

# Stage 2: Serve the Angular application with Nginx
FROM nginx:alpine

# Copy the finished build from Stage 1 to the Nginx web directory
COPY --from=build /app/dist/angular-conduit /usr/share/nginx/html

# Copy the Nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

# Start Nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]