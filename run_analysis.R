# run_analysis.R
#
# Should be run in the same directory with "UCI HAR Dataset" directory
#
#  The program doesoes the following.
#
#    1. Merges the training and the test sets to create one data set.
#    2. Extracts only the measurements on the mean and standard deviation
#      for each measurement.
#    3. Uses descriptive activity names to name the activities in the data set
#    4. Appropriately labels the data set with descriptive activity names.
#    5. Creates a second, independent tidy data set with the average of each
#       variable for each activity and each subject.
#
#
#

library(data.table)
library(gdata)


#    1. Merge the training and the test sets and create one data set
if (!file.exists("UCI HAR Dataset/test/X_test.txt")) stop ("test/X_test.txt not found.")
if (!file.exists("UCI HAR Dataset/train/X_train.txt")) stop ("train/X_train.txt not found.")

if (!file.exists("tidyData")) {
    dir.create("tidyData")
}

X_test_5rows <- read.table("UCI HAR Dataset/test/X_test.txt", nrows=5)
classes <- sapply(X_test_5rows, class)

X_test <- read.table("UCI HAR Dataset/test/X_test.txt", colClasses=classes)
X_train <- read.table("UCI HAR Dataset/train/X_train.txt", colClasses=classes)

X_tidy <- rbind(X_train, X_test)

X_test <- NULL
X_train <- NULL

############################################################################


#    2. Extracts only the measurements on the mean and standard deviation
#      for each measurement.
features_names <- read.table("UCI HAR Dataset/features.txt")

colnames(X_tidy) <- features_names$V2

g <- grepl( "mean\\(\\)|std\\(\\)", features_names$V2, ignore.case=T)

X_tidy <- subset(X_tidy, select=features_names[g,][,1])

############################################################################


#    3. Uses descriptive activity names to name the activities in the data set
if (!file.exists("UCI HAR Dataset/test/y_test.txt")) stop ("test/y_test.txt not found.")
if (!file.exists("UCI HAR Dataset/train/y_train.txt")) stop ("train/y_train.txt not found.")

y_test <- read.table("UCI HAR Dataset/test/y_test.txt")
y_train <- read.table("UCI HAR Dataset/train/y_train.txt")

y_tidy <- rbind(y_train, y_test)

activity_names <- read.table("UCI HAR Dataset/activity_labels.txt")

for (num in activity_names$V1) {
  y_tidy[y_tidy == num] <- as.character(activity_names$V2[num])
}

X_tidy <- cbind(y_tidy, X_tidy)

############################################################################


#    4. Appropriately labels the data set with descriptive activity names.
if (!file.exists("UCI HAR Dataset/test/subject_test.txt")) stop ("test/subject_test.txt not found.")
if (!file.exists("UCI HAR Dataset/train/subject_train.txt")) stop ("train/subject_train.txt not found.")

subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt")
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt")

subject_tidy <- rbind(subject_train, subject_test)

X_tidy <- cbind(subject_tidy, X_tidy)

colnames(X_tidy)[1] <- "subjectID"
colnames(X_tidy)[2] <- "activity_name"

############################################################################


#    5. Creates a second, independent tidy data set with the average of each
#       variable for each activity and each subject.
X_tidy <- data.table(X_tidy)
setkey(X_tidy, subjectID, activity_name)

X_tidy.stats <- X_tidy[, lapply(.SD, mean), by=list(subjectID, activity_name) ]

write.fwf(data.frame(X_tidy.stats), file="tidyData/tidy.txt", quote=F)

