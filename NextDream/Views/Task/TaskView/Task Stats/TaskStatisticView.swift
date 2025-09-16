//
//  TaskStatisticView.swift
//  NextDream
//
//  Created by Belexiu Eugeniu on 16.09.2025.
//

import SwiftUI
import SwiftData

struct TaskStatisticView: View {
    
    @State var vm: TaskStatisticViewModel
    
    init(modelContext: ModelContext, taskID: String) {
        _vm = State(wrappedValue: TaskStatisticViewModel(taskID: taskID, modelContext: modelContext))
    }
    
    var body: some View {
        ScrollView{
            VStack{
                HStack{
                    createStatsCell(
                        completedTask: vm.daysCompleted,
                        totalTask: vm.totalDays,
                        color: .blue,
                        text: "Days: "
                    )
                    createStatsCell(
                        completedTask: vm.weeksCompleted,
                        totalTask: vm.totalWeeks,
                        color: .red,
                        text: "Weeks: "
                    )
                }
                HStack{
                    createStatsCell(
                        completedTask: vm.monthsCompleted,
                        totalTask: vm.totalMonths,
                        color: .green,
                        text: "Months"
                    )
                    createStatsCell(
                        completedTask: vm.yearsCompleted,
                        totalTask: vm.totalYears,
                        color: .orange,
                        text: "Years"
                    )
                }
                
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    TaskStatisticView(modelContext: MockModels.container.mainContext, taskID: "12")
}

extension TaskStatisticView {
    
    func createStatsCell(completedTask: Int, totalTask: Int, color: Color, text: String) -> some View{
        VStack{
            Text(text)
                .font(.headline)
                .fontWeight(.semibold)
            StatsCell(completed: completedTask, total: totalTask, color: color)
        }
    }
}
