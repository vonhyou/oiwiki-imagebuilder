This repository contains a CI pipeline and a docker file that builds Alpine-based images for [OI Wiki](https://github.com/OI-wiki/OI-wiki).

## What This Does

The pipeline clones the official OI Wiki repository and builds a static site served by nginx. The build runs weekly on a private Forgejo instance and pushes images to Docker Hub and GitHub Container Registry.

## Modifications

The build process removes two components from the upstream project:

- Feedback system placeholders 
- Giscus comment system 

These changes eliminate HTTP 404 errors and reduce external dependencies. The core documentation remains unchanged.

## Quick Start

### Using Docker

Pull from Docker Hub:

```bash
docker pull vonhyou/oiwiki:latest # alternatively: ghcr.io/vonhyou/oiwiki:latest
docker run -d -p 2333:80 vonhyou/oiwiki:latest
```

Access the site at http://localhost:2333

### Using Docker Compose

Create a [`compose.yaml`](./compose.yaml) file:

```yaml
---
services:
  oiwiki:
    image: vonhyou/oiwiki:latest
    container_name: oiwiki
    ports:
      - "2333:80"
    restart: unless-stopped
```

> Note: if you use traefik as your reverse proxy, please refer to [compose.traefik.yaml](./compose.traefik.yaml)

Run the service:

```bash
docker compose up -d 
```

## Image Building

Images are rebuilt automatically every sunday at 2 A.M. UTC, or triggered manually. 

### Local Development Build

Build and test locally:

```bash
docker build -f Dockerfile -t oiwiki:local .
docker run -d -p 2333:80 oiwiki:local
```


### Migrate to Github Action

If you prefer to build the image on your own infrastructure or on Github, simply rename `.forgejo` folder to `.github`. The pipeline syntax is compatible with GitHub Actions.

```bash
# Remember to fork the repo

mv .forgejo .github
git add .
git commit -m "Switch to GitHub Actions"
git push
```

**Add a new repository variable**
  - Name: `NAME_PUBLIC`
  - Value: `your-dockerhub-username/your-image-name`

  Example: `vonhyou/oiwiki`

**Configure these secrets in your GitHub repository settings:**

  - `DOCKERHUB_USERNAME` - Docker Hub username
  - `DOCKERHUB_TOKEN` - Docker Hub access token
  - `GH_USERNAME` - GitHub username
  - `GH_TOKEN` - GitHub personal access token with write:packages permission

If you only want to push to one registry, you can remove the unused login and modify the tag generation accordingly. And for Github action, it's safe to remove the `Install Docker CLI` part in the pipeline. 

The workflow will run automatically on the same schedule.

## Credits

All documentation content belongs to the OI Wiki Team and the contributors at <https://github.com/OI-wiki/OI-wiki> .

This repository only provides the build automation. No content is claimed or modified beyond the removal of interactive features that require external services.
