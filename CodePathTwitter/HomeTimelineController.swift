//
//  HomeTimelineController.swift
//  CodePathTwitter
//
//  Created by Ray Ho on 10/7/14.
//  Copyright (c) 2014 Prime Rib Software. All rights reserved.
//

import UIKit

class HomeTimelineController: TimelineController {
    override func viewDidLoad() {
        super.viewDidLoad()

        // Construct navigation
        self.navigationItem.title = "Twitter"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "Menu"), style: UIBarButtonItemStyle.Plain, target: self, action: "openMenu:")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Compose, target: self, action: "openComposer:")
    }

    // Fetches data for a clean, empty timeline. Subclasses can override this
    override func fetchClean() {
        // No items in timeline. Fetch clean.
        TWTR.getHomeTimeline(nil)
    }

    // Fetches data that is newer than the latest item in the timeline
    override func fetchNewer(newest: Tweet) {
        TWTR.getHomeTimeline(newest.id)
    }

    // Returns the notification name that will carry the array of tweets to populate in this timeline
    override func getSuccessNotificationName() -> String? {
        return TWTR_NOTIF_HOME_TIMELINE_SUCCESS
    }

    func openMenu(sender: AnyObject) {
        NSLog("Opening menu from nav bar button ...")
        NSNotificationCenter.defaultCenter().postNotificationName(TWTR_NOTIF_OPEN_MENU, object: nil)
    }

    func openComposer(sender: AnyObject) {
        NSLog("Opening composer ...")
        ComposeController.launch(self)
    }
}
