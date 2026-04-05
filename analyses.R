library(readr)
library(dplyr)

# Load data, make feedback type a factor
df <- read_csv("app/data.csv")
df$feedback <- factor(df$feedback, levels = c("no_timer", "timer"))


# General Statistics and Plotting ----------------------------------------------

# Sumarry table for both feedback groups
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
dev.new()
par(mfrow = c(1, 2))
boxplot(
  speed ~ feedback,
  data = df,
  main = "Speed by Feedback Group",
  xlab = "Feedback",
  ylab = "Speed"
)
boxplot(
  accuracy ~ feedback,
  data = df,
  main = "Accuracy by Feedback Group",
  xlab = "Feedback",
  ylab = "Accuracy"
)
par(mfrow = c(1, 1))
dev.copy(
  png,
  filename = "images/boxplots.png",
  width = 500,
  height = 500,
  pointsize = 18
)
dev.off()

# Scatterplot of accuracy vs. speed
dev.new()
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
  "bottomleft",
  legend = levels(df$feedback),
  col = c("blue", "red"),
  pch = 19
)
dev.copy(
  png,
  filename = "images/scatterplot.png",
  width = 500,
  height = 500,
  pointsize = 18
)
dev.off()


# Normal QQ Plots and Shapiro-Wilk Tests ---------------------------------------

# Speed for no timer
dev.new()
qqnorm(df$speed[df$feedback == "no_timer"], main = "QQ Plot: Speed (no_timer)")
qqline(df$speed[df$feedback == "no_timer"])

dev.copy(
  png,
  filename = "images/qqspeednotimer.png",
  width = 500,
  height = 500,
  pointsize = 18
)
dev.off()

print(shapiro.test(df$speed[df$feedback == "no_timer"]))

# Speed for timer
dev.new()
qqnorm(df$speed[df$feedback == "timer"], main = "QQ Plot: Speed (timer)")
qqline(df$speed[df$feedback == "timer"])

dev.copy(
  png,
  filename = "images/qqspeedtimer.png",
  width = 500,
  height = 500,
  pointsize = 18
)
dev.off()

print(shapiro.test(df$speed[df$feedback == "timer"]))

# Accuracy for no timer
dev.new()
qqnorm(
  df$accuracy[df$feedback == "no_timer"],
  main = "QQ Plot: Accuracy (no_timer)"
)
qqline(df$accuracy[df$feedback == "no_timer"])

dev.copy(
  png,
  filename = "images/qqaccuracynotimer.png",
  width = 500,
  height = 500,
  pointsize = 18
)
dev.off()

print(shapiro.test(df$accuracy[df$feedback == "no_timer"]))

# Accuracy for timer
dev.new()
qqnorm(df$accuracy[df$feedback == "timer"], main = "QQ Plot: Accuracy (timer)")
qqline(df$accuracy[df$feedback == "timer"])

dev.copy(
  png,
  filename = "images/qqaccuracytimer.png",
  width = 500,
  height = 500,
  pointsize = 18
)
dev.off()

print(shapiro.test(df$accuracy[df$feedback == "timer"]))


# Two Sample t-Tests -----------------------------------------------------------

# F-test to check equal variance assumption
print(var.test(speed ~ feedback, data = df))
print(var.test(accuracy ~ feedback, data = df))

# t-tests for speed and accuracy by feedback type
print(t.test(speed ~ feedback, data = df, var.equal = TRUE))
print(t.test(accuracy ~ feedback, data = df, var.equal = TRUE))


# Speed-Accuracy Correlation ---------------------------------------------------

# Correlation for no timer
print(cor.test(
  df$speed[df$feedback == "no_timer"],
  df$accuracy[df$feedback == "no_timer"],
  method = "pearson"
))

# Correlation for timer
print(cor.test(
  df$speed[df$feedback == "timer"],
  df$accuracy[df$feedback == "timer"],
  method = "pearson"
))
