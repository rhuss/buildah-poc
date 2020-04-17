#!/bin/sh

set -x

# Add docker credentials from args (if given in form 'user' 'password')
if [ -n "$1" ]; then
  kubectl create secret generic docker-creds --from-literal=DOCKER_USER=$1 --from-literal=DOCKER_PASSWORD=$2
fi

# Fire up pod
kubectl apply -f buildah-poc.yaml

# Sleep a bit
# TODO: Find out a better way to determinen when the init container is running.
# Maybe by parsing kubectl get pod for "Init:0/1" ?
# buildah-poc   0/1     Init:0/1   0          5s
sleep 5

# Create tar archive
tar cvf ./docker.tar -C docker .

# Upload with kubectl cp
kubectl cp docker.tar buildah-poc:/upload -c init-upload

# Mark as 'done'
kubectl exec buildah-poc -c init-upload -- touch /upload/done
