# Load packagers

library(RSQLite)
library(DBI)
library(readxl)
library(rsconnect)

setwd("C:/Users/cazej/OneDrive/Documents/Applied Database Technologies")


rsconnect::setAccountInfo(name='ezarekshinyapp',
                          token='817AE39065F54D88C127EE154915C7DE',
                          secret='ljQQuBHEUA7G4yhMddoPyhoeIvOh7UZ+FabXi5w9')

library(rsconnect)
rsconnect::deployApp('C:/Users/cazej/OneDrive/Documents/Applied Database Technologies/WorldUniversityAppv4.html')


university <- read_excel("Applied Database Technologies/university.xlsx")
location <- read_excel("Applied Database Technologies/location.xlsx")
university_ranking <- read_excel("Applied Database Technologies/university_ranking.xlsx",range = "A1:Q1423")



# Creating connection and database.
conn <- dbConnect(RSQLite::SQLite(), dbname = "World_University.db",password = "password")


# Drop Table to correct errors
# dbRemoveTable(conn,"university_ranking")



# Write the  datasets into  tables
dbWriteTable(conn, "location", location)
dbWriteTable(conn, "university", university)
dbWriteTable(conn, "university_ranking", university_ranking)


# List all the tables available in the database
dbListTables(conn) 
# Query
dbGetQuery(conn, "SELECT * FROM location limit 10")
dbGetQuery(conn, "SELECT * FROM university limit 10")
dbGetQuery(conn, "SELECT * FROM university_ranking limit 10")



dbDisconnect(conn)
