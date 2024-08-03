//
//  CRUDFileManager.swift
//  crud-file-manager-swift
//
//  Created by Mr. Kavinda Dilshan on 2024-07-27.
//

import Foundation

public actor CRUDFileManager<T: RawRepresentable & Sendable>: @preconcurrency CRUDProtocol where T.RawValue == String {
    // MARK: - PROPERTIES
    public enum ErrorTypes_Enum: LocalizedError, Sendable {
        case pathDoesNotExist(String)
        case pathAlreadyExists(String)
        case fileCreationFailed(String)
        case fileReadFailed(String)
        
        public var errorDescription: String? {
            switch self {
            case .pathDoesNotExist(let path):
                return "Path does not exist: \(path). 📁❌\n"
            case .pathAlreadyExists(let path):
                return "Path already exists: \(path). 📁📝✋🏻\n"
            case .fileCreationFailed(let path):
                return "File creation failed at path: \(path). 📁📝🚫\n"
            case .fileReadFailed(let path):
                return "File read failed at path: \(path). 📁👓🚫\n"
            }
        }
    }
    
    public typealias ErrorTypes = ErrorTypes_Enum
    public typealias SubDirectories = T
    
    // MARK: INITIALIZER
    public init() { }
    
    // MARK: - FUNCTIONS
    
    // MARK: - getFirstDirectoryURL
    /// Returns the URL for the specified directory, domain, and subdirectories.
    private func getDirectoryURL(
        directory: FileManager.SearchPathDirectory,
        subDirectories: [SubDirectories]
    ) throws -> URL {
        let firstDirectoryURL: URL = try FileManager.default.url(
            for: directory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        
        let lastDirectoryPath: String = subDirectories.map { $0.rawValue }.joined(separator: "/")
        let directoryURL: URL = firstDirectoryURL.appendingPathComponent(lastDirectoryPath)
        
        return directoryURL
    }
    
    // MARK: - isPathExist
    /// Checks if the path exists at the given URL.
    private func isPathExist(url: URL) -> Bool {
        FileManager.default.fileExists(atPath: url.path(percentEncoded: false))
    }
    
    // MARK: - CREATE
    
    // MARK: - createDirectory
    /// Creates a directory at the specified location.
    public func createDirectory(
        directory: FileManager.SearchPathDirectory,
        subDirectories: [SubDirectories]
    ) throws -> URL {
        let directoryURL: URL = try self.getDirectoryURL(directory: directory, subDirectories: subDirectories)
        
        guard !isPathExist(url: directoryURL) else { return directoryURL }
        
        try FileManager.default.createDirectory(
            at: directoryURL,
            withIntermediateDirectories: true,
            attributes: nil
        )
        
        return directoryURL
    }
    
    // MARK: - createFile
    /// Creates a file at the specified location with the given contents.
    public func createFile(
        directory: FileManager.SearchPathDirectory,
        subDirectories: [SubDirectories],
        nameWithExt: String,
        contents: Data
    ) throws -> URL {
        let directoryURL: URL = try getDirectoryURL(directory: directory, subDirectories: subDirectories)
        let fileURL = directoryURL.appendingPathComponent(nameWithExt)
        
        guard !isPathExist(url: fileURL) else { throw ErrorTypes.pathAlreadyExists(fileURL.path(percentEncoded: false)) }
        
        let fileURLString: String = fileURL.path(percentEncoded: false)
        
        guard FileManager.default.createFile(atPath: fileURLString, contents: contents, attributes: nil) else {
            throw ErrorTypes.fileCreationFailed((fileURLString))
        }
        
        return fileURL
    }
    
    // MARK: - READ
    
    // MARK: - readFile
    /// Reads the contents of the file at the specified location.
    public func readFile(
        directory: FileManager.SearchPathDirectory,
        subDirectories: [SubDirectories],
        nameWithExt: String
    ) throws -> Data {
        let directoryURL: URL = try getDirectoryURL(directory: directory, subDirectories: subDirectories)
        let fileURL = directoryURL.appendingPathComponent(nameWithExt)
        
        return try readFile(url: fileURL)
    }
    
    // MARK: - readFile
    /// Reads the contents of the file at the specified URL path.
    public func readFile(url: URL) throws -> Data {
        guard isPathExist(url: url) else { throw ErrorTypes.pathDoesNotExist(url.path(percentEncoded: false)) }
        
        let urlString: String = url.path(percentEncoded: false)
        
        guard let data: Data = FileManager.default.contents(atPath: urlString) else {
            throw ErrorTypes.fileReadFailed(urlString)
        }
        
        return data
    }
    
    // MARK: - UPDATE
    
    //  MARK: - updateFile
    /// Updates the contents of the file at the specified location.
    public func updateFile(
        directory: FileManager.SearchPathDirectory,
        subDirectories: [SubDirectories],
        nameWithExt: String,
        contents: Data
    ) throws {
        let directoryURL: URL = try getDirectoryURL(directory: directory, subDirectories: subDirectories)
        let fileURL = directoryURL.appendingPathComponent(nameWithExt)
        
        try updateFile(url: fileURL, contents: contents)
    }
    
    //  MARK: - updateFile
    /// Updates the contents of the file at the specified URL path.
    public func updateFile(url: URL, contents: Data) throws {
        guard isPathExist(url: url) else { throw ErrorTypes.pathDoesNotExist(url.path(percentEncoded: false)) }
        try contents.write(to: url)
    }
    
    // MARK: - DELETE
    
    // MARK: - deleteFile
    /// Deletes the file at the specified location.
    public func deleteFile(
        directory: FileManager.SearchPathDirectory,
        subDirectories: [SubDirectories],
        nameWithExt: String
    ) throws {
        let directoryURL: URL = try getDirectoryURL(directory: directory, subDirectories: subDirectories)
        let fileURL = directoryURL.appendingPathComponent(nameWithExt)
        
        try deleteFile(url: fileURL)
    }
    
    // MARK: - deleteFile
    /// Deletes the file at the specified URL path.
    public func deleteFile(url: URL) throws {
        guard isPathExist(url: url) else { throw ErrorTypes.pathDoesNotExist(url.path(percentEncoded: false)) }
        try FileManager.default.removeItem(at: url)
    }
    
    // MARK: - deleteDirectory
    /// Deletes the directory at the specified location.
    public func deleteDirectory(
        directory: FileManager.SearchPathDirectory,
        subDirectories: [SubDirectories]
    ) throws {
        let directoryURL: URL = try getDirectoryURL(directory: directory, subDirectories: subDirectories)
        try deleteDirectory(url: directoryURL)
    }
    
    // MARK: - deleteDirectory
    /// Deletes the directory at the specified URL path.
    public func deleteDirectory(url: URL) throws {
        guard isPathExist(url: url) else { throw ErrorTypes.pathDoesNotExist(url.path(percentEncoded: false)) }
        try FileManager.default.removeItem(at: url)
    }
}
