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

############################################################################


#    2. Extracts only the measurements on the mean and standard deviation
#      for each measurement.

features_names <- read.table("UCI HAR Dataset/features.txt")

g <- grepl( "mean\\(\\)|std\\(\\)", features_names$V2, ignore.case=T)

X_tidy <- subset(X_tidy, select=features_names[g,][,1])

############################################################################



#    3. Uses descriptive activity names to name the activities in the data set

if (!file.exists("UCI HAR Dataset/test/y_test.txt")) stop ("test/y_test.txt not found.")
if (!file.exists("UCI HAR Dataset/train/y_train.txt")) stop ("train/y_train.txt not found.")

y_test <- read.table("UCI HAR Dataset/test/y_test.txt")
y_train <- read.table("UCI HAR Dataset/train/y_train.txt")

y_tidy <- rbind(y_train, y_test)

X_tidy <- cbind(y_tidy, X_tidy)

print("finished")