//
//  MenuController.swift
//  CodePathTwitter
//
//  Created by Ray Ho on 10/5/14.
//  Copyright (c) 2014 Prime Rib Software. All rights reserved.
//

import UIKit

let TWTR_NOTIF_SELECTED_MENU_ITEM: String = "com.djprefix.twitter.SelectedMenuItem"
class MenuController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var currentMenuItem: MenuItem = MenuItem.Home
    var menuItems: Array<MenuItem> = [MenuItem.Home, MenuItem.Profile, MenuItem.Mentions, MenuItem.Logout]
    var menuTable: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()
        menuTable = UITableView()
        menuTable.setTranslatesAutoresizingMaskIntoConstraints(false)
        menuTable.registerClass(MenuCell.self, forCellReuseIdentifier: MenuCellReuseIdentifier)
        menuTable.dataSource = self
        menuTable.delegate = self
        view.addSubview(menuTable)
        var viewDict: Dictionary = ["menuTable": menuTable, "topLayoutGuide": topLayoutGuide]
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-0-[menuTable]-0-|",
            options: NSLayoutFormatOptions.allZeros,
            metrics: nil,
            views: viewDict))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:[topLayoutGuide]-0-[menuTable]-0-|",
            options: NSLayoutFormatOptions.allZeros,
            metrics: nil,
            views: viewDict))
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var displayName: String!
        switch (menuItems[indexPath.row]) {
        case .Home:
            displayName = "Home"
        case .Profile:
            displayName = "Profile"
        case .Mentions:
            displayName = "Mentions"
        case .Logout:
            displayName = "Sign Out"
        }
        var cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(MenuCellReuseIdentifier) as UITableViewCell
        cell.textLabel?.text = displayName
        return cell
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        var selectedItem: MenuItem = menuItems[indexPath.row]
        NSLog("Selected menu item: \(selectedItem)")
        NSNotificationCenter.defaultCenter().postNotificationName(TWTR_NOTIF_SELECTED_MENU_ITEM, object: selectedItem.toRaw())
    }
}

enum MenuItem: Int {
    case Home = 0
    case Profile = 1
    case Mentions = 2
    case Logout = 3
}

let MenuCellReuseIdentifier: String = "menuCell"
class MenuCell: UITableViewCell {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}