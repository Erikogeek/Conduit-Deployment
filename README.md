# Conduit-Container
This project containerizes a full-stack web application consisting of a `Django backend`, an `Angular frontend client` and a `PostgreSQL database`. The Nginx web server serves the Angular application and forwards API requests to the backend. The setup uses Docker Compose to manage all containers.

The goal of this project is to provide a reproducible containerized development and deployment environment.

## Table of contents
- [1. Prerequisites](#Prerequisites)
- [2. Quickstart](#2-Quickstart)
- [3. Usage](#Usage)
- [4. Troubleshooting](#Troubleshooting)

## 1. Prerequisites
To successfull set up this project the knowledge in following technologies and software is required:
* Docker and dockerfile for building containers.
* Docker compose for managing the containers.
* Angular for the frontend
* Django REST framework for the backend API.
* PostgreSQL as the database

## 2. Quickstart
* Clone the repository:
```bash
git clone <REPOSITORY_URL>
```
Change the working directory: `cd Conduit-Container`

* Create the environment file

Create `.env` based on `.env.example`and set the required variable values.

```bash
Copy-Item .env.example .env
```
* Building the containers:

This builds the specific frontend and backend images from the project`s own dockerfiles.
```bash
cd /Conduit-Container/Frontend
docker build --tag conduit-frontend .
```
```bash
cd /Conduit-Container/Backend
docker build --tag conduit-backend .
```
* Start the specific containers.
```bash
docker run --rm -p 8282:80 conduit-frontend
docker run --rm -p 8001:8000 conduit-backend
```
* Build the images using Docker-compose
```bash
docker compose build
```
* Start and stop the application:
```bash
docker compose up -d
docker compose down
```
* Check the containers:
```bash
docker compose ps
```
* Run django migrations:
```bash
docker compose exec backend python manage.py migrate
```
* View the container logs:
```bash
docker compose logs backend
```
* Open the application in your browser:
 `http://SERVER_IP:8282`

## 3. Usage

This section describes how the application can be configured,started, modified and operated. 
The frontend is available on `port 8282` of the host system. Nginx serves the angular application and forwards API requests to the backend container.
The django backend runs with the gunicorn on `port 8000`.

The ProgreSQL uses `port 5432` internally inside the docker network. It does not need to be exposed to the host because only the backend communicates directly with the database.

### Environment configuration

Sensitive and environment-specific values are stored in `.env`. The repository contains  `.env.example` as a template.
The following variables are used:

| `variables` | `values` |
| -------- | ------ |
| POSTGRES_DB | Name of the postgreSQL database |
| POSTGRES_USER | database user |
| POSTGRES_PASSWORD | database password |
| POSTGRES_PORT | postgreSQL port |
| DJANGO_SECRET_KEY| secret key used by django|
| DJANGO_DEBUG | enables or disables django debug mode |
| DJANGO_ALLOWED_HOSTS| hosts that django accepts|

### Backend Dockerfile

This file uses a `python 3.5` as base image, sets `/app` as working directory, copies and installs the project dependencies listed in `requirements.txt`. Copies the backend code, exposes `PORT: 8000` and starts `Gunicorn 20.1.0` with the django WSGI application.

### Backend entrypoint.sh

The backend container uses an `entrypoint.sh`script to prepare and start the django application.

The script performs the following steps when the container starts:
- Run the database migrations
- Check and create the superuser
- Start the django application with `gunicorn`

### Frontend Dockerfile

The frontend uses a multi-stage docker build.
- In the first stage `Node.js 20` is used to install dependencies defined by `package-lock.json` and build the angular application.
```bash
npm ci 
npm run build
```
- In the second stage, the compiled angular application is copied into the nginx alpine image. This multi-stage approach keeps the final image of frontend smaller because `Node.js` and the build dependencies are not required to serve the compiled application.

### Nginx configuration

Nginx performs two main taks:
- The ``serve angular application``:
The requests for the frontend are served from `/usr/share/nginx/html`.
- The `Forward API requests`: Beginning with `/api/`are forwarded to the backend.

```nginx.conf
location /api/ { 
proxy_pass http://backend:8000; 
proxy_http_version 1.1; 
proxy_set_header Host $host; 
proxy_set_header X-Real-IP $remote_addr; 
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; 
proxy_set_header X-Forwarded-Proto $scheme; 
            }
```
Nginx receives these requests and forwards to django.

The API interceptor is found under: `/Frontend/src/app/core/interceptors/`.

The frontend and backend images are built from the project`s own dockerfiles. The PostgreSQL uses the official postgreSQL image.

### Database persistence

PostgreSQL uses a named Docker volume:
```bash
volumes: 
    - postgres_data:/var/lib/postgresql/data
```
This ensures that database data is stored outside the temporary database container.
The data therefore remains available when the containers are removed and recreated, as long as the named volume is not deleted.

### rebuilding after modifications

After making modifications, the affected image needs to be rebuilt.

* For the frontend:
```bash
docker compose build frontend
docker compose up -d frontend
```
* For backend 
```bash
docker compose build backend
docker compose up -d backend
```
* Rebuild everthing at the same time
```bash
docker compose up -d --build
```
* Start and stop all containers:
```bash
docker compose up -d
docker compose down
```
The comand ` docker compose down` stops and removes the containers but keeps the named PostgreSQL volume.

* To start or stop the specific service:
```bash
docker compose up -d <service name>
docker compose  stop <service name>
```
For example:   `docker compose stop frontend`

* Remove the containers and Database data:
```bash
docker compose down -v
```
>**Warning**: Removing the volume deletes the stored progresSQL data

After the containers are running the application can be accessed in the browser at:
`htpp://<SERVER_IP>:8282`

## 4. Troubleshooting
* Frontend is not available.

Check the container status and logs:
```bash
docker compose ps
docker compose logs frontend
```
Make sure port 8282 is not already used by another application.
* Backend is not available.

Check the backend status and logs:
```bash
docker compose ps
docker compose logs backend
```
Verify that Gunicorn is running. The logs should be contain messages similar to:

`Starting gunicorn`
`Listening at: http://0.0.0.0:8000`

* Database connection errors

Check the status and logs of database:
```bash
docker compose ps
docker compose logs database
```
Verify that the `.env` values match between PostgreSQL and Django.
The backend should use:

``POSTGRES_HOST=database``
``POSTGRES_PORT=5432``

* Database tables are missing.
Run:
```bash
docker compose exec backend python manage.py migrate
```
Then reload the application.

* Changes are not visible

Rebuild the affected service:
```bash
docker compose up -d --build
```
Then reload the application on the browser.
to start the app for test in workflow .
Der erst test hat nicht funktioniert.