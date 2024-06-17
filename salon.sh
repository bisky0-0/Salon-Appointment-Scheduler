#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only  -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU(){
  if [[ $1 ]]
     then 
        echo -e "\n$1\n"
    else
        echo -e "Welcome to My Salon, how can I help you?\n"    
  fi

  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  # echo  "$SERVICES"

  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  read SERVICE_ID_SELECTED

  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then MAIN_MENU "That's not a valid service number"
  else 
     CHOSEN_SERVICE=$($PSQL "SELECT * FROM services WHERE service_id=$SERVICE_ID_SELECTED")

     if [[ -z $CHOSEN_SERVICE ]]  
       then MAIN_MENU "I could not find that service. What would you like today?"

       else 
       echo -e "\nWhat's your phone number?"
       read CUSTOMER_PHONE

       CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

       if [[ -z $CUSTOMER_NAME ]]
        then
          echo -e "\nI don't have a record for that phone number, what's your name?"
          read CUSTOMER_NAME
          SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id='$SERVICE_ID_SELECTED'")
          echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
          read SERVICE_TIME

          INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO CUSTOMERS(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
          CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
          CUSTOMER_TIME=$($PSQL "INSERT INTO appointments(time, customer_id, service_id) VALUES('$SERVICE_TIME', $CUSTOMER_ID, $SERVICE_ID_SELECTED)")


          echo -e "\nI have put you down for a$SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME.\n\n"


          else
          echo -e "\nWhat time would you like your '$SERVICE_NAME', '$CUSTOMER_NAME'?"
          read SERVICE_TIME
          CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
          CUSTOMER_TIME=$($PSQL "INSERT INTO appointments(time, customer_id, service_id) VALUES('$SERVICE_TIME', $CUSTOMER_ID, $SERVICE_ID_SELECTED)")
           
       fi    
           
     fi  
  fi  
}

MAIN_MENU