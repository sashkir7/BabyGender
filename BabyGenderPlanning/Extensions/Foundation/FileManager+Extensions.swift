//
//  FileManager+Extensions.swift
//  BabyGenderPlanning
//
//  Created by Nikita Velichkin on 09/04/2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import Foundation

extension FileManager {

    var privateDataPath: String {
        let searchPath = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)

        guard let path = searchPath.first else { return "" }

        if !fileExists(atPath: path) {
            try? createDirectory(atPath: path, withIntermediateDirectories: true)
        }
        return path
    }

    func createDirectoryForFilepath(_ url: URL) throws {
        let path = url.deletingLastPathComponent().path

        if !fileExists(atPath: path) {
            try createDirectory(atPath: path, withIntermediateDirectories: true)
        }
    }

    func urlForPrivateFile(_ relativePath: String) throws -> URL {
        var url = URL(fileURLWithPath: privateDataPath)
        url.appendPathComponent(relativePath)
        try createDirectoryForFilepath(url)
        return url
    }
}
