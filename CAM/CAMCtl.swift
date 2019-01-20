//
//  CAMCtl.swift
//  CAM
//
//  Created by Gabriel Rinaldi on 1/19/19.
//  Copyright © 2019 Gabriel Rinaldi. All rights reserved.
//

import hidapi

let BUF_LEN = 64

class CAMCtl {
    private var handle: OpaquePointer?
    private var buffer: [UInt8]
    private var status: [String: Float]?

    init() {
        hid_init()

        self.buffer = [UInt8](repeating: 0, count: BUF_LEN + 1)
        self.handle = hid_open(0x1e71, 0x170e, nil)

        refreshStatus()
    }

    func isLoaded() -> Bool {
        return (self.handle != nil)
    }

    func getStatus() -> [String: Float]? {
        if !isLoaded() {
            return nil
        }

        refreshStatus()

        return status;
    }

    func setFan(speed: Int) {
        if !isLoaded() {
            return
        }

        hid_write(handle, [2, 77, 0, 0, UInt8(speed)], 5)
    }

    func setPump(speed: Int) {
        if !isLoaded() {
            return
        }

        hid_write(handle, [2, 77, 64, 0, UInt8(speed)], 5)
    }

    private func refreshStatus() {
        let rcount = hid_read(handle, &self.buffer, BUF_LEN)

        if (rcount < 0) {
            self.status = nil

            return
        }

        let temperature = Float(self.buffer[1]) + Float(self.buffer[2]) / 10
        let fan = Float(Int(self.buffer[3]) << 8 | Int(self.buffer[4]))
        let pump = Float(Int(self.buffer[5]) << 8 | Int(self.buffer[6]))

        self.status = [
            "temperature" : temperature,
            "fan": fan,
            "pump": pump
        ]
    }

    func unload() {
        if isLoaded() {
            hid_close(handle)
        }

        hid_exit()
    }

    deinit {
        unload()
    }
}
