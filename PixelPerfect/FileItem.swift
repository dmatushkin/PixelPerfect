//
//  FileItem.swift
//  PixelPerfect
//
//  Created by Dmitry Matyushkin on 12/9/15.
//  Copyright © 2015 Dmitry Matyushkin. All rights reserved.
//

import Foundation

class FileItem {
    let filePath : String
    let dateCreated : NSDate

    init(path : String, date : NSDate) {
        self.filePath = path
        self.dateCreated = date
    }

    init(path : String) {
        self.filePath = path
        do {
            let attrs = try NSFileManager.defaultManager().attributesOfItemAtPath(path)
            self.dateCreated = attrs[NSFileCreationDate] as? NSDate ?? NSDate()
        } catch {
            self.dateCreated = NSDate()
        }
    }
}