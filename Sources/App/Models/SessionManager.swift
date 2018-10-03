//
//  SessionManager.swift
//  App
//
//  Created by Will McGinty on 10/3/18.
//

import Foundation
import Vapor

class SessionManager {
    
    static let shared = SessionManager()
    
    private(set) var sessions: LockedDictionary<Session, [WebSocket]> = [:]
    
    func createSession(for request: Request) -> Future<Session> {
        return sessionKey(for: request).flatMap { [unowned self] key in
            let session = Session(id: key)
            guard self.sessions[session] == nil else {
                return self.createSession(for: request)
            }
            
            self.sessions[session] = []
            return request.future(session)
        }
    }
    
    func update(_ location: Location, for session: Session) {
        guard let listeners = sessions[session] else { return }
        
        listeners.forEach { $0.sendEncodable(location) }
    }
    
    func close(_ session: Session) {
        sessions[session]?.forEach { $0.close() }
        sessions[session] = nil
    }
    
    func add(listener: WebSocket, to session: Session) {
        guard var listeners = sessions[session] else { return }
        listeners.append(listener)
        sessions[session] = listeners
        
        listener.onClose.always { [weak self, weak listener] in
            guard let listener = listener else { return }
            self?.remove(listener: listener, from: session)
        }
    }
    
    func remove(listener: WebSocket, from session: Session) {
        guard let listeners = sessions[session] else { return }
        let newListeners = listeners.filter { $0 !== listener }
        sessions[session] = newListeners
    }
}

private extension SessionManager {
    
    var characters: [String] { return "a b c d e f g h i j k l m n o p q r s t u v w x y z".components(separatedBy: " ") }
    
    func sessionKey(for request: Request) -> Future<String> {
        let key = (characters.random ?? "") + (characters.random ?? "") + (characters.random ?? "")
        return request.future(key)
    }
}

struct Session: Content, Parameter, Hashable {
    let id: String
    
    static func resolveParameter(_ parameter: String, on container: Container) throws -> Session {
        return .init(id: parameter)
    }
}
