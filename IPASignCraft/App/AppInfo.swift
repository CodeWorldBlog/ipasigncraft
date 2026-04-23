//
//  AppInfo.swift
//  IPASignCraft
//
//  Created by Saurav Nagpal on 22/04/26.
//

import Foundation

struct AppInfo {
    static var version: String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let b = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
        return "v\(v) (\(b))"
    }
}
