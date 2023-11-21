### Download and install libraries

packages <- c("tidyverse", "dplyr", "stringi", "knitr", "tm", "quanteda", "wordcloud")
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

## Explore Data
blog_size <- sapply(list(en_US.blogs.txt), 
                    function(x){format(object.size(x),"MB")})
blog_rows <- sapply(list(en_US.blogs.txt), 
                    function(x){length(x)})
blog_char <- sapply(list(en_US.blogs.txt), 
                    function(x){sum(nchar(x))})
blog_words <- sum(stri_count_words(en_US.blogs.txt))

news_size <- sapply(list(en_US.news.txt), 
                    function(x){format(object.size(x),"MB")})
news_rows <- sapply(list(en_US.news.txt), 
                    function(x){length(x)})
news_char <- sapply(list(en_US.news.txt), 
                    function(x){sum(nchar(x))})
news_words <- sum(stri_count_words(en_US.news.txt))

twitter_size <- sapply(list(en_US.twitter.txt), 
                       function(x){format(object.size(x),"MB")})
twitter_rows <- sapply(list(en_US.twitter.txt), 
                       function(x){length(x)})
twitter_char <- sapply(list(en_US.twitter.txt), 
                       function(x){sum(nchar(x))})
twitter_words <- sum(stri_count_words(en_US.twitter.txt))


## Clean Data

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

blog <- cleanData(readLines("en_US.blogs.txt", warn = FALSE, encoding = "UTF-8"))
news <- cleanData(readLines("en_US.news.txt", warn = FALSE, encoding = "UTF-8"))
twitter <- cleanData(readLines("en_US.twitter.txt", warn = FALSE, encoding = "UTF-8"))
blog <- unlist(blog)
news <- unlist(news)
twitter <- unlist(twitter)

## Create Sample

set.seed(1250)
sample_blog <- sample(blog, floor(0.70 * length(blog)))
sample_news <- sample(news, floor(0.70 * length(news)))
sample_twitter <- sample(twitter, floor(0.70 * length(twitter)))

## Explore Sample Data
sample_blog_rows <- sapply(list(sample_blog), 
                           function(x){length(x)})
sample_blog_char <- sapply(list(sample_blog), 
                           function(x){sum(nchar(x))})
sample_blog_words <- sum(stri_count_words(sample_blog))
sample_blog_unique_words <- sum(unique(stri_count_words(sample_blog)))


sample_news_rows <- sapply(list(sample_news), 
                           function(x){length(x)})
sample_news_char <- sapply(list(sample_news), 
                           function(x){sum(nchar(x))})
sample_news_words <- sum(stri_count_words(sample_news))
sample_news_unique_words <- sum(unique(stri_count_words(sample_news)))


sample_twitter_rows <- sapply(list(sample_twitter), 
                              function(x){length(x)})
sample_twitter_char <- sapply(list(sample_twitter), 
                              function(x){sum(nchar(x))})
sample_twitter_words <- sum(stri_count_words(sample_twitter))
sample_twitter_unique_words <- sum(unique(stri_count_words(sample_twitter)))

## N-gram model
generate_ngrams <- function(file, n) {
        corp <- corpus(file, docnames = paste0("doc_", seq_along(file)))
        tokens <- tokens(corp, what = "word")
        ngrams <- tokens_ngrams(tokens, n = n)
        return(ngrams)
}

## N-grams 1,2,3
blog_1_grams <- generate_ngrams(sample_blog, 1)
all_blog_1_grams <- unlist(blog_1_grams)
news_1_grams <- generate_ngrams(sample_news, 1)
all_news_1_grams <- unlist(news_1_grams)
twitter_1_grams <- generate_ngrams(sample_twitter, 1)
all_twitter_1_grams <- unlist(twitter_1_grams)


blog_2_grams <- generate_ngrams(sample_blog, 2)
all_blog_2_grams <- unlist(blog_2_grams)
news_2_grams <- generate_ngrams(sample_news, 2)
all_news_2_grams <- unlist(news_2_grams)
twitter_2_grams <- generate_ngrams(sample_twitter, 2)
all_twitter_2_grams <- unlist(twitter_2_grams)


blog_3_grams <- generate_ngrams(sample_blog, 3)
all_blog_3_grams <- unlist(blog_3_grams)
news_3_grams <- generate_ngrams(sample_news, 3)
all_news_3_grams <- unlist(news_3_grams)
twitter_3_grams <- generate_ngrams(sample_twitter, 3)
all_twitter_3_grams <- unlist(twitter_3_grams)

## High Frequency words
create_word_freq_df <- function(ngrams_vector) {
        word_freq_df <- data.frame(
                word = names(table(ngrams_vector)),
                frequency = as.vector(table(ngrams_vector))
        )
        word_freq_df$word <- gsub("_", " ", word_freq_df$word)
        word_freq_df <- word_freq_df[order(word_freq_df$frequency, decreasing = TRUE), ]
        return(word_freq_df)
}

## Generate word frequency dataframe
word_freq_df_blog_1_gram <- create_word_freq_df(all_blog_1_grams)
word_freq_df_news_1_gram <- create_word_freq_df(all_news_1_grams)
word_freq_df_twitter_1_gram <- create_word_freq_df(all_twitter_1_grams)

word_freq_df_blog_2_gram <- create_word_freq_df(all_blog_2_grams)
word_freq_df_news_2_gram <- create_word_freq_df(all_news_2_grams)
word_freq_df_twitter_2_gram <- create_word_freq_df(all_twitter_2_grams)


word_freq_df_blog_3_gram <- create_word_freq_df(all_blog_3_grams)
word_freq_df_news_3_gram <- create_word_freq_df(all_news_3_grams)
word_freq_df_twitter_3_gram <- create_word_freq_df(all_twitter_3_grams)


## Plots
#### 1-gram

par(mfrow = c(1, 3))
options(scipen = 999)
par(mgp = c(3, 1, 0))

barplot(word_freq_df_blog_1_gram$frequency[1:10], names.arg = word_freq_df_blog_1_gram$word[1:10],
        xlab = "Frequency (1-gram blog)", ylab = "", col = "lightblue", horiz = TRUE,
        las = 1,, xlim = c(0, max(word_freq_df_blog_1_gram$frequency[1:10]) * 1.2),
        cex.names = 1)

barplot(word_freq_df_news_1_gram$frequency[1:10], names.arg = word_freq_df_news_1_gram$word[1:10],
        main = "Top 10 High-Frequency\nWords (1-gram)",
        xlab = "Frequency (1-gram news)", ylab = "", col = "lightblue", horiz = TRUE,
        las = 1,, xlim = c(0, max(word_freq_df_news_1_gram$frequency[1:10]) * 1.2),
        cex.names = 1)

barplot(word_freq_df_twitter_1_gram$frequency[1:10], names.arg = word_freq_df_twitter_1_gram$word[1:10],
        xlab = "Frequency (1-gram twitter)", ylab = "", col = "lightblue", horiz = TRUE,
        las = 1,, xlim = c(0, max(word_freq_df_twitter_1_gram$frequency[1:10]) * 1.2),
        cex.names = 1)

options(scipen = 0)
par(mfrow = c(1, 1))

## 2-grams

par(mfrow = c(1, 3), mar = c(6.5, 6.5, 2, 1))
options(scipen = 999)
par(mgp = c(5.5, 1, 0))

barplot(word_freq_df_blog_2_gram$frequency[1:10], names.arg = word_freq_df_blog_2_gram$word[1:10],
        xlab = "Frequency (2-gram blog)", ylab = "", col = "lightblue", horiz = TRUE,
        las = 1,, xlim = c(0, max(word_freq_df_blog_2_gram$frequency[1:10]) * 1.2),
        cex.names = 1)

barplot(word_freq_df_news_2_gram$frequency[1:10], names.arg = word_freq_df_news_2_gram$word[1:10],
        main = "Top 10 High-Frequency\nWords (2-gram)",
        xlab = "Frequency (2-gram news)", ylab = "", col = "lightblue", horiz = TRUE,
        las = 1,, xlim = c(0, max(word_freq_df_news_2_gram$frequency[1:10]) * 1.2),
        cex.names = 1)

barplot(word_freq_df_twitter_2_gram$frequency[1:10], names.arg = word_freq_df_twitter_2_gram$word[1:10],
        xlab = "Frequency (2-gram twitter)", ylab = "", col = "lightblue", horiz = TRUE,
        las = 1,, xlim = c(0, max(word_freq_df_twitter_2_gram$frequency[1:10]) * 1.2),
        cex.names = 1)

options(scipen = 0)
par(mfrow = c(1, 1))

## 3-grams
par(mfrow = c(1, 3), mar = c(8.5, 8.5, 2, 1))
options(scipen = 999)
par(mgp = c(3, 1, 0))

barplot(word_freq_df_blog_3_gram$frequency[1:10], names.arg = word_freq_df_blog_3_gram$word[1:10],
        xlab = "Frequency (3-gram blog)", ylab = "", col = "lightblue", horiz = TRUE,
        las = 1,, xlim = c(0, max(word_freq_df_blog_3_gram$frequency[1:10]) * 1.2),
        cex.names = 1)

barplot(word_freq_df_news_3_gram$frequency[1:10], names.arg = word_freq_df_news_3_gram$word[1:10],
        main = "Top 10 High-Frequency\nWords (3-gram)",
        xlab = "Frequency (3-gram news)", ylab = "", col = "lightblue", horiz = TRUE,
        las = 1,, xlim = c(0, max(word_freq_df_news_3_gram$frequency[1:10]) * 1.2),
        cex.names = 1)

barplot(word_freq_df_twitter_3_gram$frequency[1:10], names.arg = word_freq_df_twitter_3_gram$word[1:10],
        xlab = "Frequency (3-gram twitter)", ylab = "", col = "lightblue", horiz = TRUE,
        las = 1,, xlim = c(0, max(word_freq_df_twitter_3_gram$frequency[1:10]) * 1.2),
        cex.names = 1)

options(scipen = 0)
par(mfrow = c(1, 1))


## Word cloud

par(mfrow = c(1, 3))

wordcloud(
        words = word_freq_df_blog_1_gram$word[1:100],
        freq = word_freq_df_blog_1_gram$frequency[1:100],
        colors = brewer.pal(7, "Dark2"),
        min.axis.freq = 10, 
        scale = c(0.6, 1),  
        random.order = FALSE,
        rot.per = 0.4,  
        main = "Word Cloud for Top 100 High-Frequency Words",
        max.words = 100  
)


wordcloud(
        words = word_freq_df_news_1_gram$word[1:100],
        freq = word_freq_df_news_1_gram$frequency[1:100],
        colors = brewer.pal(7, "Dark2"),
        min.axis.freq = 10,  
        scale = c(0.6, 1),  
        random.order = FALSE,
        rot.per = 0.4,  
        main = "Word Cloud for Top 100 High-Frequency Words",
        max.words = 100  
)


wordcloud(
        words = word_freq_df_twitter_1_gram$word[1:100],
        freq = word_freq_df_twitter_1_gram$frequency[1:100],
        colors = brewer.pal(7, "Dark2"),
        min.axis.freq = 10, 
        scale = c(0.6, 1),  
        random.order = FALSE,
        rot.per = 0.4,  
        main = "Word Cloud for Top 100 High-Frequency Words",
        max.words = 100  
)

par(mfrow = c(1, 1))

