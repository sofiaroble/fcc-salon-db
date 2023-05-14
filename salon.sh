#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo "Welcome to My Salon, how can I help you?"

MAIN_MENU() {
  if [[ $1 ]]; then
    echo -e "\n$1"
  fi
  
  # Display available services
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  
  # If there are no services available
  if [[ -z $SERVICES ]]; then
    echo "Sorry, we don't have any services right now."
  else
    # Show the available services
    echo -e "Here are the services we offer:"
    echo "$SERVICES" | while read SERVICE_ID BAR NAME; do
      echo "$SERVICE_ID) $NAME"
    done
    read SERVICE_ID_SELECTED
    # Check if the selected service exists
    SERVICE_EXISTS=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")

    if [[ -z $SERVICE_EXISTS ]]; then
      MAIN_MENU "I could not find that service. What would you like today?"
    fi
  fi
}

MAIN_MENU
# get customer phone number
echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE

# Check if the customer exists
CUSTOMER_EXISTS=$($PSQL "SELECT customer_id, name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

if [[ -z $CUSTOMER_EXISTS ]]; then
  # if it's a new customer
  # get the name, phone and include it to the table with the selected service
  echo -e "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  CUSTOMER_ID=$($PSQL "INSERT INTO customers(phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME') RETURNING customer_id")
else
  # if the customer already exists
  read CUSTOMER_ID CUSTOMER_NAME <<< "$CUSTOMER_EXISTS"
fi

SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

echo "What time would you like your $(echo $SERVICE_NAME | sed 's/|//g'), $(echo $CUSTOMER_NAME | sed 's/|//g')?"
read SERVICE_TIME


APPOINTMENT_INSERTION=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed -r 's/^ *| *$|\|//g')  at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$|\|//g')."
