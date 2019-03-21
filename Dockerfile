FROM golang:1.12.1-alpine3.9 AS build

ENV SAA_RELEASE=master \
    SAA_PROJECT=github.com/imduffy15/k8s-gke-service-account-assigner \
    SAA_GIT_SHA=af04ba0acae0a90faa600390c6de93f521872cf4 \
    CGO_ENABLED=0 \
    LANG=C.UTF-8 \
    ARCH=linux

ENV SAA_GIT_REPO=https://${SAA_PROJECT}.git \
    REPO_VERSION=${SAA_RELEASE}

RUN apk add --update --no-cache \
      curl \
      git \
      make \
    && git clone --branch "${SAA_RELEASE}" --depth=1 -- "${SAA_GIT_REPO}" "${GOPATH}/src/${SAA_PROJECT}" \
    && cd "${GOPATH}/src/${SAA_PROJECT}" \
    && git show-ref --verify HEAD | grep -q "^${SAA_GIT_SHA}" \
    && make setup \
    && make -e build \
    && mv /go/src/${SAA_PROJECT}/build/bin/${ARCH}/k8s-gke-service-account-assigner /service-account-assigner

FROM scratch

ENV SAA_UID=10000 \
    SAA_GID=10000

COPY --from=build /service-account-assigner /service-account-assigner

USER ${SAA_UID}:${SAA_GID}

ENTRYPOINT ["/service-account-assigner"]
