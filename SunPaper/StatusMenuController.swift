//
//  StatusMenuController.swift
//  SunPaper
//
//  Created by David Celis on 2/13/16.
//  Copyright © 2016 David Celis. All rights reserved.
//

import Cocoa
import CoreLocation

class StatusMenuController: NSObject, CLLocationManagerDelegate {
    @IBOutlet weak var statusMenu: NSMenu!

    var preferencesWindow: PreferencesWindow!

    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
    let locationManager = CLLocationManager()

    override func awakeFromNib() {
        let icon = NSImage(named: "StatusIcon")
        icon?.template = true // Dark mode support

        statusItem.image = icon
        statusItem.menu = statusMenu

        preferencesWindow = PreferencesWindow()

        locationManager.delegate = self

        switch CLLocationManager.authorizationStatus() {
        case .Denied:
            NSLog("You denied Location Services access to SunPaper. Please allow access in System Preferences.")
        case .Restricted:
            NSLog("You aren't allowed to use Location Services.")
        default:
            NSLog("Location Services can be authorized or accessed.")
        }

        locationManager.startUpdatingLocation()
        showPreferences()
    }

    @IBAction func updateClicked(sender: NSMenuItem) {
        locationManager.startUpdatingLocation()
    }

    @IBAction func preferencesClicked(sender: NSMenuItem) {
        showPreferences()
    }

    @IBAction func quitClicked(sender: NSMenuItem) {
        NSApplication.sharedApplication().terminate(self)
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [AnyObject]) {
        locationManager.stopUpdatingLocation()

        let location = locations.last as! CLLocation
        let period = SunCalculator.getCurrentPeriod(location.coordinate.latitude, longitude: location.coordinate.longitude)

        setWallpaper(period)
    }

    private func setWallpaper(period: String) {
        let imagePath = NSURL.fileURLWithPath("\(preferencesWindow.wallpapersPath)/\(period).png")

        do {
            let workspace = NSWorkspace.sharedWorkspace()
            if let screen = NSScreen.mainScreen()  {
                try workspace.setDesktopImageURL(imagePath, forScreen: screen, options: [:])
            }
        } catch {
            NSLog("\(error)")
        }
    }

    private func showPreferences() {
        preferencesWindow.showWindow(nil)

        preferencesWindow.window?.center()
        preferencesWindow.window?.makeKeyAndOrderFront(nil)
        NSApp.activateIgnoringOtherApps(true)
    }
}
