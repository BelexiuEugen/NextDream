import SwiftUI
import Charts
import SwiftData


// MARK: - Dashboard View
struct DashboardView: View {
    
    
    @Environment(TaskViewModel.self) var vm;
    
    @State private var todayTasks: [TaskModel] = []
    
    @State var isLoggingOut:Bool = false;
    
    // Filter today's tasks
    
    // Chart Data for Pie Chart
    private var chartData: [(String, Int)] {
        let completed = todayTasks.filter { $0.isCompleted }.count
        let uncompleted = todayTasks.count - completed
        return [("Completed", completed), ("Uncompleted", uncompleted)]
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // MARK: - Task List
            createBoardTitle()
            
            createTodayTask()
            
            // MARK: - Pie Chart
            createTaskCompletedTitle()
            
            createChart()
                .frame(height: 250)
                .padding()
        }
        .padding()
        .frame(minWidth: 400, minHeight: 600) // macOS-friendly sizing
        .navigationTitle("Dashboard")
        .onAppear{
            vm.fetchTaskByDeadline(date: Date())
        }
        
        
//        .toolbar {
//            Button("Add destination", systemImage: "rectangle.portrait.and.arrow.right", action: exitAccount)
//        }
    }
}



// MARK: - Previews
#Preview{
    NavigationStack{
        DashboardView()
    }
}

// MARK: Body

extension  DashboardView{
    func createSubTaskField(task: TaskModel) -> some View{
        HStack{
            
            Text(task.name)
                .font(.body)
            
            Spacer()
            
            Button{
                task.isCompleted.toggle()

            } label: {
                ZStack {
                    // Outer circle background
                    Circle()
                        .fill(Color.white)
                        .stroke(task.isCompleted ? Color.blue : Color.gray, lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    // Checkmark inside the circle (shown when checked)
                    if task.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.blue)
                            .font(.system(size: 20))
                    }
                    
                }
            }
            .buttonStyle(.plain)
        }
    }
    
    func createBoardTitle() -> some View{
        Text("Today's Tasks")
            .font(.title2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
    }
    
    func createTaskCompletedTitle() -> some View{
        Text("Task Completion")
            .font(.title2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
    }
    
    func createTodayTask() -> some View{
        
        List(vm.task) { task in
            createSubTaskField(task: task)
        }
        .listStyle(.plain)
        .frame(maxHeight: 300) // Limit list height
    }
    
    func createChart() -> some View{
        Chart {
            ForEach(chartData, id: \.0) { category, count in
                SectorMark(
                    angle: .value("Count", count),
                    innerRadius: .ratio(0.5),
                    outerRadius: .ratio(1.0)
                )
                .foregroundStyle(category == "Completed" ? .green : .red)
                .annotation(position: .overlay) {
                    Text("\(count)")
                        .font(.caption)
                        .foregroundColor(.white)
                }
            }
        }
    }
}

// MARK: Functions

extension DashboardView {
    func toggleTaskCompletion(at index: Int) {
        guard index >= 0 && index < todayTasks.count else { return }
        
        let item = todayTasks[index]
        item.isCompleted.toggle()
        
        DispatchQueue.global().async{
            vm.saveDataToDevice()
        }
    }
    
//    func exitAccount(){
//
//        TaskViewModel.exitAccount(with: modelContext)
//        
//        isLoggingOut.toggle()
//            
//    }
}


