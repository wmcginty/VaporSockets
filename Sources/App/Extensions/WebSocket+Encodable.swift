//
//  WebSocket+Encodable.swift
//  App
//
//  Created by Will McGinty on 10/3/18.
//

import Foundation
import Vapor

extension WebSocket {
    
    func sendEncodable<T: Encodable>(_ element: T, with encoder: JSONEncoder = JSONEncoder()) {
        guard let data = try? encoder.encode(element) else { return }
        send(data)
    }
}
