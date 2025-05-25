#Install daiR package
install.packages("daiR")
library(daiR)

# Install and load the magick package
install.packages("magick")
library(magick)

# Define the PNG file path
png <- "/Users/crboatwright/ClemsonAthletics/ClemsonBaseball/ClemsonBaseballCWS/Clemson University Baseball Stats 1958_7.png"

# Read the PNG file
image <- image_read(png)

# Save the image as a PDF
pdf_path <- "/Users/crboatwright/ClemsonAthletics/ClemsonBaseball/ClemsonBaseballCWS/Clemson University Baseball Stats 1958_7.pdf"
image_write(image, path = pdf_path, format = "pdf")

# Confirm the PDF was created
cat("PDF created at:", pdf_path)

setwd(tempdir())

#Run OCR
page7 <- dai_sync("/Users/crboatwright/ClemsonAthletics/ClemsonBaseball/ClemsonBaseballCWS/Clemson University Baseball Stats 1958.pdf")
