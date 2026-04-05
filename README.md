# MIE286 Project

Authors: Derek Chen, Han Fang, Mani Majd

## Setup

Requirements: you have `R` installed on your device.

### 1. Clone the repository

```sh
git clone https://github.com/derkychen/mie286-project.git
```

### 2. Install dependencies

Open the R console within your project directory. You can do this by running

```sh
cd <path-to-project-directory>
R
```

or, in the R console,

```R
setwd("<path-to-project-directory>")
```

Then, in your R console, run

```R
install.packages("renv") # Use a Canadian mirror
renv::restore() # Restore the packages from renv.lock
```

to install dependencies. Restart the R session after any of these steps if prompted.

## Run the App

Open your R console inside the project directory, and run

```R
source("app/generate_questions.R") # Generate questions used by app
library(shiny) # Load and attach Shiny
runApp("app") # Run the app
```

## Run the Analyses

Open your R console inside the project directory, and run

```R
source("analyses.R")
```
