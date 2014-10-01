//
//  Tweet.swift
//  CodePathTwitter
//
//  Created by Ray Ho on 9/27/14.
//  Copyright (c) 2014 Prime Rib Software. All rights reserved.
//

import Foundation

class Tweet {
    var id: String!
    var user: User!
    var text: String!
    var timestamp: NSDate!
    var timestampFormatted: String!
    var numRetweets: Int
    var numFavorites: Int
    var didRetweet: Bool
    var didFavorite: Bool
    var mentions: [String]

    init(tweetDict: NSDictionary) {
        id = tweetDict["id_str"] as NSString
        user = User(userDict: tweetDict["user"] as NSDictionary)
        text = tweetDict["text"] as NSString
        var dateFormatter: NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEE MMM dd HH:mm:ss ZZZ yyyy"
        timestamp = dateFormatter.dateFromString(tweetDict["created_at"] as NSString)
        timestampFormatted = Tweet.timeAgo(timestamp)
        numRetweets = tweetDict["retweet_count"] as Int
        numFavorites = tweetDict["favorite_count"] as Int
        didRetweet = tweetDict["retweeted"] as Bool
        didFavorite = tweetDict["favorited"] as Bool

        // Populate mentions
        mentions = []
        var entities: NSDictionary? = tweetDict["entities"] as? NSDictionary
        if (entities != nil) {
            var users: NSArray? = entities!["user_mentions"] as? NSArray
            if (users != nil) {
                for u in users! {
                    var uDict: NSDictionary = u as NSDictionary
                    mentions.append(uDict["screen_name"] as NSString)
                }
            }
        }
    }

    class func timeAgo(timestamp: NSDate) -> String {
        var timeInterval: NSTimeInterval = -timestamp.timeIntervalSinceNow

        // Seconds ago
        if (timeInterval < 60) {
            return "Just now"
        }

        // Minutes ago
        var temp: Double = timeInterval / 60
        if (temp < 60) {
            return NSString(format: "%dm", NSNumber(double: temp).integerValue)
        }

        // Hours ago
        temp /= 60
        if (temp < 24) {
            return NSString(format: "%dh", NSNumber(double: temp).integerValue)
        }

        // Days ago
        temp /= 24
        if (temp < 7) {
            return NSString(format: "%dd", NSNumber(double: temp).integerValue)
        }

        // Weeks ago
        temp /= 7
        if (temp < 4) {
            return NSString(format: "%dw", NSNumber(double: temp).integerValue)
        }

        // Months ago
        temp /= 4
        if (temp < 12) {
            return NSString(format: "%dm", NSNumber(double: temp).integerValue)
        }

        // Years ago
        temp /= 12
        return NSString(format: "%dy", NSNumber(double: temp).integerValue)
    }
}