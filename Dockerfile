FROM golang:1.12.1-alpine3.9 AS build

ENV SAA_RELEASE=add-proxy-support \
    SAA_PROJECT=github.com/imduffy15/k8s-gke-service-account-assigner \
    SAA_FORK=github.com/stepanstipl/k8s-gke-service-account-assigner \
    SAA_GIT_SHA=ef1e2f2c40a9b81e08ad246e32592d1a90ce491c \
    CGO_ENABLED=0 \
    LANG=C.UTF-8 \
    ARCH=linux

ENV SAA_GIT_REPO=https://${SAA_FORK}.git \
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

FROM alpine:3.9

ENV SAA_UID=10000 \
    SAA_GID=10000 \
    SAA_USER=saa \
    SAA_GROUP=saa \
    SAA_HOME=/opt/saa

RUN apk add --update --no-cache \
      ca-certificates \
      iptables \
      libcap \
    && mkdir -p "${SAA_HOME}" \
    && addgroup -g "${SAA_GID}" "${SAA_GROUP}" \
    && adduser -g "Service Account Assigner user" -D -h "${SAA_HOME}" -G "${SAA_GROUP}" -s /sbin/nologin -u "${SAA_UID}" "${SAA_USER}" \
    # /run is needed for /run/xtables.lock
    && chown -R "${SAA_USER}:${SAA_GROUP}" "${SAA_HOME}" /run \
    # SAA needs to run iptables
    && setcap CAP_NET_RAW,CAP_NET_ADMIN=+ep /sbin/xtables-multi \
    && apk del \
      libcap

COPY --from=build /service-account-assigner "/${SAA_HOME}/service-account-assigner"

USER ${SAA_USER}:${SAA_GROUP}

ENTRYPOINT ["/opt/saa/service-account-assigner"]
