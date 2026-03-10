//
//  TaskStatisticView.swift
//  NextDream
//
//  Created by Belexiu Eugeniu on 16.09.2025.
//

import SwiftUI
import SwiftData
import Charts

struct TaskStatisticView: View {
    
    @State var vm: TaskStatisticViewModel
    
    init(modelContext: ModelContext, taskID: String, taskStartDate: Date) {
        _vm = State(wrappedValue: TaskStatisticViewModel(taskID: taskID, taskStartDate: taskStartDate, modelContext: modelContext))
    }
    
    var body: some View {
        ScrollView{
            progressRing
            
            progressChart
            
            chartSelection
                .padding(.horizontal)
            
        }
        .navigationTitle("Task Statistic")
    }
}

#Preview {
    NavigationStack{
        TaskStatisticView(modelContext: MockModels.container.mainContext, taskID: "12", taskStartDate: .now)
    }
}

extension TaskStatisticView {
    
    private var progressRing: some View{
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
    
    func createStatsCell(completedTask: Int, totalTask: Int, color: Color, text: String) -> some View{
        VStack{
            Text(text)
                .font(.headline)
                .fontWeight(.semibold)
            StatsCell(completed: completedTask, total: totalTask, color: color)
        }
    }
    
    private var progressChart: some View{
        Chart {
            
            ForEach(vm.allTasks, id: \.0) { value in
                LineMark(
                    x: .value("Date", value.0),
                    y: .value("TaskCompleted", value.1),
                    series: .value("Type", "Uncompleted")
                )
                .foregroundStyle(.gray)
                .lineStyle(
                        StrokeStyle(
                            lineWidth: 2,       // thickness of the line
                            lineCap: .square,    // rounded ends
                            dash: [1, 20]        // 5 points line, 5 points gap
                        )
                )
            }
            
            ForEach(vm.completedTasks, id: \.0) { value in
                LineMark(
                    x: .value("Date", value.0),
                    y: .value("Task Completed", value.1),
                    series: .value("Type", "Completed")
                )
                .foregroundStyle(.green)
            }
        }
        .frame(height: 300)
        .padding()
    }
    
    private var chartSelection: some View{
        Picker("Select Asset", selection: $vm.selectedTaskType) {
            ForEach(TaskType.allCases.filter { $0 != .byDate && $0 != .custom }, id: \.self) { type in
                Text(type.displayName).tag(type)
            }
        }
        .pickerStyle(.segmented)
    }
}

