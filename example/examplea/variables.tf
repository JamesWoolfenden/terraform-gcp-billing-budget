variable "billing_account" {
  type        = string
  description = "ID of the billing account the example budget applies to"

  validation {
    condition     = can(regex("^[0-9A-Fa-f]{6}-[0-9A-Fa-f]{6}-[0-9A-Fa-f]{6}$", var.billing_account))
    error_message = "var.billing_account must be a billing account ID in the form XXXXXX-XXXXXX-XXXXXX"
  }
}
