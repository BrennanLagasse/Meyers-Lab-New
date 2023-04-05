# File: convertOphysToR.R
# Author: Brennan Lagasse (Borrowed most code from Dr. Ethan Meyers)
# Purpose: Convert rastered data from an ophys experiment from MATLAB into R

library(NeuroDecodeR)
library(dplyr)

# convert data to raster format




# should create a loop to loop over all sessions...

session_names <- list.files("OphysData/")

r_dir = "./R_OphysData/"
matlab_dir = "./OphysData/"

folder = paste0(r_dir, session_names[1], "/natural_scenes/")
test <- paste0(f, list.files(f)[1])

# Converts a session from Matlab to R
# session_name is a string that is the name of the session
# start is the start time of the observation
# end is the end time of the observation
# observations is the number of observations for a single stimulus
convert_one_session <- function(session_name, start, end, observations) {
  
  r_raster_dir_name <- paste0(r_dir, session_name, "/natural_scenes/")
  
  if (!dir.exists(r_raster_dir_name)) {
    dir.create(r_raster_dir_name, recursive = TRUE)
  }
  
  matlab_raster_dir_name <- paste0(matlab_dir, session_name, "/natural_scenes/")
  convert_matlab_raster_data(matlab_raster_dir_name, r_raster_dir_name)
  
  # While I found a variable for bin width in the binning function, I could not
  # find one in the convert_matlab_raster_data function. I will manually adjust
  # the labels here based on function inputs
  
  # Not done
  
  # Get all files
  rastered_data <- list.files(r_raster_dir_name)
  
  # Iterate through all files
  for(rastered_table in rastered_data) {
    a = load(rastered_table)
  }
  
  
  
}


for (curr_name in session_names) {
  
  print(curr_name)
  
  convert_one_session(curr_name, -300, 700, 31)
  
}

# # bin the data
# create_binned_data(r_raster_dir_name, 
#                    paste0("session_", session_num, "_natural_scenes"), 150, 50)
# 
# create_binned_data(r_raster_dir_name, 
#                    paste0("session_", session_num, "_natural_scenes"), 10, 10)







# older version...

# session_num <- 715093703
# convert_one_session(session_num)

# convert_one_session <- function(session_num) {
#   
#   r_raster_dir_name <- paste0("./R_EphysData/session_", session_num, "/natural_scenes/")
#   
#   if (!dir.exists(r_raster_dir_name)) {
#     dir.create(r_raster_dir_name, recursive = TRUE)
#   }
#   
#   matlab_raster_dir_name <- paste0("./EphysData/session_", session_num, "/natural_scenes/")
#   convert_matlab_raster_data(matlab_raster_dir_name, r_raster_dir_name, add_sequential_trial_numbers = TRUE)
#   
#   
# }
