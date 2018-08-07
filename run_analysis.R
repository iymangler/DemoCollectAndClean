
# -------------------------
# Code written for Data cleansing week 4 project
# How to use this code:
#    setwd("C:\...Yourpath...")
#     run_analysis())
# the function should throw an error in case of an unexpected issue
# The num variable can take values “best”, “worst”, or an integer indicating the ranking (smaller
# numbers are better). If the number given by num is larger than the number of hospitals in that state,
# then the function should return NA.

library(reshape2)

##1. Download and unzip the dataset
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
fileName <- "getdata_dataset.zip"
if (!file.exists(fileName)) {
    download.file(fileUrl, fileName)
} 

if (!file.exists("UCI HAR Dataset")) { 
  unzip(fileName) 
}

##2. Load train, test, activity labels, features
actvLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
actvLabels[,2] <- as.character(actvLabels[,2])

features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

# Extract only the measurement data on mean and standard deviation
onlyMyFeatures <- grep(".*mean.*|.*std.*", features[,2])
onlyMyFeatures.names <- features[onlyMyFeatures,2]
onlyMyFeatures.names <- gsub('[-()]', '', onlyMyFeatures.names)
onlyMyFeatures.names = gsub('-mean', 'Mean',onlyMyFeatures.names)
onlyMyFeatures.names = gsub('-std', 'Std', onlyMyFeatures.names)

# Load train dataset
trainFeatures <- read.table("UCI HAR Dataset/train/X_train.txt")[onlyMyFeatures]
Y_train <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
trainDataset <- cbind(trainSubjects, Y_train, trainFeatures)

# Load test dataset
testFeatures <- read.table("UCI HAR Dataset/test/X_test.txt")[onlyMyFeatures]
Y_test <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
testDataset <- cbind(testSubjects, Y_test, testFeatures)

# merge test & train datasets and add column-names
trainTestMerge <- rbind(trainDataset, testDataset)
colnames(trainTestMerge) <- c("subject", "activity", onlyMyFeatures.names)

# turn activities & subjects into factors
trainTestMerge$activity <- factor(trainTestMerge$activity, levels = actvLabels[,1], labels = actvLabels[,2])
trainTestMerge$subject <- as.factor(trainTestMerge$subject)

# massage data by melting and dcasting before writing output
trainTestMerge.massage <- melt(trainTestMerge, id = c("subject", "activity"))
trainTestMerge.mean <- dcast(trainTestMerge.massage, subject + activity ~ variable, mean)

# Write the output into a tidy file
write.table(trainTestMerge.mean, "tidyTidyTadata.txt", row.names = FALSE, quote = FALSE)