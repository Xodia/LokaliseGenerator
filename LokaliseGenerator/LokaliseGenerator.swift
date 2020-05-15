//
//  LokaliseGenerator.swift
//  LokaliseGenerator
//
//  Created by Morgan Collino on 4/10/20.
//  Copyright © 2020 Morgan Collino. All rights reserved.
//

import Foundation
import Cerberus
import CerberusCore
import Files
import Stencil
import PathKit

struct LokaliseGenerator {

    enum LanguageExtension: String {
        case lproj = ".lproj"
    }

    let parser = LokaliseParser()

    func run(directory: Folder) {
        let module = readDirectory(directory)
        let environment = stencilEnvironment()
        let context = Context()

        Cerberus(environment: environment, templates: [
            ((Templates.strings.rawValue, .eachLanguage(extension: LanguageExtension.lproj.rawValue)), context.context(for: Templates.strings)),
            ((Templates.stringsDict.rawValue, .eachLanguage(extension: LanguageExtension.lproj.rawValue)), context.context(for: Templates.stringsDict)),
            ((Templates.swiftCodeGeneration.rawValue, .once), context.context(for: Templates.swiftCodeGeneration)),
            ((Templates.xml.rawValue, .eachLanguage(extension: nil)), context.context(for: Templates.xml))
        ]).export(outputDirectory: directory, module: module)
    }
}

// Environment Set up
private extension LokaliseGenerator {

    func stencilEnvironment() -> Environment {
        let extensions = StencilExtension.ext
        let loader = FileSystemLoader(paths: [Path(Bundle.main.bundlePath)])
        return Environment(loader: loader, extensions: [extensions])
    }
}

// Parsing
private extension LokaliseGenerator {

    func readDirectory(_ directory: Folder) -> Module {
        var cache: [String: [Language]] = [:]

        parseFiles(directory, cache: &cache)
        return generateModule(directory, cache: cache)
    }

    func parseFiles(_ directory: Folder, cache: inout [String: [Language]]) {
        directory.subfolders.forEach { (languageFolder) in
            let languageFiles = languageFolder.files.filter { $0.extension == "json" }
            languageFiles.forEach { (file) in
                guard let fileData = try? file.read() else {
                    return
                }
                let copies = parser.parseJSON(data: fileData)
                let language = Language(identifier: languageFolder.name, copy: copies, array: [])
                if var cachedValue = cache[file.nameExcludingExtension] {
                    cachedValue.append(language)
                    cache[file.nameExcludingExtension] = cachedValue
                } else {
                    cache[file.nameExcludingExtension] = [language]
                }
            }
        }
    }

    func generateModule(_ directory: Folder, cache: [String: [Language]]) -> Module {
        let name = directory.name.replacingOccurrences(of: "-locale", with: "")
        let submodules = cache.compactMap { (key: String, value: [Language]) -> Submodule in
            return Submodule(name: key, language: value)
        }

        let module = Module(name: name, submodules: submodules)
        return module
    }
}
