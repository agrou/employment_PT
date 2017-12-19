# Employment in Portugal vs Europe over the years

This is a project developed for ilustat's portfolio. It aims at providing a simple web application to visualize Eurostat data on employment over the years. 

The file `Euemployment_report` has a detailed description on the data cleaning and processing phase of the project. 

To run the ShinyApp you may clone the repository, open `server.R`, `ui.R` and install the required libraries listed in the `ui.R`. Or else you can run the following code in the R console:

shiny::runGitHub("employment_pt", "agrou", subdir = "euro_employment_app")

This is a preview of the Shiny App:

![](https://github.com/agrou/employment_PT/blob/master/euro_employment_app/assets/employmentEurope.png?raw=true)





