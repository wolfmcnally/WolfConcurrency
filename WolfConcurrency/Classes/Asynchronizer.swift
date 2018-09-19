//
//  Asynchronizer.swift
//  WolfConcurrency
//
//  Created by Wolf McNally on 5/31/17.
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
import WolfLog
import WolfFoundation

extension LogGroup {
    public static let asynchronizer = LogGroup("asynchronizer")
}

public class Asynchronizer {
    public let name: String?
    private let delay: TimeInterval
    private let onSync: Block
    private var canceler: Cancelable?

    public init(name: String? = nil, delay: TimeInterval = 0.5, onSync: @escaping Block) {
        self.name = name
        self.delay = delay
        self.onSync = onSync
    }

    public func setNeedsSync() {
        logTrace("setNeedsSync", obj: self, group: .asynchronizer)
        _cancel()
        canceler = dispatchOnMain(afterDelay: delay) {
            self.sync()
        }
    }

    private func _cancel() {
        guard canceler != nil else { return }
        canceler?.cancel()
        canceler = nil
    }

    public func cancel() {
        logTrace("cancel", obj: self, group: .asynchronizer)
        _cancel()
    }

    public func syncIfNeeded() {
        logTrace("syncIfNeeded", obj: self, group: .asynchronizer)
        guard canceler != nil else { return }
        sync()
    }

    public func sync() {
        logTrace("sync", obj: self, group: .asynchronizer)
        _cancel()
        onSync()
    }

    deinit {
        _cancel()
    }
}

extension Asynchronizer: CustomStringConvertible {
    public var description: String {
        let s = ["Asynchronizer", name].flatJoined(separator: " ")
        return s
    }
}
