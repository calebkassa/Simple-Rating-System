# Caleb Kassa
# This script creates a dataframe with all 351 Division 1 Women's Basketball 
# teams and their corresponding organization id's. It then creates a csv 
# named 'teams.csv' for the data.

sport = 'WBB'
url <- paste0('http://stats.ncaa.org/team/inst_team_list?sport_code=', sport, 
              '&division=1')
x <- scan(url, what="", sep="\n")
head(x, 20)

x <- gsub(".*team/", "", x) # remove everything before id
x <- gsub(",", "", x) # remove all commas
x <- gsub("/[[:digit:]]*\">", ",", x) # remove chars between id and team name
x <- gsub("<[^<>]*>", "", x) # remove all other tags

# clean up the names
x <- gsub("&amp;", "&", x) # fix ampersand
x <- gsub("&#x27;", "'", x) # fix apostrophe

y <- strsplit(x, split=",")
table(sapply(y, length)) # check lengths, 351 teams
y <- y[which(sapply(y, length)==2)] # subset of teams only
teams.mat <- matrix(unlist(y), ncol=2, byrow=T)
teams <- data.frame(team=teams.mat[, 2],
                    orgid=teams.mat[, 1])

write.csv(teams, "teams.csv", row.names=F)
