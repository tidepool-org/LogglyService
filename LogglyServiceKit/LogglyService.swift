//
//  LogglyService.swift
//  LogglyServiceKit
//
//  Created by Darin Krauss on 6/20/19.
//  Copyright © 2019 LoopKit Authors. All rights reserved.
//

import os.log
import LoopKit


public final class LogglyService: Service {

    public static let managerIdentifier = "LogglyService"

    public static let localizedTitle = LocalizedString("Loggly", comment: "The title of the Loggly service")

    public var delegateQueue: DispatchQueue! {
        get {
            return delegate.queue
        }
        set {
            delegate.queue = newValue
        }
    }

    public weak var serviceDelegate: ServiceDelegate? {
        get {
            return delegate.delegate
        }
        set {
            delegate.delegate = newValue
        }
    }

    private let delegate = WeakSynchronizedDelegate<ServiceDelegate>()

    public var customerToken: String?

    private var client: LogglyClient?

    public init() {
        self.customerToken = try? KeychainManager().getLogglyCustomerToken()
        createClient()
    }

    public convenience init?(rawState: RawStateValue) {
        self.init()
    }

    public var rawState: RawStateValue {
        return [:]
    }

    public var hasValidConfiguration: Bool { return customerToken?.isEmpty == false }

    public func notifyCreated(completion: @escaping () -> Void) {
        try! KeychainManager().setLogglyCustomerToken(customerToken)
        createClient()
        notifyDelegateOfCreation(completion: completion)
    }

    public func notifyUpdated(completion: @escaping () -> Void) {
        try! KeychainManager().setLogglyCustomerToken(customerToken)
        createClient()
        notifyDelegateOfUpdation(completion: completion)
    }

    public func notifyDeleted(completion: @escaping () -> Void) {
        try! KeychainManager().setLogglyCustomerToken()
        notifyDelegateOfDeletion(completion: completion)
    }

    private func createClient() {
        if let customerToken = customerToken {
            client = LogglyClient(customerToken: customerToken)
        } else {
            client = nil
        }
    }

}


extension LogglyService {

    public var debugDescription: String {
        return """
        ## LogglyService
        """
    }

}


extension LogglyService: LoggingService {

    public func log (_ message: StaticString, subsystem: String, category: String, type: OSLogType, _ args: [CVarArg]) {

        // TODO: Do we need to redact private variables?

        switch type {
        case .default, .error, .fault:
            let messageWithoutQualifiers = message.description.replacingOccurrences(of: "%{public}", with: "%").replacingOccurrences(of: "%{private}", with: "%")
            let messageWithArguments = String(format: messageWithoutQualifiers, arguments: args)
            client?.send(messageWithArguments, tags: [type.description, subsystem, category])
        default:
            break
        }
    }

}


extension KeychainManager {

    func setLogglyCustomerToken(_ logglyCustomerToken: String? = nil) throws {
        try replaceGenericPassword(logglyCustomerToken, forService: LogglyCustomerTokenService)
    }

    func getLogglyCustomerToken() throws -> String {
        return try getGenericPasswordForService(LogglyCustomerTokenService)
    }

}


fileprivate let LogglyCustomerTokenService = "LogglyCustomerToken"


fileprivate class LogglyClient {

    private let customerToken: String
    private let session: URLSession

    init(customerToken: String) {
        self.customerToken = customerToken
        self.session = URLSession.logglySession()
    }

    func send(_ body: String, tags: [String]) {
        session.inputTask(body: body, customerToken: customerToken, tags: tags)?.resume()
    }

    func send(_ body: [String: Any], tags: [String]) {
        session.inputTask(body: body, customerToken: customerToken, tags: tags)?.resume()
    }

}


fileprivate extension URLSession {

    static func logglySession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.isDiscretionary = true
        configuration.networkServiceType = .background
        configuration.sessionSendsLaunchEvents = false
        return URLSession(configuration: configuration)
    }

    func inputTask(body: String, customerToken: String, tags: [String]) -> URLSessionUploadTask? {
        guard let data = body.data(using: .utf8) else {
            return nil
        }
        return inputTask(body: data, contentType: "text/plain", customerToken: customerToken, tags: tags)
    }

    func inputTask(body: [String: Any], customerToken: String, tags: [String]) -> URLSessionUploadTask? {
        do {
            let data = try JSONSerialization.data(withJSONObject: body, options: [])
            return inputTask(body: data, contentType: "application/json", customerToken: customerToken, tags: tags)
        } catch {
            return nil
        }
    }

    private func inputTask(body: Data, contentType: String, customerToken: String, tags: [String]) -> URLSessionUploadTask? {
        var request = URLRequest(url: url(customerToken: customerToken, tags: tags))
        request.httpMethod = "POST"
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        return uploadTask(with: request, from: body)
    }

    private func url(customerToken: String, tags: [String]) -> URL {
        let tags = tags.isEmpty ? ["http"] : tags
        return URL(string: "https://logs-01.loggly.com/inputs/\(customerToken)/tag/\(tags.joined(separator: ","))/")!
    }

}


extension OSLogType: CustomStringConvertible {

    public var description: String {
        switch self {
        case .info:
            return "info"
        case .debug:
            return "debug"
        case .default:
            return "default"
        case .error:
            return "error"
        case .fault:
            return "fault"
        default:
            return "unknown"
        }
    }

}
