variable "billing_account" {
  type        = string
  description = "ID of the billing account the budget applies to (XXXXXX-XXXXXX-XXXXXX)"

  validation {
    condition     = can(regex("^[0-9A-Fa-f]{6}-[0-9A-Fa-f]{6}-[0-9A-Fa-f]{6}$", var.billing_account))
    error_message = "var.billing_account must be a billing account ID in the form XXXXXX-XXXXXX-XXXXXX"
  }
}

variable "display_name" {
  type        = string
  description = "Display name of the budget"

  validation {
    condition     = length(trimspace(var.display_name)) > 0 && length(var.display_name) <= 60
    error_message = "var.display_name must be a non-empty string of at most 60 characters"
  }
}

variable "amount" {
  type        = number
  description = "Budget amount, in whole units of var.currency_code"

  validation {
    condition     = var.amount > 0 && floor(var.amount) == var.amount
    error_message = "var.amount must be a positive whole number"
  }
}

variable "currency_code" {
  type        = string
  description = "ISO 4217 currency code of the budget amount; must match the billing account currency"
  default     = "USD"

  validation {
    condition     = can(regex("^[A-Z]{3}$", var.currency_code))
    error_message = "var.currency_code must be a three-letter ISO 4217 code, e.g. USD"
  }
}

variable "threshold_rules" {
  type = list(object({
    threshold_percent = number
    spend_basis       = optional(string, "CURRENT_SPEND")
  }))
  description = "Spend thresholds (as a fraction of the budget amount, 1.0 = 100%) that trigger notifications"
  default = [
    { threshold_percent = 0.5 },
    { threshold_percent = 0.9 },
    { threshold_percent = 1.0 },
    { threshold_percent = 1.0, spend_basis = "FORECASTED_SPEND" },
  ]

  validation {
    condition     = length(var.threshold_rules) > 0 && alltrue([for r in var.threshold_rules : r.threshold_percent > 0 && contains(["CURRENT_SPEND", "FORECASTED_SPEND"], r.spend_basis)])
    error_message = "var.threshold_rules must be non-empty, with positive threshold_percent values and spend_basis CURRENT_SPEND or FORECASTED_SPEND"
  }
}

variable "projects" {
  type        = list(string)
  description = "Projects the budget covers, as projects/PROJECT_NUMBER; defaults to the current project. Use [] to cover the whole billing account"
  default     = null

  validation {
    condition     = var.projects == null || alltrue([for p in coalesce(var.projects, []) : can(regex("^projects/[0-9]+$", p))])
    error_message = "var.projects entries must be in the form projects/PROJECT_NUMBER"
  }
}

variable "services" {
  type        = list(string)
  description = "Services the budget covers, as services/SERVICE_ID; empty covers all services"
  default     = []

  validation {
    condition     = alltrue([for s in var.services : can(regex("^services/[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}$", s))])
    error_message = "var.services entries must be in the form services/XXXX-XXXX-XXXX"
  }
}

variable "credit_types_treatment" {
  type        = string
  description = "How credits are applied to spend: INCLUDE_ALL_CREDITS, EXCLUDE_ALL_CREDITS or INCLUDE_SPECIFIED_CREDITS"
  default     = "INCLUDE_ALL_CREDITS"

  validation {
    condition     = contains(["INCLUDE_ALL_CREDITS", "EXCLUDE_ALL_CREDITS", "INCLUDE_SPECIFIED_CREDITS"], var.credit_types_treatment)
    error_message = "var.credit_types_treatment must be one of INCLUDE_ALL_CREDITS, EXCLUDE_ALL_CREDITS or INCLUDE_SPECIFIED_CREDITS"
  }
}

variable "credit_types" {
  type        = list(string)
  description = "Credit types subtracted from spend when var.credit_types_treatment is INCLUDE_SPECIFIED_CREDITS"
  default     = []

  validation {
    condition = alltrue([for c in var.credit_types : contains(
      ["SUSTAINED_USAGE_DISCOUNT", "DISCOUNT", "PROMOTION", "SUBSCRIPTION_BENEFIT", "COMMITTED_USAGE_DISCOUNT", "COMMITTED_USAGE_DISCOUNT_DOLLAR_BASE", "FREE_TIER", "RESELLER_MARGIN", "FEE_UTILIZATION_OFFSET"], c
    )])
    error_message = "var.credit_types entries must be valid Cloud Billing credit types"
  }
}

variable "calendar_period" {
  type        = string
  description = "Budget period: MONTH, QUARTER or YEAR"
  default     = "MONTH"

  validation {
    condition     = contains(["MONTH", "QUARTER", "YEAR"], var.calendar_period)
    error_message = "var.calendar_period must be one of MONTH, QUARTER or YEAR"
  }
}

variable "create_pubsub_topic" {
  type        = bool
  description = "Create a CMEK-encrypted Pub/Sub topic for budget notifications and grant Cloud Billing publish on it"
  default     = true

  validation {
    condition     = var.create_pubsub_topic != null
    error_message = "var.create_pubsub_topic must be true or false"
  }
}

variable "pubsub_topic_name" {
  type        = string
  description = "Name of the Pub/Sub topic to create when var.create_pubsub_topic is true"
  default     = "billing-budget-alerts"

  validation {
    condition     = can(regex("^[A-Za-z][A-Za-z0-9._~%+-]{2,254}$", var.pubsub_topic_name)) && !startswith(lower(var.pubsub_topic_name), "goog")
    error_message = "var.pubsub_topic_name must be a valid Pub/Sub topic name (3-255 characters, starting with a letter, not starting with goog)"
  }
}

variable "pubsub_topic" {
  type        = string
  description = "Existing topic (projects/P/topics/T) to notify when var.create_pubsub_topic is false; the caller must grant billing-budget-alert@system.gserviceaccount.com publish on it"
  default     = null

  validation {
    condition     = var.pubsub_topic == null || can(regex("^projects/[^/]+/topics/[^/]+$", var.pubsub_topic))
    error_message = "var.pubsub_topic must be in the form projects/PROJECT/topics/TOPIC"
  }
}

variable "kms_key_name" {
  type        = string
  description = "KMS crypto key used to encrypt the budget notification topic; required when var.create_pubsub_topic is true"
  default     = null
  sensitive   = true

  validation {
    condition     = var.kms_key_name == null || length(trimspace(coalesce(var.kms_key_name, " "))) > 0
    error_message = "var.kms_key_name must not be an empty string when set"
  }
}

variable "message_retention_duration" {
  type        = string
  description = "How long the notification topic retains messages (e.g. 604800s), so subscribers can replay missed alerts"
  default     = "604800s"

  validation {
    condition     = can(regex("^[0-9]+s$", var.message_retention_duration))
    error_message = "var.message_retention_duration must be a duration in seconds, e.g. 604800s"
  }
}

variable "monitoring_notification_channels" {
  type        = list(string)
  description = "Cloud Monitoring notification channel IDs (projects/P/notificationChannels/ID) to notify, at most 5"
  default     = []

  validation {
    condition     = length(var.monitoring_notification_channels) <= 5 && alltrue([for c in var.monitoring_notification_channels : can(regex("^projects/[^/]+/notificationChannels/[^/]+$", c))])
    error_message = "var.monitoring_notification_channels must contain at most 5 IDs in the form projects/PROJECT/notificationChannels/ID"
  }
}

variable "disable_default_iam_recipients" {
  type        = bool
  description = "Stop emailing billing account admins/users by default; only set true when a Pub/Sub topic or notification channel is configured"
  default     = false

  validation {
    condition     = var.disable_default_iam_recipients != null
    error_message = "var.disable_default_iam_recipients must be true or false"
  }
}

variable "labels" {
  type        = map(string)
  description = "Labels to apply to the notification topic"
  default     = {}

  validation {
    condition     = alltrue([for k, v in var.labels : can(regex("^[a-z0-9_-]{1,63}$", k)) && can(regex("^[a-z0-9_-]{0,63}$", v))])
    error_message = "var.labels keys and values must be lowercase alphanumerics, underscores, or hyphens, 1-63 characters (GCP label constraints)"
  }
}
