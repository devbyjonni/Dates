//
//  ViewModel.swift
//  Dates
//
//  Created by Jonni Akesson on 2023-03-16.
//

import Foundation

struct CalendarDate: Identifiable {
    let id = UUID().uuidString
    let title: String
    let currentDate: Bool
}

struct Weekdays: Identifiable {
    let id = UUID().uuidString
    let title: String
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
    
    init() {
        calendar.locale = .autoupdatingCurrent
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
        todaysDate = Date.now
        getFirstDayOfSelectedMonth(monthNumber: monthNumber)
        getYearAndMonth()
        getWeekdaySymbols()
        
        let dates = loadMonthCalendar(from: firstDayOfSelectedMonth)
        
        let calendarDates = dates.compactMap { date in
            let day = calendar.component(.day, from: date)
            return CalendarDate(title: "\(day)", currentDate: isSameDate(date1: date, date2: todaysDate))
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
    
    private func loadMonthCalendar(from date: Date) -> [Date] {
        let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
        let firstWeekdayOfMonth = calendar.component(.weekday, from: firstDayOfMonth)
        let offset = (firstWeekdayOfMonth - calendar.firstWeekday + 7) % 7
        let offsetDate = calendar.date(byAdding: .day, value: -offset, to: firstDayOfMonth)!
        let dates = (0..<totalDays).compactMap { calendar.date(byAdding: .day, value: $0, to: offsetDate) }
        
        return dates
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
}
