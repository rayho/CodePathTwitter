//
//  User.swift
//  CodePathTwitter
//
//  Created by Ray Ho on 9/27/14.
//  Copyright (c) 2014 Prime Rib Software. All rights reserved.
//

import Foundation

class User {
    var avatarUrl: NSString?
    var screenName: NSString!
    var realName: NSString?

    init(userDict: NSDictionary) {
        avatarUrl = userDict["profile_image_url"] as? NSString
        screenName = userDict["screen_name"] as NSString
        realName = userDict["name"] as? NSString
    }
}