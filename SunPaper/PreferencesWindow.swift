//
//  PreferencesWindow.swift
//  SunPaper
//
//  Created by David Celis on 2/14/16.
//  Copyright © 2016 David Celis. All rights reserved.
//

import Cocoa

class PreferencesWindow: NSWindowController {
    let wallpapersPath = NSHomeDirectory()
    let fileManager = NSFileManager.defaultManager()

    @IBOutlet weak var sunriseImageView: NSImageView!
    @IBOutlet weak var morningImageView: NSImageView!
    @IBOutlet weak var afternoonImageView: NSImageView!
    @IBOutlet weak var sunsetImageView: NSImageView!
    @IBOutlet weak var nightImageView: NSImageView!

    override var windowNibName: String! {
        return "PreferencesWindow"
    }

    override func windowDidLoad() {
        super.windowDidLoad()

        self.window?.center()
        self.window?.makeKeyAndOrderFront(nil)
        NSApp.activateIgnoringOtherApps(true)
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

    private func imageDropped(sender: NSImageView, name: String) {
        if let image = sender.image {
            let manager = NSFileManager.defaultManager()

            let bmp = NSBitmapImageRep(data: image.TIFFRepresentation!)
            let png = bmp!.representationUsingType(NSBitmapImageFileType.NSPNGFileType, properties: [:])
            manager.createFileAtPath("\(wallpapersPath)/\(name).png", contents: png, attributes: nil)
        }
    }

    private func loadWallpaper(name: String, imageView: NSImageView) {
        let path = "\(wallpapersPath)/\(name)"

        if fileManager.fileExistsAtPath(path) {
            let data = fileManager.contentsAtPath(path)
            imageView.image = NSImage(data: data!)
        }
    }
}
