# File: convertEphysToR
# Author: Dr. Ethan Meyers
# Purpose: Convert rastered data from ephys session from MATLAB into R

library(NeuroDecodeR)
library(dplyr)

# convert data to raster format




# should create a loop to loop over all sessions...

#session_names <- list.files("EphysData/")

session_names <- c("session_742951821")

r_dir = "./R_EphysData/"
matlab_dir = "./EphysData/"

convert_one_session <- function(session_name) {
  
  r_raster_dir_name <- paste0(r_dir, session_name, "/natural_scenes/")
  
  if (!dir.exists(r_raster_dir_name)) {
    dir.create(r_raster_dir_name, recursive = TRUE)
  }
  
  matlab_raster_dir_name <- paste0(matlab_dir, session_name, "/natural_scenes/")
  convert_matlab_raster_data(matlab_raster_dir_name, r_raster_dir_name, add_sequential_trial_numbers = TRUE)
  
  
}


for (curr_name in session_names) {
  
  print(curr_name)
  
  convert_one_session(curr_name)
  
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
