//
//  JSONExportDocument.swift
//  NextDream
//
//  Created by Jan on 30/06/2025.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct JSONExportDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }
    var data: Data

    init(data: Data) {
        self.data = data
    }

    init(configuration: ReadConfiguration) throws {
        self.data = Data()
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: data)
    }
}
