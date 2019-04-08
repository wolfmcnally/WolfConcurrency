//
//  Serializer.swift
//  WolfConcurrency
//
//  Created by Wolf McNally on 12/9/15.
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

import Dispatch

private typealias SerializerKey = DispatchSpecificKey<Int>
private let serializerKey = SerializerKey()
private var nextQueueContext: Int = 1

public class Serializer {
    let queue: DispatchQueue
    let queueContext: Int

    public init(label: String? = nil) {
        let label = label ?? String(nextQueueContext)
        queue = DispatchQueue(label: label, attributes: [])
        queueContext = nextQueueContext
        queue.setSpecific(key: serializerKey, value: queueContext)
        nextQueueContext += 1
    }

    var isExecutingOnMyQueue: Bool {
        guard let context = DispatchQueue.getSpecific(key: serializerKey) else { return false }
        return context == queueContext
    }

    public func dispatch(f: Block) {
        if isExecutingOnMyQueue {
            f()
        } else {
            queue.sync(execute: f)
        }
    }

    public func dispatchWithReturn<T>(f: () -> T) -> T {
        var result: T!

        if isExecutingOnMyQueue {
            result = f()
        } else {
            queue.sync {
                result = f()
            }
        }

        return result!
    }
}
