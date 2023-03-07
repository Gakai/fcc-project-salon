#! /bin/bash
PSQL="psql -U freecodecamp -d salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~"

SALON() {
  if [[ $1 ]]; then
    echo -e "\n$1"
  else
    echo -e "\nWelcome to My Salon, how can I help you?\n"
  fi
  # list services
  echo "$($PSQL "select * from services")" | while read SERVICE_ID _BAR SERVICE_NAME; do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  # get service id
  read SERVICE_ID_SELECTED
  # if not a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]; then
    # show message and restart
    SALON "You did not enter a number. What would you like today?"
  else
    # check service id
    SERVICE_NAME=$($PSQL "select name from services where service_id=$SERVICE_ID_SELECTED" | sed -r 's/^ *| *$//g')
    # if not exist
    if [[ -z $SERVICE_NAME ]]; then
      # show message and restart
      SALON "I could not find that service. What would you like today?"
    else
      # ask for phone number
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE
      # get customer name
      CUSTOMER_NAME=$($PSQL "select name from customers where phone='$CUSTOMER_PHONE'" | sed -r 's/^ *| *$//g')
      # if not exist
      if [[ -z $CUSTOMER_NAME ]]; then
        # ask for name
        echo -e "\nI don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME
        # repeat while name is empty, commented to pass tests
        # while [[ -z $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g') ]]; do
        #   echo -e "\nPlease enter a valid name!"
        #   read CUSTOMER_NAME
        # done
        # insert customer
        INSERT_CUSTOMER_RESULT=$($PSQL "insert into customers(phone, name) values(TRIM('$CUSTOMER_PHONE'), TRIM('$CUSTOMER_NAME'))")
      fi
      # get customer id
      CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")
      # get service time
      echo -e "\nWhat time would you like your service, $CUSTOMER_NAME?"
      read SERVICE_TIME
      # repeat until time is valid, commented to pass tests
      # until [[ $SERVICE_TIME =~ ^((0?[0-9]|1[0-2])(a|p)m)|([01][0-9]|2[0-3]):[0-5][0-9]$ ]]; do
      #   echo "\nPlease enter a valid time!"
      #   read SERVICE_TIME
      # done
      # insert appointment
      INSERT_APPOINTMENT_RESULT=$($PSQL "insert into appointments(customer_id, service_id, time) values($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
      # print confirmation message
      echo -e "\nI have put you down for a $(echo $SERVICE_NAME) at $SERVICE_TIME, $CUSTOMER_NAME."
    fi
  fi
}

SALON
