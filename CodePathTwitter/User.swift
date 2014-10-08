//
//  User.swift
//  CodePathTwitter
//
//  Created by Ray Ho on 9/27/14.
//  Copyright (c) 2014 Prime Rib Software. All rights reserved.
//

import Foundation

// Singleton instance of logged-in user
var __USER_ME: User? = nil

class User: NSObject {  // must inherit from NSObject for NSCoder behavior to work
    var id: NSString!
    var avatarUrl: NSString?
    var screenName: NSString!
    var realName: NSString?
    var bannerUrl: NSString?
    var tweetCount: Int
    var followingCount: Int
    var followersCount: Int

    init(userDict: NSDictionary) {
        id = userDict["id_str"] as NSString
        avatarUrl = userDict["profile_image_url"] as? NSString
        screenName = userDict["screen_name"] as NSString
        realName = userDict["name"] as? NSString
        bannerUrl = userDict["profile_banner_url"] as? NSString
        tweetCount = userDict["statuses_count"] as Int
        followingCount = userDict["friends_count"] as Int
        followersCount = userDict["followers_count"] as Int
    }

    required init(coder aDecoder: NSCoder) {
        id = aDecoder.decodeObjectForKey("id_str") as NSString
        avatarUrl = aDecoder.decodeObjectForKey("profile_image_url") as? NSString
        screenName = aDecoder.decodeObjectForKey("screen_name") as NSString
        realName = aDecoder.decodeObjectForKey("name") as? NSString
        bannerUrl = aDecoder.decodeObjectForKey("profile_banner_url") as? NSString
        tweetCount = aDecoder.decodeIntegerForKey("statuses_count")
        followingCount = aDecoder.decodeIntegerForKey("friends_count")
        followersCount = aDecoder.decodeIntegerForKey("followers_count")
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(id, forKey: "id_str")
        if (avatarUrl != nil) {
            aCoder.encodeObject(avatarUrl!, forKey: "profile_image_url")
        }
        aCoder.encodeObject(screenName, forKey: "screen_name")
        if (realName != nil) {
            aCoder.encodeObject(realName!, forKey: "name")
        }
        if (bannerUrl != nil) {
            aCoder.encodeObject(bannerUrl!, forKey: "profile_banner_url")
        }
        aCoder.encodeInteger(tweetCount, forKey: "statuses_count")
        aCoder.encodeInteger(followingCount, forKey: "friends_count")
        aCoder.encodeInteger(followersCount, forKey: "followers_count")
    }

    // Returns current logged-in user
    class func getMe() -> User? {
        if (__USER_ME == nil) {
            var meData: NSData? = NSUserDefaults.standardUserDefaults().dataForKey("me")
            if (meData != nil) {
                __USER_ME = NSKeyedUnarchiver.unarchiveObjectWithData(meData!) as? User
            }
        }
        return __USER_ME
    }

    // Sets the current logged-in user
    class func setMe(meResponse: NSDictionary?) {
        if (meResponse != nil) {
            var me: User = User(userDict: meResponse!)
            __USER_ME = me
            var meData: NSData = NSKeyedArchiver.archivedDataWithRootObject(me)
            NSUserDefaults.standardUserDefaults().setObject(meData, forKey: "me")
        } else {
            __USER_ME = nil
            NSUserDefaults.standardUserDefaults().removeObjectForKey("me")
        }
    }
}