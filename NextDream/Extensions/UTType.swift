        //
//  UTType.swift
//  NextDream
//
//  Created by Belexiu Eugeniu on 25.09.2025.
//
import UniformTypeIdentifiers

extension UTType {
    /// Map our app's ExportType to system-provided UTTypes.
    static func export(for exportType: ExportType) -> UTType {
        switch exportType {
        case .JSON:
            return .json
        case .CSV:
            return .commaSeparatedText
        }
    }
}
