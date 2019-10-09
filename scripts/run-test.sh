#!/bin/sh

# Run test
KUBE_DNS_IP=$(kubectl -n kube-system get svc kube-dns --template '{{.spec.clusterIP}}')
echo Kube DNS IP ${KUBE_DNS_IP}

docker run -it --user root:root --privileged --network=host --dns=${KUBE_DNS_IP} --env GOPATH=/workdir --env PATH=$PATH --env GINKGO_EDITOR_INTEGRATION=true --volume /bin:/bin --volume /usr:/usr --volume /workdir:/workdir --volume /root:/root --volume /kind:/kind -w /workdir/src/github.com/owensengoku/kind-run-test ubuntu:18.04 go run test.go
