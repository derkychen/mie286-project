# MIE286 Project

Authors: Derek Chen, Han Fang, Mani Majd

## Setup

Requirements: you have `R` installed on your device.

1. Clone the repository

```sh
git clone https://github.com/derkychen/mie286-project.git
```

2. Open your R console inside the project directory, and run

```sh
install.packages("renv") # If you do not have renv
renv::restore() # Restore the packages from renv.lock
```

to install dependencies

## Usage

Open your R console inside the project directory, and run

```sh
library(shiny)
runApp("app")
```
