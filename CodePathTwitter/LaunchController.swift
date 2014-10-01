//
//  LaunchController.swift
//  CodePathTwitter
//
//  Created by Ray Ho on 9/29/14.
//  Copyright (c) 2014 Prime Rib Software. All rights reserved.
//

import UIKit

class LaunchController: UIViewController {
    var signInButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Subscribe to events
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onAuthSuccess:", name: TWTR_NOTIF_AUTH_SUCCESS, object: nil)

        // Load views
        self.view.backgroundColor = UIColor.whiteColor()
        signInButton = UIButton.buttonWithType(UIButtonType.System) as UIButton
        signInButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        signInButton.setTitle("Sign In", forState: UIControlState.Normal)
        signInButton.addTarget(self, action: "signIn:", forControlEvents: UIControlEvents.TouchUpInside)
        signInButton.titleLabel!.numberOfLines = 0
        self.view.addSubview(signInButton)
        self.view.layoutIfNeeded()
        let viewDictionary = ["signInButton": signInButton]
        self.view.addConstraint(NSLayoutConstraint(item: signInButton, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: signInButton, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        // Determine whether we should:
        // Ask user to log in (not logged in yet)
        // -- OR --
        // Jump to home timeline (already logged in)
        if (TWTR.isAuthorized()) {
            NSLog("Already signed in.")
            signInButton.hidden = true
            launchTimeline()
        } else {
            NSLog("Not signed in.")
            signInButton.hidden = false
        }
    }

    func signIn(sender: AnyObject) {
        NSLog("Signing in ...")
        TWTR.requestAuth()
    }

    func onAuthSuccess(sender: AnyObject) {
        NSLog("Signed in.")
        launchTimeline()
    }

    func launchTimeline() {
        NSLog("Launching timeline ...")
        TimelineController.launch(self)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
