#
.DEFAULT_GOAL := help

# aliases
# alias m='make'
# alias tf='terraform'

##@ Utility
help: ## Display this help. (Default)
# based on "https://gist.github.com/prwhite/8168133?permalink_comment_id=4260260#gistcomment-4260260"
	@grep -hE '^[A-Za-z0-9_ \-]*?:.*##.*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

##@ Utility
help_sort: ## Display alphabetized version of help.
	@grep -hE '^[A-Za-z0-9_ \-]*?:.*##.*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

# set variables with shell scripts
# or manually edit .env and
# remove/comment the following line(s)
# $(shell ./dotenv-gen.sh > /dev/null 2>&1)
# $(shell ./startup-script-gen.sh > /dev/null 2>&1)
include .env
export

up: ## Initialize terraform and startup cloud machine. Deps: apply, update_os_login, info, config_ssh.
up: \
apply

down: ## Destroy existing cloud machine. Boot disk will be deleted and data disk will be preserved.
	terraform destroy -auto-approve

env_print: ## Print environment variables with name containing "TF_VAR" or "GITHUB" including those defined in ".env" file.
	env | grep "TF_\|GITHUB\|GOOGLE"

setup: env_print ## Setup terraform with init, fmt, validate, and plan output to "tfplan".
	terraform init
	terraform fmt
	terraform validate
	terraform plan -out=tfplan

apply: setup ## Apply terraform configuration in "tfplan".
	terraform apply -auto-approve "tfplan"

info: ## List existing GCP instances.
	gcloud compute instances list

logs: ## Show terraform logs
	terraform output --raw cpu-logs
	terraform output --raw gpu-logs

mon: ## Print monitoring output (refresh and show)
	terraform refresh
	# terraform show