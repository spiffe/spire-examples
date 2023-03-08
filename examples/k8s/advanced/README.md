This example creates a Kubernetes cluster in KIND using Helm packages, with SPIRE and
Postgres as a workload, using k8s-workload-registrar to automatically maintain registration
entries.

(Note that this is different from the k8s/postgres example which uses Postgres as a backend
for SPIRE itself, but not as a workload.)
 
The Kubernetes cluster is running SPIRE and spiffe-helper, and spiffe-helper is configured
to push certificates into a Postgres database for authentication. 

Because spiffe-helper has to be inside the same image as the Postgres server, these scripts
create a new image containing Postgres and spiffe-helper.


> **Deprecation Note**
> k8s-workload-registrar is deprecated, we recommend using the [spire-controller-manager](https://github.com/spiffe/spire-controller-manager),
> which is a Kubernetes controller used to manage registration entries and federation. A demo can be found [here](https://github.com/spiffe/spire-controller-manager/tree/main/demo)
