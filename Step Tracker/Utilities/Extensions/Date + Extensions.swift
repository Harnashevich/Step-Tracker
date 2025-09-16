//
//  Date + Extensions.swift
//  Step Tracker
//
//  Created by Andrei Harnashevich on 25.07.25.
//

import Foundation

extension Date {
    var weekdayInt: Int {
        Calendar.current.component(.weekday, from: self)
    }

    var weekdayTitle: String {
        self.formatted(.dateTime.weekday(.wide))
    }

    var accesibilityDate: String {
        self.formatted(.dateTime.month(.wide).day())
    }
}

