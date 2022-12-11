## How to deploy?

```bash
export CLUSTER_FQDN="localnetwork.dev"

curl -o values.raw.yaml https://raw.githubusercontent.com/unlockprogramming/kubernetes/main/airflow-setup/values.yaml && \

envsubst < "values.raw.yaml" > "values.out.yaml" && rm -rf values.raw.yaml

curl -s "https://raw.githubusercontent.com/unlockprogramming/kubernetes/main/airflow-setup/install.sh" | bash
```
