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
    let dateCreated : Date

    init(path : String, date : Date) {
        self.filePath = path
        self.dateCreated = date
    }

    init(path : String) {
        self.filePath = path
        do {
            let attrs = try FileManager.default.attributesOfItem(atPath: path)
            self.dateCreated = attrs[FileAttributeKey.creationDate] as? Date ?? Date()
        } catch {
            self.dateCreated = Date()
        }
    }

    func compare(_ nextItem : FileItem) -> Bool {
        return self.dateCreated.compare(nextItem.dateCreated) == ComparisonResult.orderedAscending
    }
}
