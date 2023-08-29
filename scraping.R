library(rvest)
library(dplyr)
library(stringr)

# Define the URL
VAR_PAGE_2020_2021 <- "https://www.espn.com/soccer/english-premier-league/story/3929823/how-var-decisions-have-affected-every-premier-league-club"

# Read the webpage
page <- read_html(VAR_PAGE_2020_2021)

team_list <- page %>%
  html_nodes("div.article-body h2") %>%
  html_text() %>%
  gsub("\\s+$", "", .) %>%  # Remove extra spaces at the end
  gsub("[^a-zA-Z]+$", "", .) %>%
  gsub("^Editor's Picks|How to fix VAR.*|The ultimate guide.*|ESPN's .*|Marcotti: .*", "", .) %>%
  unique()

team_list <- team_list[team_list != ""]

net_score_list <- page %>%
  html_nodes("div.article-body h2") %>%
  html_text() %>%
  gsub("^.* ", "", .) %>%
  head(20)

# Extract general statistics for each team
team_stats_list <- page %>%
  html_nodes("div.article-body p") %>%
  html_text() %>%
  grep("Overturns: ", ., value = TRUE)

# Create a data frame
data_df <- data.frame(
  team_name = team_list,
  net_score = net_score_list,
  stats_combined = team_stats_list
)

# Print the resulting data frame
print(data_df)



# Define stats column mapping
stats_col_mapping <- list(
  c('overturns_total', 'Overturns'),
  c('overturns_rejected', 'Rejected overturns'),
  c('leading_to_goals_for', 'Leading to goals for'),
  c('leading_to_goals_against', 'Leading to goals against'),
  c('disallowed_goals_for', 'Disallowed goals for'),
  c('disallowed_goals_against', 'Disallowed goals against'),
  c('net_goal_score', 'Net goal score'),
  c('subj_decisions_for', 'Subjective decisions for'),
  c('subj_decisions_against', 'Subjective decisions against'),
  c('net_subjective_score', 'Net subjective score'),
  c('penalties_for', 'Penalties for / against'),
  c('penalties_against', 'Penalties for / against')
)

# Read your existing team_stats_df_2021 dataframe
# Assuming it's already created and contains 'stats_combined' column

# Create columns
stats_col_list <- sapply(stats_col_mapping, `[`, 1)

for (col in stats_col_list) {
  data_df[[col]] <- 0
}

# Update columns based on stats combined information
for (i in 1:nrow(data_df)) {
  stats_info <- data_df[i, 'stats_combined']
  stats_lines <- strsplit(stats_info, "(?<=\\d)(?=[A-Z])", perl = TRUE)[[1]]
  
  for (line in stats_lines) {
    key <- strsplit(line, ': ')[[1]][1]
    value <- strsplit(line, ': ')[[1]][2]
    
    for (mapping in stats_col_mapping) {
      if (mapping[[2]] == key) {
        data_df[i, mapping[[1]]] <- value
      }
    }
  }
}



# Split the combined stats into individual lines
#stats_lines <- strsplit(stats_combined3, "(?<=\\d)(?=[A-Z])", perl = TRUE)[[1]]



# Print the resulting dataframe
print(data_df)

# Amend penalties_for and penalties_against columns
data_df$penalties_for <- str_extract(data_df$penalties_for, "\\d+")
data_df$penalties_against <- str_extract(data_df$penalties_against, "\\d+")

# Add year column
data_df$year <- '2019/2020'

# Drop stats_combined column
data_df <- data_df %>%
  select(-stats_combined)

# Print the resulting dataframe
print(data_df)

net_score_columns <- data_df %>% 
  select(starts_with("net_")) %>% 
  names()

data_df <- data_df %>% 
  mutate(across(all_of(net_score_columns), ~ gsub("\\+", "", .)))
print(data_df)

year <- '2019_2020'
csv_file_name <- paste0("Team", year, ".csv")

write.csv(data_df, csv_file_name, row.names = T)

