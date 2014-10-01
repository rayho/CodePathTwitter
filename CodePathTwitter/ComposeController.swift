//
//  ComposeController.swift
//  CodePathTwitter
//
//  Created by Ray Ho on 9/28/14.
//  Copyright (c) 2014 Prime Rib Software. All rights reserved.
//

import UIKit

class ComposeController: UIViewController, UITextViewDelegate {
    let MAX_CHARS: Int = 140
    var charsRemainingLabel: UILabel!
    var textView: UITextView!
    var inReplyToTweet: Tweet?

    // Convenience method to launch this view controller, for composing a new tweet
    class func launch(fromViewController: UIViewController) {
        launch(fromViewController, inReplyToTweet: nil)
    }

    // Convenience method to launch this view controller, for replying to a tweet
    class func launch(fromViewController: UIViewController, inReplyToTweet: Tweet?) {
        var toViewController: ComposeController = ComposeController()
        toViewController.inReplyToTweet = inReplyToTweet
        var navController: UINavigationController = UINavigationController(rootViewController: toViewController)
        fromViewController.presentViewController(navController, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Construct navigation
        self.navigationItem.title = inReplyToTweet != nil ? "Reply" : "Compose"
        var cancelButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "cancel:")
        var submitButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "submit:")
        self.navigationItem.leftBarButtonItem = cancelButton
        self.navigationItem.rightBarButtonItem = submitButton

        // Construct views
        self.view.backgroundColor = UIColor.whiteColor()
        charsRemainingLabel = UILabel()
        charsRemainingLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        charsRemainingLabel.numberOfLines = 0
        charsRemainingLabel.textAlignment = NSTextAlignment.Right
        textView = UITextView()
        textView.setTranslatesAutoresizingMaskIntoConstraints(false)
        textView.font = UIFont.systemFontOfSize(17)
        textView.delegate = self
        if (inReplyToTweet != nil) {
            var replyToText: String = "@\(inReplyToTweet!.user.screenName) "
            for screenName in inReplyToTweet!.mentions {
                replyToText += "@\(screenName) "
            }
            textView.text = replyToText
        }
        self.view.addSubview(charsRemainingLabel)
        self.view.addSubview(textView)
        self.view.layoutIfNeeded()
        let viewDictionary: Dictionary = ["charsRemainingLabel": charsRemainingLabel, "textView": textView]
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[textView]-[charsRemainingLabel(60)]-|", options: NSLayoutFormatOptions.allZeros, metrics: nil, views: viewDictionary))
        self.view.addConstraint(NSLayoutConstraint(item: textView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.topLayoutGuide, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: textView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self.bottomLayoutGuide, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: charsRemainingLabel, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: textView, attribute: NSLayoutAttribute.TopMargin, multiplier: 1, constant: 0))
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }

    func cancel(sender: AnyObject) {
        NSLog("Cancelling composer ...")
        dismissViewControllerAnimated(true, completion: nil)
    }

    func submit(sender: AnyObject) {
        NSLog("Submitting tweet ...")
        var textTrimmed = textView.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        if (textTrimmed.utf16Count > 0) {
            TWTR.postTweet(textTrimmed, inReplyToStatusId: (inReplyToTweet != nil) ? inReplyToTweet!.id : nil)
            dismissViewControllerAnimated(true, completion: nil)
        } else {
            NSLog("No text in tweet. Ignoring submit button press.")
        }
    }

    func textViewDidChange(textView: UITextView) {
        updateUI()
    }

    func updateUI() {
        let numCharsRemaining: Int = MAX_CHARS - self.textView.text.utf16Count
        charsRemainingLabel.text = "\(numCharsRemaining)"
    }
}
