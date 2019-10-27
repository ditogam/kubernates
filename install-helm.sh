#!/bin/bash

##https://programming.vip/docs/deploying-kubernetes-through-kubeadm.html

sudo apt-get install open-iscsi -y

for i in *; do sed -i 's/'extensions/v1beta1'/apps\/v1/g' "$i"; done


sudo systemctl enable iscsid && sudo systemctl start iscsid
helm del $(helm ls --all --short) --purge


kubectl -n kube-system delete deployment tiller-deploy
kubectl delete clusterrolebinding tiller
kubectl -n kube-system delete serviceaccount tiller
curl -L https://git.io/get_helm.sh | bash
kubectl create serviceaccount --namespace kube-system tiller
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
#helm init --service-account tiller --upgrade --output yaml | sed 's@apiVersion: extensions/v1beta1@apiVersion: apps/v1@' | sed 's@  replicas: 1@  replicas: 1\n  selector: {"matchLabels": {"app": "helm", "name": "tiller"}}@' |kubectl apply -f -
helm init --service-account tiller --skip-refresh
kubectl -n kube-system patch deploy/tiller-deploy -p '{"spec": {"template": {"spec": {"serviceAccountName": "tiller"}}}}'
kubectl -n kube-system patch deployment tiller-deploy -p '{"spec": {"template": {"spec": {"automountServiceAccountToken": true}}}}'
helm repo update

TILER_POD=$(kubectl -n kube-system get po| grep 'tiller-deploy'| sed 's/|/ /' | awk '{print $1}')
echo $TILER_POD
while [[ $(kubectl get pods -n kube-system $TILER_POD -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do echo "waiting for pod" && sleep 1; done

helm install --namespace openebs stable/openebs
#wait until all running
kubectl get pods --all-namespaces -o wide -w
#wait until all running
kubectl get storageclass
kubectl patch storageclass openebs-hostpath  -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
https://hub.docker.com/_/microsoft-mmlspark-release?tab=description
