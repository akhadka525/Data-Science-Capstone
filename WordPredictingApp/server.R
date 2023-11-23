## Libraries
library(dplyr)
library(tm)
library(stringi)
library(shiny)
library(shinythemes)

# Load data
df_4gm <- readRDS("text_4gm_count_df.RData");
df_3gm <- readRDS("text_3gm_count_df.RData");
df_2gm <- readRDS("text_2gm_count_df.RData");



# Preprocess User input and define predicting algorithm

predict <- function(inputdata) {
    clean_input_data <- removeNumbers(removePunctuation(tolower(inputdata)))
    data_split <- strsplit(clean_input_data, " ")[[1]]
    
    
    if (length(data_split)>= 3) {
        data_split <- tail(data_split,3)
        if (identical(character(0),head(df_4gm[df_4gm$unigram == data_split[1] & df_4gm$df_2gm == data_split[2] & df_4gm$df_3gm == data_split[3], 4],1))){
            predict(paste(data_split[2],data_split[3],sep=" "))
        }
        else {mesg <<- "Next word is"; head(df_4gm[df_4gm$unigram == data_split[1] & df_4gm$df_2gm == data_split[2] & df_4gm$df_3gm == data_split[3], 4],1)}
    }
    else if (length(data_split) == 2){
        data_split <- tail(data_split,2)
        if (identical(character(0),head(df_3gm[df_3gm$unigram == data_split[1] & df_3gm$df_2gm == data_split[2], 3],1))) {
            predict(data_split[2])
        }
        else {mesg<<- "Next word is"; head(df_3gm[df_3gm$unigram == data_split[1] & df_3gm$df_2gm == data_split[2], 3],1)}
    }
    else if (length(data_split) == 1){
        data_split <- tail(data_split,1)
        if (identical(character(0),head(df_2gm[df_2gm$unigram == data_split[1], 2],1))) {head("Words do not match! Try next.",1)}
        else {mesg <<- "Next word is "; head(df_2gm[df_2gm$unigram == data_split[1],2],1)}
    }
}


shinyServer(function(input, output) {
    output$userText <- renderText({input$userInput});
    
    output$word <- renderPrint({
        predict(input$userInput)
    })
    
    output$how <- renderText({
        "To use this app, enter your input text word or incomplete sentence. 
        The app will process the input text within the blogs, news and twitter
        text data used to develop word predicting model and display the most 
        frequently used word after the input text. If the app didnot find any 
        word it will display 'Words do not match! Try next.' "
    })
    
    output$exmptxt <- renderText({
        "New YorK City"
    })
    
    output$exmpword <- renderText({
        predict("New York City")
    })
}
)
