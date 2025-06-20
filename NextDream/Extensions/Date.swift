//
//  Untitled.swift
//  NextDream
//
//  Created by Jan on 15/05/2025.
//

import Foundation

extension Date{
    
    func convertToStringFormat() -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        return dateFormatter.string(from: self)
    }
}
