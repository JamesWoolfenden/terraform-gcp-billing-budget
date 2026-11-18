# holden:ignore:HLD_TF_026 — examples intentionally use ../../ to reference the local module root
module "billing-budget" {
  source                           = "../../"
  billing_account                  = var.billing_account
  display_name                     = "example-project-monthly"
  amount                           = 500
  currency_code                    = "USD"
  kms_key_name                     = google_kms_crypto_key.budget.id
  monitoring_notification_channels = [google_monitoring_notification_channel.finance.id]
  disable_default_iam_recipients   = true

  labels = {
    team = "finance"
  }
}
