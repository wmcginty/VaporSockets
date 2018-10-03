//
//  WebSockets.swift
//  App
//
//  Created by Will McGinty on 10/2/18.
//

import Foundation
import Vapor

struct WebSocketRouter {
    
    func boot(socketServer: NIOWebSocketServer) {
        
        socketServer.get("listen", Session.parameter) { socket, req in
            let session = try req.parameters.next(Session.self)
            guard SessionManager.shared.sessions[session] != nil else {
                socket.close()
                return
            }
            
            SessionManager.shared.add(listener: socket, to: session)
        }
        
        socketServer.get("echo") { socket, req in
            debugPrint("Socket connected")
            
            socket.onText { socket, text in
                debugPrint("Echoing - \(text)")
                socket.send("echo - \(text)")
            }
        }
    }
}
