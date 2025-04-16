#vault kv put secret/myapp/config username="admin" password="supersecret"

# policy.hcl
path "secret/data/myapp/config" {
  capabilities = ["read"]
}

