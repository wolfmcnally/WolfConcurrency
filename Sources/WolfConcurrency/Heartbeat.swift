//
//  Heartbeat.swift
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

// To send heartbeats:
//
// After a connection, instantiate a Heartbeat object and call reset().
// After a disconnect, call cancel() or destroy the Heartbeat object.
// Every time you send a non-heartbeat packet, call reset().
// When expired() is called, send a heartbeat packet and call reset().

// To listen for heartbeats:
//
// After a connection, instantiate a Heartbeat object and call reset().
// After a disconnect, call cancel() or destroy the Heartbeat object.
// The interval of a listener Heartbeat should be longer than the interval of the sender Heartbeat to allow for latency.
// Every time you receive a packet, call reset().
// When expired() is called, you've lost the heartbeat, so disconnect. If you're the client, attempt to reconnect.

public class Heartbeat {
    public var interval: TimeInterval
    public var expired: Block
    private var canceler: Cancelable?

    public init(interval: TimeInterval, expired: @escaping Block) {
        self.interval = interval
        self.expired = expired
    }

    deinit {
        cancel()
    }

    public func cancel() {
        canceler?.cancel()
        canceler = nil
    }

    public func reset() {
        cancel()
        canceler = dispatchOnMain(afterDelay: interval) { [unowned self] in
            self.expired()
        }
    }
}
