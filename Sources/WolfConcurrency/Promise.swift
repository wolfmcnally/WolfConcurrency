//
//  Promise.swift
//  WolfConcurrency
//
//  Created by Wolf McNally on 4/26/17.
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

//import Foundation
//import WolfNumerics
//import WolfFoundation
//
///// A promise that returns no value (actually `Void`) when it succeeds.
//public typealias SuccessPromise = Promise<Void>
//
///// A promise that returns a `Data` when it succeeds.
//public typealias DataPromise = Promise<Data>
//
///// A typed asynchonous task including a placeholder result value.
//public class Promise<T>: Cancelable, CustomStringConvertible {
//    public typealias `Self` = Promise<T>
//    public typealias ValueType = T
//    public typealias ResultType = Result<T, AnyError>
//
//    /// A block that executes the core functionality of the promise.
//    ///
//    /// At some point the `RunBlock` must execute one of the methods on
//    /// the promise that signals completion: `keep()`, `fail()`,
//    /// `abort()`, or `cancel()`, which set the promise's `result`
//    /// attribute and then executes the promise's `DoneBlock`.
//    ///
//    /// - parameters:
//    ///   - promise: The promise that is running.
//    public typealias RunBlock = (_ promise: Self) -> Void
//
//    /// A block that executes after the `RunBlock` of the promise.
//    ///
//    /// - parameters:
//    ///   - promise: The promise that just ran.
//    public typealias DoneBlock = (_ promise: Self) -> Void
//
//    /// A user-definable auxilliary task that must conform to `Cancelable`.
//    ///
//    /// For example, URLSessionTask has a `cancel()` method, so it can be
//    /// extended to conform to `Cancelable`.
//    public var task: Cancelable?
//
//    private var onRun: RunBlock!
//    private var onDone: DoneBlock!
//
//    /// The result of the promise being run.
//    public private(set) var result: ResultType?
//
//    /// The value returned by the successful promise.
//    ///
//    /// `nil` if the promise has not completed.
//    /// Traps if accessed when the result was not successful.
//    public var value: ValueType? {
//        switch result {
//        case nil:
//            return nil
//        case .value(let value)?:
//            return value
//        default:
//            fatalError("Invalid value: \(self).")
//        }
//    }
//
//    /// Creates an instance of a promise.
//    ///
//    /// - parameters:
//    ///   - task: An optional auxillary task, which is user-defined except
//    ///           that it must conform to `Cancelable`.
//    ///   - onRun: A block to execute when the promise runs.
//    public init(task: Cancelable? = nil, with onRun: @escaping RunBlock) {
//        self.task = task
//        self.onRun = onRun
//    }
//    // Example:
//    //
//    //   let promise = Promise<Int> { me in
//    //     print("I'm running.")
//    //     me.keep(2)
//    //   }
//    //
//
//    /// Creates an instance of a promise that always fails with the given error.
//    ///
//    /// - parameters:
//    ///   - error: The error that the promise will fail with when ran.
//    public convenience init(error: Error) {
//        self.init {
//            $0.fail(error)
//        }
//    }
//
//    /// Runs the promise, then the given `onDone` block.
//    ///
//    /// A promise may only be run once. Traps on an attempt to run the promise again.
//    ///
//    /// - parameters:
//    ///   - onDone: The block to execute after the promise finishes running.
//    ///
//    /// - returns: The original promise, which may be ignored.
//    @discardableResult func run(with onDone: @escaping DoneBlock) -> Self {
//        assert(self.onDone == nil)
//        self.onDone = onDone
//        onRun(self)
//        onRun = { _ in
//            fatalError("ran")
//        }
//        return self
//    }
//
//    /// Runs the promise.
//    ///
//    /// A promise may only be run once. Traps on an attempt to run the promise again.
//    ///
//    /// - returns: The original promise, which may be ignored.
//    @discardableResult func run() -> Self {
//        return run { _ in }
//    }
//
//    /// Transforms this promise to another dependent promise of a different value type.
//    ///
//    /// Takes a new promise of a different type (`uPromise`), runs this promise (`tPromise`),
//    /// and if successful calls the `success` block with `uPromise` and `tPromise`'s
//    /// result value. If `tPromise` fails, is aborted, or is canceled, then `uPromise`
//    /// likewise fails, is aborted, or is canceled.
//    ///
//    /// - parameters:
//    ///   - uPromise: The promise that will depend on this promise's outcome.
//    ///   - success: The block to call when this promise succeeds.
//    ///   - uPromise2: The promise the depends on the success value of this promise.
//    ///   - tPromiseValue: The success value of this promise.
//    ///
//    /// - returns: The dependent promise.
//    @discardableResult func runTransforming<U>(to uPromise: Promise<U>, with success: @escaping (_ uPromise2: Promise<U>, _ tPromiseValue: ValueType) -> Void) -> Promise<U> {
//        run { tPromise in
//            switch tPromise.result! {
//            case .value(let tValue):
//                success(uPromise, tValue)
//            case .error(let anyError):
//                let error = anyError.error
//                switch error {
//                case is Aborted:
//                    uPromise.abort()
//                case is Canceled:
//                    uPromise.cancel()
//                default:
//                    uPromise.fail(anyError)
//                }
//            }
//        }
//        return uPromise
//    }
//
//    /// Chains this promise to a dependent promise.
//    ///
//    /// Takes a block that transforms this promise's success value to the dependent promise's success value.
//    /// This block may throw, which results in the dependent promise failing.
//    ///
//    /// - parameters:
//    ///   - success: The block to call when this promise succeeds.
//    ///   - tValue: The success value of this promise.
//    ///
//    /// - returns: The dependent promise.
//    func thenWithValue<U>(with success: @escaping (_ tValue: ValueType) throws -> U) -> Promise<U> {
//        return Promise<U> { (uPromise: Promise<U>) in
//            self.runTransforming(to: uPromise) { (uPromise2, tValue) in
//                do {
//                    let uValue = try success(tValue)
//                    uPromise2.keep(uValue)
//                } catch let error {
//                    uPromise2.fail(error)
//                }
//            }
//        }
//    }
//
//    /// Chains this promise to a dependent `SuccessPromise`.
//    ///
//    /// Takes a block that performs an action. The block may throw, which results
//    /// in the dependent `SuccessPromise` failing.
//    ///
//    /// - parameters:
//    ///   - success: The block to call when this promise succeeds.
//    ///
//    /// - returns: The dependent `SuccessPromise`.
//    func then(with success: @escaping () throws -> Void) -> SuccessPromise {
//        return SuccessPromise { (uPromise: SuccessPromise) in
//            self.runTransforming(to: uPromise) { (uPromise2, tValue) in
//                do {
//                    try success()
//                    uPromise2.keep()
//                } catch {
//                    uPromise2.fail(error)
//                }
//            }
//        }
//    }
//
//    func then(with success: @escaping (SuccessPromise) -> Void) -> SuccessPromise {
//        return SuccessPromise { (uPromise: SuccessPromise) in
//            self.runTransforming(to: uPromise) { (uPromise2, tValue) in
//                success(uPromise2)
//            }
//        }
//    }
//
//    /// Chains this promise to a SuccessPromise, effectively ignoring
//    /// this promise's success value.
//    ///
//    /// - returns: A dependent `SuccessPromise`.
//    @discardableResult public func succeed() -> SuccessPromise {
//        return then { }
//    }
//
//    /// Chains this promise to a dependent promise.
//    ///
//    /// Takes a block that transforms this promise to the dependent promise's success value.
//    /// This block may throw, which results in the dependent promise failing.
//    ///
//    /// - parameters:
//    ///   - success: The block to call when this promise succeeds.
//    ///   - tPromise: This promise.
//    ///
//    /// - returns: The dependent promise.
//    func thenWithPromise<U>(_ success: @escaping (_ tPromise: Promise<T>) throws -> U) -> Promise<U> {
//        return Promise<U> { (uPromise: Promise<U>) in
//            self.runTransforming(to: uPromise) { (uPromise2, _) in
//                do {
//                    let uValue = try success(self)
//                    uPromise2.keep(uValue)
//                } catch let error {
//                    uPromise2.fail(error)
//                }
//            }
//        }
//    }
//
//    /// Chains this promise to a dependent promise.
//    ///
//    /// Takes a block that transforms this promise's success value to the dependent promise.
//    /// When this promise succeeds, the block is run, and then the dependent promise it returns is run.
//    ///
//    /// - parameters:
//    ///   - success: The block to call when this promise succeeds.
//    ///   - tValue: This promise's success value.
//    ///
//    /// - returns: The dependent promise.
//    func thenWithValueToPromise<U>(with success: @escaping (_ tValue: ValueType) -> Promise<U>) -> Promise<U> {
//        return Promise<U> { (uPromise: Promise<U>) in
//            self.runTransforming(to: uPromise) { (uPromise2, tValue2) in
//                success(tValue2).runTransforming(to: uPromise2) { (uPromise3, uValue) in
//                    uPromise3.keep(uValue)
//                }
//            }
//        }
//    }
//
//    /// Chains this promise to a block that runs when the promise fails,
//    func `catch`(with failure: @escaping ErrorBlock) -> Promise<T> {
//        return Promise<T> { (catchPromise: Promise<T>) in
//            self.run { throwPromise in
//                switch throwPromise.result! {
//                case .value(let value):
//                    catchPromise.keep(value)
//                case .error(let anyError):
//                    let error = anyError.error
//                    switch error {
//                    case is Aborted:
//                        catchPromise.abort()
//                    case is Canceled:
//                        catchPromise.cancel()
//                    default:
//                        catchPromise.fail(error)
//                        failure(error)
//                    }
//                }
//            }
//        }
//    }
//
//    func recover(with failing: @escaping (Error, Promise<T>) -> Void) -> Promise<T> {
//        return Promise<T> { (recoverPromise: Promise<T>) in
//            self.run { failingPromise in
//                switch failingPromise.result! {
//                case .value(let value):
//                    recoverPromise.keep(value)
//                case .error(let anyError):
//                    let error = anyError.error
//                    switch error {
//                    case is Aborted:
//                        recoverPromise.abort()
//                    case is Canceled:
//                        recoverPromise.cancel()
//                    default:
//                        failing(error, recoverPromise)
//                    }
//                }
//            }
//        }
//    }
//
//    func finally(with block: @escaping Block) -> Promise<T> {
//        return Promise<T> { (finallyPromise: Promise<T>) in
//            self.run { finishedPromise in
//                switch finishedPromise.result! {
//                case .value(let value):
//                    finallyPromise.keep(value)
//                    block()
//                case .error(let anyError):
//                    let error = anyError.error
//                    switch error {
//                    case is Aborted:
//                        finallyPromise.abort()
//                        block()
//                    case is Canceled:
//                        finallyPromise.cancel()
//                    default:
//                        finallyPromise.fail(error)
//                        block()
//                    }
//                }
//            }
//        }
//    }
//
//    private func done(_ result: ResultType) {
//        guard self.result == nil else { return }
//        self.result = result
//        onDone(self)
//        onDone = Self.doneTwice
//        task?.cancel()
//        task = nil
//    }
//
//    private static func doneTwice(_ promise: Promise<T>) {
//        fatalError("done twice")
//    }
//
//    public func keep(_ value: ValueType) {
//        done(.value(value))
//    }
//
//    public func fail(_ error: Error) {
//        done(.error(AnyError(error)))
//    }
//
//    public func abort() {
//        done(.error(AnyError(aborted)))
//    }
//
//    public func cancel() {
//        done(.error(AnyError(canceled)))
//    }
//
//    public var isCanceled: Bool {
//        return result?.isCanceled ?? false
//    }
//
//    public var description: String {
//        return "Promise(\(result†))"
//    }
//}
//
//extension Promise where T == Void {
//    public func keep() {
//        done(.value(()))
//    }
//}
