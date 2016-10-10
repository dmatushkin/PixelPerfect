//
//  DirectoryMonitor.swift
//  PixelPerfect
//
//  Created by Dmitry Matyushkin on 12/9/15.
//  Copyright © 2015 Dmitry Matyushkin. All rights reserved.
//

import Foundation

protocol DirectoryMonitorDelegate: class {
    func directoryMonitorDidObserveChange(_ directoryMonitor: DirectoryMonitor)
}

class DirectoryMonitor {
    weak var delegate: DirectoryMonitorDelegate?
    var monitoredDirectoryFileDescriptor: CInt = -1
    let directoryMonitorQueue = DispatchQueue(label: "folder.monitoring.queue", attributes: DispatchQueue.Attributes.concurrent)
    var directoryMonitorSource: DispatchSource?
    var URL: Foundation.URL

    init() {
        if let desktopPath = NSSearchPathForDirectoriesInDomains(.desktopDirectory, .userDomainMask, true).first {
            self.URL = Foundation.URL(fileURLWithPath: desktopPath)
        } else {
            print("can't find home dir path")
            self.URL = Foundation.URL(fileURLWithPath: "/")
        }
    }

    init(URL: Foundation.URL) {
        self.URL = URL
    }

    init(path : String) {
        self.URL = Foundation.URL(fileURLWithPath: path)
    }

    func startMonitoring() {
        if directoryMonitorSource == nil && monitoredDirectoryFileDescriptor == -1 {
            monitoredDirectoryFileDescriptor = open(URL.path, O_EVTONLY)
            directoryMonitorSource = DispatchSource.makeFileSystemObjectSource(fileDescriptor: monitoredDirectoryFileDescriptor, eventMask: DispatchSource.FileSystemEvent.write, queue: directoryMonitorQueue) as? DispatchSource
            directoryMonitorSource!.setEventHandler {
                self.delegate?.directoryMonitorDidObserveChange(self)
                return
            }
            directoryMonitorSource!.setCancelHandler {
                close(self.monitoredDirectoryFileDescriptor)
                self.monitoredDirectoryFileDescriptor = -1
                self.directoryMonitorSource = nil
            }
            directoryMonitorSource!.resume()
        }
    }

    func stopMonitoring() {
        if directoryMonitorSource != nil {
            directoryMonitorSource!.cancel()
        }
    }
}
