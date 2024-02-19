SHELL=bash
current_dir = $(shell pwd)

BACKEND_CONFIG_BUCKET_REGION=${aws_default_region}
BACKEND_CONFIG_BUCKET=xyz-project-terraform-tfstatefile
BACKEND_CONFIG_TFSTATE_FILE_KEY=client-infrastructure.tfstate
BACKEND_CONFIG_ROLE_ARN=arn:aws:iam::857783516949:role/terraform

help:
	@echo "Usage: make CLIENT=%CLIENT_NAME% %action%"
	@echo ""
	@echo "eg."
	@echo "    make CLIENT=app plan"
	@echo "    make CLIENT=app apply"
	@echo ""
	@echo "Currently supported clients:"
	@echo "- app"
	@echo "- qa"
	@echo ""
	@echo "You need a role assumed terraform/admin role"
	@echo "in client AWS account."

aws_default_region = $(shell aws configure get region)
aws_access_key_id = $(shell aws configure get aws_access_key_id)
aws_secret_access_key = $(shell aws configure get aws_secret_access_key)
aws_session_token = $(shell aws configure get aws_session_token)

ifeq (${aws_default_region},)
       aws_default_region = ${AWS_DEFAULT_REGION}
endif
ifeq (${aws_access_key_id},)
       aws_access_key_id = ${AWS_ACCESS_KEY_ID}
endif
ifeq (${aws_secret_access_key},)
       aws_secret_access_key = ${AWS_SECRET_ACCESS_KEY}
endif
ifeq (${aws_session_token},)
       aws_session_token = ${AWS_SESSION_TOKEN}
endif

check_args:
ifeq (${CLIENT},)
	@echo "CLIENT must be set"
	@exit 1
endif

set_env:
PASSED_ENVS=
DOCKER_ENV=
ifneq (${aws_default_region},)
       PASSED_ENVS += AWS_DEFAULT_REGION
       DOCKER_ENV += -e AWS_DEFAULT_REGION=${aws_default_region}
endif
ifneq (${aws_access_key_id},)
       PASSED_ENVS += AWS_ACCESS_KEY_ID
       DOCKER_ENV += -e AWS_ACCESS_KEY_ID=${aws_access_key_id}
endif
ifneq (${aws_secret_access_key},)
       PASSED_ENVS += AWS_SECRET_ACCESS_KEY
       DOCKER_ENV += -e AWS_SECRET_ACCESS_KEY=${aws_secret_access_key}
endif
ifneq (${aws_session_token},)
       PASSED_ENVS += AWS_SESSION_TOKEN
       DOCKER_ENV += -e AWS_SESSION_TOKEN=${aws_session_token}
endif

AWS_SESSION_TOKEN=
ifeq (${CLIENT},app)
	AWS_ACCOUNT_ID=857783516949
endif

build_docker_container:
	@echo ">> Building local terraform container with EKS tools"
	@docker build --network host -t terraform_with_eks_tools.local .

generate_kubeconfig: check_args set_env build_docker_container
	@echo ">> Generating kubeconfig from Terraform statefile"

	@echo "===> terraform init"
	@docker run --rm -v ${current_dir}:${current_dir} --network host -w ${current_dir} ${DOCKER_ENV} \
		terraform_with_eks_tools.local:latest terraform init \
			-backend-config "region=${BACKEND_CONFIG_BUCKET_REGION}" \
			-backend-config "bucket=${BACKEND_CONFIG_BUCKET}" \
			-backend-config "key=${CLIENT}/${BACKEND_CONFIG_TFSTATE_FILE_KEY}" \
			-backend-config "role_arn=${BACKEND_CONFIG_ROLE_ARN}"

	@echo "===> terraform output kubeconfig"
	@-docker run --rm -v ${current_dir}:${current_dir} --network host -w ${current_dir} ${DOCKER_ENV} \
		terraform_with_eks_tools.local terraform \
		output -module=eks -no-color kubeconfig > .kube_config.yaml

	@docker run --rm -v ${current_dir}:${current_dir} --network host -w ${current_dir} \
		terraform_with_eks_tools.local \
		bash -c '$$(kubectl config --kubeconfig .kube_config.yaml view > /dev/null 2>&1) || rm -f .kube_config.yaml'			

	@echo "===> Cleaning up..."
	@docker run --rm -v ${current_dir}:${current_dir} -w ${current_dir} \
		busybox:latest rm -rf .terraform

generate_kubeconfig-m: check_args set_env build_docker_container
	@echo ">> mannual terraform flow"

plan: generate_kubeconfig
	@echo ">> Running terraform plan"
	@echo "===> Passing the following ENV to the terraform container ${PASSED_ENVS}"

	@echo "===> terraform init"
	@docker run --rm -v ${current_dir}:${current_dir} --network host -w ${current_dir} ${DOCKER_ENV} \
		terraform_with_eks_tools.local:latest terraform init \
			-backend-config "region=${BACKEND_CONFIG_BUCKET_REGION}" \
			-backend-config "bucket=${BACKEND_CONFIG_BUCKET}" \
			-backend-config "key=${CLIENT}/${BACKEND_CONFIG_TFSTATE_FILE_KEY}" \
			-backend-config "role_arn=${BACKEND_CONFIG_ROLE_ARN}"

	@echo "===> terraform plan"
	@docker run --rm -v ${current_dir}:${current_dir} --network host -w ${current_dir} ${DOCKER_ENV} \
		terraform_with_eks_tools.local:latest terraform plan \
			-var target_account_id=${AWS_ACCOUNT_ID} \
			-var backend_config_bucket_region=${BACKEND_CONFIG_BUCKET_REGION} \
			-var backend_config_bucket=${BACKEND_CONFIG_BUCKET} \
			-var backend_config_role_arn=${BACKEND_CONFIG_ROLE_ARN} \
			-var backend_config_tfstate_file_key=${BACKEND_CONFIG_TFSTATE_FILE_KEY} \
			-var name=${CLIENT} \
			-var-file=tfvars/${CLIENT}.tfvars \
			-out=terraform.plan

	@echo "===> Cleaning up..."
	@docker run --rm -v ${current_dir}:${current_dir} --network host -w ${current_dir} \
		busybox:latest rm -rf .terraform

plan-m: generate_kubeconfig-m
	@echo ">> Running terraform plan"
	@echo "===> Passing the following ENV to the terraform container ${PASSED_ENVS}"

	@echo "===> terraform init"
	@docker run --rm -v ${current_dir}:${current_dir} --network host -w ${current_dir} ${DOCKER_ENV} \
		terraform_with_eks_tools.local:latest terraform init  \
			-backend-config "region=${BACKEND_CONFIG_BUCKET_REGION}" \
			-backend-config "bucket=${BACKEND_CONFIG_BUCKET}" \
			-backend-config "key=${CLIENT}/${BACKEND_CONFIG_TFSTATE_FILE_KEY}" \
			-backend-config "role_arn=${BACKEND_CONFIG_ROLE_ARN}"

	@echo "===> terraform plan"
	@docker run --rm -v ${current_dir}:${current_dir} --network host -w ${current_dir} ${DOCKER_ENV} \
		terraform_with_eks_tools.local:latest terraform plan \
			-var target_account_id=${AWS_ACCOUNT_ID} \
			-var backend_config_bucket_region=${BACKEND_CONFIG_BUCKET_REGION} \
			-var backend_config_bucket=${BACKEND_CONFIG_BUCKET} \
			-var backend_config_role_arn=${BACKEND_CONFIG_ROLE_ARN} \
			-var backend_config_tfstate_file_key=${BACKEND_CONFIG_TFSTATE_FILE_KEY} \
			-var name=${CLIENT} \
			-var-file=tfvars/${CLIENT}.tfvars \
			-out=terraform.plan

apply: generate_kubeconfig
	@echo ">> Running terraform apply"
	@echo "===> Passing the following ENV to the terraform container ${PASSED_ENVS}"

	@echo "===> terraform init"
	@docker run --rm -v ${current_dir}:${current_dir} --network host -w ${current_dir} ${DOCKER_ENV} \
		terraform_with_eks_tools.local:latest terraform init \
			-backend-config "region=${BACKEND_CONFIG_BUCKET_REGION}" \
			-backend-config "bucket=${BACKEND_CONFIG_BUCKET}" \
			-backend-config "key=${CLIENT}/${BACKEND_CONFIG_TFSTATE_FILE_KEY}" \
			-backend-config "role_arn=${BACKEND_CONFIG_ROLE_ARN}"

	@echo "===> terraform apply"
	@docker run --rm -v ${current_dir}:${current_dir} --network host -w ${current_dir} ${DOCKER_ENV} \
		terraform_with_eks_tools.local:latest terraform apply  -auto-approve -lock=true \
			-var target_account_id=${AWS_ACCOUNT_ID} \
			-var backend_config_bucket_region=${BACKEND_CONFIG_BUCKET_REGION} \
			-var backend_config_bucket=${BACKEND_CONFIG_BUCKET} \
			-var backend_config_role_arn=${BACKEND_CONFIG_ROLE_ARN} \
			-var backend_config_tfstate_file_key=${BACKEND_CONFIG_TFSTATE_FILE_KEY} \
			-var name=${CLIENT} \
			-var-file=tfvars/${CLIENT}.tfvars

	@echo "===> Cleaning up..."
	@docker run --rm -v ${current_dir}:${current_dir} --network host -w ${current_dir} \
		busybox:latest rm -rf .terraform

apply-m: generate_kubeconfig-m
	@echo ">> Running terraform apply"
	@echo "===> Passing the following ENV to the terraform container ${PASSED_ENVS}"

	@echo "===> terraform init"
	@docker run --rm -v ${current_dir}:${current_dir} --network host -w ${current_dir} ${DOCKER_ENV} \
		terraform_with_eks_tools.local:latest terraform init \
			-backend-config "region=${BACKEND_CONFIG_BUCKET_REGION}" \
			-backend-config "bucket=${BACKEND_CONFIG_BUCKET}" \
			-backend-config "key=${CLIENT}/${BACKEND_CONFIG_TFSTATE_FILE_KEY}" \
			-backend-config "role_arn=${BACKEND_CONFIG_ROLE_ARN}"

	@echo "===> terraform apply"
	@docker run --rm -v ${current_dir}:${current_dir} --network host -w ${current_dir} ${DOCKER_ENV} \
		terraform_with_eks_tools.local:latest terraform apply  -auto-approve -lock=true \
			-var target_account_id=${AWS_ACCOUNT_ID} \
			-var backend_config_bucket_region=${BACKEND_CONFIG_BUCKET_REGION} \
			-var backend_config_bucket=${BACKEND_CONFIG_BUCKET} \
			-var backend_config_role_arn=${BACKEND_CONFIG_ROLE_ARN} \
			-var backend_config_tfstate_file_key=${BACKEND_CONFIG_TFSTATE_FILE_KEY} \
			-var name=${CLIENT} \
			-var-file=tfvars/${CLIENT}.tfvars

destroy: check_args set_env build_docker_container generate_kubeconfig
	@echo ">> Running terraform destroy"

	@echo "===> terraform init"
	@docker run --rm -v ${current_dir}:${current_dir} -w ${current_dir} ${DOCKER_ENV} \
		terraform_with_eks_tools.local:latest terraform init  \
			-backend-config "region=${BACKEND_CONFIG_BUCKET_REGION}" \
			-backend-config "bucket=${BACKEND_CONFIG_BUCKET}" \
			-backend-config "key=${CLIENT}/${BACKEND_CONFIG_TFSTATE_FILE_KEY}" \
			-backend-config "role_arn=${BACKEND_CONFIG_ROLE_ARN}"


	@echo "===> terraform destroy"
	@docker run --rm -v ${current_dir}:${current_dir} -w ${current_dir} ${DOCKER_ENV} \
		terraform_with_eks_tools.local:latest terraform destroy  -auto-approve \
			-var target_account_id=${AWS_ACCOUNT_ID} \
			-var backend_config_bucket_region=${BACKEND_CONFIG_BUCKET_REGION} \
			-var backend_config_bucket=${BACKEND_CONFIG_BUCKET} \
			-var backend_config_role_arn=${BACKEND_CONFIG_ROLE_ARN} \
			-var backend_config_tfstate_file_key=${BACKEND_CONFIG_TFSTATE_FILE_KEY} \
			-var name=${CLIENT} \
			-var-file=tfvars/${CLIENT}.tfvars

	@echo "===> Cleaning up..."
	@docker run --rm -v ${current_dir}:${current_dir} -w ${current_dir} \
		busybox:latest rm -rf .terraform
