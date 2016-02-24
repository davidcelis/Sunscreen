//
//  AppDelegate.swift
//  Sunscreen
//
//  Created by David Celis on 2/13/16.
//  Copyright © 2016 David Celis. All rights reserved.
//

import Cocoa
import ServiceManagement

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        let identifier = "com.davidcelis.SunscreenLauncher"
        var startedAtLogin = false

        for app in NSWorkspace.sharedWorkspace().runningApplications {
            if app.bundleIdentifier == identifier {
                startedAtLogin = true
            }
        }

        if startedAtLogin {
            NSDistributedNotificationCenter.defaultCenter().postNotificationName("killme", object: NSBundle.mainBundle().bundleIdentifier!)
        }

        let defaults = NSUserDefaults.standardUserDefaults()
        if defaults.valueForKey("launchAtLogin") == nil {
            defaults.setValue(false, forKey: "launchAtLogin")
        }

        if defaults.valueForKey("launchAtLogin") as! Bool {
            SMLoginItemSetEnabled(identifier, true)
        }
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
}

