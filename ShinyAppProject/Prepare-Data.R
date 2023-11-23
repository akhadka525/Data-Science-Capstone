### Download and install libraries

packages <- c("tidyverse", "dplyr", "stringi", "knitr", "tm", "quanteda", "Rweka", "rJava")
installed_packages <- packages %in% rownames(installed.packages())
if (any(installed_packages == FALSE)) {
        install.packages(packages[!installed_packages])
}
invisible(lapply(packages, library, character.only = TRUE))

## Download and load the data if not downloaded and loaded 

dir_path <- getwd() 
data_url <- "https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip"
zip_data_file <- "Coursera-SwiftKey.zip"
unzip_dir <- "data"


# Check if the file already exists in the current directory then download data
if (!file.exists(zip_data_file)) {
        download.file(data_url, zip_data_file) # If the file does not exist, download it
        print("File downloaded successfully.")
} else {
        print("File already exists.")
}

# Check if the unzipped data folder already exists

if (!dir.exists(unzip_dir)){
        unzip(zip_data_file, exdir = unzip_dir) # If the folder does not exist, unzip the file
        print("Data unzipped successfully.")
} else {
        print("Data folder already exists.")
}


## Load and read data
en_US.blogs.txt <- readLines(paste("data/final/en_US/en_US.blogs.txt",sep=""), 
                             encoding = 'UTF-8', skipNul = TRUE)
en_US.news.txt <- readLines(paste("data/final/en_US/en_US.news.txt",sep=""), 
                            encoding = 'UTF-8', skipNul = TRUE)
en_US.twitter.txt <- readLines(paste("data/final/en_US/en_US.twitter.txt",sep=""), 
                               encoding = 'UTF-8', skipNul = TRUE)

### Sample only 10% data 

blog <- sample(en_US.blogs.txt, floor(0.10 * length(en_US.blogs.txt)))
news <- sample(en_US.news.txt, floor(0.10 * length(en_US.news.txt)))
twitter <- sample(en_US.twitter.txt, floor(0.10 * length(en_US.twitter.txt)))


### Combine sample data and write to text file
all_text <- c(blog, news, twitter)
writeLines(all_text, "all_text.txt")

## Clean data

cleanData <- function(x) {
        text <- Corpus(VectorSource(x))
        removeURL <- function(x) gsub("http[[:alnum:]]*", "", x)
        removeSign <- function(x) gsub("[[:punct:]]", "", x)
        removeNum <- function(x) gsub("[[:digit:]]", "", x)
        removeapo <- function(x) gsub("'", "", x)
        removeNonASCII <- function(x) iconv(x, "latin1", "ASCII", sub = "")
        removerepeat <- function(x) gsub("([[:alpha:]])\\1{2,}", "\\1\\1", x)
        toLowerCase <- function(x) sapply(x, tolower)
        removeSpace <- function(x) gsub("\\s+", " ", x)
        updatedStopwords <- c(stopwords('en'), "im")
        
        text <- tm_map(text, content_transformer(tolower)) %>%
                tm_map(content_transformer(removeapo)) %>%
                tm_map(content_transformer(removeNum)) %>%
                tm_map(content_transformer(removeURL)) %>%
                tm_map(content_transformer(removeSign)) %>%
                tm_map(content_transformer(removeNonASCII)) %>%
                tm_map(content_transformer(toLowerCase)) %>%
                tm_map(content_transformer(removerepeat)) %>%
                tm_map(content_transformer(removeSpace)) %>%
                tm_map(removeWords, stopwords("english")) %>%
                tm_map(removeWords, updatedStopwords)
        
        return(text)
}

cleaned_data <- cleanData(readLines("all_text.txt", warn = FALSE, encoding = "UTF-8"))
cleaned_data <- unlist(cleaned_data)

## N-gram model

generate_ngrams <- function(file, n) {
        corp <- corpus(file, docnames = paste0("doc_", seq_along(file)))
        tokens <- tokens(corp, what = "word")
        ngrams <- tokens_ngrams(tokens, n = n)
        return(ngrams)
}

text_1gm <- generate_ngrams(cleaned_data, 1)
text_2gm <- generate_ngrams(cleaned_data, 2)
text_3gm <- generate_ngrams(cleaned_data, 3)
text_4gm <- generate_ngrams(cleaned_data, 4)

unlist_text_1gm <- unlist(text_1gm)
unlist_text_2gm <- unlist(text_2gm)
unlist_text_3gm <- unlist(text_3gm)
unlist_text_4gm <- unlist(text_4gm)

## Word frequency table

create_word_count <- function(ngrams_vector) {
        word_count <- data.frame(
                word = names(table(ngrams_vector)),
                count = as.vector(table(ngrams_vector))
        )
        word_count$word <- gsub("_", " ", word_count$word)
        word_count <- word_count[order(word_count$count, decreasing = TRUE), ]
        return(word_count)
}

text_1gm_count <- create_word_count(unlist_text_1gm)
text_2gm_count <- create_word_count(unlist_text_2gm)
text_3gm_count <- create_word_count(unlist_text_3gm)
text_4gm_count <- create_word_count(unlist_text_4gm)


## Save data in dataframe in rdata format
text_4gm_count_split <- strsplit(as.character(text_4gm_count$word),split=" ")
text_4gm_count_dataSep <- transform(text_4gm_count,
                                    first = sapply(text_4gm_count_split,"[[",1),
                                    second = sapply(text_4gm_count_split,"[[",2),
                                    third = sapply(text_4gm_count_split,"[[",3), 
                                    fourth = sapply(text_4gm_count_split,"[[",4))
text_4gm_count_df <- data.frame(unigram = text_4gm_count_dataSep$first,
                                bigram = text_4gm_count_dataSep$second, 
                                trigram = text_4gm_count_dataSep$third, 
                                quadgram = text_4gm_count_dataSep$fourth, 
                                freq = text_4gm_count_dataSep$count,
                                stringsAsFactors=FALSE)
write.csv(text_4gm_count_df[text_4gm_count_df$freq > 1,],
          "./text_4gm_count_df.csv",row.names=F)
text4gmdata <- read.csv("text_4gm_count_df.csv",stringsAsFactors = F)
saveRDS(text4gmdata, "text_4gm_count_df.RData")




text_3gm_count_split <- strsplit(as.character(text_3gm_count$word),split=" ")
text_3gm_count_dataSep <- transform(text_3gm_count,
                                    first = sapply(text_3gm_count_split,"[[",1),
                                    second = sapply(text_3gm_count_split,"[[",2),
                                    third = sapply(text_3gm_count_split,"[[",3))
text_3gm_count_df <- data.frame(unigram = text_3gm_count_dataSep$first,
                                bigram = text_3gm_count_dataSep$second, 
                                trigram = text_3gm_count_dataSep$third, 
                                freq = text_3gm_count_dataSep$count,
                                stringsAsFactors=FALSE)
write.csv(text_3gm_count_df[text_3gm_count_df$freq > 1,],
          "./text_3gm_count_df.csv",row.names=F)
text3gmdata <- read.csv("text_3gm_count_df.csv",stringsAsFactors = F)
saveRDS(text3gmdata, "text_3gm_count_df.RData")


text_2gm_count_split <- strsplit(as.character(text_2gm_count$word),split=" ")
text_2gm_count_dataSep <- transform(text_2gm_count,
                                    first = sapply(text_2gm_count_split,"[[",1),
                                    second = sapply(text_2gm_count_split,"[[",2))
text_2gm_count_df <- data.frame(unigram = text_2gm_count_dataSep$first,
                                bigram = text_2gm_count_dataSep$second, 
                                freq = text_2gm_count_dataSep$count,
                                stringsAsFactors=FALSE)
write.csv(text_2gm_count_df[text_2gm_count_df$freq > 1,],
          "./text_2gm_count_df.csv",row.names=F)
text2gmdata <- read.csv("text_2gm_count_df.csv",stringsAsFactors = F)
saveRDS(text2gmdata, "text_2gm_count_df.RData")
