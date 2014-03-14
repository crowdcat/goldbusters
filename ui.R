######### this is the ui part of the Goldbusters app ###################

library(shiny)
print("at least i'm running")
# Define UI
shinyUI(pageWithSidebar(
  
  # Application title
  headerPanel("Make your job a golddigging job!"),
  
  # Sidebar with controls to select the variable to plot against mpg
  # and to specify whether outliers should be included
  sidebarPanel(
    numericInput("jobID", h4("Id of the job to be goldified:"), ""),
    br(),
    p("This job will be copied with data, modified CML, disabled Golds,
      and advanced setting optimized for the GoldBusters."),
    br(),
    #h4("Type any Gold-specific Instructions here (as HTML):"),
    #HTML('<textarea id="foo" rows="10" cols="60" width="100%"><li>This task is very subjective,
    #     don\'t forget to include musltiple correct answers in your Golds!</li>
    #     <li>Question X demands your special attention because...</li>
    #     <li>Please help us find units that are Y! We\'d like to have a few Golds with Y tags.
    #     You can skip the N tags because they are too popular.</li></textarea>'),
    #br(),
    #p("You can also make edits to Instructions directly in the job after it gets processed."),
    br(),
    p("There will be an option to make a spotcheck here."),
    br(),
    h4(a(href='https://crowdflower.atlassian.net/wiki/display/ENT/How+to+use+GoldBusters',
         "Detailed Description Here", target="_blank"))
  ),
  
  # Show the caption and plot of the requested variable against mpg
  mainPanel(
    tabsetPanel(
      tabPanel("Send to GoldBusters",
               htmlOutput("link_and_comment"),
               p(textOutput("get_json")), #1
               p(textOutput("transform_css")), #2
               p(textOutput("transform_instructions")), #3
               p(textOutput("transform_title")), #4
               p(textOutput("transform_cml")), #5
               p(textOutput("copy_job")), #6
               p(textOutput("copy_job_with_settings")), #7
               p(textOutput("update_title")), #8
               p(textOutput("update_css")), #9
               p(textOutput("update_instructions")), #10
               p(textOutput("update_cml")), #11
               p("***If every line above has turned grey, your job is being goldified. Patience!")
      ),
      tabPanel("View Goldified CML (debug manually)",
               p(textOutput("new_cml"))
      ),
      tabPanel("Make a Gold Report")
    )
    # would you like to add instructions?
    
  )))