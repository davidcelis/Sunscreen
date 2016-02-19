//
//  AppDelegate.swift
//  SunscreenLauncher
//
//  Created by David Celis on 2/18/16.
//  Copyright © 2016 David Celis. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        let identifier = "com.davidcelis.Sunscreen",
            running = NSWorkspace.sharedWorkspace().runningApplications
        var alreadyRunning = false

        for app in running {
            if app.bundleIdentifier == identifier {
                alreadyRunning = true
                break
            }
        }

        if !alreadyRunning {
            NSDistributedNotificationCenter.defaultCenter().addObserver(self, selector: "terminate", name: "killme", object: identifier)

            let path = NSBundle.mainBundle().bundlePath as NSString
            var components = path.pathComponents

            components.removeLast()
            components.removeLast()
            components.removeLast()
            components.append("MacOS")
            components.append("Sunscreen")

            let newPath = NSString.pathWithComponents(components)

            NSWorkspace.sharedWorkspace().launchApplication(newPath)
        } else {
            NSApp.terminate(nil)
        }
    }

    func applicationWillTerminate(aNotification: NSNotification) {

    }
}

