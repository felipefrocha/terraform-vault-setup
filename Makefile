.ONESHELL:
.DEFAULT_GOAL := help
SHELL := /bin/bash
RANDOM := $(shell bash -c 'echo $$RANDOM')
BACKEND?=../../smart-backend
ENV?=dev

# cnf ?= .env
# include $(cnf)
# export $(shell sed 's/=.*//' $(cnf))

# Get the latest tag
TAG = $(shell git describe --tags --abbrev=0)
GIT_COMMIT = $(shell git log -1 --format=%h)

FOLDER := $(shell echo $${PWD} | rev | cut -d/ -f1 | rev)
FOLDER_NAME := $(shell printf '%s\n' "${FOLDER}" | awk '{ print toupper($$0) }')

CASE?=case

.PHONY: help

help: ## This help.

	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

initial_setup:
	@cd setup \
		&& terraform init -upgrade \
		&& terraform validate \
		&& terraform apply -auto-approve
		
deploy_cli: 
	@sudo cp cli/citcli /usr/local/bin/
	@sudo chmod +x /usr/local/bin/citcli

vault_config:
	@cd vault \
		&& terraform init -upgrade \
		&& terraform validate \
		&& terraform apply -auto-approve
