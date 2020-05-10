//
//  Contexts+CodeGeneration.swift
//  LokaliseGenerator
//
//  Created by Morgan Collino on 4/11/20.
//  Copyright © 2020 Morgan Collino. All rights reserved.
//

import Foundation
import CerberusCore

// MARK: - generated code

extension Context {

    func codeContext(module: Module, submodule: Submodule, language: Language) -> (String, [String: Any]) {
        let fileName = "\(module.name.capitalizingFirstLetter())\(submodule.name.capitalizingFirstLetter()).swift"

        let copies = language.copy.compactMap { codeCopyFormat(copy: $0) }
        let context = _codeContext(copies: copies, arrays: language.array, moduleName: module.name, submoduleName: submodule.name, fileName: fileName)
        return (fileName, context)
    }

    struct Subkey: Codable {
        let name: String
        let isPascal: Bool
    }

    func _codeContext(copies: [Copy], arrays: [CopyArray], moduleName: String, submoduleName: String, fileName: String) -> [String: Any] {
        let arrays = arrays.compactMap { $0.asDictionary() }

        let keys = Array(Set(copies.compactMap { $0.key }))
        let subkeys = Array(Set(copies.compactMap { $0.value.parameters?.compactMap({ $0.name }) }.flatMap({ $0 }))).compactMap({
            Subkey(name: $0, isPascal:  $0.contains("_")) })
        let singles = copies.compactMap { $0.asDictionary() }
        let formats = copies.filter({ $0.isPlural }).compactMap { $0.asDictionary() }

        return [
            "copy": singles,
            "formats": formats,
            "array": arrays,
            "module_name": moduleName,
            "submodule_name": submoduleName,
            "file_name": fileName,
            "keys": keys,
            "subkeys": subkeys
        ]
    }

    func codeCopyFormat(copy: Copy) -> Copy {
        let currentValue = copy.value
        let val: String = {
            var currentVal = currentValue.value
            currentValue.parameters?.forEach({ (parameter) in
                currentVal = currentVal.replacingOccurrences(of: "__\(parameter.name)__", with: "{{\(parameter.name)}}")
            })
            currentVal = currentVal.replacingOccurrences(of: "\n", with: "\\n")
            return currentVal
        }()
        let parameters = parametersFormat(parameters: currentValue.parameters ?? [])
        let value = Value(value: val, parameters: parameters)
        return Copy(key: copy.key, value: value)
    }

    func parametersFormat(parameters: [Parameter]) -> [Parameter] {
        return parameters.compactMap { (parameter) -> Parameter in
            let variants = variantsFormat(parentName: parameter.name, variants: parameter.variants)
            let newParamter = Parameter(name: parameter.name, type: parameter.type, variants: variants)
            return newParamter
        }
    }

    func variantsFormat(parentName: String, variants: [Variant]) -> [Variant] {
        let doesntContainOneButContainOther: Bool = {
            let hasOne = variants.filter({ $0.qualifier == .one }).count > 0
            let hasOther = variants.filter({ $0.qualifier == .other }).count > 0 || variants.filter({ $0.qualifier == .many }).count > 0

            return !hasOne && hasOther
        }()

        var newVariants = variants.compactMap { (variant) -> Variant in
            Variant(variant: variant.variant.replacingOccurrences(of: "__\(parentName)__", with: "{{count}}"), qualifier: variant.qualifier)
        }

        if doesntContainOneButContainOther {
            guard let variant = newVariants.first(where: { (variant) -> Bool in
                variant.qualifier == .many || variant.qualifier == .other
            }) else {
                return newVariants
            }

            let oneVariant = Variant(variant: variant.variant, qualifier: .one)
            newVariants.append(oneVariant)
        }
        return newVariants
    }
}
