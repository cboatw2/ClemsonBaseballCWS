#Load packages
library(tesseract)
library(magick)
library(png)
library(boundingbox)
library(grid)
library(magrittr)
library(ggplot2)
library(dplyr)
library(stringdist)

#See how well the OCR is reading the table data
img <- image_read('/Users/crboatwright/ClemsonAthletics/ClemsonBaseball/ClemsonBaseballCWS/Clemson University Baseball Stats 1958_7.png')
text_raw <- ocr(img)
cat(text_raw)
#Output indicates that the OCR is not reading the table data well

bb <- ocr_data(img)
bb <- as.data.frame(bb)

#Extract bounding box coordinates
bb$bbox <- strsplit(bb$bbox, ",")
bb$xmin <- sapply(bb$bbox, function(x) as.numeric(x[1]))
bb$ymin <- sapply(bb$bbox, function(x) as.numeric(x[2]))
bb$xmax <- sapply(bb$bbox, function(x) as.numeric(x[3]))
bb$ymax <- sapply(bb$bbox, function(x) as.numeric(x[4]))
bb$ymid <- (bb$ymin + bb$ymax) / 2

#Group words horizontally
bb$line_id <- round(bb$ymid / 10)

#Make sure column names are correct
colnames(bb)[colnames(bb) == "text"] <- "ocr_text"
bb$ocr_text <- as.character(bb$ocr_text)

#Rename 'word' column to 'text'
colnames(bb)[colnames(bb) == "word"] <- "ocr_text"

#Make sure text is character
bb$ocr_text <- as.character(bb$ocr_text)

#Recombine words into lines, sorted by x position
lines_df <- bb %>%
    group_by(line_id) %>%
    arrange(xmin) %>%
    summarise(text = paste(ocr_text, collapse = " ")) %>%
    arrange(line_id)

#print(lines_df, n = Inf) #Print all lines

# Remove short lines and junk lines
lines_clean <- lines_df$text[!grepl("^\\W*$", lines_df$text)]  # remove symbols-only
lines_clean <- lines_clean[nchar(lines_clean) > 10]  # drop short garbage lines

# Remove extra symbols and whitespace
lines_clean <- gsub("[^a-zA-Z0-9, ]", "", lines_clean)  # Keep only alphanumeric, commas, and spaces
lines_clean <- trimws(lines_clean)  # Trim leading/trailing whitespace
lines_clean <- tolower(lines_clean)  # Convert to lowercase for case-insensitive matching

print(lines_clean)

# Print cleaned lines to inspect
cat(paste(lines_clean, collapse = "\n"))
#Manually define player names
clemson_players <- c("Hendley", "Bagwell", "Spires", "Wilson", "DeBerry", "Hoffman", "Coker", "Burnette", "Norris", "Stowe", "McDonald")
michiganstate_players <- c("Golden", "Warner", "Palamara", "Gilbert", "Look", "Russell", "Stifler", "Meredith", "Fleser", "Perranoski", "Curley")

# Convert player names to lowercase for consistent matching
all_players <- tolower(all_players)

#Combine player lists
all_players <- c(clemson_players, michiganstate_players)

print(all_players)

#Group
player_data <- extract_player_blocks(lines_clean, all_players)

#Display for review
for (name in names(player_data)) {
    cat(paste0("\n\n---", name, "---\n"))
    cat(paste(player_data[[name]], collapse = "\n"))
}

#Use regex and fuzzy matching to group lines by players and teams

#Group lines by player name anchors
extract_player_blocks <- function(lines, player_names) {
  player_blocks <- list()
  current_player <- NULL

  for (line in lines) { #try exact or fuzzy match

    print(paste("Processing line:", line))  # Debug: Print each line
    matched <- player_names[amatch(player_names, line, maxDist = 5)]
    print(paste("Matched player:", matched))  # Debug: Print matched player

    if (length(matched) > 0 && !is.na(matched[1])) {
        current_player <- matched[1]
        player_blocks[[current_player]] <- c()
    }

    if (!is.null(current_player)) {
      player_blocks[[current_player]] <- c(player_blocks[[current_player]], line)
    }
  }
    return(player_blocks)
}

print(player_data)

