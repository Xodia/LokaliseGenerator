//
//  Parser.swift
//  LokaliseGenerator
//
//  Created by Morgan Collino on 4/10/20.
//  Copyright © 2020 Morgan Collino. All rights reserved.
//

import Foundation
import CerberusCore

struct LokaliseParser {

    let jsonDecoder = JSONDecoder()

    init() {

    }

    func parseJSON(data: Data) -> [Copy] {
        var copies: [Copy] = []

        let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        jsonObject?.forEach({ (key, value) in
            let valueDictionary = value as? [String: Any]
            let jsonData: Data = {
                if let data = try? JSONSerialization.data(withJSONObject: valueDictionary ?? [:], options: .prettyPrinted) {
                    return data
                }
                return Data()
            }()

            if let singular = try? jsonDecoder.decode(Singular.self, from: jsonData) {
                let output = parseParameters(from: singular.translation)
                let value = Value(value: output.0, parameters: output.1)
                let copy = Copy(key: key, value: value)
                copies.append(copy)
            } else if let plural = try? jsonDecoder.decode(Plural.self, from: jsonData) {
                let parameters = parsePlural(dictionary: plural.translation)
                let value = Value(value: "__value__", parameters: parameters)
                let copy = Copy(key: key, value: value)
                copies.append(copy)
            }
        })
        return copies
    }

    func parseParameter(from parameterString: String) -> Parameter {
        var buffer = parameterString
        buffer.removeFirst()

        let lastChar = buffer.last ?? "s"
        buffer.removeLast() // Remove s/d/f
        buffer.removeLast() // Remove $
        let index = Int(buffer) ?? 1

        return Parameter(name: "parameter\(index)", type: parseParameterType(from: lastChar), variants: [])
    }

    func parseParameters(from string: String) -> (String, [Parameter]) {
        var parsedString = string
        let regex = try! NSRegularExpression(pattern: "%[0-9]\\$[a-z]")
        var buffer: [Parameter] = []

        let matches = regex.matches(in: string, options: [], range: NSRange(location: 0, length: string.count) )
        matches.forEach { (result) in
            let parsedMatchedString = (string as NSString)
                .substring(with: result.range)
            let parameter = parseParameter(from: parsedMatchedString)
            parsedString = parsedString.replacingOccurrences(of: parsedMatchedString, with: "__\(parameter.name)__")
            buffer.append(parameter)
        }
        return (parsedString, buffer)
    }

    func parsePlural(dictionary: [String: String]) -> [Parameter] {
        var variants: [Variant] = []
        dictionary.enumerated().forEach { (index, arg1) in
            let (key, value) = arg1
            let variant = Variant(variant: value, qualifier: QualifierType.init(rawValue: key) ?? .other)
            variants.append(variant)
        }
        let param = Parameter(name: "value", type: .integer, variants: variants)
        return [param]
    }

    func parseParameterType(from character: Character) -> ParameterType {
        switch character {
        case "s":
            return .string
        case "d":
            return .integer
        case "f":
            return .float
        default:
            return .string
        }
    }
}
