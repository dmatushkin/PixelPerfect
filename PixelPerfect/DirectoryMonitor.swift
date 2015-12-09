//
//  DirectoryMonitor.swift
//  PixelPerfect
//
//  Created by Dmitry Matyushkin on 12/9/15.
//  Copyright © 2015 Dmitry Matyushkin. All rights reserved.
//

import Foundation

protocol DirectoryMonitorDelegate: class {
    func directoryMonitorDidObserveChange(directoryMonitor: DirectoryMonitor)
}

class DirectoryMonitor {
    weak var delegate: DirectoryMonitorDelegate?
    var monitoredDirectoryFileDescriptor: CInt = -1
    let directoryMonitorQueue = dispatch_queue_create("folder.monitoring.queue", DISPATCH_QUEUE_CONCURRENT)
    var directoryMonitorSource: dispatch_source_t?
    var URL: NSURL

    init() {
        if let desktopPath = NSSearchPathForDirectoriesInDomains(.DesktopDirectory, .UserDomainMask, true).first {
            self.URL = NSURL(fileURLWithPath: desktopPath)
        } else {
            print("can't find home dir path")
            self.URL = NSURL(fileURLWithPath: "/")
        }
    }

    init(URL: NSURL) {
        self.URL = URL
    }

    init(path : String) {
        self.URL = NSURL(fileURLWithPath: path)
    }

    func startMonitoring() {
        if directoryMonitorSource == nil && monitoredDirectoryFileDescriptor == -1 {
            monitoredDirectoryFileDescriptor = open(URL.path!, O_EVTONLY)
            directoryMonitorSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE, UInt(monitoredDirectoryFileDescriptor), DISPATCH_VNODE_WRITE, directoryMonitorQueue)
            dispatch_source_set_event_handler(directoryMonitorSource!) {
                self.delegate?.directoryMonitorDidObserveChange(self)
                return
            }
            dispatch_source_set_cancel_handler(directoryMonitorSource!) {
                close(self.monitoredDirectoryFileDescriptor)
                self.monitoredDirectoryFileDescriptor = -1
                self.directoryMonitorSource = nil
            }
            dispatch_resume(directoryMonitorSource!)
        }
    }

    func stopMonitoring() {
        if directoryMonitorSource != nil {
            dispatch_source_cancel(directoryMonitorSource!)
        }
    }
}