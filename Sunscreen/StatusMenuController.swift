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
    var mainTimer: NSTimer?

    var sunriseTimer: NSTimer?
    var morningTimer: NSTimer?
    var afternoonTimer: NSTimer?
    var sunsetTimer: NSTimer?
    var nightTimer: NSTimer?

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
            NSLog("You denied Location Services access to Sunscreen. Please allow access in System Preferences.")
        case .Restricted:
            NSLog("You aren't allowed to use Location Services.")
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

        if mainTimer == nil {
            mainTimer = NSTimer(timeInterval: 60, target: self, selector: "updateTimers", userInfo: nil, repeats: true)
            NSRunLoop.mainRunLoop().addTimer(mainTimer!, forMode: NSRunLoopCommonModes)

            // Set the wallpaper for the first time
            let times = SunCalculator.calculateTimes(NSDate(), latitude: currentLocation!.coordinate.latitude, longitude: currentLocation!.coordinate.longitude)
            setWallpaper(times.currentPeriod)
        }
    }

    private func updateTimers() {
        let times = SunCalculator.calculateTimes(NSDate(), latitude: currentLocation!.coordinate.latitude, longitude: currentLocation!.coordinate.longitude),
            noon = times.solarNoon,
            now = NSDate()

        // If sunrise is going to start but not end:
        //   * Set the sunriseTimer to times.sunriseStart
        //   * Set the sunsetTimer to times.solarNoon
        //   * set the nightTimer to times.sunsetEnd
        //
        // If sunrise is going to finish:
        //   * Set the sunriseTimer to times.sunriseStart
        //   * Set the morningTimer to times.sunriseEnd
        //   * Set the afternoonTimer to times.solarNoon
        //   * Set the sunsetTimer to times.sunsetStart
        //   * Set the nightTimer to times.sunsetEnd
        //
        // Otherwise... It's just gonna keep being night so oh well ¯\_(ツ)_/¯

        if let sunriseStart = times.sunriseStart {
            if sunriseTimer == nil && sunriseStart.compare(now) == .OrderedAscending {
                sunriseTimer = NSTimer(fireDate: sunriseStart, interval: 0, target: self, selector: "setWallpaper", userInfo: "sunrise", repeats: false)
                NSRunLoop.mainRunLoop().addTimer(sunriseTimer!, forMode: NSRunLoopCommonModes)
            }

            // If the sunrise ends and we enter morning, we can set everything else.
            if let sunriseEnd = times.sunriseEnd {
                if morningTimer == nil && sunriseEnd.compare(now) == .OrderedAscending {
                    morningTimer = NSTimer(fireDate: sunriseEnd, interval: 0, target: self, selector: "setWallpaper", userInfo: "morning", repeats: false)
                    NSRunLoop.mainRunLoop().addTimer(morningTimer!, forMode: NSRunLoopCommonModes)
                }

                if afternoonTimer == nil && noon.compare(now) == .OrderedAscending {
                    afternoonTimer = NSTimer(fireDate: noon, interval: 0, target: self, selector: "setWallpaper", userInfo: "afternoon", repeats: false)
                    NSRunLoop.mainRunLoop().addTimer(afternoonTimer!, forMode: NSRunLoopCommonModes)
                }

                let sunsetStart = times.sunsetStart!
                if sunsetTimer == nil && sunsetStart.compare(now) == .OrderedAscending {
                    afternoonTimer = NSTimer(fireDate: sunsetStart, interval: 0, target: self, selector: "setWallpaper", userInfo: "sunset", repeats: false)
                    NSRunLoop.mainRunLoop().addTimer(sunsetTimer!, forMode: NSRunLoopCommonModes)
                }
            }

            let sunsetEnd = times.sunsetEnd!
            if nightTimer == nil && sunsetEnd.compare(now) == .OrderedAscending {
                nightTimer = NSTimer(fireDate: sunsetEnd, interval: 0, target: self, selector: "setWallpaper", userInfo: "night", repeats: false)
                NSRunLoop.mainRunLoop().addTimer(nightTimer!, forMode: NSRunLoopCommonModes)
            }
        }
    }

    private func setWallpaper(timer: NSTimer) {
        let period = timer.userInfo as! String

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
