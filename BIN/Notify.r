
#' Notify
#'
#' This function allows the automated notification of the completetion of the model.
#' @param name The name of the model run that is now completed.
#' @import twitteR
#' @export
#' @examples notify()
notify = function(name) {
    consumer_key <- ''
    consumer_secret <- ''
    access_token <- ''
    access_secret <- ''
    setup_twitter_oauth(consumer_key,consumer_secret,access_token,access_secret)
    
    message = paste("@TBryceKelly. Your results of ",name, " are now in.")
    try(tweet(message))
}