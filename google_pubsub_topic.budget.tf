resource "google_pubsub_topic" "budget" {
  count = var.create_pubsub_topic ? 1 : 0

  name                       = var.pubsub_topic_name
  kms_key_name               = var.kms_key_name
  message_retention_duration = var.message_retention_duration
  labels                     = var.labels

  lifecycle {
    precondition {
      condition     = var.kms_key_name != null
      error_message = "var.kms_key_name is required when var.create_pubsub_topic is true"
    }
  }

  depends_on = [google_kms_crypto_key_iam_member.pubsub_service_agent]
}
