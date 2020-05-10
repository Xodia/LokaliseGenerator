//
//  StencilExtension.swift
//  LokaliseGenerator
//
//  Created by Morgan Collino on 4/10/20.
//  Copyright © 2020 Morgan Collino. All rights reserved.
//

import Foundation
import Stencil
import CerberusCore

struct StencilExtension {

    enum Name: String {
        case camelcase
        case pascalcase
        case parameterTypeiOS
        case parameterTypeAndroid
        case replace
        case escape
    }

    static var ext: Extension {
        let ext = Extension()

        ext.registerFilter(Name.camelcase.rawValue) { (value: Any?) in
            guard let string = value as? String else {
                return value
            }

            return camelCase(string: string)
        }

        ext.registerFilter(Name.pascalcase.rawValue) { (value: Any?) in
            guard let string = value as? String else {
                return value
            }

            return pascalCase(string: string)
        }

        ext.registerFilter(Name.replace.rawValue) { (value: Any?, parameters: [Any]?) in
            guard let string = value as? String, let pattern = parameters?.first as? String, let template = parameters?.last as? String else {
                return value
            }

            return replace(string: string, pattern: pattern, template: template)
        }

        ext.registerFilter(Name.parameterTypeiOS.rawValue) { (value) -> Any? in
            guard let string = value as? String else {
                return value
            }

            return parameterTypeiOS(string: string)
        }

        ext.registerFilter(Name.escape.rawValue) { (value) -> Any? in
            guard let string = value as? String else {
                return value
            }
            return escaped(string: string)
        }

        return ext
    }

    static func camelCase(string: String) -> String {
        let split = string.split(separator: "_")
        let result = split.enumerated().compactMap { (index, string) -> String? in
            if index == 0 {
                return String(string)
            }
            return String(string).capitalized
        }
        return result.joined()
    }

    static func pascalCase(string: String) -> String {
        let split = string.split(separator: "_")
        let result = split.enumerated().compactMap { (index, string) -> String? in
            return String(string).capitalized
        }
        return result.joined()
    }

    static func replace(string: String, pattern: String, template: String) -> String {
        let value: NSMutableString = NSMutableString(string: string)
        let regex = try? NSRegularExpression(pattern: pattern)
        regex?.replaceMatches(in: value, options: .reportProgress, range: NSRange(location: 0,length: value.length), withTemplate: template)

        return value as String
    }

    static func parameterTypeiOS(string: String) -> String {
        switch string {
        case ParameterType.integer.rawValue:
            return ParameterType.integer.iOSType
        case ParameterType.float.rawValue:
            return ParameterType.float.iOSType
        case ParameterType.string.rawValue:
            return ParameterType.string.iOSType
        default:
            return "undefined"
        }
    }

    static func escaped(string: String) -> String {
        return string
            .replacingOccurrences(of: "'", with: "\\'")
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: "?", with: "\\?")
            .replacingOccurrences(of: "@", with: "\\@")
            .replacingOccurrences(of: "\"", with: "\\\"")
    }

}
