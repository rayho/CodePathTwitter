//
//  TimelineController.swift
//  CodePathTwitter
//
//  Created by Ray Ho on 9/24/14.
//  Copyright (c) 2014 Prime Rib Software. All rights reserved.
//

import UIKit

class TimelineController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var timelineView: UITableView!
    var timelineRefreshControl: UIRefreshControl!
    var timelineData: Array<Tweet>! = []

    // Convenience method to launch this view controller
    class func launch(fromViewController: UIViewController) {
        var toViewController: TimelineController = TimelineController()
        var navController: UINavigationController = UINavigationController(rootViewController: toViewController)
        fromViewController.presentViewController(navController, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Construct navigation
        self.navigationItem.title = "Twitter"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Sign Out", style: UIBarButtonItemStyle.Plain, target: self, action: "signOut:")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Compose, target: self, action: "openComposer:")

        // Construct views
        timelineView = UITableView()
        timelineView.setTranslatesAutoresizingMaskIntoConstraints(false)
        timelineView.rowHeight = UITableViewAutomaticDimension
        timelineView.estimatedRowHeight = 100
        timelineView.registerClass(TimelineCell.self, forCellReuseIdentifier: TimelineCellReuseIdentifier)
        timelineView.allowsSelection = true
        timelineView.allowsMultipleSelection = false
        timelineView.dataSource = self
        timelineView.delegate = self
        timelineRefreshControl = UIRefreshControl()
        timelineRefreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        timelineRefreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        timelineView.addSubview(timelineRefreshControl)
        let viewDictionary: Dictionary = ["timelineView": timelineView]
        view.addSubview(timelineView)
        view.layoutIfNeeded()
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[timelineView]-0-|", options: NSLayoutFormatOptions.allZeros, metrics: nil, views: viewDictionary))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[timelineView]-0-|", options: NSLayoutFormatOptions.allZeros, metrics: nil, views: viewDictionary))

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onAuthSuccess:", name: TWTR_NOTIF_AUTH_SUCCESS, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onHomeTimelineSuccess:", name: TWTR_NOTIF_HOME_TIMELINE_SUCCESS, object: nil)
        if (TWTR.isAuthorized()) {
            TWTR.getHomeTimeline(nil)
        } else {
            TWTR.requestAuth()
        }
    }

    override func viewWillAppear(animated: Bool) {
        // Deselect any selected row
        var indexPath: NSIndexPath? = timelineView.indexPathForSelectedRow()
        if (indexPath != nil) {
            timelineView.deselectRowAtIndexPath(indexPath!, animated: false)
        }
    }

    func onAuthSuccess(notification: NSNotification) {
        if (timelineData.count == 0) {
            TWTR.getHomeTimeline(nil)
        }
    }

    func onHomeTimelineSuccess(notification: NSNotification) {
        self.timelineRefreshControl.endRefreshing()
        var moreTweets: Array<Tweet> = notification.object as Array<Tweet>
        if (timelineData.count == 0) {
            for t in moreTweets {
                NSLog("Appending tweet: %@", t.id)
                timelineData.append(t)
            }
        } else {
            for (var i = (moreTweets.count - 1); i >= 0; i--) {
                var t: Tweet = moreTweets[i]
                NSLog("Prepending newer tweet: %@", t.id)
                timelineData.insert(t, atIndex: 0)
            }
        }
        timelineView.reloadData()
    }

    func refresh(sender: UIRefreshControl) {
        NSLog("Refreshing ...")
        if (timelineData.count == 0) {
            // No items in timeline. Fetch clean.
            TWTR.getHomeTimeline(nil)
        } else {
            // Items currently in timeline. Fetch newer.
            TWTR.getHomeTimeline(timelineData[0].id)
        }
    }

    func openComposer(sender: AnyObject) {
        NSLog("Opening composer ...")
        ComposeController.launch(self)
    }

    func signOut(sender: AnyObject) {
        NSLog("Signing out ...")
        TWTR.deauthorize()
        dismissViewControllerAnimated(true, completion: nil)
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: TimelineCell = tableView.dequeueReusableCellWithIdentifier(TimelineCellReuseIdentifier) as TimelineCell
        cell.populate(timelineData[indexPath.row])
        return cell
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timelineData.count
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let row: Int = indexPath.row
        NSLog("Opening tweet detail at index #%d", row)
        let selectedTweet: Tweet = timelineData[row]
        DetailController.launch(self.navigationController!, tweet: selectedTweet)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

