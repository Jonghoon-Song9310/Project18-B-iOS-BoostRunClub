//
//  ActivityFilterType.swift
//  BoostRunClub
//
//  Created by 김신우 on 2020/12/07.
//

import Foundation

enum ActivityFilterType: Int {
    case week, month, year, all

    func groupDateRanges(from dates: [Date]) -> [DateRange] {
        guard !dates.isEmpty else { return [] }

        if self == .all {
            return [DateRange(start: dates.first!, end: dates.last ?? dates.first!)]
        }

        var results = [DateRange]()
        dates.forEach {
            if
                results.isEmpty,
                let range = $0.rangeOf(type: self)
            {
                results.append(range)
            } else if
                let lastRange = results.last,
                !lastRange.contains(date: $0),
                let newRange = $0.rangeOfWeek
            {
                results.append(newRange)
            }
        }
        return results
    }

    func rangeDescription(from range: DateRange) -> String {
        switch self {
        case .week:
            return range.start.toMDString + "~" + range.end.toMDString
        case .month:
            return range.end.toYMString
        case .year:
            return range.end.toYString
        case .all:
            let from = range.start.toYString
            let end = range.end.toYString
            return from == end ? end : from + "-" + end
        }
    }
}