//
//  TwitterClient.swift
//  CodePathTwitter
//
//  Created by Ray Ho on 9/25/14.
//  Copyright (c) 2014 Prime Rib Software. All rights reserved.
//

import UIKit

let TWTR: TwitterClient = TwitterClient()
let TWTR_CALLBACK_URL: NSURL = NSURL.URLWithString("djpxtwitter://oauth")
let TWTR_NOTIF_AUTH_SUCCESS: String = "com.djprefix.twitter.AuthSuccess"
let TWTR_NOTIF_HOME_TIMELINE_SUCCESS: String = "com.djprefix.twitter.HomeTimelineSuccess"
let TWTR_NOTIF_MENTIONS_TIMELINE_SUCCESS: String = "com.djprefix.twitter.MentionsTimelineSuccess"
let TWTR_NOTIF_POST_TWEET_SUCCESS: String = "com.djprefix.twitter.PostTweetSuccess"
let TWTR_NOTIF_POST_RETWEET_SUCCESS: String = "com.djprefix.twitter.PostRetweetSuccess"
let TWTR_NOTIF_POST_FAVORITE_SUCCESS: String = "com.djprefix.twitter.PostFavoriteSuccess"
let TWTR_NOTIF_REMOVE_FAVORITE_SUCCESS: String = "com.djprefix.twitter.RemoveFavoriteSuccess"
class TwitterClient {
    let BASE_URL: NSURL = NSURL.URLWithString("https://api.twitter.com/")
    let CONSUMER_KEY: String = "hXgMMEkjEIBfT3FGYx0kktSAu"
    let CONSUMER_SECRET: String = "gut6s2MWSt7Iw3sbikZ5Zp83zTzRr6GOQi5zI99o6aRygmO6SE"
    var operationManager: BDBOAuth1RequestOperationManager!

    // Determines whether a URL matches our OAuth callback URL
    class func isUserAuthCallbackUrl(url: NSURL) -> Bool {
        return url.scheme! == TWTR_CALLBACK_URL.scheme! && url.host! == TWTR_CALLBACK_URL.host!
    }

    init() {
        operationManager = BDBOAuth1RequestOperationManager(baseURL: BASE_URL, consumerKey: CONSUMER_KEY, consumerSecret: CONSUMER_SECRET)
    }

    // Determines whether we're authorized to pull the user's Twitter feed, profile, etc.
    func isAuthorized() -> Bool {
        return operationManager.authorized && User.getMe() != nil
    }

    // OAuth Step 1: Request token
    func requestAuth() {
        NSLog("Getting request token ...")
        operationManager.fetchRequestTokenWithPath("oauth/request_token", method: "POST", callbackURL: TWTR_CALLBACK_URL, scope: nil, success: onRequestAuthSuccess, failure: onRequestAuthFail)
    }

    // OAuth Step 2: Launch browser to request user authorization
    func onRequestAuthSuccess(requestToken: BDBOAuthToken!) {
        NSLog("Got request token: %@", requestToken.token)
        let userAuthUrlString: String = "\(BASE_URL.absoluteString!)oauth/authorize?oauth_token=\(requestToken.token)"
        let userAuthUrl: NSURL = NSURL.URLWithString(userAuthUrlString)
        NSLog("Launching user authorization URL: %@", userAuthUrl)
        UIApplication.sharedApplication().openURL(userAuthUrl)
    }

    func onRequestAuthFail(error: NSError!) {
        NSLog("Unable to get request token: %@", error)
    }

    // OAuth Step 3: Handle user authorization callback URL [which will get us an access token]
    func handleUserAuthCallbackUrl(callbackUrl: NSURL) {
        NSLog("Handling user authorization callback URL: %@", callbackUrl)
        let urlParams: Dictionary = NSDictionary(fromQueryString: callbackUrl.query)
        let authToken: AnyObject? = urlParams[BDBOAuth1OAuthTokenParameter]
        let authVerifier: AnyObject? = urlParams[BDBOAuth1OAuthVerifierParameter]
        if (authToken != nil && authVerifier != nil) {
            operationManager.fetchAccessTokenWithPath("oauth/access_token", method: "POST", requestToken: BDBOAuthToken(queryString: callbackUrl.query), success: onHandleUserAuthCallbackUrlSuccess, failure: onHandleUserAuthCallbackUrlFail)
        } else {
            NSLog("Missing auth token and verifier params in callback URL: %@", callbackUrl)
        }
    }

    // OAuth "Step 4": Get logged in user info
    func onHandleUserAuthCallbackUrlSuccess(accessToken: BDBOAuthToken!) {
        NSLog("Got access token: %@", accessToken.token)
        NSLog("Getting logged in user info ...")
        operationManager.GET("1.1/account/verify_credentials.json", parameters: nil, success: onGetLoggedInUserSuccess, failure: onGetLoggedInUserFail)
    }

    func onHandleUserAuthCallbackUrlFail(error: NSError!) {
        NSLog("Unable to get access token: %@", error)
    }

    func onGetLoggedInUserSuccess(operation: AFHTTPRequestOperation!, response: AnyObject!) {
        NSLog("Got user info: %@", operation.responseString)
        User.setMe(response as NSDictionary)
        NSNotificationCenter.defaultCenter().postNotificationName(TWTR_NOTIF_AUTH_SUCCESS, object: nil)
    }

    func onGetLoggedInUserFail(operation: AFHTTPRequestOperation!, error: NSError!) {
    }

    func deauthorize() {
        operationManager.deauthorize()
    }

    func getHomeTimeline(sinceId: String?) {
        var url: String = "1.1/statuses/home_timeline.json?count=20";
        if (sinceId != nil) {
            url += "&since_id=\(sinceId!)"
            NSLog("Fetching home timeline since %@ ...", sinceId!)
            getTimeLineLocal("twitter_home_timeline_refresh", successNotificationName: TWTR_NOTIF_HOME_TIMELINE_SUCCESS)
        } else {
            NSLog("Fetching clean home timeline ...")
            getTimeLineLocal("twitter_home_timeline2", successNotificationName: TWTR_NOTIF_HOME_TIMELINE_SUCCESS)
        }
//        operationManager.GET(url, parameters: nil, success: onGetHomeTimelineSuccess, failure: onGetTimelineFail)
    }

    func onGetHomeTimelineSuccess(operation: AFHTTPRequestOperation!, response: AnyObject!) {
        NSLog("Successfully fetched home timeline: %@", operation.responseString)
        parseTimeline(response, successNotificationName: TWTR_NOTIF_HOME_TIMELINE_SUCCESS)
    }

    func getMentionsTimeline(sinceId: String?) {
        var url: String = "1.1/statuses/mentions_timeline.json?count=20";
        if (sinceId != nil) {
            url += "&since_id=\(sinceId!)"
            NSLog("Fetching mentions timeline since %@ ...", sinceId!)
            getTimeLineLocal("twitter_mentions_timeline", successNotificationName: TWTR_NOTIF_MENTIONS_TIMELINE_SUCCESS)
        } else {
            NSLog("Fetching clean mentions timeline ...")
            getTimeLineLocal("twitter_mentions_timeline", successNotificationName: TWTR_NOTIF_MENTIONS_TIMELINE_SUCCESS)
        }
//        operationManager.GET(url, parameters: nil, success: onGetMentionsTimelineSuccess, failure: onGetTimelineFail)
    }

    func onGetMentionsTimelineSuccess(operation: AFHTTPRequestOperation!, response: AnyObject!) {
        NSLog("Successfully fetched home timeline: %@", operation.responseString)
        parseTimeline(response, successNotificationName: TWTR_NOTIF_MENTIONS_TIMELINE_SUCCESS)
    }

    // Debug function to fetch a local version of the home timeline response
    func getTimeLineLocal(name: String, successNotificationName: String) {
        let queue: dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
        dispatch_async(queue, {
            let filePath: String = NSBundle.mainBundle().pathForResource(name, ofType: "json")!
            let data: NSData = NSData(contentsOfFile: filePath)
            var error: NSErrorPointer = NSErrorPointer()
            var response: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: error)
            if (response != nil) {
                self.parseTimeline(response!, successNotificationName: successNotificationName)
            }
        })
    }

    // Parses tweet timelines
    func parseTimeline(response: AnyObject, successNotificationName: String) {
        // Parse JSON into entities in the background
        let queue: dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
        dispatch_async(queue, {
            let rawTweets: NSArray = response as NSArray
            var tweets: Array<Tweet> = Array<Tweet>()
            for rt: AnyObject in rawTweets {
                var tweetEntity: Tweet = Tweet(tweetDict: rt as NSDictionary)
                tweets.append(tweetEntity)
            }
            dispatch_async(dispatch_get_main_queue(), {
                NSNotificationCenter.defaultCenter().postNotificationName(successNotificationName, object: tweets)
            })
        })
    }

    func onGetTimelineFail(operation: AFHTTPRequestOperation!, error: NSError!) {
        NSLog("Unable to fetch timeline: %@", error)
    }

    func postTweet(text: String, inReplyToStatusId: String?) {
        NSLog("Posting tweet: %@", text)
        var params: Dictionary = ["status": text]
        if (inReplyToStatusId != nil) {
            params["in_reply_to_status_id"] = inReplyToStatusId!
        }
        operationManager.POST("1.1/statuses/update.json", parameters: params, success: onPostTweetSuccess, failure: onPostTweetFail)
    }

    func onPostTweetSuccess(operation: AFHTTPRequestOperation!, response: AnyObject!) {
        NSLog("Successfully posted tweet: %@", operation.responseString)
        NSNotificationCenter.defaultCenter().postNotificationName(TWTR_NOTIF_POST_TWEET_SUCCESS, object: response)
    }

    func onPostTweetFail(operation: AFHTTPRequestOperation!, error: NSError!) {
        NSLog("Unable to post tweet: %@", error)
    }

    func postRetweet(statusId: String) {
        operationManager.POST("1.1/statuses/retweet/\(statusId).json", parameters: nil, success: onPostFavoriteSuccess, failure: onPostFavoriteFail)
    }

    func onPostRetweetSuccess(operation: AFHTTPRequestOperation!, response: AnyObject!) {
        NSLog("Successfully posted retweet: %@", operation.responseString)
        NSNotificationCenter.defaultCenter().postNotificationName(TWTR_NOTIF_POST_RETWEET_SUCCESS, object: response)
    }

    func onPostRetweetFail(operation: AFHTTPRequestOperation!, error: NSError!) {
        NSLog("Unable to post retweet: %@", error)
    }

    func postFavorite(statusId: String) {
        operationManager.POST("1.1/favorites/create.json", parameters: ["id": statusId], success: onPostFavoriteSuccess, failure: onPostFavoriteFail)
    }

    func onPostFavoriteSuccess(operation: AFHTTPRequestOperation!, response: AnyObject!) {
        NSLog("Successfully posted favorite: %@", operation.responseString)
        NSNotificationCenter.defaultCenter().postNotificationName(TWTR_NOTIF_POST_FAVORITE_SUCCESS, object: response)
    }

    func onPostFavoriteFail(operation: AFHTTPRequestOperation!, error: NSError!) {
        NSLog("Unable to post favorite: %@", error)
    }

    func removeFavorite(statusId: String) {
        operationManager.POST("1.1/favorites/destroy.json", parameters: ["id": statusId], success: onRemoveFavoriteSuccess, failure: onRemoveFavoriteFail)
    }

    func onRemoveFavoriteSuccess(operation: AFHTTPRequestOperation!, response: AnyObject!) {
        NSLog("Successfully removed favorite: %@", operation.responseString)
        NSNotificationCenter.defaultCenter().postNotificationName(TWTR_NOTIF_REMOVE_FAVORITE_SUCCESS, object: response)
    }

    func onRemoveFavoriteFail(operation: AFHTTPRequestOperation!, error: NSError!) {
        NSLog("Unable to remove favorite: %@", error)
    }
}
