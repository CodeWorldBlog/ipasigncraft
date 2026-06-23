//
//  ParsedIPAInfo.swift
//  IPASignCraft
//
//  Created by Saurav Nagpal on 18/05/26.
//


import Foundation

/// Lightweight intermediate model
/// used during Info.plist parsing.
struct ParsedIPAInfo {

    let appName: String

    let bundleIdentifier: String

    let version: String

    let buildNumber: String
}