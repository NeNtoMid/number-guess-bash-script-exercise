#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USERNAME

USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")

if [[ -z $USER_ID ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_USERNAME=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
else
  GAMES_PLAYED=$($PSQL "SELECT COUNT(user_id) FROM games WHERE user_id=$USER_ID")
  BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games WHERE user_id=$USER_ID")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# guessing game

GUESS() {
  SECRET_NUMBER=$(( $RANDOM % 1000 + 1 ))
  NUMBER_OF_GUESSES=0

  echo "Guess the secret number between 1 and 1000:"

  while true
  do
    read GUESSING_NUMBER
    if [[ ! $GUESSING_NUMBER =~ ^[0-9]+$ ]]
    then
      echo -"\nThat is not an integer, guess again:"
    else
      if [[ $GUESSING_NUMBER -gt $SECRET_NUMBER ]]
      then
        NUMBER_OF_GUESSES=$(($NUMBER_OF_GUESSES+1))
        echo "It's lower than that, guess again:"
      fi
      if [[ $GUESSING_NUMBER -lt $SECRET_NUMBER ]]
      then
        NUMBER_OF_GUESSES=$(($NUMBER_OF_GUESSES+1))
        echo "It's higher than that, guess again:"
      fi
      if [ $GUESSING_NUMBER -eq $SECRET_NUMBER ]
      then
        NUMBER_OF_GUESSES=$(($NUMBER_OF_GUESSES+1))
        GAME_RESULT=$($PSQL "INSERT INTO games(guesses, user_id) VALUES($NUMBER_OF_GUESSES, $USER_ID)")
        echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
        break
      fi
    fi
  done

}

GUESS