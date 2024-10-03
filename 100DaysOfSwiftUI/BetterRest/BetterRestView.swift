//
//  BetterRestView.swift
//  100DaysOfSwiftUI
//
//  Created by hlwan on 28/9/2024.
//

import SwiftUI
import CoreML

struct BetterRestView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    private static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }

    private var alertMessage: String {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let seconds = (components.hour ?? 0) * 60 * 60 + (components.minute ?? 0) * 60
            let prediction = try model.prediction(wake: Double(seconds), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            let sleepTime = wakeUp - prediction.actualSleep
            return sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            return "Sorry, there was a problem calculating your bedtime."
        }
    }
    
    var body: some View {
        Form {
            Section("When do you want to wake up?") {
                DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                    .datePickerStyle(WheelDatePickerStyle())
            }

            Section("Desired amount of sleep") {
                Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
            }
            
            Section("Daily coffee intake") {
                Picker("^[\(coffeeAmount) cup](inflect: true)", selection: $coffeeAmount) {
                    ForEach(Array(1...20), id: \.self) {
                        Text("^[\($0) cup](inflect: true)").tag($0)
                    }
                }
            }
            
            VStack(alignment: .leading) {
                Text("Your ideal bedtime is…")
                    .font(.headline)
                    .foregroundColor(.secondary)
                Text(alertMessage)
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
        }
        .navigationTitle("BetterRest")
    }
}

#Preview {
    NavigationStack {
        BetterRestView()
    }
}
