library(readr)

# Load data, make feedback type a factor
df <- read_csv("app/data.csv")
df$feedback <- factor(df$feedback, levels = c("no_timer", "timer"))

# Normal QQ Plots and Shapiro-Wilk Tests ---------------------------------------

# Speed for no timer
dev.new()
qqnorm(df$speed[df$feedback == "no_timer"], main = "QQ Plot: Speed (no_timer)")
qqline(df$speed[df$feedback == "no_timer"])

dev.copy(png, filename = "qqspeednotimer.png", width = 500, height = 500)
dev.off()

print(shapiro.test(df$speed[df$feedback == "no_timer"]))

# Speed for timer
dev.new()
qqnorm(df$speed[df$feedback == "timer"], main = "QQ Plot: Speed (timer)")
qqline(df$speed[df$feedback == "timer"])

dev.copy(png, filename = "qqspeedtimer.png", width = 500, height = 500)
dev.off()

print(shapiro.test(df$speed[df$feedback == "timer"]))

# Accuracy for no timer
dev.new()
qqnorm(
  df$accuracy[df$feedback == "no_timer"],
  main = "QQ Plot: Accuracy (no_timer)"
)
qqline(df$accuracy[df$feedback == "no_timer"])

dev.copy(png, filename = "qqaccuracynotimer.png", width = 500, height = 500)
dev.off()

print(shapiro.test(df$accuracy[df$feedback == "no_timer"]))

# Accuracy for timer
dev.new()
qqnorm(df$accuracy[df$feedback == "timer"], main = "QQ Plot: Accuracy (timer)")
qqline(df$accuracy[df$feedback == "timer"])

dev.copy(png, filename = "qqaccuracytimer.png", width = 500, height = 500)
dev.off()

print(shapiro.test(df$accuracy[df$feedback == "timer"]))


# Two Sample t-Tests -----------------------------------------------------------

# F-test to check equal variance assumption
print(var.test(speed ~ feedback, data = df))
print(var.test(accuracy ~ feedback, data = df))

# t-tests for speed and accuracy by feedback group
print(t.test(speed ~ feedback, data = df, var.equal = TRUE))
print(t.test(accuracy ~ feedback, data = df, var.equal = TRUE))
