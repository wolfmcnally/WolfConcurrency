//
//  Canceler.swift
//  WolfConcurrency
//
//  Created by Wolf McNally on 6/17/16.
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

public protocol Cancelable: class {
    var isCanceled: Bool { get }
    func cancel()
}

// A block that takes a Canceler. The block will not be called again if it sets the <isCanceled> variable of the Canceler to true.
public typealias CancelableBlock = (Cancelable) -> Void

// A Canceler is returned by that either execute a block asyncronously once or at intervals. If the <isCanceled> variable is set to true, the block will never be executed, or the calling of the block at intervals will stop.
public class Canceler: Cancelable {
    public init() { }
    public var isCanceled = false
    public func cancel() { isCanceled = true }
}
