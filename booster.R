library(xgboost)
setwd("/afs/inf.ed.ac.uk/user/s16/s1668259/Documents/booster/")

#------------------------------------------
# Reading the training data and the labels.
#------------------------------------------

train <- read.csv("./clean_dataset/train.csv", stringsAsFactors = FALSE)
test <- read.csv("./clean_dataset/test.csv", stringsAsFactors = FALSE)

train_agg <- read.csv("./clean_dataset/train_aggregates.csv", stringsAsFactors = FALSE)
test_agg <- read.csv("./clean_dataset/test_aggregates.csv", stringsAsFactors = FALSE)

train <- cbind(train,train_agg)
test <- cbind(test,test_agg)

rm(train_agg,test_agg)

labels <- read.csv("./clean_dataset/target.csv", stringsAsFactors = FALSE)

train[is.na(train)] <- -300
test[is.na(test)] <- -300

#--------------------------------------------------
# Dropping the ID and selecting the label variable.
#--------------------------------------------------

test_id <- test$id
train_id <- train$id

train <- train[, 2:ncol(train)]
test <- test[, 2:ncol(test)]

target <- labels$x

train <- data.matrix(train)
test <- data.matrix(test)
rm(labels)
zeros <- rep(0, 39420)

control <- 50
for (i in 1:control){
  
  bst <- xgboost(data = train,
                  label = target,
                  eta = 0.1,
                  max_depth = 6,
                  subsample = 0.5,
                  colsample_bytree = 1,
                  nrounds = 400,
                  objective = "reg:linear",
                 eval_metric = "rmse",
                  maximize = FALSE)
    
    
  yhat <- predict(bst,test)
  zeros <- zeros + yhat
  
}

zeros <- zeros/control
submission <- data.frame(test_id, zeros, stringsAsFactors = FALSE)

colnames(submission) <- c("ID", "Footfall")
submission$Footfall <- submission$Footfall*(0.987)
write.csv(submission, file = "super_booster_submission_8.csv", row.names = FALSE)
 