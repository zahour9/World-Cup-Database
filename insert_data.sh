#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE TABLE games, teams RESTART IDENTITY")
declare -a TEAMS=()
while IFS="," read -r YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # Insert teams into the TEAMS array
  ARR=("$WINNER" "$OPPONENT")
  for i in "${ARR[@]}"; do
    found=0
    for TEAM in "${TEAMS[@]}"; do
      if [[ "$TEAM" == "$i" ]]; then
        found=1
        break
      fi
    done
    if [[ $found -eq 0 ]]; then
      TEAMS+=("$i")
    fi
  done
  # Insert teams into the database
for TEAM_INSERT in "${TEAMS[@]}"; do
  EXISTING_TEAM=$($PSQL "SELECT name FROM teams WHERE name='$TEAM_INSERT';")
  if [[ -z "$EXISTING_TEAM" ]]; then
    INSERT_TEAMS=$($PSQL "INSERT INTO teams(name) VALUES('$TEAM_INSERT')")
    echo $INSERT_TEAMS
  fi
done
   #get winner_id
  WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")
  #get opponent_id
  OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")
  # Insert in games table
  INSERT_GAME=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, opponent_goals, winner_goals) VALUES('$YEAR', '$ROUND', $WINNER_ID, $OPPONENT_ID, $OPPONENT_GOALS, $WINNER_GOALS)")
  echo $INSERT_GAME
done < testfile.csv
