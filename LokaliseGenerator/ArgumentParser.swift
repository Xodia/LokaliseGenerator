//
//  ArgumentParser.swift
//  LokaliseGenerator
//
//  Created by Morgan Collino on 4/10/20.
//  Copyright © 2020 Morgan Collino. All rights reserved.
//

import Foundation
import Files

private enum ArgumentKeys: String {
    case directory = "directory="
    case outputDirectory = "outputDirectory="
}

struct ArgumentParser {

    func parse(args: [String]) -> (Folder, Folder) {
        var arguments = args
        arguments.remove(at: 0)

        guard arguments.count == 2,
            arguments.first?.contains(ArgumentKeys.directory.rawValue) == true else {
            man()
            exit(-1)
        }

        guard arguments.count == 2,
            arguments[1].contains(ArgumentKeys.outputDirectory.rawValue) == true else {
                man()
                exit(-1)
        }

        let directory = arguments[0].replacingOccurrences(of: ArgumentKeys.directory.rawValue, with: "")
        let outputDirectory = arguments[1].replacingOccurrences(of: ArgumentKeys.outputDirectory.rawValue, with: "")
        guard let inputFolder = folder(for: directory),
            let outputFolder = folder(for: outputDirectory) else {
            man()
            exit(1)
        }

        return (inputFolder, outputFolder)
    }

    func man() {
        LokaliseLogger.log("""

        How to use:
        -----------

        ./LokaliseGenerator directory=<path to input directory> outputDirectory=<path to output directory>

        This script take as input a Structured JSON output from Lokalise. To see an example of it, check the Example directory.
        """)
    }
}

private extension ArgumentParser {

    func folder(for path: String) -> Folder? {
        do {
            if path.starts(with: "/") {
                return try Folder(path: path)
            }
            return try Folder.current.subfolder(at: path)
        } catch {
            return nil
        }
    }
}
