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

    let parser = Parser()

    func run(directory: Folder) {
        let name = directory.name.replacingOccurrences(of: "-locale", with: "")
        print("Parent directory name: \(name)")
        var cache: [String: [Language]] = [:]

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

        let submodules = cache.compactMap { (key: String, value: [Language]) -> Submodule in
            return Submodule(name: key, language: value)
        }
        let module = Module(name: name, submodules: submodules)
        let environment = stencilEnvironment()
        let context = Context()

        Cerberus(environment: environment, templates: [
            (Templates.strings.rawValue, context.context(for: Templates.strings))
        ]).export(outputDirectory: directory, module: module)
    }

    func stencilEnvironment() -> Environment {
        let extensions = StencilExtension.ext
        let loader = FileSystemLoader(paths: [Path(Bundle.main.bundlePath)])
        return Environment(loader: loader, extensions: [extensions])
    }
}

private extension LokaliseGenerator {

    
}
