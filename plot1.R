#############################################################################################
#############################################################################################

# verifing the installed packages
validate.packages <- function()
{
  pack<-"sqldf"
  if (!(is.element(pack, installed.packages()[,1]))) 
  {
    print("Installing new packages")
    install.packages(pack)
  }
  library (sqldf)
  TRUE
}

url <- "http://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip"
path <- "./exdata/household_power_consumption.txt"

## Verifying file    
    ## the zipped file exists
    if (!file.exists("./exdata-data-household_power_consumption.zip"))
    {
    if (!file.exists("./exdata")){dir.create("exdata")}
    download.file(url, destfile="./exdata-data-household_power_consumption.zip")
    }
    unzip("./exdata-data-household_power_consumption.zip", files = NULL, list = FALSE, overwrite = TRUE,
          junkpaths = FALSE, exdir = "exdata", unzip = "internal",
          setTimes = FALSE)
    
    
  
# Loading only the usable data, reading direct from the file to a dataframe called tableDf
load.data <- function(p)
{
  tableDf <- read.csv.sql(path, 
                        sql="SELECT * FROM file WHERE Date='1/2/2007' OR Date='2/2/2007'", 
                        header=TRUE,
                        sep=";",
                        colClasses=c("character","character","numeric","numeric","numeric","numeric","numeric","numeric","numeric"))

## Merging  Date & Time into one column Time
t <- paste (tableDf$Date, tableDf$Time)

tableDf <- cbind(t, tableDf)

tableDf$Date <- NULL

tableDf$Time <- NULL

names(tableDf)[1] <- "Time"

## Converting Time column from character to Date/Time POSIXt
tableDf$Time <- strptime(tableDf$Time, "%d/%m/%Y %H:%M:%S")

tableDf
}
#############################################################################################
#############################################################################################




if (validate.packages())
{
  
  data <- load.data(path)
  
  png(filename = "./exdata/plot1.png", width = 480, height = 480,
      units = "px", pointsize = 12, bg = "white", res = NA)
  
  # creates the histogram with the data of tableDf 
  with (data, hist(data$Global_active_power,  col="green", main="Global Active Power", xlab="Global Active Power (kilowatts)"))

  
  dev.copy (png, file="./exdata/plot1.png")
  

  # closing graphics device (PNG)
  dev.off()
}

