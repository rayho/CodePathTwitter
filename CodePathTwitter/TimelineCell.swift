//
//  TimelineCell.swift
//  CodePathTwitter
//
//  Created by Ray Ho on 9/27/14.
//  Copyright (c) 2014 Prime Rib Software. All rights reserved.
//

import UIKit

let TWTR_NOTIF_TIMELINE_CELL_AVATAR_TAP: String = "com.djprefix.twitter.TimelineCellAvatarTap"
let TimelineCellReuseIdentifier: String = "timelineCell";
class TimelineCell: UITableViewCell {
    var tweet: Tweet!
    var avatarView: UIImageView!
    var tweetTextView: UILabel!
    var realNameView: UILabel!
    var screenNameView: UILabel!
    var timeView: UILabel!
    var tapRecognizer: UITapGestureRecognizer!

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        tapRecognizer = UITapGestureRecognizer(target: self, action: "onTap:")
        avatarView = UIImageView()
        avatarView.setTranslatesAutoresizingMaskIntoConstraints(false)
        avatarView.userInteractionEnabled = true
        avatarView.addGestureRecognizer(tapRecognizer)
        realNameView = UILabel()
        realNameView.setTranslatesAutoresizingMaskIntoConstraints(false)
        realNameView.numberOfLines = 1
        screenNameView = UILabel()
        screenNameView.setTranslatesAutoresizingMaskIntoConstraints(false)
        screenNameView.numberOfLines = 1
        timeView = UILabel()
        timeView.setTranslatesAutoresizingMaskIntoConstraints(false)
        timeView.numberOfLines = 1
        tweetTextView = UILabel()
        tweetTextView.setTranslatesAutoresizingMaskIntoConstraints(false)
        tweetTextView.numberOfLines = 0
        let viewDictionary: Dictionary = ["tweetTextView": tweetTextView, "avatarView": avatarView, "realNameView": realNameView, "screenNameView": screenNameView, "timeView": timeView]
        addSubview(avatarView)
        addSubview(realNameView)
        addSubview(screenNameView)
        addSubview(timeView)
        addSubview(tweetTextView)
        layoutIfNeeded()
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-8-[avatarView(48)]-[realNameView]-4-[screenNameView]-(>=8)-[timeView]-8-|", options: NSLayoutFormatOptions.AlignAllTop, metrics: nil, views: viewDictionary))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[avatarView]-[tweetTextView]-8-|", options: NSLayoutFormatOptions.allZeros, metrics: nil, views: viewDictionary))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-8-[avatarView(48)]-(>=8)-|", options: NSLayoutFormatOptions.allZeros, metrics: nil, views: viewDictionary))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-8-[realNameView]-0-[tweetTextView]-8-|", options: NSLayoutFormatOptions.AlignAllLeft, metrics: nil, views: viewDictionary))
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func onTap(gestureRecognizer: UITapGestureRecognizer) {
        if (gestureRecognizer.view == avatarView) {
            NSNotificationCenter.defaultCenter().postNotificationName(TWTR_NOTIF_TIMELINE_CELL_AVATAR_TAP, object: tweet.user)
        }
    }

    func populate(tweet: Tweet) {
        self.tweet = tweet
        avatarView.image = nil
        let avatarUrl: NSString? = tweet.user.avatarUrl
        if (avatarUrl != nil) {
            avatarView.setImageWithURL(NSURL.URLWithString(avatarUrl!))
        }
        let realName: NSString? = tweet.user.realName
        realNameView.text = realName != nil ? realName! : ""
        screenNameView.text = "@\(tweet.user.screenName)"
        timeView.text = tweet.timestampFormatted
        tweetTextView.text = tweet.text
    }
}
