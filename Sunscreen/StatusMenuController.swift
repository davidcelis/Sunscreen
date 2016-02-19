//
//  StatusMenuController.swift
//  Sunscreen
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
    var timer: NSTimer?

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
            showLocationServicesErrorForStatus(CLAuthorizationStatus.Denied)
        case .Restricted:
            showLocationServicesErrorForStatus(CLAuthorizationStatus.Restricted)
        default:
            NSLog("Location Services can be authorized or accessed.")
        }

        showPreferences()

        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
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

        if timer == nil {
            timer = NSTimer(fireDate: NSDate(), interval: 60, target: self, selector: Selector("updateWallpaper"), userInfo: nil, repeats: true)
            NSRunLoop.mainRunLoop().addTimer(timer!, forMode: NSRunLoopCommonModes)
        }
    }

    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        locationManager.stopUpdatingLocation()

        let alert = NSAlert()

        alert.messageText = "Location Unavailable"
        alert.informativeText = "Sunscreen requires your current location to calculate sunrise and sunset times, but we weren't able to get your location. Sorry about that!"
        alert.addButtonWithTitle("OK")

        alert.runModal()
    }

    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .Restricted, .Denied:
            showLocationServicesErrorForStatus(status)
        default:
            return
        }
    }

    func updateWallpaper() {
        let times = SunCalculator.calculateTimes(NSDate(), latitude: currentLocation!.coordinate.latitude, longitude: currentLocation!.coordinate.longitude)

        NSLog("It's \(times.currentPeriod)! Setting wallpaper.")

        setWallpaper(times.currentPeriod)
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

    private func showLocationServicesErrorForStatus(authorizationStatus: CLAuthorizationStatus) {
        let alert = NSAlert()

        switch authorizationStatus {
        case .Denied:
            alert.messageText = "Location Services Access Denied"
            alert.informativeText = "Sunscreen requires your current location to calculate sunrise and sunset times, but you denied access. Please open System Preferences to enable Location Services, and then re-open Sunscreen."
        case .Restricted:
            alert.messageText = "Location Services Access Restricted"
            alert.messageText = "Sunscreen requires Location Services access, but your account is restricted. Please contact a system administrator. Sunscreen will now exit."
        default:
            return
        }

        alert.addButtonWithTitle("OK")
        if alert.runModal() == NSAlertFirstButtonReturn {
            NSApp.terminate(nil)
        }
    }
}
