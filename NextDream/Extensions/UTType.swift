        //
//  UTType.swift
//  NextDream
//
//  Created by Belexiu Eugeniu on 25.09.2025.
//
import UniformTypeIdentifiers

extension UTType {
    
    static func myText(exportType: ExportType, taskName: String) -> UTType {
        UTType(exportedAs: "\(taskName).\(exportType.rawValue)")
    }
    
    static var myText: UTType {
        UTType(exportedAs: "com.example.mytext")
    }
}
