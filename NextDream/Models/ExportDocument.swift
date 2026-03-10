//
//  JSONExportDocument.swift
//  NextDream
//
//  Created by Jan on 30/06/2025.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers


struct ExportDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json, .commaSeparatedText] }
    var data: Data
    var contentType: UTType

    init(data: Data, contentType: UTType = .json) {
        self.data = data
        self.contentType = contentType
    }

    init(configuration: ReadConfiguration) throws {
        self.data = Data()
        self.contentType = .json
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let wrapper = FileWrapper(regularFileWithContents: data)
        // Optionally provide a preferred filename extension when exporting
        if contentType == .json {
            wrapper.preferredFilename = wrapper.preferredFilename ?? "export.json"
        } else if contentType == .commaSeparatedText {
            wrapper.preferredFilename = wrapper.preferredFilename ?? "export.csv"
        }
        return wrapper
    }
}
