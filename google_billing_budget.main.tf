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

  lifecycle {
    precondition {
      condition     = !var.disable_default_iam_recipients || var.create_pubsub_topic || var.pubsub_topic != null || length(var.monitoring_notification_channels) > 0
      error_message = "var.disable_default_iam_recipients = true needs a Pub/Sub topic (var.create_pubsub_topic or var.pubsub_topic) or at least one var.monitoring_notification_channels entry, otherwise budget alerts reach nobody"
    }

    precondition {
      condition     = var.credit_types_treatment == "INCLUDE_SPECIFIED_CREDITS" || length(var.credit_types) == 0
      error_message = "var.credit_types must be empty unless var.credit_types_treatment is INCLUDE_SPECIFIED_CREDITS"
    }

    precondition {
      condition     = !var.create_pubsub_topic || var.pubsub_topic == null
      error_message = "var.pubsub_topic is ignored while var.create_pubsub_topic is true; set var.create_pubsub_topic = false to notify an existing topic"
    }
  }

  depends_on = [google_pubsub_topic_iam_member.billing_publisher]
}
