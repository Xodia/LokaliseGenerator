//
//  Logger.swift
//  LokaliseGenerator
//
//  Created by Morgan Collino on 5/10/20.
//  Copyright © 2020 Morgan Collino. All rights reserved.
//

import Foundation
import Logging

struct LokaliseLogger {

    static let logger = Logger(label: "com.example.LokaliseGenerator")

    static func log(_ info: String) {
        logger.info("\(info)")
    }
}
