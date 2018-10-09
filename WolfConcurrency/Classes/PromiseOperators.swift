//
//  PromiseOperators.swift
//  WolfConcurrency
//
//  Created by Wolf McNally on 10/3/18.
//

import Foundation
import WolfPipe
import WolfFoundation

precedencegroup SequencePrecedence {
    associativity: left
    higherThan: PipeBackwardPrecedence
}

precedencegroup SimultaneousPrecedence {
    associativity: left
    higherThan: SequencePrecedence
}

/// Runs the promise.
///
/// Single-argument function suitable for use with the Pipe operators.
@discardableResult public func run<T>(_ promise: Promise<T>) -> Promise<T> {
    promise.run()
    return promise
}


// Then-Operator
infix operator ||> : SequencePrecedence

public func ||> <T, U>(lhs: Promise<T>, rhs: @escaping (T) throws -> U) -> Promise<U> {
    return lhs.thenWithValue(with: rhs)
}

public func ||> <T, U>(lhs: Promise<T>, rhs: Promise<U>) -> Promise<U> {
    return Promise<U> { (uPromise: Promise<U>) in
        lhs.runTransforming(to: uPromise) { (uPromise2, _) in
            rhs.runTransforming(to: uPromise2) { (uPromise3, uValue3) in
                uPromise3.keep(uValue3)
            }
        }
    }
}

// Then-With-Promise-Operator
infix operator ||% : SequencePrecedence

public func ||% <T, U>(lhs: Promise<T>, rhs: @escaping (_ tPromise: Promise<T>) throws -> U) -> Promise<U> {
    return lhs.thenWithPromise(rhs)
}


// Simultaneous-Operator
infix operator ||| : SimultaneousPrecedence

public func ||| <A, B>(lhs: Promise<A>, rhs: Promise<B>) -> SuccessPromise {
    return SuccessPromise { (uPromise: SuccessPromise) in
        var lhsDone = false
        var rhsDone = false
        func done() {
            if lhsDone && rhsDone {
                uPromise.keep()
            }
        }

        lhs.runTransforming(to: uPromise) { (_, _) in
            lhsDone = true
            done()
        }

        rhs.runTransforming(to: uPromise) { (_, _) in
            rhsDone = true
            done()
        }
    }
}


// Catch-Operator
infix operator ||! : SequencePrecedence

public func ||! <T>(lhs: Promise<T>, rhs: @escaping ErrorBlock) -> Promise<T> {
    return lhs.catch(with: rhs)
}


// Recover-Operator
infix operator ||? : SequencePrecedence

public func ||? <T>(lhs: Promise<T>, rhs: @escaping (Error, Promise<T>) -> Void) -> Promise<T> {
    return lhs.recover(with: rhs)
}


// Finally-Operator
infix operator ||* : SequencePrecedence

public func ||* <T>(lhs: Promise<T>, rhs: @escaping Block) -> Promise<T> {
    return lhs.finally(with: rhs)
}
