library(devtools)

# devtools::install_github("c1au6i0/covid19census")
library(kableExtra)
library(covid19census)
library(dplyr)
library(showtext)
library(hexSticker)
library(ggplot2)
library(png)
library(grid)

tab2 <- getus_all()

tab2 <- ff[1:50, 1:50]


names(tab2) <- paste0("x", 1:50)


tab2 %>%
  kable(escape = F, align = "c") %>%
  column_spec(1:50, bold = T, border_right = T) %>%
  kable_styling(
    latex_options = c("striped", "scale_down"),
    full_width = FALSE,
    font_size = 5
  )



tab1 <- getit_all()
glimpse(tab1)

imgurl <- readPNG("inst/img/image_logo.png")
imgurl <- rasterGrob(imgurl, interpolate = TRUE)

font_add_google(name = "Quantico", "gira")
showtext_auto()

sticker(
  imgurl,
  package = "covid19census",
  p_size = 5,
  p_y = 1.5,
  s_x = 1.1,
  s_y = 0.7,
  s_width = 2.5,
  s_height = 2.5,
  p_color = "#b83335",
  p_family = "gira",
  filename = "inst/img/hexsticker2.png",
  h_color = "#b83335",
  h_fill = "white"
)

