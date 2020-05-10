//
//  LokaliseModels.swift
//  LokaliseGenerator
//
//  Created by Morgan Collino on 4/10/20.
//  Copyright © 2020 Morgan Collino. All rights reserved.
//

import Foundation

// Lokalise JSON models (Structured JSON)

struct Singular: Decodable {
    let notes: String
    let translation: String
}

struct Plural: Decodable {
    let notes: String
    let translation: [String: String]
}
