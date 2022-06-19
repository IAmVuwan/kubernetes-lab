.PHONY: help
.DEFAULT_GOAL := help
help:
	@echo "---------------------------------------------------------------------------------------"
	@echo ""
	@echo "				CLI"
	@echo ""
	@echo "---------------------------------------------------------------------------------------"
	@echo ""
	@awk 'BEGIN {FS = ":.*##"; printf "Usage: make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-25s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Development

get_pods: ## Get pods all namespaces
	kubectl get pods --all-namespaces

site_update: ## Update
	hugo mod get -u && \
	hugo mod npm pack && $(MAKE) install

site_start: ## Start Webpage
	hugo server --buildDrafts --buildFuture --watch

site_build: ## Build
	HUGO_ENVIRONMENT=production hugo --minify --destination ./public

##@ Infra

infra_deploy: ## Infra Deploy
	./infra/terraform.sh --deploy

infra_destroy: ## Infra Destroy
	./infra/terraform.sh --destroy

##@ Sync

sync_s3:
	./infra/terraform.sh --sync-s3

sync_cloudfront:
	./infra/terraform.sh --sync-cloudfront

##@ Cleanup

clean:
	rm -rf ./public/

##@ Releases

release: site_build sync_s3 sync_cloudfront clean