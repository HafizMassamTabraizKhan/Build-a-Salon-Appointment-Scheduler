#!/bin/bash

# Connect to the database
PSQL="psql --username=postgres --dbname=salon -t --no-align -c"

# Function to display services
DISPLAY_SERVICES() {
  echo -e "\n~~~~~ Salon Services ~~~~~\n"
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id;")
  echo "$SERVICES" | while IFS="|" read SERVICE_ID SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
}

# Function to get a valid service ID
GET_VALID_SERVICE() {
  while true
  do
    DISPLAY_SERVICES
    echo -e "\nPlease select a service by entering the number:"
    read SERVICE_ID_SELECTED

    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED;")
    if [[ -z $SERVICE_NAME ]]; then
      echo -e "\nInvalid selection. Please try again."
    else
      break
    fi
  done
}

# Start flow
GET_VALID_SERVICE

# Prompt for customer phone number
echo -e "\nEnter your phone number:"
read CUSTOMER_PHONE

# Check if customer exists
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE';")

# If not found, prompt for name and insert
if [[ -z $CUSTOMER_NAME ]]; then
  echo -e "\nIt looks like you're a new customer. Please enter your name:"
  read CUSTOMER_NAME

  INSERT_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE');")
fi

# Get customer_id (for inserting appointment)
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")

# Prompt for appointment time
echo -e "\nWhat time would you like your appointment?"
read SERVICE_TIME

# Insert the appointment
INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');")

# Confirm the appointment
SERVICE_NAME_CLEAN=$(echo $SERVICE_NAME | sed 's/^ *//g')
CUSTOMER_NAME_CLEAN=$(echo $CUSTOMER_NAME | sed 's/^ *//g')
echo -e "\nI have put you down for a $SERVICE_NAME_CLEAN at $SERVICE_TIME, $CUSTOMER_NAME_CLEAN."
