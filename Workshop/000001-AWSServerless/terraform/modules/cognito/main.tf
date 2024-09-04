resource "aws_cognito_user_pool" "cognito_pool_001" {
  name = "example-user-pool"

  # Cognito user pool sign-in options
  alias_attributes = ["email", "preferred_username"]

  # User name requirements
  # username_attributes = ["preferred_username"] # Allow users to sign in with a preferred user name
  username_configuration {
    case_sensitive = false
  }
  # Password policy 
  password_policy {
    minimum_length    = 6
    require_uppercase = false
    require_numbers   = false
    require_symbols   = false
    require_lowercase = false
  }

  # Enable MFA
  mfa_configuration = "OPTIONAL" # Options are "OFF", "ON", or "OPTIONAL"

  # MFA methods
  software_token_mfa_configuration {
    enabled = true
  }

  # User account recovery
  account_recovery_setting {
    recovery_mechanism {
      priority = 1
      name     = "verified_email" # Primary recovery mechanism
    }
  }
  # User create
  auto_verified_attributes = ["email"]
  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
    #CONFIRM_WITH_CODE
    email_message = "Your verification code is {####}. Use this code to verify your email address."
    email_subject = "Verify your email address"
    #CONFIRM_WITH_LINK
    email_message_by_link = "Click {##Click Here##}"
    email_subject_by_link = "email_subject_by_link"
  }
  # Self-service sign-up
  admin_create_user_config {
    # allow_admin_create_user_only = true # Only admins can create users; disable self-service sign-up

    invite_message_template {
      email_message = "Hello {username}, Your account has been created. Your temporary password is {####}. Please log in and change your password."
      email_subject = "Your account has been created"
      sms_message   = "Hello {username}, Your account has been created. Your temporary password is {####}. Please log in and change your password."
    }
  }
  # Custom Attribute
  schema {
    name                = "address"
    attribute_data_type = "String"
    required            = false
    mutable             = true
    string_attribute_constraints {
      min_length = 10
      max_length = 100
    }
  }

  # Configure message delivery
  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }
}

resource "aws_cognito_user_pool_client" "userpool_client" {
  name            = "cognito_client"
  user_pool_id    = aws_cognito_user_pool.cognito_pool_001.id
  generate_secret = false
  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH"
  ]
  callback_urls = [
    "https://yourapp.example.com/callback" # Your application's callback URL
  ]

  logout_urls = [
    "https://yourapp.example.com/logout" # Optional: URL for logging out
  ]
  auth_session_validity = 5
  token_validity_units {
    access_token  = "minutes"
    id_token      = "minutes"
    refresh_token = "hours"
  }
  access_token_validity         = 5
  id_token_validity             = 5
  refresh_token_validity        = 1
  enable_token_revocation       = false
  prevent_user_existence_errors = "ENABLED"
}
