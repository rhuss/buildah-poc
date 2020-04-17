## Buildah Pod with an upload init-container

This small PoC show how an init-container can be leveraged for uploading a Docker context which then can be used by `buildah` for creating an image.

To run it you need a running Kubernetes cluster.

Then just call

```
test.sh <docker user> <docker password>
```

where `<docker user>` and `<docker password>` are valid credentials of a DockerHub account.
You need to provide the credentials only once as they are then stored in a secret in the cluster.

Please check the logs after running the script.
Or, even better, call `stern buildah-poc &` before starting `test.sh`

When the script finished successfully, then you can test the result with

```
docker run -it <docker user>/buildah-test
```

which should print out a nice message.

### How it works

The following steps are performed by `test.sh` (but please have a look yourself):

* Creates a ConfigMap with the build script
* Create a Pod which mount this script and starts first a very simple init-container which just waits for a marker file to be created
* The content of `docker/` is tarred up ...
* ... and uploaded to the init container in its `/upload` dir. This is done via `kubectl cp`
* The marked file `/upload/done` is created via `kubectl exec -- touch`
* The application container in the Pod start and also mount `/upload`
* The build script then executes `buildah bud` and `buildah push` to create the image and pushes it to Docker Hub. Push-Creds are picked up from a Secret
