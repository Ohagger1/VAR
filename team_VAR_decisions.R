library(rvest)
library(dplyr)
library(stringr)
library(tidyr)

# Define the URL
VAR_PAGE_2020_2021 <- "https://www.espn.com/soccer/english-premier-league/story/3929823/how-var-decisions-have-affected-every-premier-league-club"

# Read the webpage
page <- read_html(VAR_PAGE_2020_2021)

VAR_team <- page %>%
  html_nodes("aside.inline.editorial.float-r") %>%
  html_text()
VAR_team <- VAR_team[2:3]

split_lines <- strsplit(VAR_team, "\n")
split_lines <- lapply(split_lines, function(x) x[-1])

print(split_lines)

decisions_for <- list(split_lines[[1]])
decisions_against <- list(split_lines[[2]])



# Combine the decisions_for and decisions_against lists
#combined_decisions <- c(decisions_for, decisions_against)

# Initialize empty data frame
data_df_for <- data.frame(team = character(0), count = character(0))
data_df_against <- data.frame(team = character(0), count = character(0))

# Iterate through each list and extract data
for (lines in decisions_for) {
  team <- str_extract(lines, "([\\w\\s&]+)")
  team <- gsub("\\d+", "", team)
  count <- str_extract(lines, "\\d+")
  
  data_df_for <- data_df_for %>%
    add_row(team = team, count = count)
}

for (lines in decisions_against) {
  team <- str_extract(lines, "([\\w\\s&]+)")
  team <- gsub("\\d+", "", team)
  count <- str_extract(lines, "\\d+")
  
  data_df_against <- data_df_against %>%
    add_row(team = team, count = count)
}

# Print the resulting data frame
print(data_df)

combined_data <- full_join(data_df_for, data_df_against, by = "team")

# Rename columns
colnames(combined_data) <- c("team", "count_for", "count_against")

# Print the combined data frame
print(combined_data)

combined_data$year <- '2019/2020'

setwd("C:/Users/ohagg/OneDrive - University College London/Desktop/VAR_scraping")
# Assuming you have a data frame called combined_data and a year variable
year <- '2019_2020'
csv_file_name <- paste0("VAR_decisions", year, ".csv")

write.csv(combined_data, csv_file_name, row.names = T)


