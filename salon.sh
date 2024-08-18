#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

echo -e "Welcome to My Salon, how can I help you?\n"

MAIN_MENU() {

  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  # list of all available services
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id;")
  
  # loop of the list of services
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
  
  # select the service
  read SERVICE_ID_SELECTED
  SERVICE_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id = '$SERVICE_ID_SELECTED';")

  # if service exist or not exist
  if [[ -z $SERVICE_SELECTED ]]
  then
    echo -e "\nI could not find that service. What would you like today?"
    MAIN_MENU
  else
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    # get phone number of the customer
    CUSTOMER=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    
    # if costumer exist
    if [[ -z $CUSTOMER ]]
    then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      # send data to database
      INSERT_DATA_CUSTOMER=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
      # call ADD_TIME function
      ADD_TIME $SERVICE_SELECTED $CUSTOMER_NAME
    else
      # call ADD_TIME function
      ADD_TIME $SERVICE_SELECTED $CUSTOMER
    fi
  fi
}

ADD_TIME(){
  echo -e "\nWhat time would you like your $1, $2?"
  read SERVICE_TIME

  GET_CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE name = '$2'")
  GET_SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE name = '$1'")

  # send data for create a appointment
  ADD_APPOINTMENT=$($PSQL "INSERT INTO appointments (time, customer_id, service_id) VALUES ( '$SERVICE_TIME', '$GET_CUSTOMER_ID', '$GET_SERVICE_ID')")

  if [[ $ADD_APPOINTMENT = 'INSERT 0 1' ]]
  then
    echo -e "\nI have put you down for a $1 at $SERVICE_TIME, $2."
  else
    echo -e "\nError in safe data"
  fi
}

MAIN_MENU
