#if os(iOS)
import SwiftUI
import FSCalendar

struct FSCalendarView: UIViewRepresentable {
    @Binding var tasks: [TaskModel]
    @Binding var selectedDate: Date
    @Binding var tasksForSelectedDate: [TaskModel]
    @Binding var currentPage: Date
    @Environment(\.colorScheme) var colorScheme
    
    func makeUIView(context: Context) -> FSCalendar {
        let calendar = FSCalendar()
        calendar.delegate = context.coordinator
        calendar.dataSource = context.coordinator
        calendar.scrollDirection = .horizontal
        calendar.appearance.headerTitleColor = .blue
        calendar.appearance.weekdayTextColor = .red
        calendar.appearance.titleDefaultColor = colorScheme == .dark ? UIColor.white : UIColor.black
        calendar.firstWeekday = 1
        
        // Set initial scope to Month
        calendar.setScope(.month, animated: true)
        
        return calendar
    }

    func updateUIView(_ uiView: FSCalendar, context: Context) {
        uiView.reloadData()
    }


    func makeCoordinator() -> Coordinator {
        return Coordinator(tasks: $tasks, selectedDate: $selectedDate, tasksForSelectedDate: $tasksForSelectedDate, currentPage: $currentPage)
    }
    

    class Coordinator: NSObject, FSCalendarDelegate, FSCalendarDataSource {
        @Binding var tasks: [TaskModel]
        @Binding var selectedDate: Date
        @Binding var tasksForSelectedDate: [TaskModel]
        @Binding var currentPage: Date  // 👈 new binding

        init(tasks: Binding<[TaskModel]>, selectedDate: Binding<Date>, tasksForSelectedDate: Binding<[TaskModel]>, currentPage: Binding<Date>) {
            _tasks = tasks
            _selectedDate = selectedDate
            _tasksForSelectedDate = tasksForSelectedDate
            _currentPage = currentPage
        }
        
        func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
            
            let newPage = calendar.currentPage
            currentPage = newPage
            
            guard let endDate = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: newPage)) else { return }
            
            guard var startDate = Calendar.current.date(byAdding: .month, value: 0, to: endDate) else { return }
            startDate = Calendar.current.startOfDay(for: startDate)
            
        }
        
        func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
            return tasks.filter { Calendar.current.isDate($0.deadline, inSameDayAs: date) }.count
        }


        func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
            selectedDate = date
            tasksForSelectedDate = tasks.filter { Calendar.current.isDate($0.deadline, inSameDayAs: date) }
        }


        func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {

            if tasks.contains(where: { Calendar.current.isDate($0.deadline, inSameDayAs: date) }) {
                return .blue
            }
            return nil
        }
    }
}
#endif
