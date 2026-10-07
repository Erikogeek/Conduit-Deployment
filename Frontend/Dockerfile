# Stage 1: Build the Angular application
FROM node:20 AS build

# Set the working directory inside the container
WORKDIR /app

# Copy the package files
COPY package*.json ./

# Install dependencies from package-lock.json
RUN npm ci

# Copy the Angular application source code
COPY . .

# Build the Angular application
# The result is stored in dist/angular-conduit/
RUN npm run build


# Stage 2: Serve the Angular application with Nginx
FROM nginx:alpine

# Copy the Angular build from Stage 1 to the Nginx web directory
COPY --from=build /app/dist/angular-conduit /usr/share/nginx/html

# Copy the Nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Nginx listens on port 80 inside the container
EXPOSE 80

# Start Nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]