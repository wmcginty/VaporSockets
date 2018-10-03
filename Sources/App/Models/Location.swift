//
//  Location.swift
//  App
//
//  Created by Will McGinty on 10/3/18.
//

import Foundation
import Vapor

struct Location: Content {
    let identifier: UUID
    let latitude: Float
    let longitude: Float
}
