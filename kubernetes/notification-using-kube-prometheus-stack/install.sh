set -u # or set -o nounset

source .env

: "$SMTP_HOSTNAME"
: "$SMTP_HOSTPORT"
: "$SMTP_FROM"
: "$SMTP_USERNAME"
: "$SMTP_PASSWORD"
: "$SMTP_REQUIRE_TLS"
: "$SMTP_SKIP_SSL_VERIFY"
: "$LOG_LEVEL"
: "$EMAIL_ADDRESS"
: "$SLACK_INCOMING_WEBHOOK_URL"
: "$SLACK_CHANNEL"
: "$HTTP_SCHEME"
: "$CLUSTER_FQDN"
: "$ALERTMANAGER_EXTERNAL_HOST"
: "$PROMETHEUS_EXTERNAL_HOST"
: "$N_BYTES"
: "$N_TIMES"

envsubst <"values.yaml" >"values.out.yaml"

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
  --version 36.0.2 \
  --namespace monitoring --create-namespace \
  -f values.out.yaml

sleep 60s

kubectl apply -f docker-containers.yaml

sleep 30s

envsubst <"deployment.yaml" >"deployment.out.yaml"

kubectl apply -f deployment.out.yaml
