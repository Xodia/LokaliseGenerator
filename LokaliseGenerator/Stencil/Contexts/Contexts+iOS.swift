//
//  Contexts+iOS.swift
//  LokaliseGenerator
//
//  Created by Morgan Collino on 4/11/20.
//  Copyright © 2020 Morgan Collino. All rights reserved.
//

import Foundation
import CerberusCore

// iOS Contexts

// MARK: - .strings Context
extension Context {

    func stringsContext(module: Module, submodule: Submodule, language: Language) -> (String, [String: Any]) {
        let filename = [module.name, submodule.name].compactMap({ $0.capitalizingFirstLetter() }).joined()
        let fileName = "\(filename).strings"
        let singles = language.copy.filter { $0.isSingle }
        let plurals = language.copy.filter({ $0.isPlural || $0.isInterpolated }).compactMap { stringsFormatCopy(copy: $0) }
        let context = _stringsContext(singles: singles, formats: plurals, moduleName: module.name, submoduleName: submodule.name, fileName: fileName)
        return (fileName, context)
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

    func stringsFormatCopy(copy: Copy) -> Copy {
        let formattedCopy = stringsFormat(copy)
        let value = Value(value: formattedCopy, parameters: copy.value.parameters)
        return Copy(key: copy.key, value: value)
    }

    private func stringsFormat(_ copy: Copy) -> String {
        var value = copy.value.value
        copy.value.parameters?.enumerated().forEach({ (index, parameter) in
            value = value.replacingOccurrences(of: "__\(parameter.name)__", with: "%\(index + 1)$\(ParameterType.string.iOS)")
        })
        return value
    }
}

// MARK: - .stringsDict Context

extension Context {

    func stringsDictContext(module: Module, submodule: Submodule, language: Language) -> (String, [String: Any]) {
        let filename = [module.name, submodule.name].compactMap({ $0.capitalizingFirstLetter() }).joined()
        let fileName = "\(filename).stringsdict"
        let formats = language.copy.filter({ $0.isPlural || $0.isInterpolatedPlural }).compactMap({ pluralFormat(copy: $0) }).flatMap({ $0 })
        let context = _stringsDictContext(formats: formats, moduleName: module.name, submoduleName: submodule.name, fileName: fileName)
        return (fileName, context)
    }

    func _stringsDictContext(formats: [Format], moduleName: String, submoduleName: String, fileName: String) -> [String: Any] {
        let formats = formats.compactMap({ $0.asDictionary() })

        return [
            "formats": formats,
            "module_name": moduleName,
            "submodule_name": submoduleName,
            "file_name": fileName,
        ]
    }

    func pluralFormat(copy: Copy) -> [Format] {
        guard let formats = copy.value.parameters?.compactMap({ (parameter) -> Format? in
            guard !parameter.variants.isEmpty else {
                return nil
            }
            let variants = parameter.variants.compactMap {
                Variant(variant: variantFormat(variant: $0, parameterName: parameter.name, type: parameter.type), qualifier: $0.qualifier)
            }

            let parentFormat = copyFormat(parameters: copy.value.parameters ?? [], format: copy.value.value)
            let format = Format(parent: copy.key, parentFormat: parentFormat, key: parameter.name, type: parameter.type.iOS, variants: variants)
            return format
        }) else {
            return []
        }

        return formats
    }

    func variantFormat(variant: Variant, parameterName: String, type: ParameterType) -> String {
        let parameterKey: String = "__\(parameterName)__"
        let parameterReplacement: String = "%\(type.iOS)"
        return variant.variant.replacingOccurrences(of: parameterKey, with: parameterReplacement)
    }

    func copyFormat(parameters: [Parameter], format: String) -> String {
        var format = format

        parameters.forEach { (parameter) in
            let parameterKey: String = "__\(parameter.name)__"
            let parameterReplacement: String = "%\(parameter.type.iOS)"
            format = format.replacingOccurrences(of: parameterKey, with: parameterReplacement)
        }
        return format
    }
}
