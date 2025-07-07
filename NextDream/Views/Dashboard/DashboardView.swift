import SwiftUI
import Charts
import SwiftData


// MARK: - Dashboard View
struct DashboardView: View {
    
    @State var viewModel: DashboardViewModel
    
    init(modelContext: ModelContext, taskRepository: TaskRepository) {
        _viewModel = State(wrappedValue: DashboardViewModel(modelContext: modelContext, taskRepository: taskRepository))
    }
    
    var body: some View {
        
        VStack(spacing: 20) {
            
            StreakRowView(streakCount: 10, todayTaskAchieved: 0, totalTaskAchieved: 10)
            
            createTodayTask
            
            // MARK: - Pie Chart
            createTaskCompletedTitle
            
            createChart
                .frame(height: 250)
                .padding()
        }
        .padding()
//        .background(.purple)
        .frame(minWidth: 400, minHeight: 600) // macOS-friendly sizing
//        .navigationTitle("Dashboard")
        .toolbar {
            userSettingsButton
        }
    }
}



// MARK: - Previews
#Preview{
// container.mainContext
    do{
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: TaskModel.self, configurations: config)
        return NavigationStack{DashboardView(
            modelContext: container.mainContext,
            taskRepository: DefaultTaskRepository(
                modelContext: container.mainContext
            )
        )
        .modelContainer(container)
        }
        
    }catch{
        fatalError("Failed to create ModelContainer for preview: \(error)")
    }
}

// MARK: Body

extension  DashboardView{
    
    private var createBoardTitle: some View{
        Text("Today's Tasks")
            .font(.title2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
    }
    
    private var createTaskCompletedTitle: some View{
        Text("Task Completion")
            .font(.title2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
    }
    
    private var createTodayTask: some View{
        
        List(viewModel.tasks) { task in
            createSubTaskField(task: task)
        }
        .listStyle(.plain)
        .frame(maxHeight: 300) // Limit list height
    }
    
    private var createChart: some View{
        Chart {
            ForEach(viewModel.chartData, id: \.0) { category, count in
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
    
    private var userSettingsButton: ToolbarItem<Void, some View>{
        ToolbarItem(placement: .topBarTrailing) {
            
            NavigationLink {
                UserSettingsView()
            } label: {
                Image(systemName: "gear")
            }
        }
    }
}

//MARK: UI Function
extension DashboardView{
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
}


