library(readr)
library(dplyr)

# Load data, make gender and feedback type factors
df <- read_csv("app/data.csv")
df$gender <- factor(df$gender, levels = c("Man", "Woman"))
df$feedback <- factor(df$feedback, levels = c("no_timer", "timer"))

# Plot and save a figure
plot_and_save <- function(
  filename,
  plot_function,
  width = 500,
  height = 500,
  pointsize = 18
) {
  dev.new()
  plot_function()
  dev.copy(
    png,
    filename = filename,
    width = width,
    height = height,
    pointsize = pointsize
  )
  dev.off()
}


# General Statistics and Plotting ----------------------------------------------

# Summary table for both feedback groups
print(
  df %>%
    group_by(feedback) %>%
    summarise(
      n = n(),
      mean_speed = mean(speed, na.rm = TRUE),
      sd_speed = sd(speed, na.rm = TRUE),
      mean_accuracy = mean(accuracy, na.rm = TRUE),
      sd_accuracy = sd(accuracy, na.rm = TRUE)
    )
)

# Box plots for speed and accuracy by feedback type
plot_and_save(
  "images/genderboxplot.png",
  function() {
    par(mfrow = c(1, 4))
    boxplot(
      speed ~ feedback,
      data = subset(df, gender == "Man"),
      main = "Speed by Feedback Type for Men",
      xlab = "Feedback",
      ylab = "Speed"
    )
    boxplot(
      accuracy ~ feedback,
      data = subset(df, gender == "Man"),
      main = "Accuracy by Feedback Type for Men",
      xlab = "Feedback",
      ylab = "Accuracy"
    )
    boxplot(
      speed ~ feedback,
      data = subset(df, gender == "Woman"),
      main = "Speed by Feedback Type for Women",
      xlab = "Feedback",
      ylab = "Speed"
    )
    boxplot(
      accuracy ~ feedback,
      data = subset(df, gender == "Woman"),
      main = "Accuracy by Feedback Type for Women",
      xlab = "Feedback",
      ylab = "Accuracy"
    )
  },
  width = 1000
)

# Box plots for speed and accuracy by feedback type
plot_and_save("images/feedbackboxplot.png", function() {
  par(mfrow = c(1, 2))
  boxplot(
    speed ~ feedback,
    data = df,
    main = "Speed by Feedback Type",
    xlab = "Feedback",
    ylab = "Speed"
  )
  boxplot(
    accuracy ~ feedback,
    data = df,
    main = "Accuracy by Feedback Type",
    xlab = "Feedback",
    ylab = "Accuracy"
  )
})

# Scatterplot of accuracy vs. speed
plot_and_save("images/scatterplot.png", function() {
  plot(
    df$speed,
    df$accuracy,
    xlab = "Speed",
    ylab = "Accuracy",
    main = "Accuracy vs. Speed",
    pch = 19,
    col = ifelse(df$feedback == "timer", "red", "blue")
  )
  legend(
    "bottomright",
    legend = levels(df$feedback),
    col = c("blue", "red"),
    pch = 19
  )
})

# Normal QQ Plots and Shapiro-Wilk Tests ---------------------------------------

# Speed for no_timer
plot_and_save("images/qqspeednotimer.png", function() {
  qqnorm(
    df$speed[df$feedback == "no_timer"],
    main = "QQ Plot: Speed (no_timer)"
  )
  qqline(df$speed[df$feedback == "no_timer"])
})

print(shapiro.test(df$speed[df$feedback == "no_timer"]))

# Speed for timer
plot_and_save("images/qqspeedtimer.png", function() {
  qqnorm(df$speed[df$feedback == "timer"], main = "QQ Plot: Speed (timer)")
  qqline(df$speed[df$feedback == "timer"])
})

print(shapiro.test(df$speed[df$feedback == "timer"]))

# Accuracy for no_timer
plot_and_save("images/qqaccuracynotimer.png", function() {
  qqnorm(
    df$accuracy[df$feedback == "no_timer"],
    main = "QQ Plot: Accuracy (no_timer)"
  )
  qqline(df$accuracy[df$feedback == "no_timer"])
})

print(shapiro.test(df$accuracy[df$feedback == "no_timer"]))

# Accuracy for timer
plot_and_save("images/qqaccuracytimer.png", function() {
  qqnorm(
    df$accuracy[df$feedback == "timer"],
    main = "QQ Plot: Accuracy (timer)"
  )
  qqline(df$accuracy[df$feedback == "timer"])
})

print(shapiro.test(df$accuracy[df$feedback == "timer"]))


# Two Sample t-Tests -----------------------------------------------------------

# F-test to check equal variance assumption
print(var.test(speed ~ feedback, data = df))
print(var.test(accuracy ~ feedback, data = df))

# t-tests for speed and accuracy by feedback type
print(t.test(speed ~ feedback, data = df, var.equal = TRUE))
print(t.test(accuracy ~ feedback, data = df, var.equal = TRUE))


# Speed-Accuracy Correlation ---------------------------------------------------

# Test for negative correlation for no_timer
print(cor.test(
  df$speed[df$feedback == "no_timer"],
  df$accuracy[df$feedback == "no_timer"],
  method = "pearson",
  alternative = "less"
))

# Test for negative correlation for timer
print(cor.test(
  df$speed[df$feedback == "timer"],
  df$accuracy[df$feedback == "timer"],
  method = "pearson",
  alternative = "less"
))
