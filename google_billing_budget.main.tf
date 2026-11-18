resource "google_billing_budget" "main" {
  billing_account = var.billing_account
  display_name    = var.display_name

  amount {
    specified_amount {
      currency_code = var.currency_code
      units         = tostring(var.amount)
    }
  }

  dynamic "threshold_rules" {
    for_each = var.threshold_rules
    content {
      threshold_percent = threshold_rules.value.threshold_percent
      spend_basis       = threshold_rules.value.spend_basis
    }
  }

  budget_filter {
    projects               = local.projects
    services               = var.services
    credit_types_treatment = var.credit_types_treatment
    credit_types           = var.credit_types
    calendar_period        = var.calendar_period
  }

  all_updates_rule {
    pubsub_topic                     = local.pubsub_topic
    schema_version                   = "1.0"
    monitoring_notification_channels = var.monitoring_notification_channels
    disable_default_iam_recipients   = var.disable_default_iam_recipients
  }

  depends_on = [google_pubsub_topic_iam_member.billing_publisher]
}
