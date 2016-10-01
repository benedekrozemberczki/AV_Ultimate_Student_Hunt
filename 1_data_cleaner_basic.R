library(caTools)
library(lubridate)

train <- read.csv("./raw_dataset/train.csv", stringsAsFactors = FALSE)
test <- read.csv("./raw_dataset/test.csv", stringsAsFactors = FALSE)

target <- train$Footfall

train <- train[, 1:17]

proper_feature_names <- function(input_table){
  
  #--------------------------------------------
  # INPUT -- Table with messed up column names.
  # OUTPUT -- Table with proper column names.
  #--------------------------------------------
  
  colnames(input_table) <- tolower(colnames(input_table))
  
  colnames(input_table) <- gsub('([[:punct:]])|\\s+','_',colnames(input_table))
  
  while (any(grepl("__",colnames(input_table),fixed = TRUE)) == TRUE){
    colnames(input_table) <- gsub("__","_",colnames(input_table),fixed = TRUE) 
  }
  
  colnames(input_table) <- gsub("\\*$", "",colnames(input_table))
  
  return(input_table)
}


dummygen <- function(new_table, original_table, dummified_column, column_values, new_name){ 
  
  #-----------------------------------------------------------------
  # INPUT 1. -- The new cleaned table -- I will attach the dummies.
  # INPUT 2. -- The original table that is being cleaned.
  # INPUT 3. -- The column that has the strings.
  # INPUT 4. -- The unique values in the column encoded.
  # INPUT 5. -- The new name of the columns.
  # OUTPUT -- The new table with the dummy variables.
  #-----------------------------------------------------------------
  
  i <- 0
  
  for (val in column_values){
    i <- i + 1
    new_variable <- data.frame(matrix(0, nrow(new_table), 1))
    new_variable[original_table[,dummified_column] == val, 1] <- 1
    colnames(new_variable) <- paste0(new_name, i)
    new_table <- cbind(new_table,new_variable)
  }
  return(new_table)
}


train <- proper_feature_names(train)
test <- proper_feature_names(test)

input_table <- train

data_munger <- function(input_table){
  
  #------------------------------------
  # INPUT -- The table to be cleaned.
  # OUTPUT -- The cleaned numeric tables.
  #------------------------------------
  
  #----------------------------------------------
  # Defining a target table for the cleaned data.
  #----------------------------------------------
  
  new_table <- data.frame(matrix(0, nrow(input_table), 1))
  new_table[, 1] <- input_table$id
  
  #-----------------------------------------------------
  # The first variable is an artifical ID.
  #-----------------------------------------------------
  
  colnames(new_table) <- c("id")
  
  #---------------------------------------------
  # Park ID
  #---------------------------------------------
  
  park_id <- c(12:39)
  
  new_table <- dummygen(new_table, input_table, "park_id", park_id, "park_id_")
  
  input_table$monkey <- paste0(substr(input_table$date, 7, 10),"-",substr(input_table$date, 4, 5),"-",substr(input_table$date, 1, 2)) 
  
  input_table$days <- lubridate::wday(input_table$monkey)
  
  new_table$super_monkey <- yday(input_table$monkey)
   
  new_table$hyper_monkey <- mday(input_table$monkey)
  days <- c(1:7)

  new_table <- dummygen(new_table, input_table, "days", days, "week_days_")

  #-----------------------
  # Days simple solution
  #-----------------------
  
  new_table$date <- yday(input_table$date)
  
  #--------
  # Month
  #--------
   
  input_table$first_two <- substr(input_table$date, 6, 7)
  
  first_two <- c("01", "02", "03", "04", "05", "06",
                 "07", "08", "09", "10", "11", "12")
  
  
  new_table <- dummygen(new_table, input_table, "first_two", first_two, "first_two_")
  
  #---------------------------
  #
  #---------------------------
  
  columns_to_extract_exactly <- c("direction_of_wind", 
                                  "average_breeze_speed",
                                  "max_breeze_speed",            
                                  "min_breeze_speed",
                                  "var1",           
                                  "average_atmospheric_pressure",
                                  "max_atmospheric_pressure",    
                                  "min_atmospheric_pressure",
                                  "min_ambient_pollution",       
                                  "max_ambient_pollution",
                                  "average_moisture_in_park",    
                                  "max_moisture_in_park",
                                  "min_moisture_in_park")
  
  sub_table <- input_table[, columns_to_extract_exactly]
  
  
  new_table <- cbind(new_table, sub_table)
  
  names_to_use <- colnames(sub_table)
  
  keys <- unique(input_table$park_id)
  
  for (i in 1:ncol(sub_table)){
    for (k in keys){
    sub_table[input_table$park_id == k ,i] <- runsd(sub_table[input_table$park_id == k,i], 4, endrule="constant")
    
    }
  }
  
  colnames(sub_table) <- paste0("sd_", names_to_use)
  
  new_table <- cbind(new_table, sub_table)
  
  keys <- unique(input_table$park_id)
  for (i in 1:ncol(sub_table)){
    for (k in keys){
    sub_table[input_table$park_id == k,i] <- runmean(sub_table[input_table$park_id == k,i], 4, endrule="constant")
    }
  }
  
  colnames(sub_table) <- paste0("mean_", names_to_use)
  
  new_table <- cbind(new_table, sub_table)
  
  keys <- unique(input_table$park_id)
  for (i in 1:ncol(sub_table)){
    for (k in keys){
      sub_table[input_table$park_id == k,i] <- runmax(sub_table[input_table$park_id == k,i], 7, endrule="constant")
    }
  }
  colnames(sub_table) <- paste0("max_", names_to_use)
  
  new_table <- cbind(new_table, sub_table)
  
  keys <- unique(input_table$park_id)
  for (i in 1:ncol(sub_table)){
    for (k in keys){
      sub_table[input_table$park_id == k,i] <- runmin(sub_table[input_table$park_id == k,i], 7, endrule="constant")
    }
  }
  
  colnames(sub_table) <- paste0("min_", names_to_use)
  
  new_table <- cbind(new_table, sub_table)
  
  
  location_type <- c(1:4)
  
  
  new_table <- dummygen(new_table, input_table, "location_type", location_type, "location_type_")
  
  return(new_table)
}

#----------------------
# Creating the tables
#----------------------

new_train <- data_munger(train)
new_test <- data_munger(test)

#-----------------------------------------
#
#
#-----------------------------------------

write.csv(new_train, file = "./clean_dataset/train.csv", row.names = FALSE)
write.csv(new_test, file = "./clean_dataset/test.csv", row.names = FALSE)
write.csv(target, file = "./clean_dataset/target.csv", row.names = FALSE)
