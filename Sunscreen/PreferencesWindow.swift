//
//  PreferencesWindow.swift
//  Sunscreen
//
//  Created by David Celis on 2/14/16.
//  Copyright © 2016 David Celis. All rights reserved.
//

import Cocoa
import ServiceManagement

class PreferencesWindow: NSWindowController {
    let wallpapersPath = NSHomeDirectory()
    let fileManager = NSFileManager.defaultManager()

    @IBOutlet weak var sunriseImageView: NSImageView!
    @IBOutlet weak var morningImageView: NSImageView!
    @IBOutlet weak var afternoonImageView: NSImageView!
    @IBOutlet weak var sunsetImageView: NSImageView!
    @IBOutlet weak var nightImageView: NSImageView!
    @IBOutlet weak var startAtLoginButton: NSButton!

    override var windowNibName: String! {
        return "PreferencesWindow"
    }

    override func windowDidLoad() {
        loadExistingWallpapers()

        let defaults = NSUserDefaults.standardUserDefaults()

        switch defaults.boolForKey("launchAtLogin") {
        case true:
            startAtLoginButton.state = 1
        case false:
            startAtLoginButton.state = 0
        }
    }

    func loadExistingWallpapers() {
        loadWallpaper("sunrise", imageView: sunriseImageView)
        loadWallpaper("morning", imageView: morningImageView)
        loadWallpaper("afternoon", imageView: afternoonImageView)
        loadWallpaper("sunset", imageView: sunsetImageView)
        loadWallpaper("night", imageView: nightImageView)
    }

    @IBAction func sunriseImageDropped(sender: NSImageView) {
        imageDropped(sender, name: "sunrise")
    }

    @IBAction func morningImageDropped(sender: NSImageView) {
        imageDropped(sender, name: "morning")
    }

    @IBAction func afternoonImageDropped(sender: NSImageView) {
        imageDropped(sender, name: "afternoon")
    }

    @IBAction func sunsetImageDropped(sender: NSImageView) {
        imageDropped(sender, name: "sunset")
    }

    @IBAction func nightImageDropped(sender: NSImageView) {
        imageDropped(sender, name: "night")
    }

    @IBAction func startAtLoginClicked(sender: NSButton) {
        let identifier = "com.davidcelis.SunscreenLauncher",
            defaults = NSUserDefaults.standardUserDefaults()

        switch sender.state {
        case 1:
            defaults.setBool(true, forKey: "launchAtLogin")
            SMLoginItemSetEnabled(identifier, true)
        case 0:
            defaults.setBool(false, forKey: "launchAtLogin")
            SMLoginItemSetEnabled(identifier, false)
        default:
            defaults.setBool(false, forKey: "launchAtLogin")
            SMLoginItemSetEnabled(identifier, false)
        }
    }

    private func imageDropped(sender: NSImageView, name: String) {
        let manager = NSFileManager.defaultManager(),
            defaults = NSUserDefaults.standardUserDefaults(),
            uuid = NSUUID().UUIDString,
            path = "\(wallpapersPath)/\(uuid).png"

        // If there's an old image, delete it
        removeWallpaper(name)

        if let image = sender.image {
            let bmp = NSBitmapImageRep(data: image.TIFFRepresentation!)
            let png = bmp!.representationUsingType(NSBitmapImageFileType.NSPNGFileType, properties: [:])
            manager.createFileAtPath(path, contents: png, attributes: nil)
            defaults.setValue(path, forKey: "\(name)Wallpaper")
        }
    }

    private func loadWallpaper(name: String, imageView: NSImageView) {
        let defaults = NSUserDefaults.standardUserDefaults()

        if let path = defaults.valueForKey("\(name)Wallpaper"), image = NSImage(byReferencingFile: path as! String) {
            imageView.image = image
        }
    }

    private func removeWallpaper(name: String) {
        let manager = NSFileManager.defaultManager(),
            defaults = NSUserDefaults.standardUserDefaults()

        if let oldImagePath = defaults.valueForKey("\(name)Wallpaper") {
            do {
                try manager.removeItemAtPath(oldImagePath as! String)
            } catch {
                NSLog("\(error)")
            }
        }
    }
}
