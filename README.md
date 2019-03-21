# docker-image-service-account-assigner

This is Docker image build of k8s-gke-service-account-assigner
(https://github.com/imduffy15/k8s-gke-service-account-assigner).
K8s-gke-service-account-assigner is a Kubernetes DaemonSet that acts as a proxy
between individual pods and GCP metadata. This allows to provide different
Google Service Accounts and Scopes for pods and protects compute instance
Service Account access.

## Building

### Master

On push/merge to master, CI will automatically build and push
`gpii/service-account-assigner:latest` image.

### Tags

Create and push git tag and CI will build and publish corresponding`
`gpii/service-account-assigner:${git_tag}` docker image.

#### Tag format

Tags should follow actual service-account-assigner version, suffixed by
`-gpii.${gpii_build_number}`, where `gpii_build_number` is monotonically
increasing number denoting Docker image build number,  starting from `0`
for each upstream version.

Example:
```
0.0.3-gpii.0
0.0.3-gpii.1
...
0.0.4-gpii.0
```

### Manually

Run `make` to see all available steps.

- `make build` to build image as latest
- `make push` to push this image to registry
