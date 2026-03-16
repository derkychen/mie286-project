library(shiny)
library(bslib)
library(readr)
library(shinyjs)

# Read questions (NOTE: questions.csv must exist)
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
    state = "pretest",
    question_num = 1,
    responses = data.frame(),
    question_start = NULL
  )

  participant_info <- reactiveVal(NULL)

  # Ending test
  end_test <- function() {
    rv$state <- "posttest"

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

    # Store summary in data.csv
    num_answers <- nrow(rv$responses)
    num_correct_answers <- sum(rv$responses$correct)
    time <- sum(rv$responses$response_time)
    summary <- data.frame(
      name = participant_info()$name,
      email = participant_info()$email,
      gender = participant_info()$gender,
      discipline = participant_info()$discipline,
      feedback = feedback,
      num_answers = num_answers,
      num_correct_answers = num_correct_answers,
      time = time,
      speed = if (time > 0) num_answers / time else NA_real_,
      accuracy = if (num_answers > 0) {
        num_correct_answers / num_answers
      } else {
        NA_real_
      }
    )
    write.table(
      summary,
      file = "data.csv",
      sep = ",",
      append = file.exists("data.csv"),
      col.names = !file.exists("data.csv"),
      row.names = FALSE
    )
  }

  # Main UI pages (pretest -> test -> posttest)
  output$ui_content <- renderUI({
    if (rv$state == "pretest") {
      tagList(
        h1("Mental Arithmetic Test"),
        div(
          p(paste(
            "You will be presented with",
            nrow(questions),
            "mental addition, subtraction, multiplication, and division problems of various difficulties."
          )),
          p(
            "Enter digits with the number row. Use backspace to clear the last entered digit. Press the Enter/Return key to submit your answer."
          ),
          p("To the best of your ability, answer as many questions correctly."),
          class = "instructions-text"
        ),
        layout_columns(
          col_widths = c(6, 6),
          textInput("participant_name", "Name"),
          textInput("participant_email", "Email"),
          selectInput(
            "participant_gender",
            "Gender",
            choices = c(
              "Select..." = "",
              "Man",
              "Woman",
              "Other",
              "Prefer not to say"
            )
          ),
          selectInput(
            "participant_discipline",
            "Discipline",
            choices = c(
              "Select..." = "",
              "Engineering Science",
              "Chemical Engineering",
              "Civil Engineering",
              "Electrical & Computer Engineering",
              "Industrial Engineering",
              "Materials Engineering",
              "Mechanical Engineering",
              "Mineral Engineering"
            )
          ),
          class = "participant-info-section"
        ),
        actionButton("start", "Start")
      )
    } else if (rv$state == "test") {
      tagList(
        div(
          paste("Question", rv$question_num, "of", nrow(questions)),
          class = "progress-text"
        ),
        div(questions$question[rv$question_num], class = "question-text"),
        div(
          textInput("user_ans", label = NULL), # Text instead of numeric input for less clutter and more control over behaviour
          class = "input-wrap"
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

  # Enable 'Start' building when all input fields are filled
  observe({
    is_filled <- function(x) {
      !is.null(x) && nzchar(trimws(x))
    }
    ready <-
      is_filled(input$participant_name) &&
      is_filled(input$participant_email) &&
      is_filled(input$participant_gender) &&
      is_filled(input$participant_discipline)
    if (ready) {
      enable("start")
    } else {
      disable("start")
    }
  })

  # On test start
  observeEvent(input$start, {
    req(
      nzchar(trimws(input$participant_name)),
      nzchar(trimws(input$participant_email)),
      nzchar(input$participant_gender),
      nzchar(input$participant_discipline)
    )

    rv$state <- "test"

    # Store participant information
    participant_info(list(
      name = input$participant_name,
      email = input$participant_email,
      gender = input$participant_gender,
      discipline = input$participant_discipline
    ))

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
  observeEvent(input$submission, {
    req(rv$state == "test")

    # Store question data
    question <- questions$question[rv$question_num]
    answer <- questions$answer[rv$question_num]
    submission <- as.numeric(input$submission)
    response_time <- as.numeric(difftime(
      Sys.time(),
      rv$question_start,
      units = "secs"
    ))
    rv$responses <- rbind(
      rv$responses,
      data.frame(
        question_num = rv$question_num,
        question = question,
        answer = answer,
        submission = submission,
        correct = submission == answer,
        response_time = response_time
      )
    )

    # Move on to next question unless at the last question
    if (rv$question_num < nrow(questions)) {
      rv$question_num <- rv$question_num + 1
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
