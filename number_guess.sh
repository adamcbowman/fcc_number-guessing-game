#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
SECRET_NUMBER=$((1 + RANDOM % 1000))
counter=0

echo "Enter your username:"
read USERNAME

# Check if username in db
USER_RESULT=$($PSQL "SELECT * FROM users WHERE username = '$USERNAME'")

if [[ -z $USER_RESULT ]]; then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  USER_INSERT=$($PSQL "INSERT INTO users(username, games_played) VALUES ('$USERNAME', 0)")
  GAMES_PLAYED=0
  BEST_GAME=1000
else 
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username='$USERNAME'")
  GAMES_PLAYED=$(echo $GAMES_PLAYED | sed -r 's/^ *| *$//g')
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME'")
  BEST_GAME=$(echo $BEST_GAME | sed -r 's/^ *| *$//g')
  echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses.\n"
fi

echo "Guess the secret number between 1 and 1000:"

while true; do
  read GUESS
  ((counter++))

  # Regular expression to match an integer
  integer_pattern='^[0-9]+$'

  if [[ $GUESS =~ $integer_pattern ]]; then
    if [[ $GUESS -lt $SECRET_NUMBER ]]; then
      echo "It's higher than that, guess again:"

    elif [[ $GUESS -gt $SECRET_NUMBER ]]; then
      echo "It's lower than that, guess again:"
    
    else 
      echo "You guessed it in $counter tries. The secret number was $SECRET_NUMBER. Nice job!"
    
      # Increment the games played in the database
      UPDATED_GAMES_PLAYED=$((GAMES_PLAYED + 1))
      UPDATE_GAMES=$($PSQL "UPDATE users SET games_played = $UPDATED_GAMES_PLAYED WHERE username = '$USERNAME'")
    
      # Update best game if needed
      if [[ $counter -lt $BEST_GAME ]]; then
        UPDATE_BEST=$($PSQL "UPDATE users SET best_game = $counter WHERE username = '$USERNAME'")
      fi
    
      break
    
    fi
  
  else 
    echo "That is not an integer, guess again:"
  fi

done
