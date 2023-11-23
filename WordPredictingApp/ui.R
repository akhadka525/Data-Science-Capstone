## Libraries
library(dplyr)
library(tm)
library(stringi)
library(shiny)
library(shinythemes)

shinyUI(
    navbarPage("Word Prediction App",
               theme = shinytheme("spacelab"),
               tabPanel("App Home",
                        fluidPage(
                            titlePanel("App Home"),
                            sidebarLayout(
                                sidebarPanel(
                                    helpText("Please enter word(s) or partial/incomplete sentence to begin"),
                                    textInput("userInput",
                                              "Enter Text Here",
                                              value =  "",
                                              placeholder = "Enter text here"),
                                    br(),
                                    br(),
                                    h4("App: Word Predicting App"),
                                    p("Created by Anil K. Khadka"),
                                    p("Email: akhadka525@gmail.com"),
                                    p("Website: https://github.com/akhadka525"),
                                    p("RPub: https://rpubs.com/anil_khadka"),
                                    ),
                                mainPanel(
                                    h2("Input text"),
                                    verbatimTextOutput("userText", placeholder = TRUE),
                                    br(),
                                    h2("Predicted Next Word"),
                                    verbatimTextOutput("word", placeholder = TRUE),
                                br(),
                                br(),
                                br(),
                                h2("How to Use App?"),
                                textOutput("how"),
                                h3("Example Input Text"),
                                textOutput("exmptxt"),
                                br(),
                                h3("Example Predicted Next Word"),
                                   textOutput("exmpword")
                                )
                            )
                        )
               ),
               tabPanel("About the App",
                        includeMarkdown("app_description.md")
                        )
    )
)