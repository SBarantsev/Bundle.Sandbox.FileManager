//
//  FileManagerService.swift
//  Bundle.Sandbox.FileManager.HomeWork
//
//  Created by Sergey on 23.04.2024.
//

import Foundation
import UIKit

protocol FileManagerServiceProtocol {
    
    func contentsOfDirectory(_ index: Int) -> Bool
    func createDirectory(name: String)
    func createFile(name: String, content: UIImage)
    func removeContent(at index: Int)
}

final class FileManagerService: FileManagerServiceProtocol {
    
    private let pathForFolder: String
    
    var items: [String] {
        (try? FileManager.default.contentsOfDirectory(atPath: pathForFolder)) ?? []
    }
    
    init(pathForFolder: String) {
        self.pathForFolder = pathForFolder
    }
    
    init() {
        pathForFolder = NSSearchPathForDirectoriesInDomains(
            .documentDirectory,
            .userDomainMask,
            true
        )[0]
    }
    
    func getContent() -> [Content] {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        var contentArray = [Content]()
        
        do {
            let contents = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            
            for itemURL in contents {
                var type: ContetntType = .file
                var isDirectory: ObjCBool = false
                if fileManager.fileExists(atPath: itemURL.path, isDirectory: &isDirectory) {
                    if isDirectory.boolValue {
                        type = .folder
                    }
                }
                let itemName = itemURL.lastPathComponent
                let contentItem = Content(name: itemName, type: type)
                contentArray.append(contentItem)
            }
        } catch {
            print("Error: \(error)")
        }
        return contentArray
    }
    
    func createDirectory(name: String) {
        try? FileManager.default.createDirectory(atPath: pathForFolder + "/" + name, withIntermediateDirectories: true)
    }
    
    func createFile(name: String, content: UIImage) {
        let path = URL(filePath: pathForFolder + "/" + name)
        do {
            if let imageData = content.pngData() {
                try imageData.write(to: path)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func removeContent(at index: Int) {
        let path = pathForFolder + "/" + items[index]
        try? FileManager.default.removeItem(atPath: path)
    }
    
    func getPath(at index: Int) -> String {
        pathForFolder + "/" + items[index]
    }
    
    func contentsOfDirectory(_ index: Int) -> Bool {
        
        let item = items[index]
        let path = pathForFolder + "/" + item
        
        var objcBool: ObjCBool = false
        
        FileManager.default.fileExists(atPath: path, isDirectory: &objcBool)
        
        return objcBool.boolValue
    }
}


