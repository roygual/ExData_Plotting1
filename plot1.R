#############################################################################################
#############################################################################################


## Verifying file
validate.file <- function(p, urlzip)
{
    ## divides the path of the archive into only path & file apart
    k<-strsplit(p,"/")[[1]]
    file.text <- k[length(k)]    
    path.text <- substring(p, 1, nchar(p)-nchar(file.text))
    
    ## the directory exists?
    if (!file.exists(substring(p, 1, nchar(p)-nchar(file.text)-1)))   dir.create(path.text)
      
    zipped.file <- paste(path.text, "dataset.zip", sep="")
    
    ## the zipped file exists
    if (!file.exists(zipped.file))
    download.file(urlzip, zipped.file, method="auto")
    
    
    unzip(zipped.file, files = NULL, list = FALSE, overwrite = TRUE,
          junkpaths = FALSE, exdir = substring(p, 1, nchar(p)-nchar(file.text)-1), unzip = "internal",
          setTimes = FALSE)
    closeAllConnections()
    TRUE
}

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
  

# Loading only the usable data direct from the file to a dataframe called tableDf
load.data <- function(p)
{
  tableDf <- read.csv.sql(p, 
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
closeAllConnections()
tableDf
}
#############################################################################################
#############################################################################################



##"Time"  "Global_active_power"  "Global_reactive_power"  "Voltage" "Global_intensity" "Sub_metering_1" "Sub_metering_2" "Sub_metering_3" 
url <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip"
path <- "/exdata/household_power_consumption.txt"

if (validate.file(path, url) && validate.packages())
{
  
  data <- load.data(path)
  
  # Configuring PNG graphics device to print in 480x480
  png(filename = "/exdata/plot1.png", width = 480, height = 480,
      units = "px", pointsize = 12, bg = "white", res = NA)

  # creates the histogram with the data of tableDf 
  with (data, hist(data$Global_active_power,  col="green", main="Global Active Power", xlab="Global Active Power (kilowatts)"))

  # digitally print the histogram to plot1.png
  dev.copy (png, file="/exdata/plot1.png")

  # closing graphics device (PNG)
  dev.off()
  closeAllConnections()
}

