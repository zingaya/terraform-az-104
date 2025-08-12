######################################
# CURRENT AZURE SUBSCRIPTION DATA
######################################
# This data source fetches details of the current subscription
# where Terraform is authenticated. Used to avoid hardcoding subscription ID.
data "azurerm_subscription" "current" {}

######################################
# SUBSCRIPTION BUDGET CONFIGURATION
######################################
# Create a budget for the current subscription with a monthly limit of $1.00
resource "azurerm_consumption_budget_subscription" "example" {
  name            = "Freetier"                    # Budget name identifier
  subscription_id = data.azurerm_subscription.current.id  # Link budget to current subscription
  amount          = 1.00                           # Budget limit in USD
  time_grain      = "Monthly"                      # Budget resets every month

  time_period {
    start_date = "2025-08-01T00:00:00Z"           # Budget active start date (UTC)
    end_date   = "2035-09-01T00:00:00Z"           # Budget active end date (UTC)
  }

  notification {
    enabled   = true                               # Enable alert notification
    threshold = 90.0                               # Alert when 90% of budget spent
    operator  = "GreaterThan"                      # Condition: budget spent exceeds threshold

    contact_emails = var.email                      # Send alert email to this address(es)
  }

  notification {
    enabled        = false                          # Disabled alert for forecasted spend
    threshold      = 100.0                          # Would trigger alert at 100% forecasted spend
    operator       = "GreaterThan"                  # Condition: forecasted spend exceeds threshold
    threshold_type = "Forecasted"                   # Applies to forecasted budget consumption

    contact_emails = var.email                      # Email recipients for this notification
  }
}
