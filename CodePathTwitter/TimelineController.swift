//
//  TimelineController.swift
//  CodePathTwitter
//
//  Created by Ray Ho on 9/24/14.
//  Copyright (c) 2014 Prime Rib Software. All rights reserved.
//

import UIKit

// Override this class, implementing methods labeled "OVERRIDE THIS"
class TimelineController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var timelineView: UITableView!
    var timelineRefreshControl: UIRefreshControl!
    var timelineData: Array<Tweet>! = []
    var timelineConstraintLeft: NSLayoutConstraint!
    var timelineConstraintRight: NSLayoutConstraint!
    var menuConstraintLeft: NSLayoutConstraint!
    var menuConstraintRight: NSLayoutConstraint!

    // OVERRIDE THIS: Fetches data for a clean, empty timeline. Subclasses can override this
    func fetchClean() {
    }

    // OVERRIDE THIS: Fetches data that is newer than the latest item in the timeline
    func fetchNewer(newest: Tweet) {
    }

    // OVERRIDE THIS: Returns the notification name that will carry the array of tweets to populate in this timeline
    func getSuccessNotificationName() -> String? {
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

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
        timelineRefreshControl.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        timelineView.addSubview(timelineRefreshControl)
        let viewDictionary: Dictionary = ["topLayoutGuide": topLayoutGuide, "timelineView": timelineView]
        view.addSubview(timelineView)
        view.layoutIfNeeded()

        // Initialize timeline horizontal constraints
        timelineConstraintLeft = NSLayoutConstraint(
            item: timelineView, attribute: NSLayoutAttribute.Left,
            relatedBy: NSLayoutRelation.Equal,
            toItem: view, attribute: NSLayoutAttribute.Left,
            multiplier: 1, constant: 0)
        timelineConstraintRight = NSLayoutConstraint(
            item: timelineView, attribute: NSLayoutAttribute.Right,
            relatedBy: NSLayoutRelation.Equal,
            toItem: view, attribute: NSLayoutAttribute.Right,
            multiplier: 1, constant: 0)
        view.addConstraint(timelineConstraintLeft)
        view.addConstraint(timelineConstraintRight)
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[timelineView]-0-|", options: NSLayoutFormatOptions.allZeros, metrics: nil, views: viewDictionary))

        // Events
        var successNotificationName: String? = getSuccessNotificationName()
        if (successNotificationName != nil) {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "onTimelineSuccess:", name: successNotificationName!, object: nil)
        }

        // Load timeline
        refresh()
    }

    override func viewWillAppear(animated: Bool) {
        // Deselect any selected row
        var indexPath: NSIndexPath? = timelineView.indexPathForSelectedRow()
        if (indexPath != nil) {
            timelineView.deselectRowAtIndexPath(indexPath!, animated: false)
        }

        // Listen for avatar taps
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onAvatarTap:", name: TWTR_NOTIF_TIMELINE_CELL_AVATAR_TAP, object: nil)
    }

    override func viewWillDisappear(animated: Bool) {
        // Stop listening for avatar taps when view controller disappears
        NSNotificationCenter.defaultCenter().removeObserver(self, name: TWTR_NOTIF_TIMELINE_CELL_AVATAR_TAP, object: nil)
    }

    func onTimelineSuccess(notification: NSNotification) {
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

    func onAvatarTap(notification: NSNotification) {
        NSLog("Avatar tapped. Launching profile ...")
        var user: User = notification.object as User
        ProfileController.launch(navigationController!, user: user)
    }

    func refresh() {
        NSLog("Refreshing ...")
        if (timelineData.count == 0) {
            fetchClean()
        } else {
            fetchNewer(timelineData[0])
        }
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

