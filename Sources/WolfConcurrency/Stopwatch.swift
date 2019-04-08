//
//  Stopwatch.swift
//  WolfConcurrency
//
//  Created by Wolf McNally on 6/15/17.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import Foundation

public class Stopwatch {
    public private(set) var startTime: Date?
    public private(set) var stopTime: Date?

    public init() { }

    public func start() {
        startTime = Date()
        stopTime = nil
    }

    public func stop() {
        stopTime = Date()
        if startTime == nil { startTime = stopTime }
    }

    public var elapsedTime: TimeInterval? {
        guard let startTime = startTime else { return nil }
        let stopTime = self.stopTime ?? Date()
        return stopTime.timeIntervalSince(startTime)
    }

    public func after(_ timeInterval: TimeInterval, perform block: Block) {
        if elapsedTime! > timeInterval {
            block()
        }
    }

    public func every(_ timeInterval: TimeInterval, perform block: Block) {
        if elapsedTime! > timeInterval {
            block()
            start()
        }
    }
}
