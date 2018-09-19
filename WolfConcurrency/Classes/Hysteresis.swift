//
//  Hysteresis.swift
//  WolfConcurrency
//
//  Created by Wolf McNally on 12/15/15.
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

/**
 
 hys·ter·e·sis
 ˌhistəˈrēsis/
 noun
 Physics
 
 noun: hysteresis
 the phenomenon in which the value of a physical property lags behind changes in the effect causing it, as for instance when magnetic induction lags behind the magnetizing force.
 
 **/

public class Hysteresis {
    private let useMainQueue: Bool
    public var startLag: TimeInterval
    public var endLag: TimeInterval
    private let onStart: Block
    private let onEnd: Block
    private var startCanceler: Cancelable?
    private var endCanceler: Cancelable?
    private var isStarted: Bool = false

    private lazy var locker = Locker(
        useMainQueue: self.useMainQueue,
        onLocked: { [unowned self] in self.startEffectLagged() },
        onUnlocked: { [unowned self] in self.endEffectLagged() }
    )

    /// It is *not* guaranteed that `onStart` and `onEnd` will be called on the main queue.
    public init(useMainQueue: Bool = true, onStart: @escaping Block, onEnd: @escaping Block, startLag: TimeInterval, endLag: TimeInterval) {
        self.useMainQueue = useMainQueue
        self.onStart = onStart
        self.onEnd = onEnd
        self.startLag = startLag
        self.endLag = endLag
    }

    public func newCause() -> LockerCause {
        return locker.newCause()
    }

    private func startEffectLagged() {
        endCanceler?.cancel()
        let queue = useMainQueue ? mainQueue : backgroundQueue
        startCanceler = dispatchOnQueue(queue, afterDelay: startLag) {
            if !self.isStarted {
                self.onStart()
                self.isStarted = true
            }
        }
    }

    private func endEffectLagged() {
        startCanceler?.cancel()
        let queue = useMainQueue ? mainQueue : backgroundQueue
        endCanceler = dispatchOnQueue(queue, afterDelay: endLag) {
            if self.isStarted {
                self.onEnd()
                self.isStarted = false
            }
        }
    }

    public func startCause() {
        locker.lock()
    }

    public func endCause() {
        locker.unlock()
    }
}
