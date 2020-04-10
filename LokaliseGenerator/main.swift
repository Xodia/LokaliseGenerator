//
//  main.swift
//  LokaliseGenerator
//
//  Created by Morgan Collino on 4/2/20.
//  Copyright © 2020 Morgan Collino. All rights reserved.
//

import Foundation
import Files

let argumentParser = ArgumentParser()
let folder = argumentParser.parse(args: CommandLine.arguments)
LokaliseGenerator().run(directory: folder)
