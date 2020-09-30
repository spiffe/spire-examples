This example creates a Kubernetes cluster in KIND using Helm packages, with SPIRE and
Postgres as a workload, using k8s-workload-registrar to automatically maintain registration
entries.

(Note that this is different from the k8s/postgres example which uses Postgres as a backend
for SPIRE itself, but not as a workload.)
 
The Kubernetes cluster is running SPIRE and spiffe-helper, and spiffe-helper is configured
to push certificates into a Postgres database for authenticaiton. 

Because spiffe-helper has to be inside the same image as the Postgres server, these scripts
create a new image containg Postgres and spiffe-helper.

Also since we are not releasing k8s-workload-registrar as a finished image yet, the scripts
download the source and build it. 

