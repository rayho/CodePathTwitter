//
//  MainController.swift
//  CodePathTwitter
//
//  Created by Ray Ho on 10/5/14.
//  Copyright (c) 2014 Prime Rib Software. All rights reserved.
//

import UIKit

let TWTR_NOTIF_OPEN_MENU: String = "com.djprefix.twitter.OpenMenu"
let TWTR_NOTIF_SCREEN_CHANGE: String = "com.djprefix.twitter.ScreenChange"
class MainController: UIViewController {

    let menuWidth: CGFloat = 300
    var menuController: MenuController!
    var navController: UINavigationController!
    var homeTimelineController: HomeTimelineController!
    var profileController: ProfileController? = nil // lazily initialized
    var mentionsTimelineController: MentionsTimelineController? = nil   // lazily initialized
    var menuLeft: NSLayoutConstraint!
    var menuRight: NSLayoutConstraint!
    var navLeft: NSLayoutConstraint!
    var navRight: NSLayoutConstraint!
    var panRecognizer: UIPanGestureRecognizer!
    var lastCenterPanePosition: CGFloat = 0

    // Convenience method to launch this view controller
    class func launch(fromViewController: UIViewController) {
        var toViewController: MainController = MainController()
        fromViewController.presentViewController(toViewController, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Add menu
        menuController = MenuController()
        addChildViewController(menuController)
        view.addSubview(menuController.view)
        menuController.view.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addConstraint(NSLayoutConstraint(
            item: menuController.view,
            attribute: NSLayoutAttribute.Top,
            relatedBy: NSLayoutRelation.Equal,
            toItem: view,
            attribute: NSLayoutAttribute.Top,
            multiplier: 1,
            constant: 0))
        view.addConstraint(NSLayoutConstraint(
            item: menuController.view,
            attribute: NSLayoutAttribute.Bottom,
            relatedBy: NSLayoutRelation.Equal,
            toItem: view,
            attribute: NSLayoutAttribute.Bottom,
            multiplier: 1,
            constant: 0))
        menuLeft = NSLayoutConstraint(
            item: menuController.view,
            attribute: NSLayoutAttribute.Left,
            relatedBy: NSLayoutRelation.Equal,
            toItem: view,
            attribute: NSLayoutAttribute.Left,
            multiplier: 1,
            constant: 0)
        menuRight = NSLayoutConstraint(
            item: menuController.view,
            attribute: NSLayoutAttribute.Right,
            relatedBy: NSLayoutRelation.Equal,
            toItem: view,
            attribute: NSLayoutAttribute.Right,
            multiplier: 1,
            constant: 0)
        view.addConstraint(menuLeft)
        view.addConstraint(menuRight)

        // Add timeline
        homeTimelineController = HomeTimelineController()
        navController = UINavigationController(rootViewController: homeTimelineController)
        addChildViewController(navController)
        view.addSubview(navController.view)
        navController.view.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addConstraint(NSLayoutConstraint(
            item: navController.view,
            attribute: NSLayoutAttribute.Top,
            relatedBy: NSLayoutRelation.Equal,
            toItem: view,
            attribute: NSLayoutAttribute.Top,
            multiplier: 1,
            constant: 0))
        view.addConstraint(NSLayoutConstraint(
            item: navController.view,
            attribute: NSLayoutAttribute.Bottom,
            relatedBy: NSLayoutRelation.Equal,
            toItem: view,
            attribute: NSLayoutAttribute.Bottom,
            multiplier: 1,
            constant: 0))
        navLeft = NSLayoutConstraint(
            item: navController.view,
            attribute: NSLayoutAttribute.Left,
            relatedBy: NSLayoutRelation.Equal,
            toItem: view,
            attribute: NSLayoutAttribute.Left,
            multiplier: 1,
            constant: 0)
        navRight = NSLayoutConstraint(
            item: navController.view,
            attribute: NSLayoutAttribute.Right,
            relatedBy: NSLayoutRelation.Equal,
            toItem: view,
            attribute: NSLayoutAttribute.Right,
            multiplier: 1,
            constant: 0)
        view.addConstraint(navLeft)
        view.addConstraint(navRight)

        // Confirm view controller additions
        menuController.didMoveToParentViewController(self)
        navController.didMoveToParentViewController(self)

        // Initialize gestures
        panRecognizer = UIPanGestureRecognizer(target: self, action: "onPan:")
        view.addGestureRecognizer(panRecognizer)

        // Initialize events
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onMenuItemTap:", name: TWTR_NOTIF_SELECTED_MENU_ITEM, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "openMenu", name: TWTR_NOTIF_OPEN_MENU, object: nil)
    }

    func onPan(sender: UIPanGestureRecognizer) {
        switch (sender.state) {
        case .Began:
            NSLog("Panning began")
            lastCenterPanePosition = navLeft.constant
        case .Changed:
            let point: CGPoint = sender.translationInView(view)
            NSLog("Panning changed: \(point)")
            var position: CGFloat = lastCenterPanePosition + point.x
            navLeft.constant = max(0, position)
            navRight.constant = max(0, position)
        case .Ended, .Cancelled:
            NSLog("Panning ended")
            var screenBounds: CGRect = UIScreen.mainScreen().bounds
            var displacementThreshold: CGFloat = (screenBounds.size.width / 2)
            if (navLeft.constant > displacementThreshold) {
                openMenu()
            } else {
                closeMenu()
            }
        default:
            NSLog("Unhandled pan state: \(sender.state)")
        }
    }

    func onMenuItemTap(sender: NSNotification) {
        var menuItem: MenuItem = MenuItem.fromRaw(sender.object as Int)!

        switch (menuItem) {
        case .Home:
            if (navController.topViewController == homeTimelineController) {
                NSLog("Already in home timeline. Ignoring home menu item tap.")
            } else {
                NSLog("Returning home ...")
                navController.popToRootViewControllerAnimated(true)
            }
            closeMenu()
        case .Profile:
            if (navController.topViewController == profileController) {
                NSLog("Already in profile screen. Ignoring profile menu item tap.")
            } else {
                NSLog("Launching profile ...")
                if (profileController == nil) {
                    profileController = ProfileController()
                    profileController!.user = User.getMe()
                }
                if (isInStack(profileController!)) {
                    navController.popToViewController(profileController!, animated: true)
                } else {
                    navController.pushViewController(profileController!, animated: true)
                }
            }
            closeMenu()
        case .Mentions:
            if (navController.topViewController == mentionsTimelineController) {
                NSLog("Already in mentions screen. Ignoring mentions menu item tap.")
            } else {
                NSLog("Launching mentions ...")
                if (mentionsTimelineController == nil) {
                    mentionsTimelineController = MentionsTimelineController()
                }
                if (isInStack(mentionsTimelineController!)) {
                    navController.popToViewController(mentionsTimelineController!, animated: true)
                } else {
                    navController.pushViewController(mentionsTimelineController!, animated: true)
                }
            }
            closeMenu()
        case .Logout:
            NSLog("Signing out ...")
            signOut()
        }
    }

    func closeMenu() {
        UIView.animateWithDuration(0.25, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.navLeft.constant = 0
            self.navRight.constant = 0
            self.navController.view.layoutIfNeeded()
        }, completion: nil)
    }

    func openMenu() {
        var screenBounds: CGRect = UIScreen.mainScreen().bounds
        var screenWidth: CGFloat = screenBounds.size.width
        var navDisplacement: CGFloat = screenWidth - 64
        UIView.animateWithDuration(0.25, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.navLeft.constant = navDisplacement
            self.navRight.constant = navDisplacement
            self.navController.view.layoutIfNeeded()
        }, completion: nil)
    }

    func signOut() {
        NSLog("Signing out ...")
        TWTR.deauthorize()
        dismissViewControllerAnimated(true, completion: nil)
    }

    func isInStack(viewController: UIViewController) -> Bool {
        return (navController.viewControllers as NSArray).containsObject(viewController)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
