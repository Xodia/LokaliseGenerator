//
//  Template.swift
//  LokaliseGenerator
//
//  Created by Morgan Collino on 4/10/20.
//  Copyright © 2020 Morgan Collino. All rights reserved.
//

import Foundation
import Stencil

enum Templates: String {
    case swiftCodeGeneration = "SwiftCodeGeneration.stencil"
    case strings = "Strings.stencil"
    case stringsDict = "StringsDict.stencil"
    case xml = "XML.stencil"
    case web = "Web.stencil"
}
