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
        default:
            return defaultContext(module:submodule:language:)
        }
    }
}

private extension Context {

    func stringsContext(module: Module, submodule: Submodule, language: Language) -> (String, [String: Any]) {
        let filename = [module.name, submodule.name].compactMap({ $0.capitalizingFirstLetter() }).joined()
        let fileName = "\(filename).strings"
        let singles = language.copy.filter { $0.isSingle }
        let plurals = language.copy.filter({ $0.isPlural || $0.isInterpolated }).compactMap { formatCopy(copy: $0) }
        let context = _stringsContext(singles: singles, formats: plurals, moduleName: module.name, submoduleName: submodule.name, fileName: fileName)
        return (fileNlame, context)
    }

    func _stringsContext(singles: [Copy], formats: [Copy], moduleName: String, submoduleName: String, fileName: String) -> [String: Any] {
        let singles = singles.compactMap { $0.asDictionary() }
        let formats = formats.compactMap({ $0.asDictionary() })

        return [
            "singles": singles,
            "formats": formats,
            "module_name": moduleName,
            "submodule_name": submoduleName,
            "file_name": fileName
        ]
    }

    func formatCopy(copy: Copy) -> Copy {
        let formattedCopy = format(copy)
        let value = Value(value: formattedCopy, parameters: copy.value.parameters)
        return Copy(key: copy.key, value: value)
    }

    private func format(_ copy: Copy) -> String {
        var value = copy.value.value
        copy.value.parameters?.enumerated().forEach({ (index, parameter) in
            value = value.replacingOccurrences(of: "__\(parameter.name)__", with: "%\(index + 1)$\(ParameterType.string.iOS)")
        })
        return value
    }

    func defaultContext(module: Module, submodule: Submodule, language: Language) -> (String, [String: Any]) {
        return ("", [:])
    }
}
