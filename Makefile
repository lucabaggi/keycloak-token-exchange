.PHONY: help

help: ## ;-)
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

up: ## up with compose
	mkdir -p postgres_data 2>/dev/null >/dev/null
	docker-compose -f docker-compose.yml up

down: ## down with compose
	docker-compose -f docker-compose.yml down

clean: ## clean with compose
	docker-compose -f docker-compose.yml down --rm all

export-realm: ## export realm to json file (expected input parameters: "container_name","realm")
	docker exec -it $(container_name) /opt/jboss/keycloak/bin/standalone.sh \
	-Djboss.socket.binding.port-offset=100 -Dkeycloak.migration.action=export \
	-Dkeycloak.migration.provider=singleFile \
	-Dkeycloak.migration.realmName=$(realm) \
	-Dkeycloak.migration.usersExportStrategy=REALM_FILE \
	-Dkeycloak.migration.file=/tmp/export_folder/realm.json

ps: ## ps with compose
	docker-compose -f docker-compose.yml ps
