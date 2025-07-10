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
### What's docker？
Intro 
- Docker is a popular open-source project written in go and developed by Dotcloud (A PaaS Company).
- It is **a container engine that uses the Linux Kernel features** like namespaces and control groups to create containers on top of an operating system. So you can call it OS-level virtualization.

The problem docker solves: "it works on my machine"
- Developers often face the problem of their code working perfectly on their own machine, but then breaking when deployed to a testing environment, production server, or even another developer's machine. This is usually due to differences in operating system versions, installed libraries, dependencies, or configurations.

The solution: containers
- Docker addresses this by creating containers. Think of a container as a lightweight, standalone, executable package that includes everything an application needs to run:
    - Code: Your app's source code
    - Runtime: The env needed to run the code (eg. Python, Nodejs, JVM)
    - System tools: Any utilities or cmd-line tools that app relies on
    - System lib: Shared lib required by the app
    - Settings & dependencies: Config files and other software componenets
- Because the container includes everything, the application will run the same way, regardless of the underlying environment (your laptop, a cloud server, another developer's machine).

How docker works


### What's docker compose?
Intro
- Docker Compose is a tool for defining and running **multi-container applications**.

The problem docker compose solves
- Imagine you're building a web app. It likely needs
    - A web server (e.g., Nginx, Apache) to serve static files and act as a reverse proxy.
    - A backend API (e.g., Node.js, Python Flask, Java Spring Boot) to handle business logic.
    - A database (e.g., PostgreSQL, MySQL, MongoDB) to store data.
    - Perhaps a caching service (e.g., Redis) for performance.
- Manually starting and linking each of these containers with docker run commands can become cumbersome, error-prone, and difficult to reproduce. This is where Docker Compose shines.

How docker compose works
- The ```docker-compose.yml``` File
    - The core of Docker Compose is a YAML file, where you define your app's service. This file acts as a blueprint for your entire app stack, where you specify:
        - Services: Each service represents a container for a specific part of your app (eg. web, api, database). For each service, you define:
            - The docker image to use
            - How to build the image from a dockerfile
            - Port mapping
            - Env variable
            - Volumes for persistent data storage
            - Dependencies on other services
            - Network config
        - Networks: Define customer networks for your services to communicate over
        - Volumes: Define named vol for persistent data, independent of the container's lifecycle
- Single cmd to rule them all
    - Once your docker-compose.yml file is set up, you can bring your entire application stack up or down with a single command:
    - ```docker compose up```: This command reads your ```docker-compose.yml``` file, builds any necessary images, creates the defined networks and volumes, and starts all the services in the correct order. It also sets up inter-container communication.
    - ```docker compose down```: This command stops and removes all containers, networks, and volumes defined in your ```docker-compose.yml``` file.

Key benefits of docker compose
- Simplified orchestration: No need for ```docker run``` cmd for each service
- Reproducibility: App can run consistently across different env
- Ease of development: Developers can quickly spin up an entire application environment with all its dependencies with just one command
- Modularity: promote a miroservice architecture by making it easy to define and manage independent services

### Difference btw a docker image used with and without docker-compose

### Benefit of docker compared to VMs

### Reference
- [Docker docs](https://docs.docker.com/get-started/docker-overview/)
- [What's Docker? How does it work?](https://devopscube.com/what-is-docker/)