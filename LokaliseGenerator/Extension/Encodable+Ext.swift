//
//  Encodable+Ext.swift
//  LokaliseGenerator
//
//  Created by Morgan Collino on 4/10/20.
//  Copyright © 2020 Morgan Collino. All rights reserved.
//

import Foundation

extension Encodable {

    func asDictionary() -> [String: Any] {
        do {
            guard let data = try? JSONEncoder().encode(self),
                let dictionary = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String: Any] else {
                    LokaliseLogger.log("Couldn't encode \(self) to JSON dictionary.")
                    return [:]
            }
            return dictionary
        } catch {
            return [:]
        }
    }
}
