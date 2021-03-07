# Simple-Rating-System
I scraped the game results of every Division 1 Women's Basketball Game in the last five years from ncaa.stats.org, and used the Simple Rating System to be able to predict the point differential of a game played by two Division 1 teams.

## team_ids.R
This script grabs the `team_id` that the NCAA uses as a unique identifier for each team and saves them in 'teams.csv'

## get_pages.R
This script uses the `team_ids` in 'allteams.csv' to grab each team's game schedule, including the results, and save them to my computer locally in a foler called 'team_pages'.

## create_df.R
This script creates a function to extract the game information from the html pages in 'team_pages' and creates a dataframe. It then applies this function to a large list of each team's html pages to create one big dataframe of every team's results in the last five years called 'all_teams.csv'.

## prediction.R
This script performs SRS on the data in 'all_teams.csv'.
