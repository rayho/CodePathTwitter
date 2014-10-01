//
//  DetailController.swift
//  CodePathTwitter
//
//  Created by Ray Ho on 9/29/14.
//  Copyright (c) 2014 Prime Rib Software. All rights reserved.
//

import UIKit

class DetailController: UIViewController, TweetActionButtonsDelegate {
    var tweet: Tweet!
    var avatarView: UIImageView!
    var tweetTextView: UILabel!
    var realNameView: UILabel!
    var screenNameView: UILabel!
    var timeView: UILabel!
    var numRetweetView: UILabel!
    var numRetweetLabel: UILabel!
    var numFavoriteView: UILabel!
    var numFavoriteLabel: UILabel!
    var tweetActions: TweetActionButtons!

    // Convenience method to launch this view controller
    class func launch(fromNavController: UINavigationController, tweet: Tweet) {
        var toViewController: DetailController = DetailController()
        toViewController.tweet = tweet
        var toNavController: UINavigationController = UINavigationController(rootViewController: toViewController)
        fromNavController.pushViewController(toViewController, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Tweet"

        // Initialize views
        self.view.backgroundColor = UIColor.whiteColor()
        avatarView = UIImageView()
        avatarView.setTranslatesAutoresizingMaskIntoConstraints(false)
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
        numRetweetView = UILabel()
        numRetweetView.setTranslatesAutoresizingMaskIntoConstraints(false)
        numRetweetView.numberOfLines = 1
        numRetweetLabel = UILabel()
        numRetweetLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        numRetweetLabel.numberOfLines = 1
        numFavoriteView = UILabel()
        numFavoriteView.setTranslatesAutoresizingMaskIntoConstraints(false)
        numFavoriteView.numberOfLines = 1
        numFavoriteLabel = UILabel()
        numFavoriteLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        numFavoriteLabel.numberOfLines = 1
        tweetActions = NSBundle.mainBundle().loadNibNamed("TweetActionButtons", owner: self, options: nil)[0] as TweetActionButtons
        tweetActions.setTranslatesAutoresizingMaskIntoConstraints(false)
        tweetActions.delegate = self

        let viewDictionary: Dictionary = ["tweetTextView": tweetTextView, "avatarView": avatarView, "realNameView": realNameView, "screenNameView": screenNameView, "timeView": timeView, "numRetweetView": numRetweetView, "numRetweetLabel": numRetweetLabel, "numFavoriteView": numFavoriteView, "numFavoriteLabel": numFavoriteLabel, "tweetActions": tweetActions]
        self.view.addSubview(avatarView)
        self.view.addSubview(realNameView)
        self.view.addSubview(screenNameView)
        self.view.addSubview(timeView)
        self.view.addSubview(tweetTextView)
        self.view.addSubview(numRetweetView)
        self.view.addSubview(numRetweetLabel)
        self.view.addSubview(numFavoriteView)
        self.view.addSubview(numFavoriteLabel)
        self.view.addSubview(tweetActions)
        self.view.layoutIfNeeded()
        self.view.addConstraint(NSLayoutConstraint(item: avatarView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.topLayoutGuide, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 8))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-8-[avatarView(48)]-[realNameView]-(>=8)-|", options: NSLayoutFormatOptions.AlignAllTop, metrics: nil, views: viewDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[tweetTextView]-8-|", options: NSLayoutFormatOptions.allZeros, metrics: nil, views: viewDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[numRetweetView]-4-[numRetweetLabel]-[numFavoriteView]-4-[numFavoriteLabel]-(>=8)-|", options: NSLayoutFormatOptions.AlignAllBaseline, metrics: nil, views: viewDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[avatarView(48)]-[tweetTextView]-[timeView]-[numRetweetView]-[tweetActions]", options: NSLayoutFormatOptions.AlignAllLeft, metrics: nil, views: viewDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[realNameView]-0-[screenNameView]-(>=8)-|", options: NSLayoutFormatOptions.AlignAllLeft, metrics: nil, views: viewDictionary))
    }

    func clicked(sender: AnyObject) {
        NSLog("clicked")
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        updateUI()
    }

    func updateUI() {
        avatarView.image = nil
        let avatarUrl: NSString? = tweet.user.avatarUrl
        if (avatarUrl != nil) {
            avatarView.setImageWithURL(NSURL.URLWithString(avatarUrl!))
        }

        // Names, tweet text
        let realName: NSString? = tweet.user.realName
        realNameView.text = realName != nil ? realName! : ""
        screenNameView.text = "@\(tweet.user.screenName)"
        tweetTextView.text = tweet.text

        // Time
        var dateFormatter: NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "M/d/yy, h:mm a"
        timeView.text = dateFormatter.stringFromDate(tweet.timestamp)

        // Retweets and favorites
        numRetweetView.text = "\(tweet.numRetweets)"
        numRetweetLabel.text = (tweet.numRetweets == 0 || tweet.numRetweets > 1) ? "RETWEETS" : "RETWEET"
        numFavoriteView.text = "\(tweet.numFavorites)"
        numFavoriteLabel.text = (tweet.numFavorites == 0 || tweet.numFavorites > 1) ? "FAVORITES" : "FAVORITE"

        // Action buttons
        tweetActions.updateUI(tweet)
    }

    func tweetActionReply(sender: TweetActionButtons) {
        NSLog("Launching reply controller ...")
        ComposeController.launch(self, inReplyToTweet: tweet)
    }

    func tweetActionRetweet(sender: TweetActionButtons) {
        if (tweet.didRetweet) {
            NSLog("Already retweeted. Ignoring request.")
        } else {
            NSLog("Retweeting ...")
            tweet.didRetweet = true
            TWTR.postRetweet(tweet.id)
        }
        tweetActions.updateUI(tweet)
    }

    func tweetActionFavorite(sender: TweetActionButtons) {
        if (tweet.didFavorite) {
            NSLog("Favoriting ...")
            tweet.didFavorite = false
            TWTR.removeFavorite(tweet.id)
        } else {
            NSLog("Un-favoriting ...")
            tweet.didFavorite = true
            TWTR.postFavorite(tweet.id)
        }
        tweetActions.updateUI(tweet)
    }
}
