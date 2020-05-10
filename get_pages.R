# Caleb Kassa
# This script fetches each team's html script from the NCAA website 
# and saves it locally in the folder 'team_pages'.
# Collaborated with Aedan Lombardo for use of try().

teams <- read.csv("teams.csv", as.is = T)

for (i in 1:nrow(teams)) {
  Sys.sleep(runif(1, 2, 4)) # Pause for 2-4 seconds in between each query
  url <- paste0('https://stats.ncaa.org/team/', teams[i,2], '/15002')
  file.name <- paste0("team_pages/team", teams[i,2], ".html")
  html.page <- try(scan(url, what = "", sep = "\n"))
  if (html.page == "try-error"){
    cat(paste("Error fetching:", url, "\n"))
  }
  else
    writeLines(html.page, file.name)
}

                 
