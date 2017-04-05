//
//  WindowController.swift
//  Spacelight
//
//  Created by Arseny Zarechnev on 04/04/2017.
//  Copyright © 2017 Arseny Zarechnev. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {
    override func windowDidLoad() {
        super.windowDidLoad()
        self.window!.level = Int(CGWindowLevelForKey(.maximumWindow))
        self.window!.orderOut(true)
        self.window!.titleVisibility = NSWindowTitleVisibility.hidden;
        self.window!.titlebarAppearsTransparent = true;
        self.window!.isMovableByWindowBackground  = true;
        self.window!.standardWindowButton(NSWindowButton.closeButton)!.isHidden = true;
        self.window!.standardWindowButton(NSWindowButton.miniaturizeButton)!.isHidden = true;
        self.window!.standardWindowButton(NSWindowButton.zoomButton)!.isHidden = true;
        self.window!.isOpaque = false;
        //self.window!.hasShadow = false
        self.window!.backgroundColor = NSColor.init(calibratedRed: 1, green: 1, blue: 1, alpha: 0.9);
    }

}
