.ONESHELL:
.SHELL := /usr/bin/bash
RANDOM := $(shell bash -c 'echo $$RANDOM')
BACKEND?=../../smart-backend
ENV?=dev

# cnf ?= .env.vault
# include $(cnf)
# export $(shell sed 's/=.*//' $(cnf))


download:
	@curl \
    --silent \
    --remote-name \
    "${VAULT_URL}/${VAULT_VERSION}/vault_${VAULT_VERSION}_${VAULT_RELEASE}.zip"
	@curl \
      --silent \
      --remote-name \
      "${VAULT_URL}/${VAULT_VERSION}/vault_${VAULT_VERSION}_SHA256SUMS"
	@curl \
      --silent \
      --remote-name \
      "${VAULT_URL}/${VAULT_VERSION}/${VAULT_VERSION}/vault_${VAULT_VERSION}_SHA256SUMS.sig"

install:
	@unzip vault_${VAULT_VERSION}_linux_amd64.zip
	@sudo chown root:root vault
	@sudo mv vault /usr/local/bin/
	@vault -autocomplete-install
	@complete -C /usr/local/bin/vault vault

configuration:
	@sudo setcap cap_ipc_lock=+ep /usr/local/bin/vault
	@sudo useradd --system --home /etc/vault.d --shell /bin/false vault

folder_structure:
	@sudo mkdir --parents /etc/vault.d
	@sudo touch /etc/vault.d/vault.hcl
	@sudo chown --recursive vault:vault /etc/vault.d
	@sudo chmod 640 /etc/vault.d/vault.hcl

vault_config:
	@cd vault \
		&& terraform init -upgrade \
		&& terraform validate \
		&& terraform apply -auto-approve
