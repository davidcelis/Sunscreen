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
            defaults.setValue(true, forKey: "launchAtLogin")
            SMLoginItemSetEnabled(identifier, true)
        case 0:
            defaults.setValue(false, forKey: "launchAtLogin")
            SMLoginItemSetEnabled(identifier, false)
        default:
            defaults.setValue(false, forKey: "launchAtLogin")
            SMLoginItemSetEnabled(identifier, false)
        }
    }

    private func imageDropped(sender: NSImageView, name: String) {
        if let image = sender.image {
            let manager = NSFileManager.defaultManager()

            let bmp = NSBitmapImageRep(data: image.TIFFRepresentation!)
            let png = bmp!.representationUsingType(NSBitmapImageFileType.NSPNGFileType, properties: [:])
            manager.createFileAtPath("\(wallpapersPath)/\(name).png", contents: png, attributes: nil)

            NSLog("Created file: \(wallpapersPath)/\(name).png")
        }
    }

    private func loadWallpaper(name: String, imageView: NSImageView) {
        let path = "\(wallpapersPath)/\(name).png"

        if let image = NSImage(byReferencingFile: path) {
            imageView.image = image
            NSLog("Loaded file: \(path)")
        }
    }
}
