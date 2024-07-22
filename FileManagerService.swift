//
//  FileManagerService.swift
//  Bundle.Sandbox.FileManager.HomeWork
//
//  Created by Sergey on 23.04.2024.
//

import Foundation

protocol FileManagerServiceProtocol {

    func createDirectory(name: String)
    func createFile(name: String, content: Data)
    func removeContent(at index: Int)
    func isDirectoryAtIndex(_ index: Int) -> Bool
    func getPath(at index: Int) -> String
}

class FilemanagerService: FileManagerServiceProtocol {

    var items: [String] = []
    let pathForFolder: String

    init() {
        self.pathForFolder = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    }

    init(pathForFolder: String) {
        self.pathForFolder = pathForFolder
    }

    func createDirectory(name: String) {
        let pathToSave = pathForFolder + "/" + name
        do {
            try FileManager.default.createDirectory(atPath: pathToSave, withIntermediateDirectories: true)
        } catch {
            print(error.localizedDescription)
        }
    }

    func createFile(name: String, content: Data) {
        let pathToSave = URL(filePath: pathForFolder + "/" + name)
        do {
            try content.write(to: pathToSave)
        } catch {
            print(error.localizedDescription)
        }
    }

    func removeContent(at index: Int) {
        let path = pathForFolder + "/" + items[index]
        do {
            try FileManager.default.removeItem(atPath: path)
        } catch {
            print(error.localizedDescription)
        }
    }

    func fetchData() {
        do {
            items = try FileManager.default.contentsOfDirectory(atPath: pathForFolder)
        } catch {
            items = []
        }
    }

    func sort(by: Sorting) {
        switch by {
        case .notSorted:
            break
        case .sortedUpper:
            do {
                items = try FileManager.default.contentsOfDirectory(atPath: pathForFolder).sorted(by: <)
            } catch {
                items = []
            }
        case .soertedLower:
            do {
                items = try FileManager.default.contentsOfDirectory(atPath: pathForFolder).sorted(by: >)
            } catch {
                items = []
            }
        }
    }

    func sort() {
        items = items.sorted()
        print(items)
    }

    func getPath(at index: Int) -> String {
        return pathForFolder + "/" + items[index]
    }

    func isDirectoryAtIndex(_ index: Int) -> Bool {
        let item = items[index]
        let path = pathForFolder + "/" + item
        var objcBool: ObjCBool = false
        FileManager.default.fileExists(atPath: path, isDirectory: &objcBool)
        return objcBool.boolValue
    }
}
