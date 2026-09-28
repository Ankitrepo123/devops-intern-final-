# DevOps Intern Final Assessment

**Name:** Ankit Kumar  
**Submission Date:** 2026-09-28

[![CI](https://github.com/Ankitrepo123/devops-intern-final/actions/workflows/ci.yml/badge.svg)](https://github.com/Ankitrepo123/devops-intern-final/actions/workflows/ci.yml)

---

## Architecture

```text
                    +------------------+
                    |   GitHub Repo    |
                    |   Source Code    |
                    +--------+---------+
                             |
                             v
                    +------------------+
                    | GitHub Actions   |
                    | CI/CD Pipeline   |
                    +--------+---------+
                             |
                    +--------+--------+
                    |                 |
                    v                 v
                 Lint/Build/Test    GHCR
                                     |
                                     v
                            +----------------+
                            |     Nomad      |
                            | Docker Driver  |
                            +-------+--------+
                                    |
                                    v
                            +----------------+
                            | NGINX App      |
                            +-------+--------+
                                    |
                                    v
                            +----------------+
                            |    Promtail    |
                            +-------+--------+
                                    |
                                    v
                            +----------------+
                            |      Loki      |
                            +-------+--------+
                                    |
                                    v
                            +----------------+
                            |    Grafana     |
                            +----------------+
Prerequisites

The following tools are required:

Git
Docker Desktop with Linux containers
GitHub account
GitHub Container Registry access
Nomad
Consul
curl
ShellCheck
Hadolint
Quick Start

Clone the repository:

git clone https://github.com/Ankitrepo123/devops-intern-final.git
cd devops-intern-final

Build the application:

docker build --build-arg BUILD_SHA=local-dev -t devops-intern-final:local ./app

Run the application:

docker run -d --name devops-intern-nginx -p 8080:8080 devops-intern-final:local

Check the application:

curl http://localhost:8080/

Check the health endpoint:

curl http://localhost:8080/healthz

Run the healthcheck script:

./scripts/healthcheck.sh http://localhost:8080/healthz

Expected result:

Healthcheck passed: HTTP 200
Task 1 — Git Repository and Version Control

The project uses incremental commits and conventional commit prefixes including:

feat
fix
docs
ci

Development work is performed using feature branches.

Example:

git checkout -b feature/final-documentation

Changes are merged into main through a Pull Request.

The final submission is tagged:

git tag v1.0.0
Task 2 — System Information and Healthcheck Scripts

The scripts are located under:

scripts/
├── sysinfo.sh
└── healthcheck.sh
System Information

Run:

./scripts/sysinfo.sh

The script reports:

Current user
Effective UID
Hostname
Kernel release
ISO-8601 system date
Disk usage
Memory usage
Docker daemon status

Example:

=== System Information ===
Current user: <user>
Effective UID: <uid>
Hostname: <hostname>
Kernel release: <kernel>
System date: <ISO-8601 date>

=== Disk Usage ===
...

=== Memory Usage ===
...

=== Docker Daemon ===
Docker daemon: running
Application Healthcheck

Run:

./scripts/healthcheck.sh

The default target is:

http://localhost:8080

A custom URL can also be supplied:

./scripts/healthcheck.sh http://localhost:8080/healthz

The script returns exit code 0 when HTTP status 200 is received and a non-zero exit code otherwise.

Task 3 — Containerization

The application is containerized using:

nginx:1.27-alpine

The Dockerfile is located at:

app/Dockerfile

Build the image:

docker build --build-arg BUILD_SHA=local-dev -t devops-intern-final:local ./app

Run the container:

docker run -d --name devops-intern-nginx -p 8080:8080 devops-intern-final:local

Check the application:

curl http://localhost:8080/

Check the health endpoint:

curl http://localhost:8080/healthz

The NGINX configuration:

Uses port 8080
Provides /healthz
Runs NGINX as a non-root user
Includes a Docker HEALTHCHECK
Exposes port 8080

The build ID is injected using the Docker build argument:

BUILD_SHA

Example:

docker build \
  --build-arg BUILD_SHA=local-dev \
  -t devops-intern-final:local \
  ./app
Task 4 — CI/CD with GitHub Actions

The CI workflow is located at:

.github/workflows/ci.yml

The workflow runs on:

Pushes to main
Pull Requests targeting main

The pipeline contains the following stages:

Lint
  |
  v
Build
  |
  v
Test
  |
  v
Publish
Lint

The pipeline runs:

ShellCheck
Hadolint
Build

The Docker image is built using the GitHub commit SHA:

BUILD_SHA=${GITHUB_SHA}
Test

The workflow:

Builds the application image
Starts the container
Waits for readiness
Runs the application healthcheck
Fails if HTTP 200 is not returned
Publish

Images are published to GitHub Container Registry when changes are pushed to main.

Image format:

ghcr.io/ankitrepo123/devops-intern-final:<commit-sha>

The latest image is also tagged:

ghcr.io/ankitrepo123/devops-intern-final:latest

The workflow uses GITHUB_TOKEN for registry authentication.

Task 5 — Nomad Deployment

The Nomad job specification is located at:

nomad/nginx-app.nomad.hcl

The Docker image tag is parameterized using:

image_tag
Validate
nomad job validate -var="image_tag=latest" nomad/nginx-app.nomad.hcl
Plan
nomad job plan -var="image_tag=latest" nomad/nginx-app.nomad.hcl
Run
nomad job run -var="image_tag=latest" nomad/nginx-app.nomad.hcl

The job configuration includes:

Service-type Nomad job
Docker driver
One task group
One NGINX task
100 MHz CPU
64 MB memory
Dynamic HTTP port
Container port 8080
Consul service registration
HTTP healthcheck at /healthz
10-second healthcheck interval
2-second healthcheck timeout
Restart policy
Reschedule policy
Rolling update configuration
max_parallel = 1
min_healthy_time = "10s"
healthy_deadline = "2m"
auto_revert = true
Local Environment Note

The Nomad job requires a Linux-compatible Nomad Docker driver environment because the application image uses the Linux-based NGINX Alpine image.

Task 6 — Loki Observability

The observability stack is located under:

monitoring/
├── loki-config.yaml
├── promtail-config.yaml
├── docker-compose.yaml
└── loki_setup.md

The stack contains:

Promtail
    |
    v
  Loki
    |
    v
 Grafana
Start the Stack
docker compose -f monitoring/docker-compose.yaml up -d

Check the services:

docker compose -f monitoring/docker-compose.yaml ps

Expected services:

loki
promtail
grafana
Loki Readiness
curl http://localhost:3100/ready

Expected:

ready
Grafana

Open:

http://localhost:3000

Configure Loki as a Grafana data source using:

http://loki:3100

The Docker Compose service name loki is used for communication between Grafana and Loki.

Promtail Labels

Promtail is configured with:

job
container
service
nomad_alloc_id
LogQL Examples

All Docker logs:

{job="docker"}

NGINX application logs:

{job="docker", service="nginx-app"}

To generate a missing-path request:

curl -i http://localhost:8080/missing-path

Expected response:

HTTP/1.1 404 Not Found

The detailed Loki setup and troubleshooting information is available in:

monitoring/loki_setup.md
Troubleshooting
1. Nomad Docker Driver

The Windows Nomad client reported an unhealthy Docker driver while Docker Desktop was configured to use Linux containers.

The Nomad job is therefore configured for a Linux-compatible Docker driver environment.

The application itself remains based on the required Linux NGINX image.

2. NGINX Non-Root Permission

During container testing, NGINX initially failed because it could not create its PID file with non-root permissions.

The NGINX configuration was updated to use:

/tmp/nginx.pid

Temporary NGINX paths were also configured under /tmp.

This allows the application to run as a non-root user.

3. GHCR Image Naming

The initial GitHub Actions workflow encountered a GHCR image naming issue because the GitHub repository owner contained uppercase characters.

The workflow now converts the repository owner to lowercase before constructing the image name.

Example:

ghcr.io/ankitrepo123/devops-intern-final
Known Limitations
Local Nomad execution requires a Linux-compatible Nomad Docker driver environment.
The monitoring configuration is designed around Docker container logs.
The repository provides commands for reproducing the Nomad and observability setup.
The final repository should be reproduced from a clean clone using the documented commands.
Project Structure
devops-intern-final/
├── README.md
├── .gitignore
├── app/
│   ├── Dockerfile
│   ├── index.html
│   └── nginx.conf
├── scripts/
│   ├── sysinfo.sh
│   └── healthcheck.sh
├── .github/
│   └── workflows/
│       └── ci.yml
├── nomad/
│   └── nginx-app.nomad.hcl
├── monitoring/
│   ├── loki-config.yaml
│   ├── promtail-config.yaml
│   ├── docker-compose.yaml
│   └── loki_setup.md
└── docs/
    └── screenshots/
Submission

Final submission should contain:

Public GitHub repository
Passing CI workflow
Completed README
Required source files and configurations
Feature branch merged into main through a Pull Request
Final release tag:
v1.0.0

Repository:

https://github.com/Ankitrepo123/devops-intern-final
