## How to deploy?

```bash
echo 'CLUSTER_FQDN=localnetwork.dev' > .env && \
curl -o values.yaml https://raw.githubusercontent.com/unlockprogramming/kubernetes/main/airflow-setup/values.yaml && \
curl -s "https://raw.githubusercontent.com/unlockprogramming/kubernetes/main/airflow-setup/install.sh" | bash
```
