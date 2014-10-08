//
//  ProfileController.swift
//  CodePathTwitter
//
//  Created by Ray Ho on 10/2/14.
//  Copyright (c) 2014 Prime Rib Software. All rights reserved.
//

import UIKit

class ProfileController: UIViewController {
    var user: User!
    var headerView: UIImageView!
    var avatarView: UIImageView!
    var realNameLabel: UILabel!
    var screenNameLabel: UILabel!
    var tweetStatView: ProfileStatView!
    var followingStatView: ProfileStatView!
    var followerStatView: ProfileStatView!

    // Convenience method to launch this view controller
    class func launch(fromNavController: UINavigationController, user: User) {
        var toViewController: ProfileController = ProfileController()
        toViewController.user = user
        var toNavController: UINavigationController = UINavigationController(rootViewController: toViewController)
        fromNavController.pushViewController(toViewController, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = (user.realName != nil) ? user.realName : user.screenName

        // Initialize views
        view.backgroundColor = UIColor.whiteColor()
        headerView = UIImageView()
        headerView.setTranslatesAutoresizingMaskIntoConstraints(false)
        headerView.contentMode = UIViewContentMode.ScaleAspectFill
        avatarView = UIImageView()
        avatarView.setTranslatesAutoresizingMaskIntoConstraints(false)
        realNameLabel = UILabel()
        realNameLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        realNameLabel.numberOfLines = 1
        realNameLabel.font = UIFont.boldSystemFontOfSize(17)
        realNameLabel.textColor = UIColor.whiteColor()
        realNameLabel.shadowColor = UIColor.blackColor()
        realNameLabel.shadowOffset = CGSize(width: 0, height: 1)
        screenNameLabel = UILabel()
        screenNameLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        screenNameLabel.numberOfLines = 1
        screenNameLabel.font = UIFont.systemFontOfSize(14)
        screenNameLabel.textColor = UIColor.whiteColor()
        screenNameLabel.shadowColor = UIColor.blackColor()
        screenNameLabel.shadowOffset = CGSize(width: 0, height: 1)
        tweetStatView = NSBundle.mainBundle().loadNibNamed("ProfileStat", owner: self, options: nil)[0] as ProfileStatView
        tweetStatView.setTranslatesAutoresizingMaskIntoConstraints(false)
        tweetStatView.textLabel.text = "TWEETS"
        followingStatView = NSBundle.mainBundle().loadNibNamed("ProfileStat", owner: self, options: nil)[0] as ProfileStatView
        followingStatView.setTranslatesAutoresizingMaskIntoConstraints(false)
        followingStatView.textLabel.text = "FOLLOWING"
        followerStatView = NSBundle.mainBundle().loadNibNamed("ProfileStat", owner: self, options: nil)[0] as ProfileStatView
        followerStatView.setTranslatesAutoresizingMaskIntoConstraints(false)
        followerStatView.textLabel.text = "FOLLOWERS"
        var viewDict: Dictionary = ["headerView": headerView, "avatarView": avatarView, "realNameLabel": realNameLabel, "tweetStatView": tweetStatView, "followingStatView": followingStatView, "followerStatView": followerStatView]
        headerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[headerView(160)]", options: NSLayoutFormatOptions.allZeros, metrics: nil, views: viewDict))
        avatarView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[avatarView(64)]", options: NSLayoutFormatOptions.allZeros, metrics: nil, views: viewDict))
        avatarView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[avatarView(64)]", options: NSLayoutFormatOptions.allZeros, metrics: nil, views: viewDict))
        view.addSubview(headerView)
        view.addSubview(avatarView)
        view.addSubview(realNameLabel)
        view.addSubview(screenNameLabel)
        view.addSubview(tweetStatView)
        view.addSubview(followingStatView)
        view.addSubview(followerStatView)
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[headerView]-0-|", options: NSLayoutFormatOptions.allZeros, metrics: nil, views: viewDict))
        view.addConstraint(NSLayoutConstraint(item: headerView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: topLayoutGuide, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: avatarView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: headerView, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 32))
        view.addConstraint(NSLayoutConstraint(item: avatarView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: headerView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: realNameLabel, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: avatarView, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: realNameLabel, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: avatarView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: screenNameLabel, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: realNameLabel, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: screenNameLabel, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: realNameLabel, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[tweetStatView][followingStatView(==tweetStatView)][followerStatView(==followingStatView)]-|", options: NSLayoutFormatOptions.AlignAllTop, metrics: nil, views: viewDict))
        view.addConstraint(NSLayoutConstraint(item: tweetStatView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: headerView, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0))
        view.layoutIfNeeded()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if (user.bannerUrl != nil) {
            self.headerView.setImageWithURL(NSURL.URLWithString(user.bannerUrl!))
//            headerView.setImageWithURLRequest(NSURLRequest(URL: NSURL.URLWithString(user.bannerUrl!)),
//                placeholderImage: nil,
//                success: { (request: NSURLRequest!, response: NSHTTPURLResponse!, image: UIImage!) -> Void in
//                    self.headerView.image = image.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
//                    self.headerView.tintColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
//                },
//                failure: nil)
        } else {
            headerView.image = nil
        }
        if (user.avatarUrl != nil) {
            avatarView.setImageWithURL(NSURL.URLWithString(user.avatarUrl!))
        } else {
            avatarView.image = nil
        }
        var numberFormatter: NSNumberFormatter = NSNumberFormatter()
        numberFormatter.locale = NSLocale.autoupdatingCurrentLocale()
        numberFormatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
        var screenName: String = "@\(user.screenName)"
        realNameLabel.text = user.realName != nil ? user.realName! : screenName
        screenNameLabel.text = user.realName != nil ? screenName : ""
        tweetStatView.numberLabel.text = "\(numberFormatter.stringFromNumber(user.tweetCount))"
        followingStatView.numberLabel.text = "\(numberFormatter.stringFromNumber(user.followingCount))"
        followerStatView.numberLabel.text = "\(numberFormatter.stringFromNumber(user.followersCount))"
    }
}
