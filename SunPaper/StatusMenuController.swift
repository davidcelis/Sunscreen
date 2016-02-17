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
    var currentLocation: CLLocation?
    var currentTimes: SunData?

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

        startTimers()
        showPreferences()
    }

    @IBAction func preferencesClicked(sender: NSMenuItem) {
        showPreferences()
    }

    @IBAction func quitClicked(sender: NSMenuItem) {
        NSApplication.sharedApplication().terminate(self)
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [AnyObject]) {
        locationManager.stopUpdatingLocation()

        currentLocation = locations.last as? CLLocation
        currentTimes = SunCalculator.calculateTimes(NSDate(), latitude: currentLocation!.coordinate.latitude, longitude: currentLocation!.coordinate.longitude)
    }

    private func startTimers() {
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()

        let timer = NSTimer(fireDate: currentTimes!.solarNoon, interval: 0, target: self, selector: "updateWallpaper", userInfo: nil, repeats: false)
        NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
    }

    // One looping timer to update `currentTimes`. Once per hour?
    // One looping timer to see if the wallpaper needs to be changed

    private func updateWallpaper() {
        if let times = currentTimes {
            let imagePath = NSURL.fileURLWithPath("\(preferencesWindow.wallpapersPath)/\(times.currentPeriod).png")

            do {
                let workspace = NSWorkspace.sharedWorkspace()
                if let screen = NSScreen.mainScreen()  {
                    try workspace.setDesktopImageURL(imagePath, forScreen: screen, options: [:])
                }
            } catch {
                NSLog("\(error)")
            }
        }
    }

    private func showPreferences() {
        preferencesWindow.showWindow(nil)

        preferencesWindow.window?.center()
        preferencesWindow.window?.makeKeyAndOrderFront(nil)
        NSApp.activateIgnoringOtherApps(true)
    }
}
