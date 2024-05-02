//
//  Content.swift
//  Bundle.Sandbox.FileManager.HomeWork
//
//  Created by Sergey on 30.04.2024.
//

import Foundation

enum ContetntType {
    case folder
    case file
}

struct Content {
    let name: String
    let type: ContetntType
}
