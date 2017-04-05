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
    @IBOutlet var table: NSTableView!

    //var commandKeyDown = false
    var windowVisible = true
    var skip = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        func callback(
            proxy: OpaquePointer,
            type: CGEventType,
            event: CGEvent,
            refcon: UnsafeMutableRawPointer?
            ) -> Unmanaged<CGEvent>? {

            let viewController: ViewController = transfer(ptr: refcon!)
            
            func hideWindow() {
                viewController.view.window?.orderOut(true)
                viewController.windowVisible = false
            }
            
            func showWindow() {
                viewController.view.window?.orderFront(true)
                viewController.windowVisible = true
            }
            
            //  if [.keyDown , .keyUp].contains(type) {
            let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
            let flags = event.flags
            let hasCommand = flags.contains(CGEventFlags.maskCommand)
            print(keyCode.description, hasCommand)
            let appName = NSWorkspace.shared().frontmostApplication?.localizedName
            
            viewController.label.stringValue = flags.rawValue.description
            viewController.appLabel.stringValue = appName!
        
            if keyCode == 53 && viewController.windowVisible {
                // hide with escape
                viewController.view.window!.orderOut(true)
                viewController.windowVisible = false
            }
            
            if keyCode != 53 && keyCode != 55 && !viewController.windowVisible && hasCommand {
                // Skip on cmd+something (e.g cmd+tab)
                viewController.skip = true
                return Unmanaged.passRetained(event)
            }
            
            if (appName == "iTerm2") {
                if viewController.windowVisible && [.keyDown].contains(type) {
                    
                    if keyCode == 9 {
                        // replace mnemonic cmd - v with cmd+shift+d, split
                        event.setIntegerValueField(.keyboardEventKeycode, value: 2)
                        event.flags = event.flags.union(CGEventFlags.maskCommand)
                    } else if keyCode == 1 {
                        // replace mnemonic cmd - s with cmd+d, vetical split
                        event.setIntegerValueField(.keyboardEventKeycode, value: 2)
                        event.flags = event.flags.union(CGEventFlags.maskCommand)
                        event.flags = event.flags.union(CGEventFlags.maskShift)
                    }
                    
                    
                    hideWindow()
                    
                    return Unmanaged.passRetained(event)
                }
            }
            
            if keyCode == 55 {
                if viewController.windowVisible {
                    if !hasCommand {
                        viewController.view.window?.orderOut(true)
                        viewController.windowVisible = false
                    }
                } else {
                    if !hasCommand {
                        if !viewController.skip {
                            viewController.view.window?.orderFront(true)
                            viewController.windowVisible = true
                        } else {
                            viewController.skip = false
                        }
                    }
                }
            }

            //
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

