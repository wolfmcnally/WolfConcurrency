//
//  Locker.swift
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

public class LockerCause {
    private weak var locker: Locker?

    init(locker: Locker) {
        self.locker = locker
        locker.lock()
    }

    deinit {
        locker?.unlock()
    }
}

public class Locker {
    private var count = 0
    private var serializer: Serializer?
    private lazy var reasonCauses = [String: LockerCause]()

    public var onLocked: Block?
    public var onUnlocked: Block?
    public typealias ChangedBlock = (Locker) -> Void
    public var onChanged: ChangedBlock?
    public var onReasonsChanged: ChangedBlock?

    public init(useMainQueue: Bool = true, onLocked: Block? = nil, onUnlocked: Block? = nil, onChanged: ChangedBlock? = nil, onReasonsChanged: ChangedBlock? = nil) {
        self.onLocked = onLocked
        self.onUnlocked = onUnlocked
        self.onChanged = onChanged
        self.onReasonsChanged = onReasonsChanged
        if !useMainQueue {
            serializer = Serializer(label: "\(self)")
        }
    }

    public var isLocked: Bool {
        return count > 0
    }

    public func newCause() -> LockerCause {
        return LockerCause(locker: self)
    }

    public var reasons: [String] {
        return Array(reasonCauses.keys)
    }

    public subscript(reason: String) -> Bool {
        get {
            return reasonCauses[reason] != nil
        }

        set {
            if newValue {
                guard reasonCauses[reason] == nil else { return }
                reasonCauses[reason] = newCause()
                onReasonsChanged?(self)
            } else {
                guard reasonCauses.removeValue(forKey: reason) != nil else { return }
                onReasonsChanged?(self)
            }
        }
    }

    private func _lock() {
        count += 1
        if count == 1 {
            onLocked?()
        }
        onChanged?(self)
    }

    private func _unlock() {
        assert(count > 0)
        count -= 1
        if count == 0 {
            onUnlocked?()
        }
        onChanged?(self)
    }

    public func lock() {
        if let serializer = serializer {
            serializer.dispatch {
                self._lock()
            }
        } else {
            dispatchOnMain {
                self._lock()
            }
        }
    }

    public func unlock() {
        if let serializer = serializer {
            serializer.dispatch {
                self._unlock()
            }
        } else {
            dispatchOnMain {
                self._unlock()
            }
        }
    }
}
