//
//  Errors.swift
//  NextDream
//
//  Created by Jan on 17/06/2025.
//

import Foundation

protocol NextDreamErrorProtocol{
    
}

enum MyCusotmError: Error, LocalizedError, NextDreamErrorProtocol{
    case myFirstError
    case mySecondError
    case myThridError
    
    var title: String {
        switch self {
        case .myFirstError:
            "That's my first response"
        case .mySecondError:
            "Thta' my second response"
        case .myThridError:
            "That's my last response"
        }
    }
    
    var subTitle: String {
        switch self {
        case .myFirstError:
            "That's my first response"
        case .mySecondError:
            "Thta' my second response"
        case .myThridError:
            "That's my last response"
        }
    }
}
