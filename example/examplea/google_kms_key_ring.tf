# Pub/Sub topics are global and Cloud Billing publishes through the global
# endpoint, so the topic's CMEK key should be global too.
resource "google_kms_key_ring" "budget" {
  name     = "billing-budget-keyring"
  location = "global"
}
