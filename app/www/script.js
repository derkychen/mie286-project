let duringTest = false;
var startTime, timerInterval;
var totalDuration = 3 * 60 * 1000;

function startTestPhase() {
  duringTest = true;

  // Start timer
  startTime = Date.now();
  timerInterval = setInterval(updateTimer, 10);
  updateTimer();
}

function endTestPhase() {
  duringTest = false;

  // Stop timer
  clearInterval(timerInterval);
}

// Update the displayed timer
function updateTimer() {
  var elapsed = Date.now() - startTime;
  var remaining = Math.max(0, totalDuration - elapsed);

  var minutes = Math.floor(remaining / 60000);
  var seconds = Math.floor((remaining % 60000) / 1000);

  var display =
    (minutes < 10 ? "0" : "") +
    minutes +
    ":" +
    (seconds < 10 ? "0" : "") +
    seconds;

  var timerEl = document.getElementById("timer");
  if (timerEl) timerEl.innerHTML = display;

  if (remaining <= 0) {
    endTestPhase();
    Shiny.setInputValue("time_up", Date.now(), { priority: "event" });
  }
}

// Always focus on input field
setInterval(function () {
  if (!duringTest) return;

  var input = document.getElementById("user_ans");
  if (input && document.activeElement !== input) input.focus();
}, 50);

// Key filtering during test
$(document).on("keydown", function (e) {
  if (!duringTest) return;
  var input = $("#user_ans");

  // Only allow character input for numbers
  if (
    !(
      (e.key >= "0" && e.key <= "9") ||
      e.key === "Backspace" ||
      e.key === "ArrowLeft" ||
      e.key === "ArrowRight" ||
      e.key === "ArrowUp" ||
      e.key === "ArrowDown"
    )
  ) {
    e.preventDefault();
  }
  // Submit when Enter key pressed on non-empty input
  if (e.key === "Enter" && input.val() !== "") {
    Shiny.setInputValue("submission", input.val(), { priority: "event" });
    input.val("");
  }
});
