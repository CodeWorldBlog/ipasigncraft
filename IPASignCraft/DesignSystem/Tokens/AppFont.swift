//
//  AppFont.swift
//  IPASignCraft
//
//  Created by Saurav Nagpal on 23/04/26.
//

import SwiftUI

enum AppFont {
    static let title = Font.system(size: 28, weight: .semibold)

    static let heading1 = Font.system(size: 20, weight: .semibold)
    static let heading2 = Font.system(size: 18, weight: .semibold)
    static let section = Font.system(size: 16, weight: .semibold)
    static let heading3 = Font.system(size: 15, weight: .semibold)

    static let body = Font.system(size: 13, weight: .regular)
    static let secondary = Font.system(size: 12, weight: .regular)
    static let caption = Font.system(size: 11, weight: .regular)
    static let small = Font.system(size: 10, weight: .regular)

    static let button = Font.system(size: 13, weight: .medium)
}
