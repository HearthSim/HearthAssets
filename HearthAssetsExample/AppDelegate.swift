//
//  AppDelegate.swift
//  HearthAssetsExample
//
//  Created by Benjamin Michotte on 7/02/17.
//  Copyright © 2017 Benjamin Michotte. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

    @IBOutlet weak var locale: NSPopUpButton!
    @IBOutlet weak var cardChooser: NSPopUpButton!

    var controller: Controller?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        controller = Controller(nibName: NSNib.Name(rawValue: "Window"), bundle: nil)
        if let mainController = controller {
            self.window.contentView?.addSubview(mainController.view)
            mainController.view.frame = window.contentView?.bounds ?? NSRect.zero
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    @IBAction func changeLocale(_ sender: Any) {
        print("changeLocale : \(sender)")
    }

    @IBAction func changeCard(_ sender: Any) {
        print("changeCard : \(sender)")
    }
}

