//
//  Contexts.swift
//  LokaliseGenerator
//
//  Created by Morgan Collino on 4/10/20.
//  Copyright © 2020 Morgan Collino. All rights reserved.
//

import Foundation
import CerberusCore

struct Context {

    func context(for template: Templates) -> ((Module, Submodule, Language) -> (String, [String: Any])) {
        switch template {
        case .strings:
            return stringsContext(module:submodule:language:)
        case .stringsDict:
            return stringsDictContext(module:submodule:language:)
        case .swiftCodeGeneration:
            return codeContext(module:submodule:language:)
        case .xml:
            return androidContext(module:submodule:language:)
        default:
            return defaultContext(module:submodule:language:)
        }
    }
}

extension Context {

    func defaultContext(module: Module, submodule: Submodule, language: Language) -> (String, [String: Any]) {
        return ("", [:])
    }
}
