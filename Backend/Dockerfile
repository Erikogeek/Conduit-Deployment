# Stage 1: Install python dependencies.
FROM python:3.5-slim AS dependencies

# Set the working directory in Container to 'app'.
WORKDIR /app  

# copy the requirements file into the build context.
COPY requirements.txt .

# Install dependencies into separate directory without pip cache.
RUN pip install --no-cache-dir --prefix=/INSTALL -r requirements.txt

# Stage 2: Runtime image
FROM python:3.5-slim

WORKDIR /app

# copy the installed dependencies from stage 1.
COPY --from=dependencies /INSTALL /usr/local

# copy the django application in the runtime image
COPY . .

# Make the entrypoint script executable
RUN chmod +x entrypoint.sh

# Django/Gunicorn is reachable on Port 8000 inside the container.
EXPOSE 8000

ENTRYPOINT [ "./entrypoint.sh" ]