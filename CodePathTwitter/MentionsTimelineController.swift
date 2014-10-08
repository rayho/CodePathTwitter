//
//  MentionsTimelineController.swift
//  CodePathTwitter
//
//  Created by Ray Ho on 10/7/14.
//  Copyright (c) 2014 Prime Rib Software. All rights reserved.
//

import UIKit

class MentionsTimelineController: TimelineController {
    override func viewDidLoad() {
        super.viewDidLoad()

        // Construct navigation
        self.navigationItem.title = "Mentions"
    }

    // Fetches data for a clean, empty timeline. Subclasses can override this
    override func fetchClean() {
        // No items in timeline. Fetch clean.
        TWTR.getMentionsTimeline(nil)
    }

    // Fetches data that is newer than the latest item in the timeline
    override func fetchNewer(newest: Tweet) {
        TWTR.getMentionsTimeline(newest.id)
    }

    // Returns the notification name that will carry the array of tweets to populate in this timeline
    override func getSuccessNotificationName() -> String? {
        return TWTR_NOTIF_MENTIONS_TIMELINE_SUCCESS
    }
}
