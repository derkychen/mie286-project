# MIE286 Project

Authors: Derek Chen, Han Fang, Mani Majd

## Setup

Requirements: you have `R` installed on your device.

1. Clone the repository

```sh
git clone https://github.com/derkychen/mie286-project.git
```

2. Open your R console inside the project directory, and run

```R
install.packages("renv") # If you do not have renv
renv::restore() # Restore the packages from renv.lock
```

to install dependencies

## Run the App

Open your R console inside the project directory, and run

```R
source("app/generate_questions.R") # Generate questions used by app
library(shiny) # Load and attach Shiny
runApp("app") # Run the app
```
