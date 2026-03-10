import SwiftUI
import FSCalendar
import SwiftData

struct CalendarView: View {
    
    @State private var viewModel: CalendarViewModel
    @Environment(\.colorScheme) private var colorScheme
    @State private var calendarResetToken = UUID()
    
    init(modelContext: ModelContext, taskRepository: TaskRepository){
        _viewModel = State(wrappedValue: CalendarViewModel(modelContext: modelContext, taskRepository: taskRepository))
    }
    
    var body: some View {
        
        @Bindable var viewModel = viewModel;
        
        VStack {
            FSCalendarView(
                tasks: $viewModel.tasks,
                selectedDate: $viewModel.selectedDate,
                tasksForSelectedDate: $viewModel.tasksForSelectedDate,
                currentPage: $viewModel.currentPage
            )
            .frame(height: 300)
            .id(calendarResetToken)
            
            Text("Selected Date: \(viewModel.selectedDate.toMediumStyle())")
                .font(.headline)
                .padding()
            
            showTaskDetails
        }
        .padding()
        .onChange(of: colorScheme) { _, _ in
            // Force re-create FSCalendar when appearance changes to avoid rendering bug
            calendarResetToken = UUID()
        }
//        .sheet(isPresented: $viewModel.isPresented, content: {
////            EventSelectionView(modelContext: viewModel.modelContext)
////                .presentationDetents([.fraction(0.4), .medium, .large])
//                Text("Coming Soon - Apple Calendar integration is on its way!")
//        })
//        .toolbar {
//            calendarButton
//        }
    }
}

#Preview {
    HomeView()
}

//MARK: Body

extension CalendarView{
    func createButton(task: TaskModel) -> some View{
        Button{
            task.isCompleted.toggle()
        } label: {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .stroke(task.isCompleted ? Color.blue : Color.gray, lineWidth: 2)
                    .frame(width: 24, height: 24)
                
                if task.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 20))
                }
                
            }
        }
        .padding(.horizontal)
    }
    
    private var calendarButton: ToolbarItem<Void, some View>{
        ToolbarItem(placement: .topBarTrailing) {
            
            Button {
                viewModel.isPresented.toggle()
            } label: {
                Image(systemName: "calendar.badge.plus")
            }
        }
    }
    
    private var showTaskDetails: some View{
        Group{
            if !viewModel.tasksForSelectedDate.isEmpty {
                createScrollView
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            } else {
                Text("No tasks for this day")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
    }
    
    private var createScrollView: some View{
        ScrollView {
            ForEach(viewModel.tasksForSelectedDate, id: \.self) { task in
                HStack{
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Task: \(task.name)")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundStyle(task.isCompleted ? .green : .red)
                            .frame(alignment: .leading)
                        
                        if ((task.taskDescription?.isEmpty) != nil){
                            Text("Description: \(task.taskDescription ?? "No description found")")
                                .font(.body)
                                .foregroundColor(.gray)
                            Divider()
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 10)
                    
                    Spacer()
                    
                    createButton(task: task)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }

}
