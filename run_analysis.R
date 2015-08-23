# Let's load reshape2 library in order to use melt and dcast functions
library(reshape2)

# STEP 0
filename <- "getdata_dataset.zip"

# Download the dataset
if (!file.exists(filename)){
    fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
    download.file(fileURL, filename, method="curl")
}
# Unzip downloaded file
if (!file.exists("UCI HAR Dataset")) { 
    unzip(filename) 
}

# Load activity labels
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
activityLabels[,2] <- as.character(activityLabels[,2])

# Load features
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

# Extract only the data on mean and standard deviation
featuresWanted <- grep(".*mean.*|.*std.*", features[,2])
featuresWanted.names <- features[featuresWanted,2]

# Modify feature names
featuresWanted.names <- gsub('-mean', 'Mean', featuresWanted.names)
featuresWanted.names <- gsub('-std', 'Std', featuresWanted.names)
featuresWanted.names <- gsub('[-()]', '', featuresWanted.names)

# Load training dataset
train <- read.table("UCI HAR Dataset/train/X_train.txt")[featuresWanted]
trainActivities <- read.table("UCI HAR Dataset/train/y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainSubjects, trainActivities, train)

# Load tests dataset
test <- read.table("UCI HAR Dataset/test/X_test.txt")[featuresWanted]
testActivities <- read.table("UCI HAR Dataset/test/y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects, testActivities, test)

# Merge datasets and set pretty labels
allData <- rbind(train, test)
colnames(allData) <- c("subject", "activity", featuresWanted.names)

# turn activities into factors
allData$activity <- factor(allData$activity, levels = activityLabels[,1], labels = activityLabels[,2])
# turn subjects into factors
allData$subject <- as.factor(allData$subject)

# Let's create a long dataset from allData$subject and allData$activity
allData.melted <- melt(allData, id = c("subject", "activity"))
# Now, let's create a wide dataset with means for each subject/activiy combinations from allData$melted
allData.mean <- dcast(allData.melted, subject + activity ~ variable, mean)

# Last but not least, let's print the tidy.txt file!
write.table(allData.mean, "tidy.txt", row.names = FALSE, quote = FALSE)