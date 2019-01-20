//
//  AppDelegate.swift
//  CAM
//
//  Created by Gabriel Rinaldi on 1/19/19.
//  Copyright © 2019 Gabriel Rinaldi. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    private var camctl: CAMCtl?
    private var menu: Menu?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        self.camctl = CAMCtl()

        if let camctl = self.camctl {
            self.menu = Menu(camctl: camctl)
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        if let camctl = self.camctl {
            camctl.unload()
        }
    }
}
