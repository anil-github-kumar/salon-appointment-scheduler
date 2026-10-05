#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~"

MAIN_MENU() {

  echo -e "\nHow can I help you?"

  # Display services
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")

  echo "$SERVICES" | while IFS='|' read SERVICE_ID SERVICE_NAME
  do
    SERVICE_ID=$(echo $SERVICE_ID | xargs)
    SERVICE_NAME=$(echo $SERVICE_NAME | xargs)
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  # Ask for service
  echo
  read SERVICE_ID_SELECTED

  # Check if service exists
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

  if [[ -z $SERVICE_NAME ]]
  then
    MAIN_MENU
    return
  fi

  # Ask for phone
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  # Find customer
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

  # New customer
  if [[ -z $CUSTOMER_NAME ]]
  then
    echo -e "\nI don't have a record for that phone number. What's your name?"
    read CUSTOMER_NAME

    $PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')"
  fi

  # Get customer ID
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

  # Ask appointment time
  echo -e "\nWhat time would you like your appointment?"
  read SERVICE_TIME

  # Create appointment
  $PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')"

  # Success message
  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
}

MAIN_MENU