# 42_Inception
## Project intro
- Intro
    - Part of the DevOps track, intro to
        - System admin
        - Virtualization
        - Containerization with Docker
        - Service orchestration with Docker Compose
        - Security & deployment best practices
- Main tasks
    - Construct a mini infra composed of several services, all running in containers, and managed via Docker Compose, incl.
        - A web server (eg. NGINX)
        - A database (eg. MariaDB)
        - A content mgmt system (eg. WordPress)
        - A reverse proxy
        - Bonus: redis, adminer, static websites, monitoring tools
- Key concepts
    - Docker: how to containerize services - create dockerfiles, manage images and containers
    - Docker Compose: how to orchestrate multiple services together
    - Volumes & networking: persist data and securely manage internal/ external access
    - Environment isolation: ensure each service is independent but can communicate via networks
    - Security: set strong pwd, limit permissions, use HTTPS
    - Automation: automate builds and service restarts
- Project constraints
    - Everything must run inside containers.
    - You cannot use pre-built images (like official WordPress or MariaDB ones).
    - You must build each service image yourself.
    - Data must persist even when containers are restarted.
    - Services must be reachable only via defined ports or internal Docker networks.
    - Some security best practices are enforced (e.g., HTTPS, non-root users).
- Bonus
    - Redis for caching
    - Portainer for managing containers visually
    - Adminer or phpMyAdmin for database UI
    - Email service, FTP, monitoring, etc.

## Notes
### What's docker, docker compose?


