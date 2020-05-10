# Caleb Kassa
# This script creates a list of the html pages from all 351 for the past 
# 6 seasons (retrieved by Jay Emerson). We then create a function that 
# takes an html page, extracts the desired information from that page and 
# creates a dataframe. Lastly, we apply the function to all teams and seasons, 
# and combine them all to create one large dataframe.

files <- dir("WBB_Historic/WBB_multiple", full.names=TRUE, pattern="RData")
length(files)                                                    # 351

# Pull them in and get them into a list of length 351.
temp <- sapply(files, load, envir=.GlobalEnv)
all <- lapply(temp, get)
names(all) <- temp

rm(list=ls(pattern="team.*|temp|files"))           # Housekeeping

create.df <- function(x) {
  # I'll take care of these now so I don't have to remember later:
  x <- gsub("&amp;", "&", x)
  x <- gsub("&#x27;", "'", x)
  
  # Get the team name:
  team <- grep("<legend><img alt=", x, value = T)
  team <- trimws(gsub("<legend><img alt=\\\"(.*)\\\" height.*", "\\1", team))
  
  # Obtain the line numbers containing the game dates:
  dateLines <- grep("<td>\\d+/\\d+/\\d+", x)
  # Error for Old Dominion vs Villanova 2018-19; fix date:
  x[dateLines] <- gsub("(<td>\\d+/\\d+/\\d+).*)", "\\1", x[dateLines])
  
  temp <- paste(x[dateLines], x[dateLines+2], x[dateLines+5], sep=";")
  temp <- gsub("<br/>@.*;", "@N;", temp) # For neutral site games
  temp <- gsub("<br/>.*;", ";", temp) # For neutral site games
  temp <- gsub("<[^<>]*>", "", temp)
  temp <- gsub("/", ";", temp)
  unplayedLines <- grep("\\d-\\d", temp, invert = T)
  temp[unplayedLines] <- paste(temp[unplayedLines], "X 0-0")
  temp <- gsub("([WLX]) (\\d+)-(\\d+)", "\\1;\\2;\\3", temp)
  y <- matrix(trimws(unlist(strsplit(temp, ";"))),
              ncol=7, byrow=TRUE)
  
  # Create a location vector:
  location.v <- ifelse(grepl("^@", y[,4]), "Away",
                       ifelse(grepl("@N", y[,4]), "Neutral", "Home"))
  
  # Clean the opponent column:
  y[,4] <- gsub("@N", "", y[,4])
  y[,4] <- gsub("@", "", y[,4])
  y[,4] <- trimws(gsub("#\\d+", "", y[,4]))
  
  # Create a vector for OT:
  ot.v <- rep(0, nrow(y))
  ot.index <- grep("OT", y[,7])
  ot.v[grep("OT", y[,7])] <- gsub("(\\d+) .(\\d+) (OT))", "\\2", y[ot.index,7])
  ot.v <- as.numeric(ot.v)
  
  # Clean opponent scores (remove OTs):
  y[,7] <- gsub(" .*", "", y[,7])
  
  # Clean year column (remove time):
  y[,3] <- gsub(" .*", "", y[,3])
  
  # Set scores and overtime in unplayed games to NA:
  y[unplayedLines, c(6,7)] <- NA
  ot.v[unplayedLines] <- NA
  
  # Add season:
  min.year <- min(unique(y[,3]))
  max.year <- max(unique(y[,3]))
  season <- paste0(min.year, "-", substr(max.year, 3, 4))
  
  # Create data frame:
  df <- data.frame(team = rep(team, nrow(y)),
                   season = rep(season, nrow(y)), opponent = y[,4],
                   year = as.integer(y[,3]), month = as.integer(y[,1]),
                   day = as.integer(y[,2]), teamscore = as.integer(y[,6]),
                   opponentscore = as.integer(y[,7]),
                   location = location.v, overtime = ot.v,
                   stringsAsFactors = F)
  return(df)
}


# Replace the pages from the 2019-20 season with my more recent pull:
files <- dir("team_pages", full.names = T)
for (i in 1:length(all)) {
  all[[i]][["2019-20"]] <- scan(files[i], what = "", sep = "\n")
}

# Run the function on a list of all teams and seasons, and create a data frame:
x <- lapply(all, function(team) lapply(team, create.df))
df <- do.call(rbind, do.call(rbind, x))

# Sanity Check:
length(unique(df$team))      # 351
summary(df$teamscore)        # A case where a team scores 0 points?
                                # Confirmed, Southern U. vs Texas Southern: 0-0.
summary(df$overtime)         # A game with 5 overtimes... Sheesh.
length(unique(df$opponent))  #
table(df$location)           # 


# Looks like we're good. Create the csv:
write.csv(df, "all_teams.csv", row.names = F)


