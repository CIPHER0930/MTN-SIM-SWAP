import requests
import json

# Get the SIM swap customer ID from the URL.
def get_customer_id():
  sim_swap_url = "https://api.mtn.com/v1/simManagement/customers/{customerId}/simSwap"
  customer_id = sim_swap_url.split("/")[5]
  return customer_id


# Validate the user's input.
def validate_input(old_sim_card_number, new_sim_card_number):
  if not old_sim_card_number.isdigit() or len(old_sim_card_number) != 10:
    raise ValueError("Invalid old SIM card number.")
  if not new_sim_card_number.isdigit() or len(new_sim_card_number) != 10:
    raise ValueError("Invalid new SIM card number.")


# Make the SIM swap request.
def make_sim_swap_request(mtn_api_key, customer_id, old_sim_card_number, new_sim_card_number):
  headers = {
    "Authorization": f"Bearer {mtn_api_key}",
    "Content-Type": "application/json",
  }
  payload = {
    "oldSimCardNumber": old_sim_card_number,
    "newSimCardNumber": new_sim_card_number,
  }

  response = requests.post(
    f"https://api.mtn.com/v1/simManagement/customers/{customer_id}/simSwap", headers=headers, json=payload
  )

  # Check the response status code.
  if response.status_code != 200:
    raise Exception("Failed to make SIM swap request.")


# Main function.
def main():
  # Prompt the user for their old and new SIM card numbers.
  old_sim_card_number = input("Enter your old SIM card number: ")
  new_sim_card_number = input("Enter your new SIM card number: ")

  # Validate the user's input.
  validate_input(old_sim_card_number, new_sim_card_number)

  # Get the SIM swap customer ID from the URL.
  customer_id = get_customer_id()

  # Prompt the user for their login credentials.
  username = input("Enter your MTN username: ")
  password = input("Enter your MTN password: ")

  # Get the API key from the login response.
  login_response = requests.post(
    "https://api.mtn.com/v1/auth/login", json={"username": username, "password": password}
  )
  login_response.raise_for_status()

  mtn_api_key = login_response.json()["token"]

  # Make the SIM swap request.
  make_sim_swap_request(mtn_api_key, customer_id, old_sim_card_number, new_sim_card_number)

  # Print a success message to the user.
  print("SIM swap request was successful.")


if __name__ == "__main__":
  main()
