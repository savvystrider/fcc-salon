#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo "Welcome to My Salon, how can I help you?"
  echo -e "\n1) cut\n2) color\n3) perm\n4) style\n5) trim"
  read SERVICE_ID_SELECTED

  case $SERVICE_ID_SELECTED in
    1) SERVICE_NAME="cut" ;;
    2) SERVICE_NAME="color" ;;
    3) SERVICE_NAME="perm" ;;
    4) SERVICE_NAME="style" ;;
    5) SERVICE_NAME="trim" ;;
    *) MAIN_MENU "I could not find that service. What would you like today?" ; return ;;
  esac

  APPOINTMENT_MENU
}

APPOINTMENT_MENU() {
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  # look up customer phone number
  QUERY_CUSTOMER=$($PSQL "SELECT customer_id, name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  # if phone number doesn't exist
  if [[ -z $QUERY_CUSTOMER ]]
  then
    echo -e "\nI don't have a record for that phone number, what's your name?"

    # get customer name
    read CUSTOMER_NAME

    # insert customer into database
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")

    # get new customer ID
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  else
    CUSTOMER_ID=$(echo $QUERY_CUSTOMER | cut -d'|' -f1 | xargs) # clean up the query result
    CUSTOMER_NAME=$(echo $QUERY_CUSTOMER | cut -d'|' -f2 | xargs)
  fi

  echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
  read SERVICE_TIME

  # insert appointment into database
  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, (SELECT service_id FROM services WHERE name='$SERVICE_NAME'), '$SERVICE_TIME')")

  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
}

MAIN_MENU
