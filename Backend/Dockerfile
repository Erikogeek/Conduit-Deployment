# Build an image with python 3.5.2 (Basic image)
FROM python:3.5-slim

# Set the working directory in Container to 'app'.
WORKDIR /app  

# copy the relevant files and assets from the Host during the build process
COPY . .

# Install all dependencies for the application that lives in the container.
RUN python -m pip install -r requirements.txt && chmod +x entrypoint.sh

# Django/WSGI is reachable via Port 8000 in container.
EXPOSE 8000

ENTRYPOINT [ "./entrypoint.sh" ]