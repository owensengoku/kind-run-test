FROM kindest/node:v1.13.4

RUN apt-get update \
 && apt-get install -y dnsutils iputils-ping \
 && apt-get install -y make gcc musl-dev golang-go libzmqpp-dev

ENV GOPATH /go

RUN go version

ARG HELM_VERSION=v2.10.0
ARG FILENAME=helm-${HELM_VERSION}-linux-amd64.tar.gz
ARG HELM_URL=https://storage.googleapis.com/kubernetes-helm/${FILENAME}
RUN echo $HELM_URL
RUN mkdir -p /tmp/helm && curl -o /tmp/helm/$FILENAME ${HELM_URL} \
  && tar -zxvf /tmp/helm/${FILENAME} -C /tmp/helm \
  && mv /tmp/helm/linux-amd64/helm /usr/local/bin/helm \
  && rm -rf /tmp/helm
RUN helm init --client-only

ENV PATH "/go/bin:$PATH"
