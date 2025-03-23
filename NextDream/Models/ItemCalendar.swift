//
//  Untitled.swift
//  NextDream
//
//  Created by Jan on 22/01/2025.
//

import Foundation

@Observable
class ItemCalendarSelection : Identifiable{
    var item: TaskModel
    var isSelected: Bool
    
    init(item: TaskModel, isSelected: Bool) {
        self.item = item
        self.isSelected = isSelected
    }
}
