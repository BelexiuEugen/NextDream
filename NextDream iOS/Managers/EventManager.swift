//
//  EventManager.swift
//  NextDream
//
//  Created by Jan on 30/01/2025.
//

import Foundation
import EventKit

class EventManager{
    
    private let eventStore = EKEventStore()
    
    func requestAccess(completion: @escaping (Bool, Error?) -> Void) {
        eventStore.requestFullAccessToEvents { granted, error in
            completion(granted, error)
        }
    }
    
    func createEvent(name: String, description: String, endDate: Date) -> String?{
        
        let event = EKEvent(eventStore: eventStore)
        
        event.title = name;
        event.notes = description;
        event.startDate = endDate - 3600;
        event.endDate = endDate;
        
        return saveEvent(event: event);
    }
    
    func saveEvent(event: EKEvent) -> String?{
        
        do {
            event.calendar = eventStore.defaultCalendarForNewEvents
            
            try eventStore.save(event, span: .thisEvent)
            
            if let eventIdentifier = event.eventIdentifier {
                return eventIdentifier
            }
            
        } catch {
            return nil;
        }
        
        return nil;
    }
    
    func deleteEvent(eventIdentifier: String) -> Bool{
        
        guard let event = eventStore.event(withIdentifier: eventIdentifier) else {return true}
        
        do {
            try eventStore.remove(event, span: .thisEvent, commit: true)
            
            return true;
        } catch{
            print("Error deleting event: \(error.localizedDescription)")
            return false;
        }
    }
    
    func modifyEvent(eventIdentifier: String, name: String, description: String, deadline: Date) -> Bool{
        
        guard let event = eventStore.event(withIdentifier: eventIdentifier) else {return false}
        
        event.title = name;
        event.notes = description;
        event.startDate = deadline - 3600;
        event.endDate = deadline;
        
        do {
            try eventStore.save(event, span: .thisEvent)
            return true;
        } catch {
            print("Error updating event: \(error.localizedDescription)")
            return false;
        }
    }
    
    
}
