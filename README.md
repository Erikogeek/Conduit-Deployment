# Conduit-Deployment
This project focuses on deploying a full-stack web application consisting of a `Django backend` and an `Angular frontend` using a `GitHub Actions workflow`.
This is an extension of the previous `Conduit-Container`project.

The deployment process is automated through a CI/CD pipeline. Before deployment, the application container images are automatically built and pushed to the GitHub Container Registry (GHCR). The resulting containers are then deployed to a target cloud VM via SSH and started using Docker Compose.

The project demonstrates an automated and reproducible deployment process for a containerized full-stack application.
## Table of contents
- [1. Prerequisites](#Prerequisites)
- [2. project architecture](#project-architecture)
- [3. Quickstart](#2-Quickstart)
- [4. Usage](#Usage)
- [5. Deployment](#Deployment)

## 1. Prerequisites
To successfully set up and use this project, knowledge of the following technologies and software is recommended:
* Docker and Docker compose for building and managing the containers.
* Github and Github actions.
* A cloud VM 
* SSH access to the cloud VM.

For local development, Docker Desktop is recommanded.
## 2. Project architecture
The application uses the following deployment flow:

The developer changes the code, creates commit and pushes it to the repository. GitHub Actions then builds the application images, stores them in GitHub Container Register, and deploys them to a cloud VM through SSH. Docker Compose then starts the frontend, backend, and PostgreSQL services.

![Project architecture](images/conduit-deployment-architektur.png)

The Docker images are built by GitHub Actions. The cloud VM does not build the application images itself. It pulls the already-built images from GitHub Container Registry (GHCR).


## 3. Quickstart

* Clone the repository and change into the project directory:
```bash
git clone <REPOSITORY_URL>
`cd Conduit-Deployment`
```
* Create the environment file

Create `.env` based on `.env.example`and set the required variable values.

```bash
Copy-Item .env.example .env
```
The `.env` file contains configuration for the Docker images, ports, Django application, and PostgreSQL database.

* Building the containers:
```bash
cd /Conduit-Deployment/Frontend
docker buildx build --tag ghcr.io/<GITHUB_USERNAME>/conduit-frontend:latest .
```
```bash
cd /Conduit-Deployment/Backend
docker buildx build --tag ghcr.io/<GITHUB_USERNAME>/conduit-frontend:latest .
```
* Start manually and check the application:
```bash
docker compose up -d
docker compose ps
```
* CI/CD deployment

After changes are pushed in the `c-deployment`branch, the GitHub Actions workflow starts automatically.

Open the application in your browser:
| **local deployment** | **CI/CD deployment** |
| ---------------- | ---------------- |
| `http://localhost:8282` | `http://SERVER_IP:8282` |
 

## 4. Usage
After cloning the repository and create the `env.example` 
* Configure the `.env.example` file.

The configuration of env.example looks like:
| **variables** | **values** |
| --------- | --------- |
|POSTGRES_DB|Name of the postgreSQL database|
|POSTGRES_USER|postgreSQL database user|
|POSTGRES_PASSWORD|postgreSQLdatabase password|
|POSTGRES_PORT|postgreSQL port|
|DJANGO_SECRET_KEY|secret key used by django|
|DJANGO_DEBUG|enables or disables django debug mode|
|DJANGO_ALLOWED_HOSTS|hosts that django accepts|
|BACKEND_IMAGE|Backend Docker image|
|FRONTEND_IMAGE|Frontend Docker image|
|IMAGE_TAG|Docker image tag|
|FRONTEND_PORT|Host port for the frontend|
|BACKEND_PORT|Host port for the backend|

Example image configuration:
| **variables** | **values** |
| --------- | --------- |
|BACKEND_IMAGE|ghcr.io/erikogeek/conduit-backend|
|FRONTEND_IMAGE|ghcr.io/erikogeek/conduit-frontend|
|IMAGE_TAG|latest|

* Configure the `repository variables`

The GitHub Actions workflow uses the following repository variables:

| **variables** | **values** |
| --------- | --------- |
| BACKEND_IMAGE | ghcr.io/<github_username>/conduit-backend |
| FRONTEND_IMAGE | ghcr.io/<github_username>/conduit-frontend |
| IMAGE_TAG | latest |

|**repository secrets**|**meaning**|
| --------- | --------- |
| SSH_PRIVATE_KEY_B64| private deployment-key |
| SSH_HOST | Server-Adresse |
| SSH_USER | Server-username |

These values are configured under:

`GitHub -> Repository Settings -> Secrets and variables -> Actions -> Variables -> GitHub Repository Secrets`

* Git workflow

After making changes, commit and push them to the deployment branch:
 ```bash
git add <FILE_NAME>
```
```bash
git commit -m "<commit message>"
```
```bash
git push origin c-deployment
```
Pushing to `c-deployment` automatically triggers the GitHub Actions deployment workflow.
* Local docker image build

The Dockerfiles can also be tested locally.
```bash
docker buildx build --tag ghcr.io/erikogeek/conduit-frontend:latest .
docker buildx build --tag ghcr.io/erikogeek/conduit-backend:latest .
docker build --tag conduit-frontend .
docker build --tag conduit-backend .
```
The `.` at the end specifies the current directory as the Docker build context.
`Buildx` is used because the github actions workflow uses `Docker Buildx`.
| **elements** | **meaning** |
| -------- | ------ |
| ghcr.io | github container registry |
| <GITHUB_USERNAME> | github username of organization |
| conduit-frontend | docker image name |
| latest | docker image tag |
| `.`| the docker build context |

The result these commands ensures if everything is running successfully or more changes are required. After pushing and succesfull building of images, the deployment starts automatically.

## 5. Deployment

 The deployment uses the file named `deployment.yaml` in `.github/workflows/deployment.yaml`. 
 
 The workflow contains two jobs:
* Build

The `build`job performs the following steps:

| **step** | **activity** |
| -------- | ------------ |
| 1. | check out the repository |
| 2. | Logs in to GitHub Container Registry|
| 3. | Builds the Django backend Docker image|
| 4. | Pushes the backend image to GHCR|
| 5. | Builds the Angular frontend Docker image.|
| 6. | Pushes the frontend image to GHCR. |

The images are tagged using the configured github repository variables:

`ghcr.io/<GITHUB_USERNAME>/conduit-frontend:latest`

`ghcr.io/<GITHUB_USERNAME>/conduit-backend:latest`

* Deploy

The `deploy` job runs after the `build` job succeeds.

The deployment performs the following steps:

| ` step` | ` activity` |
| -------- | ------ |
| 1. | Creates the SSH key from the configured GitHub secret |
| 2. | Connects to the cloud VM using SSH|
| 3. | Updates the repository on the VM|
| 4. | Pulls the latest Docker images from GHCR |
| 5. | Starts the application with Docker Compose |

The deployment commands executed on the cloud VM are:
```bash
cd ~/Conduit-Deployment
ssh -i ~/.ssh/deployment_key "$SSH_USER@$SSH_HOST"
git pull origin c-deployment
docker compose pull
docker compose up -d
```
The deployment job depends on the build job:

`needs: build`

This ensures that deployment only starts after the images have been successfully built and pushed to GHCR.

After deployment, the frontend is available on `port 8282` of the host system.use: `http://<VM-IP>:8282`

The resulting setup provides a reproducible CI/CD deployment process for the full-stack application.