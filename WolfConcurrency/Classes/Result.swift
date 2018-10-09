//
//  Result.swift
//  WolfConcurrency
//
//  Created by Wolf McNally on 3/17/16.
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

import WolfFoundation

/// Classes that represent process results must conform to this protocol.
public protocol ResultSummary {
    /// Returns true if the process completed successfully; false otherwise.
    var isSuccess: Bool { get }

    /// Returns true if the process was cancelled; false otherwise.
    var isCanceled: Bool { get }

    /// Returns a human-readable error message, or `nil` if none was provided.
    var message: String? { get }

    /// Returns a numeric error code, or `nil` if none was provided.
    var code: Int? { get }

    /// Returns a non-user-facing indentifier used for automated UI testing
    var identifier: String? { get }

    /// Returns the error object
    var error: Error? { get }
}

/// Represents a process result with a specific type returned upon success.
///
///   * On success it is associated with a generic, process-dependent type.
///   * On failure it is associated with an Error.
///   * Aborted means there was no error, but the original process should not take action associated with success or failure.
///   * Canceled means the original process should not be called back at all.
public enum Result<T>: ResultSummary {
    case success(T)
    case failure(Error)
    case aborted
    case canceled

    /// Returns true if the process completed successfully; false otherwise.
    public var isSuccess: Bool {
        switch self {
        case .success:
            return true
        default:
            return false
        }
    }

    public var isFailure: Bool {
        switch self {
        case .failure:
            return true
        default:
            return false
        }
    }

    public var isAborted: Bool {
        switch self {
        case .aborted:
            return true
        default:
            return false
        }
    }

    public var isCanceled: Bool {
        switch self {
        case .canceled:
            return true
        default:
            return false
        }
    }

    /// Returns a human-readable error message, or `nil` if none was provided.
    public var message: String? {
        switch self {
        case .failure(let error as DescriptiveError):
            return error.message
        default:
            return nil
        }
    }

    /// Returns a numeric error code, or `nil` if none was provided.
    public var code: Int? {
        switch self {
        case .failure(let error as DescriptiveError):
            return error.code
        default:
            return nil
        }
    }

    /// Returns a non-user-facing indentifier used for automated UI testing
    public var identifier: String? {
        switch self {
        case .failure(let error as DescriptiveError):
            return error.identifier
        default:
            return nil
        }
    }

    /// Returns the error object
    public var error: Error? {
        switch self {
        case .failure(let error):
            return error
        default:
            return nil
        }
    }
}
