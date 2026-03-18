library(readr)

# Set seed for reproducibility
set.seed(42)

# Addition and subtraction questions with non-negative results
add_sub_questions <- data.frame(
  question = character(20),
  answer = numeric(20)
)

for (i in seq_len(10)) {
  op <- sample(c("+", "-"), 1)

  if (op == "+") {
    a <- sample(100:999, 1)
    b <- sample(100:999, 1)
    add_sub_questions$question[i] <- paste(a, "+", b)
    add_sub_questions$answer[i] <- a + b
  } else {
    a <- sample(100:999, 1)
    b <- sample(100:a, 1)
    add_sub_questions$question[i] <- paste(a, "\u2212", b)
    add_sub_questions$answer[i] <- a - b
  }
}

# Multiplication and division questions
mul_div_questions <- data.frame(
  question = character(20),
  answer = numeric(20)
)

for (i in seq_len(10)) {
  op <- sample(c("*", "/"), 1)

  if (op == "*") {
    a <- sample(100:999, 1)
    b <- sample(2:9, 1)
    mul_div_questions$question[i] <- paste(a, "\u00d7", b)
    mul_div_questions$answer[i] <- a * b
  } else {
    b <- sample(3:9, 1)
    ans <- sample(100:999, 1)
    a <- b * ans
    mul_div_questions$question[i] <- paste(a, "\u00f7", b)
    mul_div_questions$answer[i] <- ans
  }
}

# Alternate between addition/subtraction and multiplication/division
questions <- add_sub_questions[0, ]

for (i in seq_len(10)) {
  questions <- rbind(
    questions,
    add_sub_questions[i, ],
    mul_div_questions[i, ]
  )
}

# Write questions and answers to csv
write_csv(questions, "app/questions.csv")
