//
//  Event.swift
//  WolfConcurrency
//
//  Created by Wolf McNally on 11/15/17.
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
import WolfFoundation

public class Event<T> {
    public typealias ValueType = T
    private var observers = Set<Observer>()

    public init() { }

    public class Observer: Hashable, Invalidatable {
        public typealias FuncType = (ValueType) -> Void
        private let id = UUID()
        public let closure: FuncType
        weak var event: Event?

        public init(event: Event, closure: @escaping FuncType) {
            self.event = event
            self.closure = closure
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }

        public static func == (lhs: Observer, rhs: Observer) -> Bool {
            return lhs.id == rhs.id
        }

        public func invalidate() {
            event?.remove(observer: self)
        }

        deinit {
            invalidate()
        }
    }

    public func add(observerFunc: @escaping Observer.FuncType) -> Observer {
        let observer = Observer(event: self, closure: observerFunc)
        observers.insert(observer)
        return observer
    }

    public func remove(observer: Observer?) {
        guard let observer = observer else { return }
        observers.remove(observer)
    }

    public func notify(_ value: ValueType) {
        for observer in observers {
            observer.closure(value)
        }
    }

    public var isEmpty: Bool {
        return observers.isEmpty
    }
}
