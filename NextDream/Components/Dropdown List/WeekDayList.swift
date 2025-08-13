//
//  WeekDayList.swift
//  NextDream
//
//  Created by Belexiu Eugeniu on 13/08/2025.
//

import SwiftUI

struct WeekDayList: View {
    
    @Binding var selectedTask: [Weekday: Bool];
    
    var body: some View {
        ForEach(Weekday.allCases, id: \.self){ day in
            HStack{
                
                Text(day.dayName)
                
                Spacer()
                
                Image(systemName: selectedTask[day] == true ? "checkmark.square.fill" : "square.dashed")
            }
            .contentShape(RoundedRectangle(cornerRadius: 10))
            .onTapGesture {
                if let currentValue = selectedTask[day] {
                    selectedTask[day] = !currentValue
                } else {
                    selectedTask[day] = true
                }
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    
    @Previewable @State var selectedTask = Dictionary(uniqueKeysWithValues: Weekday.allCases.map { ($0, false) })

    
    WeekDayList(selectedTask: $selectedTask)
}
