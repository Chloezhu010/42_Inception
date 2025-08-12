NAME = Inception
DOCKER_COMPOSE = docker compose
DOCKER_COMPOSE_FILE = docker-compose.yml

.PHONY: kill build log down clean restart

build:
	@$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE) up -d --build

kill:
	@$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE) kill

down:
	@$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE) down

log:
	@$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE) logs

clean:
	@$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE) down -v

fclean: clean
	@docker system prune -a -f
	@docker volume prune -f
	@docker network prune -f
	@docker builder prune -a -f

restart: clean build