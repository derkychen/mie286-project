library(shiny)
library(bslib)
library(readr)
library(shinyjs)

# Read questions
questions <- read_csv("questions.csv")

ui <- page_fillable(
  # Styles and app behaviour
  theme = bs_theme(version = 5, bootswatch = "flatly"),
  tags$head(
    useShinyjs(),
    includeCSS("www/style.css"),
    includeScript("www/script.js")
  ),

  # Main content
  div(
    class = "main-content",
    div(class = "timer-wrapper", div(id = "timer")),
    card(class = "main-card", uiOutput("ui_content"))
  )
)

server <- function(input, output, session) {
  # Randomly sample for presence of timer feedback
  feedback <- sample(c("timer", "no_timer"), 1)
  print(paste("Feedback:", feedback))

  rv <- reactiveValues(
    state = "instructions",
    qnum = 1,
    responses = data.frame(),
    question_start = NULL
  )

  # Ending test
  end_test <- function() {
    rv$state <- "done"

    # Stop timer
    runjs("endTestPhase();")

    # Store detailed results in dedicated csv
    if (!dir.exists("results")) {
      dir.create("results")
    }
    write_csv(
      rv$responses,
      paste0(
        "results/",
        format(Sys.time(), "%Y-%m-%d_%H-%M-%S_"),
        feedback,
        ".csv"
      )
    )
  }

  # Main UI pages (instructions -> test -> done)
  output$ui_content <- renderUI({
    if (rv$state == "instructions") {
      tagList(
        h1("Mental Arithmetic Test"),
        div(
          p(
            "You will be presented with 50 mental addition (+), subtraction (-), multiplication (*), and division (/) problems of various difficulties."
          ),
          p("To the best of your ability, answer as many questions correctly."),
          class = "instructions"
        ),
        actionButton("start", "Begin")
      )
    } else if (rv$state == "test") {
      tagList(
        div(paste("Question", rv$qnum, "of 50"), class = "progress-text"),
        div(questions$question[rv$qnum], class = "question-text"),
        div(
          textInput("user_ans", label = NULL),
          class = "centered-input-wrap"
        ),
      )
    } else {
      tagList(
        h1("Thank you for participating!"),
        p(
          "The test has ended. Your results have been recorded. Have a good day."
        )
      )
    }
  })

  # On test start
  observeEvent(input$start, {
    rv$state <- "test"

    # Record question start time
    rv$question_start <- Sys.time()

    # Show timer depending on feedback condition
    if (feedback == "timer") {
      runjs("$('#timer').show();")
    } else {
      runjs("$('#timer').hide();")
    }

    # Start the test phase behaviour
    runjs("startTestPhase();")
  })

  # On submission of an answer
  observeEvent(input$submit_val, {
    req(rv$state == "test")

    # Store question data
    question <- questions$question[rv$qnum]
    answer = questions$answer[rv$qnum]
    submission = input$submit_val
    response_time <- as.numeric(difftime(
      Sys.time(),
      rv$question_start,
      units = "secs"
    ))
    rv$responses <- rbind(
      rv$responses,
      data.frame(
        qnum = rv$qnum,
        question = question,
        answer = answer,
        submission = submission,
        correct = submission == answer,
        response_time = response_time
      )
    )

    # Move on to next question unless at the last question
    if (rv$qnum < nrow(questions)) {
      rv$qnum <- rv$qnum + 1
      rv$question_start <- Sys.time()
    } else {
      end_test()
    }
  })

  # Finish test if time is up
  observeEvent(input$time_up, {
    req(rv$state == "test")
    end_test()
  })
}

shinyApp(ui, server)
