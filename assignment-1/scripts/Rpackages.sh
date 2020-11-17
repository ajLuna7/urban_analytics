#!/bin/bash
module load R/3.2
R &&
.libPaths(new='~/R/x86_64-pc-linux-gnu-library/3.2')
dir.create('~/R/x86_64-pc-linux-gnu-library/3.2', showWarnings = FALSE, recursive = TRUE)
libPaths()
install.packages("tidyverse")
install.packages("sf")
install.packages("tmap")
install.packages("leaflet")
quit()
y

