//
//  TweetActionButtons.swift
//  CodePathTwitter
//
//  Created by Ray Ho on 9/30/14.
//  Copyright (c) 2014 Prime Rib Software. All rights reserved.
//

import UIKit

// Displays reply, retweet, and favorite buttons
class TweetActionButtons: UIView {
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    var delegate: TweetActionButtonsDelegate?

    @IBAction func onPress(sender: UIButton) {
        NSLog("touched")
        sender.highlighted = true
    }

    @IBAction func onClick(sender: UIButton) {
        NSLog("clicked")
        sender.highlighted = false
        if (sender == replyButton) {
            delegate?.tweetActionReply(self)
        } else if (sender == retweetButton) {
            delegate?.tweetActionRetweet(self)
        } else if (sender == favoriteButton) {
            delegate?.tweetActionFavorite(self)
        }
    }

    @IBAction func onCancel(sender: UIButton) {
        NSLog("cancelled")
        sender.highlighted = false
    }

    func updateUI(tweet: Tweet) {
        retweetButton.selected = tweet.didRetweet
        favoriteButton.selected = tweet.didFavorite
    }
}

protocol TweetActionButtonsDelegate {
    func tweetActionReply(sender: TweetActionButtons)
    func tweetActionRetweet(sender: TweetActionButtons)
    func tweetActionFavorite(sender: TweetActionButtons)
}
