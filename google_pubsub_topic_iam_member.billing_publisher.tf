# Lets Cloud Billing publish budget notifications to the topic.
resource "google_pubsub_topic_iam_member" "billing_publisher" {
  count = var.create_pubsub_topic ? 1 : 0

  topic  = google_pubsub_topic.budget[0].id
  role   = "roles/pubsub.publisher"
  member = local.billing_budget_publisher
}
