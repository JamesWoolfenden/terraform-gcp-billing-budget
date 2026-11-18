resource "google_kms_key_ring" "budget" {
  name     = "billing-budget-keyring"
  location = "europe-west2"
}
