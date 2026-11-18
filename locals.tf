locals {
  # Pub/Sub service agent — encrypts budget notification messages with the CMEK key.
  pubsub_service_agent = "serviceAccount:service-${data.google_project.current.number}@gcp-sa-pubsub.iam.gserviceaccount.com"

  # Google-managed identity Cloud Billing uses to publish budget notifications.
  billing_budget_publisher = "serviceAccount:billing-budget-alert@system.gserviceaccount.com"

  # Scope the budget to the current project unless projects are given explicitly.
  projects = var.projects == null ? ["projects/${data.google_project.current.number}"] : var.projects

  pubsub_topic = var.create_pubsub_topic ? one(google_pubsub_topic.budget[*].id) : var.pubsub_topic
}
