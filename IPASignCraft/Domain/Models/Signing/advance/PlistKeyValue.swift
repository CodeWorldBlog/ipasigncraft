//
//  PlistKeyValue.swift
//  IPASignCraft
//
//  Created by Saurav Nagpal on 06/04/26.
//

import Foundation

struct PlistKeyValue: Identifiable {
    let id = UUID()
    
    /// Info.plist key (e.g. NSCameraUsageDescription)
    var key: String = ""
    
    /// Value as string (can evolve later to typed)
    var value: String = ""
}
