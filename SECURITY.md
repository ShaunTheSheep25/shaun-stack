# Security Notes

## Key Features Covered/Used

- **Base Image:** All three services use `python:3.11-slim` as the runtime base image, which is a less-memory heavy variant excludes compilers, documentation + non-essential OS packages, thus lowering the performance overload as compared to the full Python image.
Here, gcc is installed only in the builder stage and is never carried into the runtime image.

- **Secrets:** No secrets are hardcoded in any Dockerfile or in the docker-compose.yml file in shaun-stack. Each service documents its required environment variables in a `.env.example` file (but at production level, these environmental variables would be revealed via a secrets manager). The GHCR_TOKEN used in CI is stored as a GitHub Actions repository secret and never printed in logs/exposed in image layers.

- **Image publishing:** Images are published to GHCR only on a git tag push, not on every commit. The publish job uses a Personal Access Token (PAT) with the write:packages scope stored as a GitHub Actions secret.

---

## OWASP Docker Top 10 Self-Assessment

Given below is my honest assessment of my "service-deploying" application implemented via Docker in shaun-stack, in comparison to the OWASP Docker Top 10 parameters. Do keep in mind that I've graded these based off the fact that this was given to me as an internship task, and that on a larger scale, the ways I've implemented the containerization wouldn't hold up, and I would need to go about this in a different way.

### D01 — Secure user mapping
**Status: NOT MET**

All three containers run as root by default, implying that if an attacker exploits a vulnerability in the application, they have root
access inside the container. TO fix this, I would add a non-root user to each Dockerfile:

```dockerfile
RUN useradd --create-home appuser
USER appuser
```

### D02 — Patch management strategy
**Status: PARTIALLY MET**

The base image `python:3.11-slim` is pinned to a specific Python version, which gives reproducibility. However there is no automated
image scanning or scheduled rebuild to pick up OS-level security patches in the base image. I would suggest adding Trivy or Snyk scanning to CI, and set up a weekly rebuild trigger to automate patching in the image.

### D03 — Network segmentation
**Status: PARTIALLY MET**

All three services share a single Docker network (`shaun-net`), which means they can all talk to each other freely. For this internship project that's acceptable, but in production each service should only be able to reach the services it genuinely needs to talk to.

### D04 — Secure defaults
**Status: MET**

Services bind to `0.0.0.0` inside the container (required for docker-compose port mapping) but are only exposed on localhost ports
8001-8003 on the host machine. No unnecessary ports are exposed + the slim base image ships with minimal default packages.

### D05 — Maintain security contexts
**Status: NOT MET**

No Linux security profiles (AppArmor/seccomp) are configured in the docker-compose.yml. These restrict what system calls a container
can make, limiting damage if a container is compromised. Docker does apply a default seccomp profile automatically, which provides some baseline protection, but no custom hardening has been applied. Ideally I'd look into this as one of the first steps, especially if I was bringing this up to production level where security of the working containers is of utmost importance.

### D06 — Protect secrets
**Status: PARTIALLY MET**

No secrets are hardcoded in Dockerfiles or committed to version control. However, senpai-lessons has a hardcoded SECRET_KEY in
auth.py which would need to be moved to an environment variable before any real deployment. The `.env.example` pattern documents
what secrets are needed without exposing values (as all .env files are ignored when pushing thanks to .gitignore).

### D07 — Resource limiting
**Status: NOT MET**

No CPU or memory limits are set on containers in docker-compose.yml. If not checked, while building the image, a container could consume all available host resources. I'd fix this by adding resource limits to each service in docker-compose.yml:

```yaml
deploy:
  resources:
    limits:
      memory: 256M
      cpus: "0.5"
```

### D08 — Share volumes and filesystems carefully
**Status: MOSTLY MET**

Named volumes are used for database files rather than bind mounts, which is the safer method to go about this. No host directories are mounted into containers. However, atabase files in volumes are not encrypted at rest, which would be a concern in production.

### D09 — Monitor container activity
**Status: NOT MET**

No runtime monitoring or anomaly detection is configured. In production you would want container-level logging sent to a
centralised log management system and alerting on unusual activity. structlog is used in senpai-lessons for
structured application logging, which is a good foundation, but there is no container-level monitoring for immediate, accurate detection.

### D10 — Image provenance and integrity
**Status: PARTIALLY MET**

Images are built from source in CI and published to GHCR with version tags, giving a clear audit trail of what code went into each image. However, image signing (Docker Content Trust/Sigstore) is not configured, so there is no cryptographic proof that a pulled image hasn't been tampered with.

In my opinion, the most important deliverables to address before any real deployment would be D01 (non-root user), DO5 (maintaining container security), D06 (move SECRET_KEY to environment variable) and D07 (resource limits), as these have the most direct impact on security and stability.