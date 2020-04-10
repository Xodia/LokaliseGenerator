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
}

struct ArgumentParser {

    func parse(args: [String]) -> Folder {
        var arguments = args
        arguments.remove(at: 0)

        guard arguments.count == 1,
            arguments.first?.contains(ArgumentKeys.directory.rawValue) == true else {
            man()
            exit(-1)
        }

        let directory = arguments[0].replacingOccurrences(of: ArgumentKeys.directory.rawValue, with: "")
        guard let parentFolder = folder(for: directory) else {
            man()
            exit(1)
        }

        return parentFolder
    }

    func man() {
        print("man really")
    }

    func folder(for path: String) -> Folder? {
        do {
            if path.starts(with: "/") {
                return try Folder(path: path)
            }

            return try Folder.current.subfolder(at: path)
        } catch {
            print(error)
            return nil
        }
    }

}
