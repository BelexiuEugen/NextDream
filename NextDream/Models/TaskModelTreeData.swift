//
//  TaskModelTreeData.swift
//  NextDream
//
//  Created by Belexiu Eugeniu on 19.09.2025.
//

import Foundation

public struct TaskModelTreeData: Codable {
    public var id: String
    public var title: String
    public var isCompleted: Bool
    public var deadline: Date
}
