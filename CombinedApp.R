library(shiny)
library(RSQLite)
library(DBI)
library(DT)
library(dplyr)




this_table<- dbGetQuery(conn, "SELECT u.univ_id
                        ,u.institution_name
                        ,l.location
                        ,scaled_score
                        ,overall_rank
                   FROM university_ranking ur
                   inner join university u on ur.univ_id = u.univ_id
                   inner join location l on l.location_cd = u.location_cd
                   order by overall_rank ")

top_hundred <-this_table%>%filter(overall_rank <= 100)%>%select(location,univ_id)%>%
                           group_by(location)%>%tally()%>%
                           rename(Country = location,Number = n)%>%arrange(desc(Number))





ui <- fluidPage(
  titlePanel("World University Rankings Update"),

  tabsetPanel(
    tabPanel(title = "Home",
             img(src='./BC_Campus_Green.jpg',align = "center",height = 800, widtth = 1200)
             ),
    tabPanel(title = "Update",
             
    
 
  br(),
  br(),
  
  
  sidebarLayout(
    sidebarPanel(
      
      numericInput("univid", 
                   h3("University ID"), 
                   value = 1423) ,
      textInput("name", h3("University Name"), 
                value = "Enter name..."), 
      
      textInput("loca", h3("Country"), 
                value = "Enter location..."),   
      
      numericInput("scale_score", 
                   h3("Scaled Score"), 
                   value = 0) ,
      numericInput("overall_rnk", 
                   h3("Overall Rank"), 
                   value = 1423) ,
      
      actionButton("add_btn", "Add"),
      actionButton("delete_btn", "Delete")
      
# close sidebarPanel      
    ),
    
    mainPanel(
      #      DTOutput("shiny_table")
      
      DT::dataTableOutput("shiny_table")
# close mainPanel
    )


# close sidebarLayout
  )

# tab panel

),


  tabPanel(title = "Interactive Ranking",

         
         fluidPage(
           
           titlePanel("World University Interactive Rankings"),
           
           
           fluidRow(
             
             column(4,sliderInput("AcadRep", 
                                  label = "Academic Reputation Percentile Weight:",
                                  min = 0, max = 1, value = .4,step = .05)),
             column(4,sliderInput("EmployRep", 
                                  label = "Employer Reputation Percentile Weight:",
                                  min = 0, max = 1, value = .1,step = .05)),
             column(4,sliderInput("FacultyStudent", 
                                  label = "Faculty Student Ratio Percentile Weight:",
                                  min = 0, max = 1, value = .2,step = .05))
           ),
           
           
           
           fluidRow(
             
             column(4,sliderInput("Citations", 
                                  label = "Citations Per Faculty Percentile Weight:",
                                  min = 0, max = 1, value = .2,step = .05)),  
             column(4,sliderInput("IntFaculty", 
                                  label = "International Faculty Ratio Percentile Weight:",
                                  min = 0, max = 1, value = .05,step = .05)),    
             column(4,sliderInput("IntStudent", 
                                  label = "International Student Ratio Percentile Weight:",
                                  min = 0, max = 1, value = .05,step = .05))
           ),
           

           
                      
           fluidRow(
             DT::dataTableOutput("table")  
           )  
           
           
# Close Fluid page          
         )         




# tab panel 

), tabPanel(title = "Top 100 Universities by Country",

         fluidRow(
           
           
            DT::dataTableOutput("shiny_Table")

            
)
)


# Close tabsetPanel

)

# Close Fluid page
)
server <- function(input, output) {
  
  # Reactive expression to compose a data frame containing all of the values
  sliderValues <- reactive({

    
    Value = c(input$AcadRep,
              input$EmployRep,
              input$FacultyStudent,
              input$Citations,
              input$IntFaculty,
              input$IntStudent
              
    )

  })
  
  
  
  
  this_table <- reactiveVal(this_table)

  
  
  observeEvent(input$add_btn, {
    t = rbind(data.frame(univ_id = as.numeric(input$univid),
                         institution_name = as.character(input$name),
                         location = as.character(input$loca),
                         scaled_score = as.numeric(input$scale_score),
                         overall_rank = as.numeric(input$overall_rnk)
                         
    ), this_table())
    this_table(t)
  })
  
  observeEvent(input$delete_btn, {
    t = this_table()
    print(nrow(t))
    if (!is.null(input$shiny_table_rows_selected)) {
      t <- t[-as.numeric(input$shiny_table_rows_selected),]
    }
    this_table(t)
  })
  
  output$shiny_table <- renderDT({
    # produces the editable data table by removing the options = list(dom = 't'). Also, do we want editable
    #    datatable(this_table(), selection = 'single', options = list(dom = 't'),editable = TRUE)
    datatable(this_table(), selection = 'single',editable = TRUE)
  })
  
  
  # Filter data based on selections
  output$table <- DT::renderDataTable(DT::datatable({
    
    
    data <- dbGetQuery(conn, "SELECT u.univ_id
                        ,u.institution_name
                        ,l.location
                        ,ur.academic_reputation_score
                        ,ur.employer_reputation_score
                        ,ur.faculty_student_ratio_score
                        ,ur.citations_per_faculty_score
                        ,ur.international_faculty_ratio_score
                        ,ur.international_student_ratio_score
                        ,adj_scaled_score
                        ,overall_rank
                   FROM university_ranking ur
                   inner join university u on ur.univ_id = u.univ_id
                   inner join location l on l.location_cd = u.location_cd
                   order by overall_rank ")
    
 
    
    data$adj_scaled_score <- ((data$academic_reputation_score*input$AcadRep) + (data$employer_reputation_score*input$EmployRep)
                              + (data$faculty_student_ratio_score*input$FacultyStudent)
                              + (data$citations_per_faculty_score*input$Citations)
                              + (data$international_faculty_ratio_score*input$IntFaculty) 
                              + (data$international_student_ratio_score*input$IntStudent) 
    
    )     
    
    data
  }))
  
   output$shiny_Table <- DT::renderDataTable(DT::datatable({
     
     
    top_hundred 
  
  })) 
  
  
  
  
  
  
  
  
}




shinyApp(ui = ui, server = server)