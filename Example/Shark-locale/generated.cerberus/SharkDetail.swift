// SharkDetail.swift
// Generated using Cerberus — https://github.com/StashInvest/Cerberus

import Foundation

private class SharkDetailLocalized { }

public struct SharkDetailStrings {

    static let tableName: String = "SharkDetail"

    static func localize(_ key: String) -> String {
        return NSLocalizedString(key, tableName: tableName, bundle: Bundle(for: SharkDetailLocalized.self), comment: "")
    }

    enum Keys: String {
        case viewTitle = "shark.detail.view_title"
    }
    
    static let viewTitle: String = localize(Keys.viewTitle.rawValue)
}
