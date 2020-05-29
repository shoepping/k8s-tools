# docker build -t shoepping/k8s-tools:YY.0M.0D ./
# Based on:
# https://github.com/lachie83/k8s-kubectl/blob/master/Dockerfile
# https://github.com/nosinovacao/fluxctl-docker/blob/master/Dockerfile
# https://github.com/alpine-docker/helm/blob/master/Dockerfile
# https://github.com/Azure/azure-cli/issues/8863

FROM alpine:3.11.6


# https://github.com/fluxcd/flux/releases
ENV FLUX_VERSION=1.19.0
# https://github.com/helm/helm/releases
ENV HELM_VERSION=3.2.1
# https://github.com/kubernetes/kubectl/releases
ENV KUBECTL_VERSION=1.16.7
# https://github.com/Azure/azure-cli/releases
ENV AZURE_CLI_VERSION=2.6.0

LABEL KUBECTL_VERSION=${KUBECTL_VERSION} \
	HELM_VERSION=${HELM_VERSION} \
	FLUX_VERSION=${FLUX_VERSION} \
	AZURE_CLI_VERSION=${AZURE_CLI_VERSION}

RUN apk add --update ca-certificates \
 && apk add --update -t deps curl \
 && curl -L https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl \
 && chmod +x /usr/local/bin/kubectl \
 && apk del --purge deps \
 && rm /var/cache/apk/*

RUN apk add --update ca-certificates \
 && apk add --update -t deps curl \
 && curl -L https://github.com/fluxcd/flux/releases/download/${FLUX_VERSION}/fluxctl_linux_amd64 -o /usr/local/bin/fluxctl \
 && chmod +x /usr/local/bin/fluxctl \
 && apk del --purge deps \
 && rm /var/cache/apk/*

ENV BASE_URL="https://get.helm.sh"
ENV TAR_FILE="helm-v${HELM_VERSION}-linux-amd64.tar.gz"

RUN apk add --update --no-cache curl ca-certificates && \
    curl -L ${BASE_URL}/${TAR_FILE} |tar xvz && \
    mv linux-amd64/helm /usr/bin/helm && \
    chmod +x /usr/bin/helm && \
    rm -rf linux-amd64 && \
    apk del curl && \
    rm -f /var/cache/apk/*

# azure cli
RUN apk add --no-cache curl tar openssl sudo bash jq python3
RUN apk --update --no-cache add postgresql-client postgresql
RUN apk add --virtual=build gcc libffi-dev musl-dev openssl-dev make python3-dev
RUN pip3 install virtualenv &&\
    python3 -m virtualenv /azure-cli
RUN /azure-cli/bin/python -m pip --no-cache-dir install azure-cli==${AZURE_CLI_VERSION}
COPY az /usr/bin/az
RUN chmod +x /usr/bin/az

COPY ./az_aks_browse.sh /root/az_aks_browse.sh

# nice-to-have
RUN apk add --no-cache fish
