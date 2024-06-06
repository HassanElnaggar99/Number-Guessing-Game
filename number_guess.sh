#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))
# SECRET_NUMBER=10

# ask for username
echo "Enter your username:"
read USERNAME

USER_DETAILS=$($PSQL "SELECT * FROM users WHERE username = '$USERNAME';")
# check if user is not empty
if [[ -n $USER_DETAILS ]]
then
  # show user properties
  echo $USER_DETAILS | while IFS=" | " read USER_ID TEMP GAMES_PLAYED BEST_GAME
  do
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done
else
  # show welcome message
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME');")
fi

echo "Guess the secret number between 1 and 1000:"

GUESS=0
NUMBER_OF_GUESSES=0
while [[ $GUESS -ne $SECRET_NUMBER ]]
do
  read GUESS
  if [[ -z $GUESS || ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  elif (( $GUESS > $SECRET_NUMBER ))
  then
    echo "It's lower than that, guess again:"
  elif (( $GUESS < $SECRET_NUMBER ))
  then
    echo "It's higher than that, guess again:"
  fi
  (( NUMBER_OF_GUESSES++ ))
done

# update database
if [[ -z $USER_DETAILS ]] 
then
  INSERT_GAME_RESULT=$($PSQL "UPDATE users SET games_played = 1, best_game = $NUMBER_OF_GUESSES WHERE username='$USERNAME'")
else
  echo $USER_DETAILS | while IFS=" | " read USER_ID TEMP GAMES_PLAYED BEST_GAME
  do
    (( GAMES_PLAYED++ ))
    if (( BEST_GAME > NUMBER_OF_GUESSES ))
    then
      BEST_GAME=$NUMBER_OF_GUESSES
    fi
    INSERT_GAME_RESULT=$($PSQL "UPDATE users SET games_played = $GAMES_PLAYED, best_game = $BEST_GAME WHERE username='$USERNAME'")
  done
fi

# show results
echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
