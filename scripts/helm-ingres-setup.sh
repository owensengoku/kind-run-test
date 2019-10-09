#!/bin/sh

cp /etc/kubernetes/admin.conf /root/.kube/config
kubectl apply --filename yamls/helm/tiller-service-account.yaml
helm init --wait --service-account tiller
