resource "google_monitoring_notification_channel" "finance" {
  display_name = "Finance budget alerts"
  type         = "email"
  labels = {
    email_address = "finance@example.com"
  }
}
