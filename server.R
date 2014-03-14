######################## the server part of the Goldbusters app ######################
require('shiny')
require('stringr')
options(stringsAsFactors=F)
library('rjson')

source("parse_xml_for_goldbusters.R")

auth_key = "5b7d73e5e7eb06556f12b45f87b013fc419f45f2"

shinyServer(function(input, output) {
  
  print("at least i'm running 2")
  
  job_id <- reactive({
    if (is.na(input$jobID)) {
      return(NULL)
    } else  {
      print("i'm in job id")
      input$jobID
    }
  })
  # print(job_id)
  
  job_and_cml <- reactive({
    job_id = job_id()
    print("i am in job_and_cml")
    
    ######### start replace
    system(paste("cd ~/Documents/new_goldbuster_app/"), intern=TRUE)
    system("source /Users/catherine/.rvm/scripts/rvm")
    system("rvm use ruby-2.0.0-p195")
    ########## end replace
    # replace with this:
    #system(paste("cd /var/deploy/coolstuff/current/goldbusters/"), intern=TRUE)
    job_and_cml = system(paste("bundle exec ruby add_reasons.rb", job_id), intern=TRUE)
    # job_and_cml = system(paste("ruby /var/deploy/coolstuff/current/goldbusters/add_reasons.rb", job_id), intern=TRUE)
    job_and_cml
  })
  
  # print(job_and_cml)
  # parse two arguments: new job id and new cml
  
  output$link_and_comment <- renderText({
    if (is.na(input$jobID)) {
      paste("The new job id will appear here once the program is done.")
    } else {
      start= "<div class=\"well\">"
      new_job_id = copied_job()
      job_preview_link = paste0("https://make.crowdflower.com/jobs/",new_job_id,"/preview")
      line1 = paste0("Alright we're done. New job id is ", new_job_id,".Your job is here: ", 
                    "<a href=\"",
                    job_preview_link, "\" target=\"job_preview\"> preview job</a>.")
      br = "<br/>"
      line2 = paste0("If there were no errors below, you can launch it to GB. Otherwise, copy your CML from ",
                    "\"View Goldified CML (debug manually)\"",
                    ", paste into the new job's CML and debug manually.")
      end = "</div>"
      paste(start, line1, br, line2, end)
    }
  })
  
  
  args <- reactive({
    print("in args")
    args = unlist(str_split(paste(job_and_cml(), collapse="\n"), 
                            pattern="\n\nnnewlinenewlinethisisanewline\n\n", n=2))
    print(length(args))
    print(args)
    args
  })
  
  output$string_new_job_id <- renderText({
    if (is.na(input$jobID)) {
      paste("The new job id will appear here once the program is done.")
    } else {
      print("well here i am")
      args = args()
      # escape the quots on the second argument
      paste("This is the new job id:", args[2])
    }
  })
  
  output$new_cml <- renderText({
    print("i am in output$new_cml")
    if (is.na(input$jobID)) {
      paste("You will be able to view the updated CML here once the program is done.")
    } else {
      cml_string = transform_cml_reactive()
      paste(cml_string)
    } 
  })
  
  output$wrap_up <- renderText({
    if (is.na(input$jobID)) {
      paste("Enter your job id in the text box on the left to begin!")
    } else {
      p1 = "1. Job copied & modified successfully? Congratulations.
                   You may release the job to Goldbusters: just order judgments on all channels!"
      p2 = "2. Got an error message? New job is identical to the one supplied? <br> Try goldifying again
        (refresh the page and re-paste the job id) or choose 'View Goldified CML (debug manually)' 
        and follow instructions."
      html_wrap = paste("<p>",p1,"</p><p>",p2,"</p>")
      paste(html_wrap)
    }
  })
  
  output$job_url <- renderText({
    if (is.na(input$jobID)) {
      paste("This section will turn into a clickable preview link if the process is successfull.")
    } else {
      print("and how about job_url?")
      args = args()
      link = paste("https://crowdflower.com/jobs/",
                   args[2], "/preview", sep="")
      href_text = paste("<p>Your job has been copied and modified, although there may be units pending.
                        </p><br><a href=\"", link, "\" target=\"blank\">Click here to preview the new job!</a>",
                        sep="")
      href_text
    }
  })
  ########################## experimantal part #########################
  get_json_ruby <- reactive({
    if (is.null(job_id())) {
      return("No job id supplied")
    } else {
      job_id = job_id()
      print("i am in get_json_ruby")
      ######### start replace
      system(paste("cd ~/Documents/new_goldbuster_app/"), intern=TRUE)
      system("source /Users/catherine/.rvm/scripts/rvm")
      #system("rvm use ruby-2.0.0-p195")
      ########## end replace
      # replace with this:
      #system(paste("cd /var/deploy/coolstuff/current/goldbusters/"), intern=TRUE)
      json_to_print = system(paste("bundle exec ruby add_reasons_part1.rb", job_id), intern=TRUE)
      # job_and_cml = system(paste("ruby /var/deploy/coolstuff/current/goldbusters/add_reasons.rb", job_id), intern=TRUE)
      print("got json in get_json_ruby")
      json_to_print
    }
  })
  
  output$get_json <- renderText({
    if (is.na(input$jobID)) {
      paste("1. Get JSON from job")
    } else {
      print("and how about job_url?")
      print_var = ""
      json_text = get_json_ruby()
      if (grepl(json_text, pattern="^\\{\"error\"\\:")) {
        stop(paste("1. Get JSON from job: ERROR! \nWe got the following error message trying to retrieve json:", json_to_print))
      } else {
        print_var = paste("1. Get JSON from job: SUCCESS")
      }
      print("about to print json in get_json")
      print_var
    }
  })
  
  get_all_elements <- reactive({
    json_text = get_json_ruby()
    print("i am in transform_css_ruby")
    ######### start replace
    system(paste("cd ~/Documents/new_goldbuster_app/"), intern=TRUE)
    system("source /Users/catherine/.rvm/scripts/rvm")
    json_to_print = system(
      paste("bundle exec ruby add_reasons_part1.rb", job_id(), "> ~/Documents/new_goldbuster_app/some_file.json"),
      intern= F)
    #json_to_print = read.lines('~/Documents/new_goldbuster_app/some_file.json')
    parsed_json = fromJSON(file="/Users/catherine/Documents/new_goldbuster_app/some_file.json")
    
    #system(paste("cd ~/Documents/new_goldbuster_app/"), intern=TRUE)
    #system("source /Users/catherine/.rvm/scripts/rvm")
    #system("rvm use ruby-2.0.0-p195")
    ########## end replace
    # replace with this:
    #system(paste("cd /var/deploy/coolstuff/current/goldbusters/"), intern=TRUE)
    #json_text = 
    #new_css = system(paste("bundle exec ruby add_reasons_part1.rb", json_text), intern=TRUE)
    # job_and_cml = system(paste("ruby /var/deploy/coolstuff/current/goldbusters/add_reasons.rb", job_id), intern=TRUE)
    print("make the css")
    list(css=parsed_json$css,cml=parsed_json$problem,instructions=parsed_json$instructions,
         title = parsed_json$title)
    #new_css
  })
  
  transform_css_reactive  <- reactive({
    if (is.na(input$jobID)) {
      paste("This will be get_json.")
    } else {
      print("I am in transform_css")
      old_css = get_all_elements()$css
      new_css = paste(".background-yellow { background-color: #ffcb02; }", "\n", old_css,
                      sep="")
      new_css
    }
  })
  
  transform_title_reactive  <- reactive({
    if (is.na(input$jobID)) {
      paste("This will be get_json.")
    } else {
      print("I am in transform_css")
      old_title = get_all_elements()$title
      new_title = paste('GOLD: ', old_title, sep="")
      new_title
    }
  })
  
  transform_cml_reactive  <- reactive({
    if (is.na(input$jobID)) {
      paste("This will be get_json.")
    } else {
      print("I am in transform_cml_reactive")
      old_cml = get_all_elements()$cml
      #new_title = paste('GOLD: ', old_title, sep="")
      new_cml = change_cml_R(old_cml)
      new_cml
    }
  })
  
  transform_instructions_reactive  <- reactive({
    if (is.na(input$jobID)) {
      paste("This will be get_json.")
    } else {
      print("I am in transform_css")
      old_instructions = get_all_elements()$instructions
      new_instructions = paste("<div class='background-yellow'>\n", 
                               "<p>Dear Contributor,<br>This is a special Gold Digging task!", 
                               " We appreciate your careful work on this one.",
                               " <br>Thanks a lot for your help and Good  Luck!</p>\n</div>\n", old_instructions,
                               sep="")
      new_instructions
    }
  })
  
  copied_job <- reactive({
    if (is.na(input$jobID)) {
      paste("This will be get_json.")
    } else {
      job_id = job_id()
      command = paste('curl "https://api.crowdflower.com/v1/jobs/',
                      job_id,
                      '/copy.json?key=',
                      auth_key,
                      '&all_units=true&gold=false"',
                      ' > /Users/catherine/Documents/new_goldbuster_app/some_new_file.json',
                      sep="")
      print(command)
      copied_json = system(command, intern=F)
      parsed_json = fromJSON(file="/Users/catherine/Documents/new_goldbuster_app/some_new_file.json")
      new_id = parsed_json$id
      print(paste("Job id ", new_id))
      new_id
    }
  })
  
  updated_setting <- reactive({
    if (is.na(input$jobID)) {
      paste("This will be get_json.")
    } else {
      new_id = copied_job()
      system(paste("cd ~/Documents/new_goldbuster_app/"), intern=TRUE)
      system("source /Users/catherine/.rvm/scripts/rvm")
      json_to_print = system(
        paste("bundle exec ruby change_settings.rb", new_id),
        intern= F)
      json_to_print
    }
  })
  
  output$transform_css <- renderText({
    if (is.na(input$jobID)) {
      paste("2. Transform CSS")
    } else {
      print("I am in transform_css")
      new_css = transform_css_reactive()
      print_var = ""
      if (grepl(new_css, pattern="^\\{\"error\"\\:")) {
        stop(paste("2. Transform CSS: ERROR! \nWe got the following error message trying to retrieve json:", new_css))
      } else {
        print_var = paste("2. Transform CSS: SUCCESS")
      }
      print_var
    }
  })
  
  output$transform_title <- renderText({
    if (is.na(input$jobID)) {
      paste("4. Transform Title")
    } else {
      print("I am in transform_title")
      new_title = transform_title_reactive()
      print_var = paste("4. Transform Title: SUCCESS. The new title is\"", new_title, "\"")
      print_var
    }
  })
  
  output$transform_cml <- renderText({
    if (is.na(input$jobID)) {
      paste("5. Transform CML")
    } else {
      print("I am in transform_cml")
      new_cml = transform_cml_reactive()
      print_var = paste("5. Transform CML: SUCCESS. New CML has", nchar(new_cml), "characters")
      print_var
    }
  })
  
  output$transform_instructions <- renderText({
    if (is.na(input$jobID)) {
      paste("3. Transform Instrustions")
    } else {
      print("I am in transform_instructions")
      new_instructions = transform_instructions_reactive()
      print_var = paste("3. Transform Instrustions: SUCCESS. New Instrustions have", nchar(new_instructions), "characters")
      print_var
    }
  })
  
  
  
  output$copy_job <- renderText({
    if (is.na(input$jobID)) {
      paste("6. Make a copy of the job")
    } else {
      print("I am in copy_job")
      job_id = copied_job()
      print(job_id)
      if (grepl(job_id, pattern="^\\{\"error\"\\:")) {
        stop(paste("6. Make a copy of the job: ERROR! \nWe got the following error message trying to copy the job:", job_id))
      } else {
        print_var = paste("6. Make a copy of the job: SUCCESS. The new job is at", job_id)
      }
      print_var
    }
  })
  
  output$copy_job_with_settings <- renderText({
    if (is.na(input$jobID)) {
      paste("7. Update Settings. This part takes a little time.")
    } else {
      print("I am in copy_job_with_settings")
      update = updated_setting()
      if (grepl(update, pattern="^\\{\"error\"\\:")) {
        stop(paste("7. Update Settings: ERROR! \nWe got the following error message when we tried to update job settings:", update))
      } else {
        print_var = paste("7. Update Settings: SUCCESS. This job has been optimized for GoldBUsters.")
      }
      print_var
    }
  })
  
  update_title_reactive <- reactive({
    if (is.na(input$jobID)) {
      paste("This will be get_json.")
    } else {
      new_id = copied_job()
      print(paste("got job id ", new_id))
      new_title = transform_title_reactive()
      print(paste("got new title ", new_title))
      system(paste("cd ~/Documents/new_goldbuster_app/"), intern=TRUE)
      system("source /Users/catherine/.rvm/scripts/rvm")
      print("about to command")
      updated_title = system(
        paste("bundle exec ruby update_title.rb ", new_id, " \"",new_title,"\" ", sep=""),
        intern= T)
      paste(updated_title)
    }
  })
  
  output$update_title <- renderText({
    if (is.na(input$jobID)) {
      paste("8. Update Title")
    } else {
      print("I am in update_title")
      update = update_title_reactive()
      if (length(update) > 0 && grepl(update, pattern="^\\{\"error\"\\:")) {
        stop(paste("8. Update Title: ERROR! \nWe got the following error message when we tried to update the title:", update))
      } else {
        print_var = paste("8. Update Settings: SUCCESS.")
      }
      print_var
    }
  })
  
  
  update_instructions_reactive <- reactive({
    if (is.na(input$jobID)) {
      paste("This will be update_instructions_reactive")
    } else {
      new_id = copied_job()
      print(paste("got job id ", new_id))
      new_instructions = transform_instructions_reactive()
      print(paste("got new instructions ", new_instructions))
      system(paste("cd ~/Documents/new_goldbuster_app/"), intern=TRUE)
      system("source /Users/catherine/.rvm/scripts/rvm")
      print("about to command")
      new_instructions = gsub(new_instructions, pattern='"', replacement='\\\\"')
      command = paste("bundle exec ruby update_instructions.rb ",
                      new_id, ' """', new_instructions, '"""', sep="")
      print(command)
      updated_instructions = system(command,
                                    intern= T)
      updated_instructions
    }
  })
  
  
  update_css_reactive <- reactive({
    if (is.na(input$jobID)) {
      paste("This will be update_instructions_reactive")
    } else {
      new_id = copied_job()
      print(paste("got job id ", new_id))
      new_css = transform_css_reactive()
      print(paste("got new css ", new_css))
      system(paste("cd ~/Documents/new_goldbuster_app/"), intern=TRUE)
      system("source /Users/catherine/.rvm/scripts/rvm")
      print("about to command")
      new_css = gsub(new_css, pattern='"', replacement='\\\\"')
      command = paste("bundle exec ruby update_css.rb ",
                      new_id, ' """', new_css, '"""', sep="")
      print(command)
      updated_instructions = system(command,
                                    intern= T)
      updated_instructions
    }
  })
  
  update_cml_reactive <- reactive({
    if (is.na(input$jobID)) {
      paste("This will be update_instructions_reactive")
    } else {
      new_id = copied_job()
      print(paste("got job id ", new_id))
      new_cml = transform_cml_reactive()
      print(paste("got new CML ", new_cml))
      system(paste("cd ~/Documents/new_goldbuster_app/"), intern=TRUE)
      system("source /Users/catherine/.rvm/scripts/rvm")
      print("about to command")
      new_cml = gsub(new_cml, pattern='"', replacement='\\\\"')
      command = paste("bundle exec ruby update_cml.rb ",
                      new_id, ' """', new_cml, '"""', sep="")
      print(command)
      updated_instructions = system(command,
                                    intern= T)
      paste(updated_instructions)
    }
  })
  
  
  output$update_instructions <- renderText({
    if (is.na(input$jobID)) {
      paste("10. Update Instructions")
    } else {
      print("I am in update_instructions")
      update = update_instructions_reactive()
      if (length(update) > 0 && grepl(update, pattern="^\\{\"error\"\\:")) {
        stop(paste("10. Update Instructions: ERROR! \nWe got the following error message when we tried to update Instructions:", update))
      } else {
        print_var = paste("10. Update Instructions: SUCCESS.")
      }
      print_var
    }
  })
  
  output$update_css <- renderText({
    if (is.na(input$jobID)) {
      paste("9. Update CSS")
    } else {
      print("I am in update_css")
      update = update_css_reactive()
      if (length(update) > 0 && grepl(update, pattern="^\\{\"error\"\\:")) {
        stop(paste("9. Update CSS: ERROR! \nWe got the following error message when we tried to update Instructions:", update))
      } else {
        print_var = paste("9. Update CSS: SUCCESS.")
      }
      print_var
    }
  })
  
  output$update_cml <- renderText({
    if (is.na(input$jobID)) {
      paste("11. Update CML. This is the tricky part.")
    } else {
      print("I am in update_cml")
      update = update_cml_reactive()
      print(update)
      
      # store fields that got goldified as a vector
      if (length(update) > 0 && grepl(update, pattern="^\\{\"error\"\\:")) {
        stop(paste("11. Update CML: ERROR! \nWe got the following error message when we tried to update CML:", update))
      } else {
        print_var = paste("11. Update CML: SUCCESS.")
      }
      print_var
    }
  })
  
})

