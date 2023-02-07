# Data wrangling for spatial analysis in R

[Chris Brown](https://experts.griffith.edu.au/7867-chris-brown)  

### [Course notes](https://www.seascapemodels.org/spatial-analysis-in-r/spatial-analysis-in-r.html)

### [Data for course](https://github.com/cbrown5/spatial-analysis-in-r/raw/main/data-for-course.zip)

### [Just the R code](https://github.com/cbrown5/spatial-analysis-in-r/raw/main/spatial-analysis-in-r.R)

## Setup

So that the course runs efficiently, and to save plenty of time for trying fun things in R, we'd ask that you come to the course prepared.
This is an intermediate level course, so we'll assume you know how to install R and R packages. As a general guide to what we expect in terms of prior knowledge, we'll assume you can run R, load data and write basic calculations that you save in a script.

Please have R ([install from here](https://cran.r-project.org/)) and [Rstudio](https://www.rstudio.com/products/rstudio/) (we use the free desktop version) installed on your computer before starting. You'll want to save plenty of time for doing this, it can be tricky on some computers, especially if you do not have 'admin' permission on a work computer. You may need to call IT to get help. We obviously only offer limited help with such installation issues.
We are using R version >4.0.2 currently for writing this course, so there may be some minor differences if you have a different version. We definitely recommend making sure you have version 4 or greater.

You'll also need to install a few R packages. You can install them with this R code in R's console, e.g. 
`install.packages(c("tmap"))`
If that doesn't work email us with the error and we'll try to help. Otherwise, see your IT department for help.

We're using dplyr version 1.0, which was released earlier this year. If you have an older version of dplyr the course should still work fine, but there may be some minor differences in the code.

### Technical notes about the github repo

All code is in the main folder
'data-raw/' has raw data files used to create data for the students (so don't share this with students its too big). 
'data-for-course' has modified data files for the students. 
These scripts take the full data and make simpler
versions for the course: 
aggregate-spatio-temporal-dat.R
create-polygons.R
create-data-for-course.R

#### Structure of Rmd files  

4_1_1-master.Rmd
This is a master file with a bit of intro material and our names etc... It also knits together the two sub-folders for the first and second parts of the course

4_1_data_wrangling_plotting.Rmd  
This is the first part of the course. It can be run stand-alone, or as a child of the master file

4_2_intro_to_mapping.Rmd
This is the second part of the course. It can be run stand-alone, or as a child of the master file
