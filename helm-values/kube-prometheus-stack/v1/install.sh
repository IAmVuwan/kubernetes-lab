set -u # or set -o nounset

source .env

: "$SMTP_HOSTNAME"
: "$SMTP_HOSTPORT"
: "$SMTP_FROM"
: "$SMTP_USERNAME"
: "$SMTP_PASSWORD"
: "$SMTP_REQUIRE_TLS"
: "$LOG_LEVEL"
: "$EMAIL_ADDRESS"
: "$SLACK_INCOMING_WEBHOOK_URL"
: "$SLACK_CHANNEL"

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

eval "echo \"$(cat values.yaml)\"" >values.out.yaml

helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
  --version 36.0.2 \
  --namespace monitoring --create-namespace \
  -f values.out.yaml
