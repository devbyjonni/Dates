//
//  ViewModel.swift
//  Dates
//
//  Created by Jonni Akesson on 2023-03-16.
//

import Foundation

struct CalendarDate: Identifiable {
    let id = UUID().uuidString
    let date: Date
    let title: String
    let isTodaysDate: Bool
    let completed: Bool
    let offset: Bool
}

struct Weekdays: Identifiable {
    let id = UUID().uuidString
    let title: String
}

struct Task: Identifiable {
    let id = UUID().uuidString
    let title: String
    let completed: Bool
    let date: Date
}

class ViewModel: ObservableObject {
    // Generate an array of 42 dates (6 weeks)
    private let totalDays = 42
    private var firstDayOfSelectedMonth = Date()
    private var todaysDate = Date()
    private var calendar = Calendar(identifier: .gregorian)
    private(set) var allWeekdays = [Weekdays]()
    private(set) var selectedYear = ""
    private(set) var selectedMonth = ""
    
    @Published var allDates = [CalendarDate]()
    @Published var tasks: [Task] = []
    
    init() {
        calendar.locale = .autoupdatingCurrent
        loadSampleData()
    }
    
    var getCurrentMonthNumber: Int {
        calendar.component(.month, from: todaysDate)
    }
    
    private func getYearAndMonth() {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY"
        selectedYear = formatter.string(from: firstDayOfSelectedMonth)
        formatter.dateFormat = "MMM"
        selectedMonth = formatter.string(from: firstDayOfSelectedMonth)
    }
    
    func createCalendarDates(monthNumber: Int) {
        todaysDate = calendar.startOfDay(for: Date.now)
        getFirstDayOfSelectedMonth(monthNumber: monthNumber)
        getYearAndMonth()
        getWeekdaySymbols()
        
        let data = loadMonthCalendar(from: firstDayOfSelectedMonth)
        let offset = data.offsets
        var numberOneDidShow = 0
        var postset = false
        let calendarDates = data.dates.enumerated().compactMap { (index, date) in
            let day = calendar.component(.day, from: date)
            
            // Set postset to true when the first day of the next month is found
            if day == 1 {
                numberOneDidShow += 1
                if numberOneDidShow == 2 {
                    postset = true
                }
            }
            
            // Get the associated task for the current date
            let task = sampleTasks.first { task in
                isSameDate(date1: task.date , date2: date)
            }
            
            // Determine if the date is within the valid offset range
            let isValidOffset = index <= offset || postset

            return CalendarDate(date: date, title: "\(day)", isTodaysDate: isSameDate(date1: date, date2: todaysDate), completed: task?.completed ?? false, offset: isValidOffset)
        }
        allDates = calendarDates
    }
    
    private func getFirstDayOfSelectedMonth(monthNumber: Int) {
        let currentYear = calendar.component(.year, from: todaysDate)
        var startDateComponents = DateComponents()
        startDateComponents.year = currentYear
        startDateComponents.month = monthNumber
        startDateComponents.day = 1
        firstDayOfSelectedMonth = calendar.date(from: startDateComponents)!
    }
    
    private func loadMonthCalendar(from date: Date) -> (dates: [Date], offsets: Int) {
        let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
        let firstWeekdayOfMonth = calendar.component(.weekday, from: firstDayOfMonth)
        let offset = (firstWeekdayOfMonth - calendar.firstWeekday + 7) % 7
        let offsetDate = calendar.date(byAdding: .day, value: -offset, to: firstDayOfMonth)!
        let dates = (0..<totalDays).compactMap { calendar.date(byAdding: .day, value: $0, to: offsetDate) }
        
        return (dates, offset)
    }
    
    private func isSameDate(date1: Date, date2: Date) -> Bool {
        calendar.isDate(date1, inSameDayAs: date2)
    }
    
    private func getCurrentLocale() {
        // Get the user's current locale
        let currentLocale = Locale.autoupdatingCurrent
        // Print the locale identifier
        print("Locale identifier:", currentLocale.identifier)
    }
    
    private func getWeekdaySymbols() {
        // Initialize a DateFormatter
        let dateFormatter = DateFormatter()
        
        // Set the locale to the user's current locale
        dateFormatter.locale = Locale.autoupdatingCurrent
        
        // Get the abbreviated weekday names
        let abbreviatedWeekdaySymbols = dateFormatter.shortWeekdaySymbols
        
        // Find the index of Sunday
        let sundayIndex = (dateFormatter.calendar.firstWeekday + 5) % 7
        
        // Reorder the array to start with Monday
        let part1 = abbreviatedWeekdaySymbols![sundayIndex + 1..<abbreviatedWeekdaySymbols!.count]
        let part2 = abbreviatedWeekdaySymbols![0...sundayIndex]
        let weekdays = Array(part1) + Array(part2)
        
        allWeekdays = weekdays.compactMap { Weekdays(title: $0) }
    }
    
    private func loadTwoWeekCalendar(from date: Date) -> [Date] {
        let firstDayOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date))!
        let oneWeekAgo = calendar.date(byAdding: .weekOfYear, value: -1, to: firstDayOfWeek)!
        
        // Generate an array of 14 dates (2 weeks) starting from one week ago
        let dates = (0..<14).compactMap {
            calendar.date(byAdding: .day, value: $0, to: oneWeekAgo)
        }
        
        return dates
    }
    
    // Sample data
    func loadTasks(date: Date) {
        var tempTasks = [Task]()
        for task in sampleTasks {
            if isSameDate(date1: task.date , date2: date) {
                tempTasks.append(task)
            }
        }
        tasks = tempTasks
    }
    private var sampleTasks: [Task] = []
    private func loadSampleData() {
        sampleTasks = [
            Task(title: "Task 1", completed: true, date: todaysDate),
            Task(title: "Task 2", completed: true, date: todaysDate),
            Task(title: "Task 3", completed: true, date: todaysDate),
            Task(title: "Task 4", completed: true, date: todaysDate),
            Task(title: "Task 5", completed: true, date: todaysDate),
            Task(title: "Task 6", completed: true, date: todaysDate),
            Task(title: "Task 7", completed: true, date: todaysDate),
            
            Task(title: "Task 1", completed: true, date: getSampleData(offset: -1)),
            Task(title: "Task 2", completed: true, date: getSampleData(offset: -1)),
            Task(title: "Task 3", completed: true, date: getSampleData(offset: -1)),
            
            Task(title: "Task 1", completed: true, date: getSampleData(offset: -3)),
            Task(title: "Task 1", completed: true, date: getSampleData(offset: -4)),
            Task(title: "Task 1", completed: true, date: getSampleData(offset: -17))
        ]
    }
    
    private func getSampleData(offset: Int) -> Date {
        let date = calendar.date(byAdding: .day, value: offset, to: Date())
        return date ?? Date()
    }
}
