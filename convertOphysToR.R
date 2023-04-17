# File: convertOphysToR.R
# Author: Brennan Lagasse (Borrowed most code from Dr. Ethan Meyers)
# Purpose: Convert rastered data from an ophys experiment from MATLAB into R


library(NeuroDecodeR)
library(dplyr)







convert_local <- function(matlab_raster_dir_name,
                                       r_raster_dir_name = NULL,
                                       start_ind = NULL,
                                       end_ind = NULL,
                                       zero_time_bin = NULL,
                                       files_contain = "") {
  
  message(sprintf("Starting"))
  
  
  # if matlab directory name ends with a slash, remove this slash
  matlab_raster_dir_name <- paste0(
    trimws(file.path(dirname(matlab_raster_dir_name), " ")),
    basename(matlab_raster_dir_name)
  )
  
  
  matlab_file_names <- list.files(matlab_raster_dir_name, pattern = files_contain)
  
  
  
  for (iSite in seq_along(matlab_file_names)) {
    
    # print message to show progress the number of sites that have been converted    
    if (iSite == 1) {
      message(sprintf("converting site %-5s", iSite))
    } else {
      message(paste0(rep("\b", 22), collapse = ""), sprintf("converting site %-5s", iSite))
    }
    
    # first, load in raster as a list
    curr_matlab_file_name <- matlab_file_names[iSite]
    
    # replace .mat with .rda for matlab_raster_directory_name
    curr_r_file_name <- paste0(substr(curr_matlab_file_name, 1, nchar(curr_matlab_file_name) - 3), "rda")
    
    raster <- R.matlab::readMat(file.path(matlab_raster_dir_name, curr_matlab_file_name))
    
    message(sprintf("Handling Site Info"))
    
    # second, create the raster_site_info list
    raster_site_info <- raster$raster.site.info[, , 1]
    
    message(sprintf("AR"))
    
    sum(sapply(lapply(raster_site_info, dim), function(x) x[[1]]) == 0)
    
    
    message(sprintf("C"))
    
    
    # find if any of the site_info is missing values and add them as NAs
    if (sum(sapply(lapply(raster_site_info, dim), function(x) x[[1]]) == 0)) {
      message(sprintf("."))
      raster_site_info[sapply(lapply(raster_site_info, dim), function(x) x[[1]]) == 0][[1]] <- matrix(NA)
    }
    
    message(sprintf("B"))
    
    # convert the raster site info to a data frame and add it to the raster data
    raster_site_info_df <- as.data.frame(raster_site_info)
    
    
    # if there are more then one row to site_info_df, flatten it to a single row
    if (dim(raster_site_info_df)[1] > 1) {
      
      all_rows_same_vals <- sapply(raster_site_info_df, n_distinct)
      raster_site_info_df_diff_row_vals <- dplyr::select(raster_site_info_df, which(all_rows_same_vals > 1))
      
      # reduce to a single row all columns that have all of the same values
      raster_site_info_df <- dplyr::select(raster_site_info_df, which(all_rows_same_vals <= 1))
      raster_site_info_df <- raster_site_info_df[1, ]
      
      # deal with rows that don't have the same value in each row
      for (iDupSiteInfo in 1:dim(raster_site_info_df_diff_row_vals)[2]) {
        
        curr_dup_col_df <- dplyr::select(raster_site_info_df_diff_row_vals, iDupSiteInfo)
        curr_dup_col_df <- distinct(curr_dup_col_df) # remove duplicated rows (keep nested df)
        curr_dup_col_df <- as.data.frame(t(as.matrix(curr_dup_col_df))) # a bit of a hack
        
        raster_site_info_df <- cbind(raster_site_info_df, curr_dup_col_df)
      }
    }
    
    
    # create the appropriave site_info.X prefix variables names
    raster_site_info_names <- convert_dot_back_to_underscore(names(raster_site_info_df))
    names(raster_site_info_df) <- raster_site_info_names
    names(raster_site_info_df) <- paste0("site_info.", names(raster_site_info_df))
    
    
    # third, create the raster_data df
    raster_data <- data.frame(raster$raster.data)
    
    
    # if start or end inds are not specified used the full data set
    # also create save names if start and end inds are specified
    if (is.null(start_ind)) {
      start_ind <- 1
      start_ind_save_dir_name <- ""
    } else {
      start_ind_save_dir_name <- paste0("_start_", start_ind)
    }
    
    
    if (is.null(end_ind)) {
      end_ind <- dim(raster_data)[2]
      end_ind_save_dir_name <- ""
    } else {
      end_ind_save_dir_name <- paste0("_end_", end_ind)
    }
    
    
    raster_data <- raster_data[, start_ind:end_ind]
    
    
    # Add column names to the raster data in the form of: time.1, time.2 etc.
    data_times <- 1:dim(raster_data)[2]
    
    
    # if there is an alignment time, subtract the start_ind offset from the
    # alignment and subtract alignment from the raster times
    if ( (sum(names(raster_site_info) == "alignment.event.time")) || (is.numeric(zero_time_bin)) ) {
      
      if (is.numeric(zero_time_bin)) {
        
        data_times <- (data_times - rep.int(zero_time_bin - (start_ind - 1), length(data_times)))
        
      } else {
        
        data_times <- (data_times - rep.int(raster_site_info$alignment.event.time - (start_ind - 1), length(data_times)))
      }
      
      
      # remove the alignment time from the site info since it is incorporated into the time bin names
      raster_site_info_df$site_info.alignment_event_time <- NULL
      
      
      # update the names if start_ind or end_ind were given as arguments
      if (!(start_ind_save_dir_name == "")) {
        start_ind_save_dir_name <- paste0("_start_", start_ind - raster_site_info$alignment_event_time)
      }
      
      if (!(end_ind_save_dir_name == "")) {
        end_ind_save_dir_name <- paste0("_end_", end_ind - raster_site_info$alignment_event_time)
      }
      
    }
    
    names(raster_data) <- paste0("time.", data_times)
    
    
    
    # forth, add the labels to raster_data
    # Get the labels for what happened on each trial and add them to the raster_data data frame
    raster_labels <- raster$raster.labels
    
    
    # loop over label names and parse them
    all_labels <- convert_dot_back_to_underscore(row.names(raster_labels))
    
    for (iLabel in seq_along(all_labels)) {
      
      # get the name for the current raster_labels
      curr_var_name <- all_labels[iLabel]
      
      # add the prefix labels. to the curr label name...
      curr_var_name <- paste0("labels.", curr_var_name)
      
      # levels are contained in an extra list - remove this extra list to get the vector of names
      curr_levels <- raster_labels[iLabel, , ][[1]]
      curr_levels <- sapply(curr_levels, function(x) x[[1]])
      
      # convert to a factor
      curr_levels <- as.factor(curr_levels)
      
      # put into a data frame with the appropriate column name
      curr_var_column <- eval(parse(text = paste0("curr_var_column <- data.frame(", curr_var_name, " = curr_levels)")))
      
      # add to the raster_data
      raster_data <- cbind(curr_var_column, raster_data)
      
    }
    
    
    # add the site_info to the raster_data with the same values in each row (trial)
    raster_data <- cbind(raster_site_info_df[rep(1, nrow(raster_data)), ], raster_data)
    rownames(raster_data) <- NULL # remove any row names if they exist
    
    
    # finally, save the raster data in the file
    if (is.null(r_raster_dir_name)) {
      
      # if the directory name ends with "_mat", remove "_mat"
      non_desired_pattern <- ".*_mat$"
      if (grepl(non_desired_pattern, matlab_raster_dir_name) == TRUE) {
        r_raster_dir_name <- substr(matlab_raster_dir_name, 1, nchar(matlab_raster_dir_name) - 4)
      }
      
      
      # append start and end index if applicable and append "_rda/"
      r_raster_dir_name <- file.path(paste0(
        r_raster_dir_name, start_ind_save_dir_name,
        end_ind_save_dir_name, "_rda"), "")
      
    }
    
    
    # change the class to be raster_data, data.frame
    attr(raster_data, "class") <- c("raster_data", "data.frame")
    
    
    if (dir.exists(r_raster_dir_name) == FALSE) {
      dir.create(r_raster_dir_name)
    }
    
    save(raster_data, file = paste0(r_raster_dir_name, curr_r_file_name), compress = TRUE)
    
  }
  
  r_raster_dir_name
  
}




# a helper function to convert . to _
convert_dot_back_to_underscore <- function(oldnames) {
  newnames <- gsub(oldnames, pattern = "\\.", replacement = "_")
  return(newnames)
}











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

for (curr_name in session_names) {
  
  print(curr_name)
  
  convert_one_session(curr_name, -300, 700)
  
}




