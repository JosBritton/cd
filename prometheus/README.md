# Prometheus Operator

## Deployment

### Initial

The prometheus-operator deployment hydrate the manifests in the source code.
This will cause the generated secrets to be in plain text in the source control.
Kustomize is configured to ignore the secrets in code. Instead, an initial secret
will need to be configured manually.

Add the `admin-password` key to the secret with a base64 encoded value

```
kubectl edit secret prometheus-operator-grafana
```
