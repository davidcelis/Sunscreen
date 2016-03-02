//
//  AppDelegate.swift
//  Sunscreen
//
//  Created by David Celis on 2/13/16.
//  Copyright © 2016 David Celis. All rights reserved.
//
//  The source code of this project is licensed under The MIT License. A copy of this license
//  can be found in the LICENSE file in the root of this repository.
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

        if defaults.boolForKey("launchAtLogin") {
            SMLoginItemSetEnabled(identifier, true)
        }
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
}

