//
//  PreferencesWindow.swift
//  SunPaper
//
//  Created by David Celis on 2/14/16.
//  Copyright © 2016 David Celis. All rights reserved.
//

import Cocoa

class PreferencesWindow: NSWindowController, NSWindowDelegate {
    
    @IBOutlet weak var sunriseWallpaper: NSImageView!
    @IBOutlet weak var morningWallpaper: NSImageView!
    @IBOutlet weak var afternoonWallpaper: NSImageView!
    @IBOutlet weak var sunsetWallpaper: NSImageView!
    @IBOutlet weak var nightWallpaper: NSImageView!

    override var windowNibName: String! {
        return "PreferencesWindow"
    }

    override func windowDidLoad() {
        super.windowDidLoad()

        self.window?.center()
        self.window?.makeKeyAndOrderFront(nil)
        NSApp.activateIgnoringOtherApps(true)
    }
    
    func windowWillClose(notification: NSNotification) {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        defaults.setValue(sunriseWallpaper.image, forKey: "sunriseWallpaper")
        defaults.setValue(morningWallpaper.image, forKey: "morningWallpaper")
        defaults.setValue(afternoonWallpaper.image, forKey: "afternoonWallpaper")
        defaults.setValue(sunsetWallpaper.image, forKey: "sunsetWallpaper")
        defaults.setValue(nightWallpaper.image, forKey: "nightWallpaper")
    }
}
