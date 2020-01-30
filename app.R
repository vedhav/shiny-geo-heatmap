library(tidyverse)
library(shiny)
library(reticulate)
library(digest)
use_python("/usr/bin/python3")
source_python("geo_heatmap.py")
absolute_path <- "/home/vedha/vedha/repo/shiny-geo-heatmap/"

ui <- fluidPage(
    fluidRow(fileInput("takeout_zip", "Upload your takeout location zip file", accept = ".zip")),
    fluidRow(style = "height: 90vh; width: 100vw", uiOutput("i_frame_output"))
)

server <- function(input, output, session) {
    random_file_name <- ""
    options(shiny.maxRequestSize=30*1024^2)
    observeEvent(input$takeout_zip, {
        print(random_file_name)
        # Deleting the file from this current sesion, if this is not the first upload
        print(input$takeout_zip$datapath)
        if (file.exists(random_file_name)) 
            file.remove(random_file_name)
        random_file_name <<- paste0("www/", digest(input$takeout_zip$datapath), ".html")
        save_geo_heatmap(
            data_file = list(input$takeout_zip$datapath),
            output_file = paste0(absolute_path, random_file_name),
            date_range = list(NULL, NULL),
            stream_data = FALSE,
            settings = list('tiles' = 'OpenStreetMap', 'zoom_start' = 6, 'radius' = 7, 'blur' = 4, 'min_opacity' = 0.2, 'max_zoom' = 4)
        )
        output$i_frame_output <- renderUI({
            tags$iframe(src=gsub("www/", "", random_file_name), height="1000px", width="100%")
        })
    })
    session$onSessionEnded(function() {
        # Delerting the last file once the session has ended
        if (file.exists(random_file_name)) 
            file.remove(random_file_name)
    })
}

shinyApp(ui, server)