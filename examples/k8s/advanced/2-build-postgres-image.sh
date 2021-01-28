# check for kubectl, helm, and docker

pushd spiffe-postgres-image
docker build . -t spiffe-postgres-image
docker tag spiffe-postgres-image localhost:5000/spiffe-postgres-image
docker push localhost:5000/spiffe-postgres-image
# Both push the new image into the local registry and also manually preload it into the nodes
kind load docker-image spiffe-postgres-image --name spire-example
popd

