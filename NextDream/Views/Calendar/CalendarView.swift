import SwiftUI
import FSCalendar
import SwiftData

struct CalendarView: View {
    
    @Environment(TaskViewModel.self) var vm;
    
    // Calendar
    @State private var tasksForSelectedDate: [TaskModel] = []
    @State private var selectedDate: Date = Date()
    @State var currentPage: Date = Date()
    @State private var isPresented: Bool = false;
    
    var body: some View {
        
        @Bindable var vm = vm;
        
        VStack {
            
            FSCalendarView(tasks: $vm.task, selectedDate: $selectedDate, tasksForSelectedDate: $tasksForSelectedDate, currentPage: $currentPage)
                .frame(height: 300)
                .onChange(of: selectedDate) {
                    updateTasksForSelectedDate()
                }
            
            Text("Selected Date: \(formattedDate(selectedDate))")
                .font(.headline)
                .padding()
            
            showTaskDetails()
        }
        .padding()
        .sheet(isPresented: $isPresented, content: {
            EventSelectionView()
                .presentationDetents([.fraction(0.4), .medium, .large])
        })
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                
                Button {
                    isPresented.toggle()
                } label: {
                    Image(systemName: "calendar.badge.plus")
                }
            }
        }
        .onAppear {
            updateTasksForSelectedDate()
        }
        .onChange(of: currentPage) {
            createMonthTask()
        }
    }
    
    func createMonthTask(){
        guard let startDate = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: currentPage)) else { return }
        
        guard let endDate = Calendar.current.date(byAdding: .month, value: 1, to: startDate) else { return }
        
        vm.fetchTaskByInterval(startDate: startDate, endDate: endDate)
        
    }
}

#Preview {
    NavigationStack{
        CalendarView()
            .environment(TaskViewModel())
    }
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
    
    func showTaskDetails() -> some View{
        Group{
            if !tasksForSelectedDate.isEmpty {
                createScrollView()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            } else {
                Text("No tasks for this day")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
    }
    
    func createScrollView() -> some View{
        ScrollView {
            ForEach(tasksForSelectedDate, id: \.self) { task in
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

//MARK: Functions

extension CalendarView{
    func updateTasksForSelectedDate() {
        
        createMonthTask()
        tasksForSelectedDate = vm.task.filter { Calendar.current.isDate($0.deadline, inSameDayAs: selectedDate) }
    }
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
