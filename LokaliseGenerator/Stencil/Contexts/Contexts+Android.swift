//
//  Contexts+Android.swift
//  LokaliseGenerator
//
//  Created by Morgan Collino on 4/11/20.
//  Copyright © 2020 Morgan Collino. All rights reserved.
//

import Foundation
import CerberusCore

// MARK: - generated code

extension Context {

    func androidContext(module: Module, submodule: Submodule, language: Language) -> (String, [String: Any]) {
        let fileName = "\(module.name.lowercased())_\(submodule.name.lowercased())_resources.xml"
        let copy = language.copy.filter({ !$0.isPlural }).compactMap({ androidFormatCopy(copy: $0) }).compactMap({ $0 })
        let formats = language.copy.filter({ $0.isPlural }).compactMap({ androidPluralFormat(copy: $0) }).flatMap({ $0 })

        let context = _androidXMLContext(copies: copy, formats: formats, arrays: language.array, moduleName: module.name, submoduleName: submodule.name, fileName: fileName)
        return (fileName, context)
    }

    func _androidXMLContext(copies: [Copy], formats: [Format], arrays: [CopyArray], moduleName: String, submoduleName: String, fileName: String) -> [String: Any] {
        let filtered = filterAndroid(copies: copies, formats: formats)

        let copies = filtered.copies.compactMap { $0.asDictionary() }
        let arrays = arrays.compactMap { $0.asDictionary() }
        let formats = filtered.formats.compactMap({ $0.asDictionary() })

        return [
            "copy": copies,
            "formats": formats,
            "array": arrays,
            "module_name": moduleName,
            "submodule_name": submoduleName,
            "file_name": fileName
        ]
    }

    func filterAndroid(copies: [Copy], formats: [Format]) -> (copies: [Copy], formats: [Format]) {
        var mutableCopies = copies
        var mutableFormats = formats

        mutableFormats = formats.compactMap { (format) -> Format in
            var mutableVariants = format.variants
            if let zeroIndex = format.variants.firstIndex(where: { (variant) -> Bool in
                return variant.qualifier == .zero
            }) {
                let zeroVariant = format.variants[zeroIndex]
                let zeroCopy = Copy(key: format.parent + "_" + format.key + "_" + zeroVariant.qualifier.rawValue, value: Value(value: zeroVariant.variant, parameters: nil))
                mutableCopies.append(zeroCopy)
                mutableVariants.remove(at: zeroIndex)
            }
            return Format(parent: format.parent, parentFormat: format.parentFormat, key: format.key, type: format.type, variants: mutableVariants)
        }
        return (mutableCopies, mutableFormats)
    }
}

extension Context {

    func androidPluralFormat(copy: Copy) -> [Format] {
        var formatAlreadyDoneForCopy: [String: String] = [:]

        guard let formats = copy.value.parameters?.compactMap({ (parameter) -> Format? in
            guard !parameter.variants.isEmpty else {
                // Avoid duplication of format copies
                guard formatAlreadyDoneForCopy[copy.key] == nil else {
                    return nil
                }

                formatAlreadyDoneForCopy[copy.key] = copy.key
                let parentFormat = copyFormat(parameters: copy.value.parameters ?? [], format: copy.value.value)
                return Format(parent: copy.key, parentFormat: parentFormat, key: parameter.name, type: parameter.type.rawValue, variants: [])
            }
            var variants = parameter.variants.compactMap { element in
                Variant(variant: variantFormat(variant: element, parameterName: parameter.name, type: parameter.type), qualifier: element.qualifier)
            }

            if variants.first(where: { $0.qualifier == .one }) == nil, let otherOrMany = variants.first(where: { $0.qualifier == .other || $0.qualifier == .many }) {
                let one = Variant(variant: otherOrMany.variant, qualifier: .one)
                variants.append(one)
            }

            let parentFormat = copyFormat(parameters: copy.value.parameters ?? [], format: copy.value.value)
            let format = Format(parent: copy.key, parentFormat: parentFormat, key: parameter.name, type: parameter.type.rawValue, variants: variants)
            return format
        }) else {
            return []
        }

        return formats
    }

    func androidFormatCopy(copy: Copy) -> Copy {
        let formattedCopy = androidFormat(copy)
        let value = Value(value: formattedCopy, parameters: copy.value.parameters)
        return Copy(key: copy.key, value: value)
    }

    func androidFormat(_ copy: Copy) -> String {
        var value = copy.value.value
        copy.value.parameters?.enumerated().forEach({ (index, parameter) in
            value = value.replacingOccurrences(of: "__\(parameter.name)__", with: "%\(index + 1)$\(parameter.type.android)")
        })
        return value
    }

    func androidVariantFormat(variant: Variant, parameterName: String, type: ParameterType) -> String {
        let parameterKey: String = "__\(parameterName)__"
        let parameterReplacement: String = "%1$\(type.android)"
        return variant.variant.replacingOccurrences(of: parameterKey, with: parameterReplacement)
    }

    func androidCopyFormat(parameters: [Parameter], format: String) -> String {
        var format = format

        parameters.enumerated().forEach { (index, parameter) in
            let parameterKey: String = "__\(parameter.name)__"
            let parameterReplacement: String = "%\(index + 1)$\(parameter.type.android)"
            format = format.replacingOccurrences(of: parameterKey, with: parameterReplacement)
        }
        return format
    }
}

