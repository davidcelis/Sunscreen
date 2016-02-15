//
//  PreferencesWindow.swift
//  SunPaper
//
//  Created by David Celis on 2/14/16.
//  Copyright © 2016 David Celis. All rights reserved.
//

import Cocoa

class PreferencesWindow: NSWindowController {
    static let directory = NSHomeDirectory()
    let sunrisePath = "\(directory)/sunrise.png"
    let morningPath = "\(directory)/morning.png"
    let afternoonPath = "\(directory)/afternoon.png"
    let sunsetPath = "\(directory)/sunset.png"
    let nightPath = "\(directory)/night.png"

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
        let fileManager = NSFileManager.defaultManager()

        if fileManager.fileExistsAtPath(sunrisePath) {
            let sunriseData = fileManager.contentsAtPath(sunrisePath)
            sunriseImageView.image = NSImage(data: sunriseData!)
        }

        if fileManager.fileExistsAtPath(morningPath) {
            let morningData = fileManager.contentsAtPath(morningPath)
            morningImageView.image = NSImage(data: morningData!)
        }

        if fileManager.fileExistsAtPath(afternoonPath) {
            let afternoonData = fileManager.contentsAtPath(afternoonPath)
            afternoonImageView.image = NSImage(data: afternoonData!)
        }

        if fileManager.fileExistsAtPath(sunsetPath) {
            let sunsetData = fileManager.contentsAtPath(sunsetPath)
            sunsetImageView.image = NSImage(data: sunsetData!)
        }

        if fileManager.fileExistsAtPath(nightPath) {
            let nightData = fileManager.contentsAtPath(nightPath)
            nightImageView.image = NSImage(data: nightData!)
        }
    }

    @IBAction func sunriseImageDropped(sender: NSImageView) {
        if let image = sender.image {
            let fileManager = NSFileManager.defaultManager()

            let bmp = NSBitmapImageRep(data: image.TIFFRepresentation!)
            let png = bmp!.representationUsingType(NSBitmapImageFileType.NSPNGFileType, properties: [:])
            fileManager.createFileAtPath(sunrisePath, contents: png, attributes: nil)
        }
    }

    @IBAction func morningImageDropped(sender: NSImageView) {
        if let image = sender.image {
            let fileManager = NSFileManager.defaultManager()

            let bmp = NSBitmapImageRep(data: image.TIFFRepresentation!)
            let png = bmp!.representationUsingType(NSBitmapImageFileType.NSPNGFileType, properties: [:])
            fileManager.createFileAtPath(morningPath, contents: png, attributes: nil)
        }
    }

    @IBAction func afternoonImageDropped(sender: NSImageView) {
        if let image = sender.image {
            let fileManager = NSFileManager.defaultManager()

            let bmp = NSBitmapImageRep(data: image.TIFFRepresentation!)
            let png = bmp!.representationUsingType(NSBitmapImageFileType.NSPNGFileType, properties: [:])
            fileManager.createFileAtPath(afternoonPath, contents: png, attributes: nil)
        }
    }

    @IBAction func sunsetImageDropped(sender: NSImageView) {
        if let image = sender.image {
            let fileManager = NSFileManager.defaultManager()

            let bmp = NSBitmapImageRep(data: image.TIFFRepresentation!)
            let png = bmp!.representationUsingType(NSBitmapImageFileType.NSPNGFileType, properties: [:])
            fileManager.createFileAtPath(sunsetPath, contents: png, attributes: nil)
        }
    }

    @IBAction func nightImageDropped(sender: NSImageView) {
        if let image = sender.image {
            let fileManager = NSFileManager.defaultManager()

            let bmp = NSBitmapImageRep(data: image.TIFFRepresentation!)
            let png = bmp!.representationUsingType(NSBitmapImageFileType.NSPNGFileType, properties: [:])
            fileManager.createFileAtPath(nightPath, contents: png, attributes: nil)
        }
    }
}
