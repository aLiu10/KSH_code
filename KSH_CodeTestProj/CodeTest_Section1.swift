//
//  CodeTest_Section1.swift
//  KSH_CodeTestProj
//
//  Created by lyl on 2024/2/7.
//

import Foundation


/*
 Given an array of meeting time intervals consisting of start and end times‬
 ‭ [[s1,e1],[s2,e2],...]‬‭ (‬‭ si‬‭
 <
 ‬‭ ei‬‭ ), please provide a function with implementation by Swift/Kotlin‬
 ‭ to determine if a person could attend all meetings.‬
 ‭ For example,‬
 ‭ Input‬‭ : intervals = [[0,30], [5,10], [15,20]]‬‭ Output‬‭ : false‬
 ‭ Explanation‬‭ : The person cannot attend all meetings because there is an overlap between‬‭ [0,30]‬
 ‭ and‬‭ [5,10]‬‭ , and between‬‭ [0,30]‬‭ and‬‭ [15,20]‬‭ .‬
 ‭ Input‬‭ : intervals = [ [7,10], [2,4]]‬‭ Output‬‭ : true‬
 ‭ Explanation‬‭ : The person can attend all meetings because there is no overlap between‬‭ [7,10]‬
 ‭ and‬‭ [2,4]‬‭ .‬
 ‭ Input‬‭ : intervals = [ [1,5], [8,9], [8,10]]‬‭ Output‬‭ : false‬
 ‭ Explanation‬‭ : The person cannot attend all meetings because there is an overlap between‬‭ [8,9]‬
 ‭ and‬‭ [8,10].
 */

class MyCodeTest{
    static let shared = MyCodeTest()
    
    private init() {
        let intervals1 = [[0,30], [5,10], [15,20]]
        print(canAttendAllMeetings(intervals1)) // 输出: false

        let intervals2 = [[7,10], [2,4]]
        print(canAttendAllMeetings(intervals2)) // 输出: true

        let intervals3 = [[1,5], [8,9], [8,10]]
        print(canAttendAllMeetings(intervals3)) // 输出: false
    }
    
    func canAttendAllMeetings(_ intervals: [[Int]]) -> Bool {
        guard intervals.count > 1 else {
            return true
        }
        //按数组内时间先后排序
        let sortedIntervals = intervals.sorted { $0[0] < $1[0] }
        //记录当前会议结束时间
        var lastEndTime = sortedIntervals[0][1]
        for i in 1..<sortedIntervals.count {
            //如果开始时间早于(小于)记录的时间 则重叠
            if sortedIntervals[i][0] < lastEndTime {
                return false
            }
            lastEndTime = max(lastEndTime, sortedIntervals[i][1])
        }
        return true
    }
}


