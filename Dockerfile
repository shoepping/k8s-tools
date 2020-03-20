# docker build -t shoepping/k8s-tools:YY.0M.0D ./
# Based on:
# https://github.com/lachie83/k8s-kubectl/blob/master/Dockerfile
# https://github.com/nosinovacao/fluxctl-docker/blob/master/Dockerfile
# https://github.com/alpine-docker/helm/blob/master/Dockerfile 

FROM alpine:3.9

ENV FLUX_VERSION=1.18.0
ENV HELM_VERSION=3.1.1
ENV KUBECTL_VERSION=1.15.10

LABEL KUBECTL_VERSION=${KUBECTL_VERSION}
LABEL HELM_VERSION=${HELM_VERSION}
LABEL FLUX_VERSION=${FLUX_VERSION}

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

RUN apk add bash