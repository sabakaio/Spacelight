//
//  ViewController.swift
//  Spacelight
//
//  Created by Arseny Zarechnev on 29/03/2017.
//  Copyright © 2017 Arseny Zarechnev. All rights reserved.
//

import Cocoa

func bridge<T : AnyObject>(obj : T) -> UnsafeMutableRawPointer {
    return UnsafeMutableRawPointer(Unmanaged.passUnretained(obj).toOpaque())
}

func transfer<T : AnyObject>(ptr : UnsafeMutableRawPointer) -> T {
    return Unmanaged<T>.fromOpaque(ptr).takeUnretainedValue()
}

class ViewController: NSViewController {
    @IBOutlet var label: NSTextFieldCell!
    @IBOutlet var appLabel: NSTextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        func callback(proxy: OpaquePointer, type: CGEventType, event: CGEvent, refcon: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {

            //  if [.keyDown , .keyUp].contains(type) {
            var keyCode = event.getIntegerValueField(.keyboardEventKeycode)
            var something = event.flags
            print(keyCode.description)
            let appName = NSWorkspace.shared().frontmostApplication?.localizedName
            let that: ViewController = transfer(ptr: refcon!)
            that.label.stringValue = something.rawValue.description//keyCode.description
            that.appLabel.stringValue = appName!
            //self.lastKey = keyCode.description
            //                if keyCode == 0 {
            //                    keyCode = 6
            //                } else if keyCode == 6 {
            //                    keyCode = 0
            //                }
            //                event.setIntegerValueField(.keyboardEventKeycode, value: keyCode)
            //}
            return Unmanaged.passRetained(event)
        }

        let eventMask = (1 << CGEventType.keyDown.rawValue) | (1 << CGEventType.keyUp.rawValue) | (1 << CGEventType.flagsChanged.rawValue)
        guard let eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(eventMask),
            callback: callback,
            userInfo: bridge(obj: self)) else {
                print("failed to create event tap")
                exit(1)
        }

        let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)
        //CFRunLoopRun()

    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}

