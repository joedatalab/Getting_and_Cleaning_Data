#If the file doesn't exist in the working directory, download it
filename <- "getdata_projectfiles_UCI HAR Dataset.zip"
if (!file.exists("getdata_projectfiles_UCI HAR Dataset.zip")) {
    fileurl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip" 
    download.file(fileurl, filename, "auto")
}

#Unzip the file(s)
unzip("getdata_projectfiles_UCI HAR Dataset.zip")

#Read the downloaded data into R
xtest <- read.table("X_test.txt")
xtrain <- read.table("X_train.txt")

ytest <- read.table("y_test.txt")
ytrain <- read.table("y_train.txt")

features <- read.table("features.txt")
activitylabels <- read.table("activity_labels.txt")

subjecttest <- read.table("subject_test.txt")
subjecttrain <- read.table("subject_train.txt")

#Column bind Dataframes y_test and subject_test and add column names Activity and Subject to it.
A <- cbind(ytest, subjecttest)
names(A) <- c("Activity", "Subject")

#Column bind Dataframes y_train and subject_train and add column names Activity and Subject to it. 
B <- cbind(ytrain, subjecttrain)
names(B) <- c("Activity", "Subject")

#Merge A and B (dim-10299*2)
C <- merge(A,B,all=TRUE)

#Merge X_train and X_test data (dim-10299*561)
D <- merge(xtest, xtrain, all=TRUE)

#Change column names of D to names in the features file
featuresnames <- as.character(features$V2)
names(D) <- featuresnames

#Eliminate columns from D which do not have "mean()" or "std()" in the column names (dim-10299*66)
E <- D[, grepl("\\-mean\\(\\)|\\-std\\(\\)", colnames(D))]

#Column bind C and E (dim-10299*68)
G <- cbind(C, E)

#Take mean of observations per activity per subject. (dim-180*68). 
numvariables <- dim(G)[2]
library(plyr)
tidydata <- ddply(G, .(Subject, Activity), function(x) colMeans(x[, 3:numvariables]))

#Link the activity label to its name
tidydata$Activity <- as.factor(tidydata$Activity)
levels(tidydata$Activity) <- factor(activitylabels$V2)

#Clean-up the labels on the data set with descriptive activity names 
colnames(tidydata) <- sub("\\-\\-|\\-$","", colnames(tidydata))
colnames(tidydata) <- sub("BodyBody", "Body", colnames(tidydata))

#Use write.table to get a text file from the above Data Frame.Submit this text file for Question 1 of Assessment
write.table(tidydata, "TidyActivityDataSet.txt", sep="\t")


