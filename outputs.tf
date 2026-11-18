output "id" {
  value       = google_billing_budget.main.id
  description = "ID of the budget"
}

output "name" {
  value       = google_billing_budget.main.name
  description = "Resource name of the budget (billingAccounts/ACCOUNT/budgets/ID)"
}

# holden:ignore:HLD_TF_080 — only the topic ID is output; it is not derived from var.kms_key_name and is not marked sensitive by the provider
output "pubsub_topic" {
  value       = local.pubsub_topic
  description = "Pub/Sub topic receiving budget notifications, or null when none is configured"
}
