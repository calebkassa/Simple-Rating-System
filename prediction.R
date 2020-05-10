# Caleb Kassa
# This script will be used for prediction.
# I will use the Simple Rating System to create relative strenghts for 
# each team. I create a matrix A that has dimensions m x n+1, where m
# is each game played in the season and n is the number of Division I 
# teams that played in that season. Each entry in the matrix will be a 1 
# if team j won game i, -1 if team j lost game i, and 0 if team j did not 
# participate in game i. The extra column records a 1/-1/0
# to denote home/away/neutral games. We will also create a column vector 
# b that hase the point differentials from each of the m games. Lastly, 
# we will find the vector of team strengths x by solving the equation 
# Ax = b.
# See this link for inspiration:
# https://www.pro-football-reference.com/blog/index4837.html?p=37
#
# For the sake of interpretability, I've decided to make the predictions 
# from the perspective of Home vs Away team, rather than Team vs Opponent. 
# To do this, I create a new 'location' vector that indicates home/away/neutral 
# from the perspective of the winner instead of the perspective of 'team'.


df <- read.csv('prediction_df.csv', as.is = T)

# Add a W/L column for team and opponent:
df$t.result <- ifelse(df$teamscore > df$opponentscore, 1, -1)
df$o.result <- -df$t.result

# Add a point differential column: Must be absolute value
# so differential is winningscore - losingscore instead of 
# teamscore - opponentscore
df$ptdiff <- abs(df$teamscore - df$opponentscore)

# Convert Home/Away/Neutral to 1/-1/0:
location <- ifelse(df$location == "Home", 1, 
                      ifelse(df$location == "Away", -1, 0))

# But this is in the team/opponent framework, we must 
# assign home/away from the point of view of winner/loser:
location <- ifelse(df$t.result == -1, -location, location)

# Create matrix A and set column names:
teams <- unique(c(df$team, df$opponent))
A <- matrix(data = 0, nrow = nrow(df), ncol = (length(teams) + 1))
colnames(A) <- c("location", teams)

# Fill matrix:
for (i in 1:nrow(df)) {
  A[i, 1] <- location[i]
  A[i, df$team[i]] <- df$t.result[i]
  A[i, df$opponent[i]] <- df$o.result[i]
}

# Create Point Differential column matrix:
b <- matrix(data = df$ptdiff, ncol = 1)

# Solve for ratings:
x <- lsfit(A, b, intercept = F)

# Make a dataframe of the teams and their coefficients:
pred.df <- data.frame(teams = colnames(A),
                      coeffs = x$coefficients,
                      row.names = NULL)

# Make predictions
## For home/away games:
h.team <- sample(teams, 1)
a.team <- sample(setdiff(teams, h.team), 1)
pred <- as.numeric(x$coefficients[h.team] - x$coefficients[a.team] + 
                     x$coefficients["location"])

## For neutral site games:
n.team1 <- sample(teams, 1)
n.team2 <- sample(setdiff(teams, n.team1), 1)
pred <- as.numeric(x$coefficients[n.team1] - x$coefficients[n.team2] + 
                     0 * x$coefficients["location"])





