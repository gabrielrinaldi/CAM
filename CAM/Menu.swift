//
//  Menu.swift
//  CAM
//
//  Created by Gabriel Rinaldi on 1/19/19.
//  Copyright © 2019 Gabriel Rinaldi. All rights reserved.
//

import Cocoa

class Menu: NSObject, NSMenuDelegate {
    private let camctl: CAMCtl
    private let statusItem: NSStatusItem
    private let menu: NSMenu
    private var titleMenu: NSMenuItem
    private var temperatureMenu: NSMenuItem
    private var fanMenu: NSMenuItem
    private var pumpMenu: NSMenuItem
    private let disabledMenu: NSMenuItem

    init(camctl: CAMCtl) {
        self.camctl = camctl

        self.statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
        if let statusItemButton = self.statusItem.button {
            if let statusImage = NSImage(named: NSImage.Name("StatusBarButtonImage")) {
                statusImage.size = NSMakeSize(18.0, 18.0)
                statusItemButton.image = statusImage
            }
        }

        self.menu = NSMenu()
        self.titleMenu = NSMenuItem(title: "NZXT Kraken X62", action: #selector(refresh), keyEquivalent: "r")
        self.temperatureMenu = NSMenuItem()
        self.temperatureMenu.title = "Loading..."
        self.fanMenu = NSMenuItem(title: "Loading...", action: nil, keyEquivalent: "f")
        self.pumpMenu = NSMenuItem(title: "Loading...", action: nil, keyEquivalent: "p")
        self.disabledMenu = NSMenuItem(title: "No devices found", action: #selector(refresh), keyEquivalent: "r")

        super.init()

        constructMenu()
    }

    func menuWillOpen(_ menu: NSMenu) {
        refreshMenus()
    }

    @objc func refresh() {
        self.refreshMenus()
    }

    @objc func setFan(_ sender: NSMenuItem) {
        self.camctl.setFan(speed: sender.tag)
    }

    @objc func setPump(_ sender: NSMenuItem) {
        self.camctl.setPump(speed: sender.tag)
    }

    private func refreshMenus() {
        if self.camctl.isLoaded() {
            if let status = self.camctl.getStatus() {
                if let temperature = status["temperature"] {
                    self.temperatureMenu.title = "Temperature: \(temperature)ºC"
                } else {
                    self.temperatureMenu.title = "Temperature: !"
                }

                if let fan = status["fan"] {
                    self.fanMenu.title = "Fan: \(fan) RPM"
                } else {
                    self.fanMenu.title = "Fan: !"
                }

                if let pump = status["pump"] {
                    self.pumpMenu.title = "Pump: \(pump) RPM"
                } else {
                    self.pumpMenu.title = "Pump: !"
                }
            } else {
                self.temperatureMenu.title = "Temperature: !"
                self.fanMenu.title = "Fan: !"
                self.pumpMenu.title = "Pump: !"
            }
        }
    }

    private func constructMenu() {
        self.titleMenu.target = self
        self.temperatureMenu.target = self
        self.fanMenu.target = self
        self.pumpMenu.target = self


        let fanMenu = NSMenu()
        for i in 3...10 {
            let menuItem = NSMenuItem()
            menuItem.title = "\(i * 10)%"
            menuItem.target = self
            menuItem.action = #selector(setFan(_:))
            menuItem.tag = i * 10
            fanMenu.addItem(menuItem)
        }
        self.fanMenu.submenu = fanMenu

        let pumpMenu = NSMenu()
        for i in 3...10 {
            let menuItem = NSMenuItem()
            menuItem.title = "\(i * 10)%"
            menuItem.target = self
            menuItem.action = #selector(setPump(_:))
            menuItem.tag = i * 10
            pumpMenu.addItem(menuItem)
        }
        self.pumpMenu.submenu = pumpMenu

        if self.camctl.isLoaded() {
            self.menu.addItem(self.titleMenu)
            self.menu.addItem(self.temperatureMenu)
            self.menu.addItem(self.fanMenu)
            self.menu.addItem(self.pumpMenu)
        } else {
            self.menu.addItem(self.disabledMenu)
        }

        self.menu.addItem(NSMenuItem.separator())
        self.menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        self.statusItem.menu = self.menu
        self.menu.delegate = self
    }
}
