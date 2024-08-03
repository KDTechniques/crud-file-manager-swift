//
//  CRUDProtocol.swift
//  crud-file-manager-swift
//
//  Created by Mr. Kavinda Dilshan on 2024-07-27.
//

import Foundation

protocol CRUDProtocol: AnyObject {
    associatedtype SubDirectories: Sendable
    associatedtype ErrorTypes: Sendable
    
    // MARK: - CREATE
    func createDirectory(directory: FileManager.SearchPathDirectory,
                         subDirectories: [SubDirectories]) throws -> URL
    
    func createFile(directory: FileManager.SearchPathDirectory,
                    subDirectories: [SubDirectories],
                    nameWithExt: String,
                    contents: Data) throws -> URL
    
    // MARK: - READ
    func readFile(directory: FileManager.SearchPathDirectory,
                  subDirectories: [SubDirectories],
                  nameWithExt: String) async throws -> Data
    
    func readFile(url: URL) throws -> Data
    
    // MARK: - UPDATE
    func updateFile(directory: FileManager.SearchPathDirectory,
                    subDirectories: [SubDirectories],
                    nameWithExt: String,
                    contents: Data) throws
    
    func updateFile(url: URL, contents: Data) throws
    
    // MARK: - DELETE
    func deleteFile(directory: FileManager.SearchPathDirectory,
                    subDirectories: [SubDirectories],
                    nameWithExt: String) throws
    
    func deleteFile(url: URL) throws
    
    func deleteDirectory(directory: FileManager.SearchPathDirectory,
                         subDirectories: [SubDirectories]) throws
    
    func deleteDirectory(url: URL) throws
}
