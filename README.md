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
    - Use penultimate version of Alpine or Debian.
    - Everything must run inside containers.
    - You cannot use pre-built images (like official WordPress or MariaDB ones).
    - You must build each service image yourself.
    - Data must persist even when containers are restarted.
    - Use docker compose to orchestrate everything.
    - Services must be reachable only via defined ports or internal Docker networks.
    - Some security best practices are enforced (e.g., HTTPS, non-root users).
- Bonus
    - Redis for caching
    - Portainer for managing containers visually
    - Adminer or phpMyAdmin for database UI
    - Email service, FTP, monitoring, etc.
## My approach
- Setup project file structure
```
42_inception/
├── .env                       # Shared environment variables (DB, WP, etc.)
├── docker-compose.yml         # Main orchestrator for all services
├── srcs/                      # All build sources
│
├── srcs/requirements/
│   ├── mariadb/
│   │   ├── Dockerfile
│   │   ├── tools/
│   │   │   └── init_mariadb.sh
│   │   ├── conf/
│   │   │   └── custom.cnf       # Optional MariaDB config override
│   │   └── .dockerignore        # Optional: ignore temp files, logs
│
│   ├── wordpress/
│   │   ├── Dockerfile
│   │   ├── tools/
│   │   │   └── init_wordpress.sh
│   │   ├── conf/
│   │   │   └── wp-config.php     # Or copied/generated in script
│   │   └── .dockerignore
│
│   ├── nginx/
│   │   ├── Dockerfile
│   │   ├── conf/
│   │   │   └── default.conf      # NGINX site config
│   │   ├── tools/
│   │   │   └── entrypoint.sh     # Optional: custom logic
│   │   └── .dockerignore
│
│   ├── bonus/                    # (optional) static site, redis, etc.               
│
└── README.md
```
- Base OS choice: Debian bookworm
    - Debian release stable version: https://www.debian.org/releases/
- Build docker image for each service
    - Start with MariaDB
        - Why first
            - WordPress depends on a database exist before it can connect, init, or install
            - It's a stateful service - needs volume, credentials, and presistant storage setup
        - What to do
            - Set up user, password, database
            - Store credentials in `.env`
            - Expose internal port
            - Test that the DB container runs correctly
        - Test cmd
            ```
            // test root login to MariaDB
            docker exec -it mariadb mysql -u root -p{RootPwd}

            // run SQL checks inside MariaDB
            SHOW DATABASES; // check the database was created
            SELECT user, host FROM mysql.user; // check users
            SHOW GRANTS FOR 'wpuser'@'%'; // check permissions
            exit; // exit mariadb

            // test user login to MariaDB
            docker exec -it mariadb mysql -u wp_user -p{UserPwd}

            // verify persistence
            docker compose down // stop everything
            docker compose up mariadb // restart
            // reconnect and confirm the DB is still there

            // complete reinitialize
            docker compose down
            docker volume rm $(docker volume ls -q | grep mariadb)
            docker compose up mariadb
            ```
    - Then Nginx (Reverse Proxy / Web Server)
        - Why second
            - NGINX is the **entry point** to your app — it handles HTTPS and routing.
            - You can test it **without WordPress** by serving a static page.
            - It's useful to validate:
            - SSL/TLS configuration
            - HTTP to HTTPS redirection
            - Port exposure
            - Docker networking
        - What to do
            - Serve a test `index.html`
            - Generate and use self-signed TLS certificates
            - Configure reverse proxy (FastCGI or PHP backend later)
    - Finally WordPress (PHP app)
        - Why last
            - WordPress needs **both the database and NGINX** to function:
            - It connects to MariaDB to initialize and load content
            - It’s proxied through NGINX
            - Installing WordPress early would result in connection errors
        - What to do
            - Download WordPress manually (no Docker Hub)
            - Set up `wp-config.php` using env vars for the DB
            - Mount a volume for persistent content
            - Confirm full setup via browser (localhost)

## Notes
### What's mariaDB, wordpress, nginx? 
- MariaDB - the filing cabinet with all the info
    - A db server (fork of Mysql)
    - Store your data for wordpress, eg. blog post, user, comments, settings etc.
    - Without it, wordpress won't have a place to keep dynamic content
- Wordpress - the actual service team doing the work
    - A php-based web app (a CMS: content manager system)
    - It's the actual website you'll access through your browser
    - Connect to mariaDB to save & retrieve data
- Nginx - the front desk
    - A web server: it listens for incoming HTTP(S) requests
    - Server static content (html, css, js, image) and forward php requests to wordpress
    - Here it's also used to termiante SSL

### What's docker？
#### Intro 
- Docker is a popular open-source project written in go and developed by Dotcloud (A PaaS Company).
- It is **a container engine that uses the Linux Kernel features** like namespaces and control groups to create containers on top of an operating system. So you can call it OS-level virtualization.

#### The problem docker solves: "it works on my machine"
- Developers often face the problem of their code working perfectly on their own machine, but then breaking when deployed to a testing environment, production server, or even another developer's machine. This is usually due to differences in operating system versions, installed libraries, dependencies, or configurations.

#### The solution: containers
- Docker addresses this by creating containers. Think of a container as a lightweight, standalone, executable package that includes everything an application needs to run:
    - Code: Your app's source code
    - Runtime: The env needed to run the code (eg. Python, Nodejs, JVM)
    - System tools: Any utilities or cmd-line tools that app relies on
    - System lib: Shared lib required by the app
    - Settings & dependencies: Config files and other software componenets
- Because the container includes everything, the application will run the same way, regardless of the underlying environment (your laptop, a cloud server, another developer's machine).

#### How docker works
- Docker uses a client-server architecture. 
    - The Docker client talks to the Docker daemon, which does the heavy lifting of building, running, and distributing your Docker containers. 
    - The Docker client and daemon can run on the same system, or you can connect a Docker client to a remote Docker daemon. 
    - The Docker client and daemon communicate using a REST API, over UNIX sockets or a network interface. 
    - Another Docker client is Docker Compose, that lets you work with applications consisting of a set of containers.
    ![alt text](<Docker Architecture.webp>)
- The Docker Daemon
    - Docker Daemon (dockerd) or server is responsible for all the actions related to containers.
    - The Docker daemon listens for Docker API requests and manages Docker objects such as images, containers, networks, and volumes.
    - A daemon can also communicate with other daemons to manage Docker services.
- The Docker Client
    - The Docker client (docker) is the primary way that many Docker users interact with Docker. - When you use commands such as ```docker run```, the client sends these commands to dockerd, which carries them out.
    - The docker command uses the Docker API. The Docker client can communicate with more than one daemon.
- Docker registries
    - A Docker registry stores Docker images. 
    - Docker Hub is a public registry that anyone can use, and Docker looks for images on Docker Hub by default. You can even run your own private registry.
- Docker objects
    - Images
        - An image is a read-only template with instructions for creating a Docker container.
        - It contains the OS libraries, dependencies, and tools to run an application.
        - Images can be prebuilt with application dependencies for creating containers.
            - For example, if you want to run an Nginx web server as a Ubuntu container, you need to create a Docker image with the Nginx binary and all the OS libraries required to run Nginx.
        - Dockerfile
            - Used for building the image
            - It's a txt file that contains one command per line
    - Containers
        - A container is a runnable instance of an image. 
        - Containers can be started, stopped, committed, and terminated.
        - Ideally, containers are treated as immutable objects, and it is not recommended to make changes to a running container. 

### What's docker compose?
#### Intro
- Docker Compose is a tool for defining and running **multi-container applications**.

#### The problem docker compose solves
- Imagine you're building a web app. It likely needs
    - A web server (e.g., Nginx, Apache) to serve static files and act as a reverse proxy.
    - A backend API (e.g., Node.js, Python Flask, Java Spring Boot) to handle business logic.
    - A database (e.g., PostgreSQL, MySQL, MongoDB) to store data.
    - Perhaps a caching service (e.g., Redis) for performance.
- Manually starting and linking each of these containers with docker run commands can become cumbersome, error-prone, and difficult to reproduce. This is where Docker Compose shines.

#### How docker compose works
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

#### Key benefits of docker compose
- Simplified orchestration: No need for ```docker run``` cmd for each service
- Reproducibility: App can run consistently across different env
- Ease of development: Developers can quickly spin up an entire application environment with all its dependencies with just one command
- Modularity: promote a miroservice architecture by making it easy to define and manage independent services

### Difference btw a docker image used with and without docker-compose
- Without docker compose
    - Manual building
    - Manual running
    - Complex for multi-container apps
- With docker compose
    - Declarative definition: all defined in a single yml file
    - Auto building
    - Simplified orchestration
    - Manage the entire app stack

### Benefit of docker compared to VMs
- The main difference between Docker (containers) and Virtual Machines (VMs) is in how they isolate and run applications:
- VM
    - A VM is an entire operating system with its own kernel, hardware drivers, programs, and applications. 
    - Each VM runs on virtualized hardware, which means spinning up a VM involves significant overhead because it replicates a full OS environment for each instance.
- Docker
    - A container is simply an isolated process with all the files it needs to run, but it shares the host system's kernel.
    - Containers are much **more lightweight than VMs** because they don't require a full OS for each instance. 
    - This allows you to run more applications on the same infrastructure, with less overhead.
    - Containers are also **portable, self-contained, and isolated from each other and the host**, making them ideal for consistent development and deployment across environments.
### PID 1 and relation with Dockerfile
- What's PID 1?
    - In Linux, every running process has a Process ID (PID).
    - The first process in any Linux system or container always has PID 1.
    - This process becomes the "init process", responsible for:
        - Reaping zombie processes (defunct children)
        - Passing/handling signals (e.g., SIGTERM, SIGINT)
- In Docker, what's PID 1?
    - When a container starts, whatever command you define as the entrypoint or CMD becomes PID 1 inside that container.
    - Example: ```CMD ["nginx", "-g", "daemon off;"]```
        - Here nginx becomes PID 1
- Why this matters in Dockerfile
    - Most processes aren’t written to behave like a proper ```init```
    - They don’t forward signals correctly
    - They don’t reap zombie child processes
    - This leads to:
        - Containers not shutting down cleanly
        - Memory leaks (zombie processes)
        - Services that hang on ```docker stop```
- Best practices for Dockerfile PID 1
    - Use a proper init system if needed
        - Use a tiny init system like ```tini```
        - Example: tini becomes PID 1 and handles signals + zombie reaping properly.
            ```
            ENTRYPOINT ["/tini", "--"]
            CMD ["your-app"]
            ```
    - One process per container (when possible)
        - Docker is designed for single-process containers
- How to test PID 1
    - Inside a container
        ```
        ps -e -o pid,ppid,cmd
        ```
    - Or run
        ```
        docker exec <container> ps -p 1 -o cmd=
        ```
### What's Docker Volume
A **Docker volume** is a way to **store data outside your container’s filesystem**, so that the data:

- ✅ Survives container restarts
- ✅ Persists even if the container is deleted
- ✅ Can be shared between multiple containers
#### Why Use Volumes?

By default, when a Docker container is removed, all its data is **lost** — including:

- WordPress uploads
- MySQL databases
- Logs and configuration changes

If you want this data to persist between builds, you need to use a **volume**.
#### Example: Volume in `docker-compose.yml`

```yaml
services:
  mariadb:
    build: ./mariadb
    volumes:
      - mariadb_data:/var/lib/mysql

volumes:
  mariadb_data:
```
### Why install ```mariadb-server``` not ```mariadb```
mariadb-server is the actual database server package
- The mariaDB daemon (```mysqld```): the core process that runs the database
- Startup scripts to manage the service
- Config templates (eg. ```/etc/mysql/```)
- Dependencies like client lib and tools
### Principle of least privilege
Running as ```root``` inside containers is a major security vulnerability:
- Container Escape: If someone exploits your MariaDB and the container is running as root, they get root access to the host system
- File System Access: Root can read/write ANY file on mounted volumes
- Process Privileges: Root can kill other processes, change system settings
- Network Access: Root can bind to privileged ports (<1024)
### What's ```mysqld_safe```
- It’s a shell script provided by MySQL and MariaDB.
- Its job is to safely start the mysqld daemon (the actual database server process).
- It includes extra checks, logging, and crash recovery features.
- Compared to ```mysqld```

    | Feature                         | `mysqld_safe`                      | `mysqld`         |
    | ------------------------------- | ---------------------------------- | ---------------- |
    | Starts `mysqld`                 | ✅                                  | ✅                |
    | Restarts `mysqld` if it crashes | ✅ Automatically restarts it        | ❌ Only runs once |
    | Handles logs                    | ✅ Redirects to log files safely    | ❌ Basic logging  |
    | Reads extra config              | ✅ Can read from `/etc/my.cnf` etc. | ✅                |
    | Runs in background              | ✅ (uses `nohup`, forked)           | ✅ or foreground  |
### What's diff btw MariaDB and WordpressDB
- Think of MariaDB like a filing cabinet:
    - The cabinet itself = MariaDB server.
    - One drawer inside it = the WordPress database.
- How they interact
    - WHen wordpress starts up, it connects to mariaDB using credentials (MYSQL_USER & MYSQL_PASSWORD) and the database name (MYSQL_DATABASE) from the .env
    - All wordpress's dynamic data (posts, comments, settings) goes into tables inside that database
### Useful cmd line
- `docker compose up -d`: start all service in the yml file, run containers in the background (detached mode)
- `docker compose up -d --build`: rebuild & run
- `docker compose logs -f mariadb`: check logs 
- `docker exec -it mariadb mariadb -u root -p`: check inside mariadb
    ```
    SHOW DATABASES;
    SELECT user, host FROM mysql.user;
    ```
    Should see: wordpress db, normal user, admin user
- `docker exec -it wordpress php -v`: check php version
- `docker exec -it wordpress ls /var/www/wordpress`: list all items in the wordpress folder




### Reference
- [Docker docs](https://docs.docker.com/get-started/docker-overview/)
- [What's Docker? How does it work?](https://devopscube.com/what-is-docker/)