#!/bin/bash

# Get the SIM swap customer ID from the URL.
function get_customer_id() {
  local sim_swap_url="https://api.mtn.com/v1/simManagement/customers/{customerId}/simSwap"
  local customer_id=$(echo $sim_swap_url | cut -d '/' -f 5)

  # Return the customer ID.
  echo $customer_id
}

# Validate the user's input.
function validate_input() {
  local old_sim_card_number=$1
  local new_sim_card_number=$2

  if [[ ! "<span class="math-inline">old\_sim\_card\_number" \=\~ ^\[0\-9\]\{10\}</span> ]]; then
    echo "Invalid old SIM card number."
    exit 1
  fi

  if [[ ! "<span class="math-inline">new\_sim\_card\_number" \=\~ ^\[0\-9\]\{10\}</span> ]]; then
    echo "Invalid new SIM card number."
    exit 1
  fi
}

# Make the SIM swap request.
function make_sim_swap_request() {
  local mtn_api_key=$1
  local customer_id=$2
  local old_sim_card_number=$3
  local new_sim_card_number=$4

  curl -X POST \
    -H "Authorization: Bearer $mtn_api_key" \
    -H "Content-Type: application/json" \
    -d '{"oldSimCardNumber": "'"$old_sim_card_number"'", "newSimCardNumber": "'"$new_sim_card_number"'"}' \
    https://api.mtn.com/v1/simManagement/customers/<span class="math-inline">customer\_id/simSwap
}

# Main function.
main() {
  # Prompt the user for their old and new SIM card numbers.
  echo "Enter your old SIM card number:"
  read old_sim_card_number

  echo "Enter your new SIM card number:"
  read new_sim_card_number

  # Validate the user's input.
  validate_input "$old_sim_card_number" "<span class="math-inline">new\_sim\_card\_number"

  # Get the SIM swap customer ID from the URL.
  customer_id=$(get_customer_id)

  # Prompt the user for their login credentials.
  echo "Enter your MTN username:"
  read username

  echo "Enter your MTN password:"
  read password

  # Get the API key from the login response.
  mtn_api_key=$(curl -X POST \
    -H "Content-Type: application/json" \
    -d '{"username": "'"$username"'", "password": "'"$password"'"}' \
    https://api.mtn.com/v1/auth/login | jq -r '.token')

  # Make the SIM swap request.
  make_sim_swap_request "$mtn_api_key" "$customer_id" "$old_sim_card_number" "$new_sim_card_number"

  # Handle any errors.
  if [[ $? -ne 0 ]]; then
    echo "Failed to make SIM swap request. Please check your input and try again."
  else
    echo "SIM swap request was successful."
  fi
}

# Call the main function.
main
