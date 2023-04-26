# File: convertOphysToR.R
# Author: Brennan Lagasse (Borrowed most code from Dr. Ethan Meyers)
# Purpose: Convert rastered data from an ophys experiment from MATLAB into R


library(NeuroDecodeR)
library(dplyr)



# Converts a session from Matlab to R
# session_name is a string that is the name of the session
# start is the start time of the observation
# end is the end time of the observation
convert_one_session <- function(session_name, start, end) {
  
  # Find/create the folder to put the data post conversion
  r_raster_dir_name <- paste0(r_dir, session_name, "/natural_scenes/")
  
  if (!dir.exists(r_raster_dir_name)) {
    dir.create(r_raster_dir_name, recursive = TRUE)
  }
  
  # Get the path to the data in matlab
  matlab_raster_dir_name <- paste0(matlab_dir, session_name, "/natural_scenes/")
  
  
  # convert_matlab_raster_data(matlab_raster_dir_name, r_raster_dir_name)
  convert_matlab_raster_data(matlab_raster_dir_name, r_raster_dir_name)
  
  # PROBLEM - Bins are still off
  
}



# Get all raw matlab data from the source folder
session_names <- list.files("OphysData/")

r_dir = "./R_OphysData/"
matlab_dir = "./OphysData/"

folder = paste0(r_dir, session_names[1], "/natural_scenes/")
test <- paste0(folder, list.files(folder)[1])


print("Starting Conversion")

new_times = c();



for (curr_name in session_names) {
  
  print(curr_name)
  
  convert_one_session(curr_name, -300, 700)

  
}




