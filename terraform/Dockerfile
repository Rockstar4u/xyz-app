FROM hashicorp/terraform:0.14.0 AS builder

ARG KUBECTL_VERSION=1.27.4
ARG KUSTOMIZE_VERSION=v5.1.1

RUN apk add --update bash openssl curl ca-certificates
# RUN wget -qO /usr/local/bin/kubectl 'https://storage.googleapis.com/kubernetes-release/release/v1.16.15/bin/linux/amd64/kubectl' \
#     && chmod 755 /usr/local/bin/kubectl

# Install kubectl (same version of aws esk)
RUN curl -sLO https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
    mv kubectl /usr/bin/kubectl && \
    chmod +x /usr/bin/kubectl

# Install kustomize (latest release)
RUN curl -sLO https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2F${KUSTOMIZE_VERSION}/kustomize_${KUSTOMIZE_VERSION}_linux_amd64.tar.gz && \
    tar xvzf kustomize_${KUSTOMIZE_VERSION}_linux_amd64.tar.gz && \
    mv kustomize /usr/bin/kustomize && \
    chmod +x /usr/bin/kustomize

RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 \
    && chmod +x get_helm.sh && ./get_helm.sh

RUN helm repo add "stable" "https://charts.helm.sh/stable" --force-update

RUN wget -qO /usr/local/bin/aws-iam-authenticator 'https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v0.6.11/aws-iam-authenticator_0.6.11_linux_amd64' \
    && chmod 755 /usr/local/bin/aws-iam-authenticator


ENTRYPOINT [""]