#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~ Hello in Salon Appointment Scheduler ~~\n"

MAIN_MENU () {
  CUSTOMER_CHOICE
  CUSTOMER_INFO
  SELECT_TIME
}

CUSTOMER_CHOICE () {
  SERVICE_INFO=$($PSQL "SELECT service_id, name FROM services")
  echo -e "\nHere are the services we offer:"
  echo "$SERVICE_INFO" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
  echo -e "\nPick a service please."
  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED == [1-5] ]]
  then
    echo "That is not a valid service."
    CUSTOMER_CHOICE
  else
    SERVICE_NAME_TO_SELECT=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED") 
  fi
}

CUSTOMER_INFO () {
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE 
  if [[ -z $CUSTOMER_PHONE ]] 
  then
    echo "Please input valid phone number (XXX-XXX-XXXX)" 
    CUSTOMER_INFO 
  else
    CHECKED_PHONE=$($PSQL "SELECT phone FROM customers WHERE phone='$CUSTOMER_PHONE'")
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE' AND name IS NULL")
    if [[ -z $CHECKED_PHONE ]]
    then
      echo -e "\nWhat's your name?"
      read CUSTOMER_NAME
      if [[ -z $CUSTOMER_NAME ]]
      then
        echo "We need a name dude, why so sus?"
        CUSTOMER_INFO 
      else
        INSERT_CUSTOMER_INFO=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
      fi
    else 
      if [[ ! -z $CUSTOMER_NAME ]]
      then
        echo -e "\nWhat's your name?"
        read CUSTOMER_NAME
        INSERT_CUSTOMER_NAME=$($PSQL "UPDATE customers SET name='$CUSTOMER_NAME' WHERE phone='$CUSTOMER_PHONE'")
      fi
    fi
  fi
}

SELECT_TIME () {
  echo -e "\nAt what time should we schedule you? (hh:mm)"
  read SERVICE_TIME
  if [[ -z $SERVICE_TIME ]]
  then
    echo "Please give us valid time hh:mm"
    SELECT_TIME 
  else
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    if [[ -z $CUSTOMER_NAME ]]
    then
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
    else
      SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id='$SERVICE_ID_SELECTED'")
      INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(service_id, customer_id, time) VALUES($SERVICE_ID_SELECTED, $CUSTOMER_ID, '$SERVICE_TIME')")
      echo -e "\nI have put you down for a $(echo $SERVICE_NAME| sed -E 's/^ +| +$//g') at $(echo $SERVICE_TIME, $CUSTOMER_NAME| sed -E 's/^ +| +$//g')."
    fi
  fi
}

EXIT () {
  echo -e "\nThank you!"
}

MAIN_MENU