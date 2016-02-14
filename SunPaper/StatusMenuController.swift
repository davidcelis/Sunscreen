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

    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
    let sunriseSunsetAPI = SunriseSunsetAPI()
    let locationManager = CLLocationManager()

    override func awakeFromNib() {
        let icon = NSImage(named: "StatusIcon")
        icon?.template = true // Dark mode support

        statusItem.image = icon
        statusItem.menu = statusMenu
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
    }

    @IBAction func updateClicked(sender: NSMenuItem) {
        locationManager.startUpdatingLocation()
    }

    @IBAction func quitClicked(sender: NSMenuItem) {
        NSApplication.sharedApplication().terminate(self)
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [AnyObject]) {
        let location = locations.last as! CLLocation

        sunriseSunsetAPI.getSunData(location.coordinate.latitude, longitude: location.coordinate.longitude) { sunData in
            NSLog("\(sunData)")
        }

        locationManager.stopUpdatingLocation()
    }
}
