# terraform-gcp-billing-budget

[![Build Status](https://github.com/JamesWoolfenden/terraform-gcp-billing-budget/workflows/Verify/badge.svg?branch=main)](https://github.com/JamesWoolfenden/terraform-gcp-billing-budget/actions)
[![Latest Release](https://img.shields.io/github/release/JamesWoolfenden/terraform-gcp-billing-budget.svg)](https://github.com/JamesWoolfenden/terraform-gcp-billing-budget/releases/latest)
[![GitHub tag (latest SemVer)](https://img.shields.io/github/tag/JamesWoolfenden/terraform-gcp-billing-budget.svg?label=latest)](https://github.com/JamesWoolfenden/terraform-gcp-billing-budget/releases/latest)
![Terraform Version](https://img.shields.io/badge/tf-%3E%3D1.5.0-blue.svg)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)

Terraform module for Cloud Billing budgets. Creates a budget for a billing account with a specified amount, threshold rules (default 50%, 90% and 100% of current spend plus 100% of forecasted spend), a project/service/credit-type filter, and an all-updates rule sending notifications to Pub/Sub and/or Cloud Monitoring channels. Optionally creates a CMEK-encrypted Pub/Sub topic for the notifications, with the KMS grant for the Pub/Sub service agent and a publisher grant for billing-budget-alert@system.gserviceaccount.com.

## Usage

Add **module.billing-budget.tf** to your code:-

```terraform
module "billing-budget" {
  source          = "jameswoolfenden/billing-budget/gcp"
  billing_account = var.billing_account
  display_name    = "example-project-monthly"
  amount          = 500
  currency_code   = "USD"
  kms_key_name    = google_kms_crypto_key.budget.id
}
```

See [example/examplea](example/examplea) for a complete working example.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_google"></a> [google](#provider\_google) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [google_billing_budget.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/billing_budget) | resource |
| [google_kms_crypto_key_iam_member.pubsub_service_agent](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/kms_crypto_key_iam_member) | resource |
| [google_pubsub_topic.budget](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic) | resource |
| [google_pubsub_topic_iam_member.billing_publisher](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic_iam_member) | resource |
| [google_project.current](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_amount"></a> [amount](#input\_amount) | Budget amount, in whole units of var.currency\_code | `number` | n/a | yes |
| <a name="input_billing_account"></a> [billing\_account](#input\_billing\_account) | ID of the billing account the budget applies to (XXXXXX-XXXXXX-XXXXXX) | `string` | n/a | yes |
| <a name="input_calendar_period"></a> [calendar\_period](#input\_calendar\_period) | Budget period: MONTH, QUARTER or YEAR | `string` | `"MONTH"` | no |
| <a name="input_create_pubsub_topic"></a> [create\_pubsub\_topic](#input\_create\_pubsub\_topic) | Create a CMEK-encrypted Pub/Sub topic for budget notifications and grant Cloud Billing publish on it | `bool` | `true` | no |
| <a name="input_credit_types"></a> [credit\_types](#input\_credit\_types) | Credit types subtracted from spend when var.credit\_types\_treatment is INCLUDE\_SPECIFIED\_CREDITS | `list(string)` | `[]` | no |
| <a name="input_credit_types_treatment"></a> [credit\_types\_treatment](#input\_credit\_types\_treatment) | How credits are applied to spend: INCLUDE\_ALL\_CREDITS, EXCLUDE\_ALL\_CREDITS or INCLUDE\_SPECIFIED\_CREDITS | `string` | `"INCLUDE_ALL_CREDITS"` | no |
| <a name="input_currency_code"></a> [currency\_code](#input\_currency\_code) | ISO 4217 currency code of the budget amount; must match the billing account currency | `string` | `"USD"` | no |
| <a name="input_disable_default_iam_recipients"></a> [disable\_default\_iam\_recipients](#input\_disable\_default\_iam\_recipients) | Stop emailing billing account admins/users by default; only set true when a Pub/Sub topic or notification channel is configured | `bool` | `false` | no |
| <a name="input_display_name"></a> [display\_name](#input\_display\_name) | Display name of the budget | `string` | n/a | yes |
| <a name="input_kms_key_name"></a> [kms\_key\_name](#input\_kms\_key\_name) | KMS crypto key used to encrypt the budget notification topic; required when var.create\_pubsub\_topic is true | `string` | `null` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Labels to apply to the notification topic | `map(string)` | `{}` | no |
| <a name="input_message_retention_duration"></a> [message\_retention\_duration](#input\_message\_retention\_duration) | How long the notification topic retains messages (e.g. 604800s), so subscribers can replay missed alerts | `string` | `"604800s"` | no |
| <a name="input_monitoring_notification_channels"></a> [monitoring\_notification\_channels](#input\_monitoring\_notification\_channels) | Cloud Monitoring notification channel IDs (projects/P/notificationChannels/ID) to notify, at most 5 | `list(string)` | `[]` | no |
| <a name="input_projects"></a> [projects](#input\_projects) | Projects the budget covers, as projects/PROJECT\_NUMBER; defaults to the current project. Use [] to cover the whole billing account | `list(string)` | `null` | no |
| <a name="input_pubsub_topic"></a> [pubsub\_topic](#input\_pubsub\_topic) | Existing topic (projects/P/topics/T) to notify when var.create\_pubsub\_topic is false; the caller must grant billing-budget-alert@system.gserviceaccount.com publish on it | `string` | `null` | no |
| <a name="input_pubsub_topic_name"></a> [pubsub\_topic\_name](#input\_pubsub\_topic\_name) | Name of the Pub/Sub topic to create when var.create\_pubsub\_topic is true | `string` | `"billing-budget-alerts"` | no |
| <a name="input_services"></a> [services](#input\_services) | Services the budget covers, as services/SERVICE\_ID; empty covers all services | `list(string)` | `[]` | no |
| <a name="input_threshold_rules"></a> [threshold\_rules](#input\_threshold\_rules) | Spend thresholds (as a fraction of the budget amount, 1.0 = 100%) that trigger notifications | <pre>list(object({<br/>    threshold_percent = number<br/>    spend_basis       = optional(string, "CURRENT_SPEND")<br/>  }))</pre> | <pre>[<br/>  {<br/>    "threshold_percent": 0.5<br/>  },<br/>  {<br/>    "threshold_percent": 0.9<br/>  },<br/>  {<br/>    "threshold_percent": 1<br/>  },<br/>  {<br/>    "spend_basis": "FORECASTED_SPEND",<br/>    "threshold_percent": 1<br/>  }<br/>]</pre> | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_id"></a> [id](#output\_id) | ID of the budget |
| <a name="output_name"></a> [name](#output\_name) | Resource name of the budget (billingAccounts/ACCOUNT/budgets/ID) |
| <a name="output_pubsub_topic"></a> [pubsub\_topic](#output\_pubsub\_topic) | Pub/Sub topic receiving budget notifications, or null when none is configured |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Role and Permissions

<!-- BEGINNING OF PRE-COMMIT-PIKE DOCS HOOK -->
The Terraform resource required is:

```golang
# apply role
resource "google_project_iam_custom_role" "terraform_pike" {
  project     = "pike-477416"
  role_id     = "terraform_pike"
  title       = "terraform_pike"
  description = "A user with least privileges"
  permissions = [
    "billing.budgets.create",
    "billing.budgets.delete",
    "billing.budgets.get",
    "billing.budgets.update",
    "cloudkms.cryptoKeys.getIamPolicy",
    "cloudkms.cryptoKeys.setIamPolicy",
    "pubsub.topics.create",
    "pubsub.topics.delete",
    "pubsub.topics.get",
    "pubsub.topics.getIamPolicy",
    "pubsub.topics.setIamPolicy",
    "pubsub.topics.update",
    "resourcemanager.projects.get"
  ]
}

# plan role
resource "google_project_iam_custom_role" "terraform_pike_plan" {
  project     = "pike-477416"
  role_id     = "terraform_pike_plan"
  title       = "terraform_pike_plan"
  description = "A user with least privileges"
  permissions = [
    "billing.budgets.get",
    "cloudkms.cryptoKeys.getIamPolicy",
    "pubsub.topics.get",
    "pubsub.topics.getIamPolicy",
    "resourcemanager.projects.get"
  ]
}


```
<!-- END OF PRE-COMMIT-PIKE DOCS HOOK -->

## Help

**Got a question?**

File a GitHub [issue](https://github.com/jameswoolfenden/terraform-gcp-billing-budget/issues).

## Contributing

### Bug Reports & Feature Requests

Please use the [issue tracker](https://github.com/jameswoolfenden/terraform-gcp-billing-budget/issues) to report any bugs or file feature requests.

## Copyrights

Copyright © 2026 James Woolfenden

## License

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

See [LICENSE](LICENSE) for full details.

Licensed to the Apache Software Foundation (ASF) under one
or more contributor license agreements. See the NOTICE file
distributed with this work for additional information
regarding copyright ownership. The ASF licenses this file
to you under the Apache License, Version 2.0 (the
"License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at

<https://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing,
software distributed under the License is distributed on an
"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
KIND, either express or implied. See the License for the
specific language governing permissions and limitations
under the License.

### Contributors

[![James Woolfenden][jameswoolfenden_avatar]][jameswoolfenden_homepage]<br/>[James Woolfenden][jameswoolfenden_homepage]

[jameswoolfenden_homepage]: https://github.com/jameswoolfenden
[jameswoolfenden_avatar]: https://github.com/jameswoolfenden.png?size=150
