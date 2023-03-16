//
//  ContentView.swift
//  Dates
//
//  Created by Jonni Akesson on 2023-03-16.
//

import SwiftUI

struct ContentView: View {
    @State var currentMonth = 0
    @ObservedObject var vm = ViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(vm.selectedYear)
                            .font(.caption)
                            .fontWeight(.semibold)
                        Text(vm.selectedMonth)
                            .font(.title)
                            .fontWeight(.bold)
                    }
                    Spacer(minLength: 0)
                    
                    Button {
                        currentMonth -= 1
                        vm.createCalendarDates(monthNumber: currentMonth)
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                    }
                    
                    Button {
                        currentMonth += 1
                        vm.createCalendarDates(monthNumber: currentMonth)
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.title2)
                    }
                }
                .padding(.horizontal)
                
                let columns = Array(repeating: GridItem(.flexible()), count: 7)
                LazyVGrid(columns: columns) {
                    ForEach(vm.allWeekdays) { weekday in
                        Text(weekday.title.uppercased())
                            .font(.caption)
                            .fontWeight(.light)
                            .foregroundColor(.secondary)
                    }
                }
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(vm.allDates) { date in
                        Text(date.title)
                            .font(.callout)
                            .foregroundColor(date.currentDate ? .accentColor : .primary)
                            .fontWeight(date.currentDate ? .bold : .light)
                    }
                }
            }
            .padding()
            Spacer()
        }
        .onAppear {
            currentMonth = vm.getCurrentMonthNumber
            vm.createCalendarDates(monthNumber: currentMonth)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
