# Stage 1: Install Python dependencies
FROM python:3.5-slim AS dependencies

# Set the working directory inside the container
WORKDIR /app

# Copy the requirements file into the container
COPY requirements.txt .

# Install dependencies into a separate directory without the pip cache
RUN pip install --no-cache-dir --prefix=/INSTALL -r requirements.txt


# Stage 2: Runtime image
FROM python:3.5-slim

# Set the working directory inside the container
WORKDIR /app

# Copy the installed dependencies from the first stage
COPY --from=dependencies /INSTALL /usr/local

# Copy the Django application into the runtime image
COPY . .

# Make the entrypoint script executable
RUN chmod +x entrypoint.sh

# Gunicorn listens on port 8000 inside the container
EXPOSE 8000

# Start the application
ENTRYPOINT ["./entrypoint.sh"]