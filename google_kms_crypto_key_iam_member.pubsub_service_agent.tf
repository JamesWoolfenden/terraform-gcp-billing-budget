resource "google_kms_crypto_key_iam_member" "pubsub_service_agent" {
  count = var.create_pubsub_topic ? 1 : 0

  crypto_key_id = var.kms_key_name
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = local.pubsub_service_agent
}
