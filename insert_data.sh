#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

get_team_id () {
  TEAM_NAME=$1
  # get team_id for team from database table teams
  TEAM_ID="$($PSQL "SELECT team_id FROM teams WHERE name = '$TEAM_NAME'")"
  # if no team_id for team in database table teams, then insert team into database table teams and get id
  if [[ -z $TEAM_ID ]]
  then
    $PSQL "INSERT INTO teams(name) VALUES ('$TEAM_NAME');" > /dev/null
    TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$TEAM_NAME'")
    #TEAM_ID_AND_INSERT_REPORT="$($PSQL "INSERT INTO teams(name) VALUES ('$TEAM_NAME') RETURNING team_id;")"
    #echo $TEAM_ID_AND_INSERT_REPORT | while IFS=' ' read REPORT_TEAM_ID INSERT_KEYWORD REPORT_ZERO REPORT_ONE
    #do
    #  TEAM_ID=$REPORT_TEAM_ID
    #done
  fi
  echo $TEAM_ID
}

insert_row_into_games_table () {
  game_year=$1
  game_round=$2
  game_winner_goals=$3
  game_opponent_goals=$4
  game_winner_team_id=$5
  game_opponent_team_id=$6
  echo $($PSQL "INSERT INTO games(year, round, winner_goals, opponent_goals, winner_id, opponent_id) VALUES ($game_year, '$game_round', $game_winner_goals, $game_opponent_goals, $game_winner_team_id, $game_opponent_team_id)")
}

cat games.csv | while IFS=',' read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != 'year' ]]
  then
    WINNER_TEAM_ID=$(get_team_id "$WINNER")
    OPPONENT_TEAM_ID=$(get_team_id "$OPPONENT")
    insert_row_into_games_table $YEAR "$ROUND" $WINNER_GOALS $OPPONENT_GOALS $WINNER_TEAM_ID $OPPONENT_TEAM_ID
  fi
done
