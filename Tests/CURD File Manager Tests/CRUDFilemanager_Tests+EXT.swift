//
//  CRUDFilemanager_Tests+EXT.swift
//  crud-file-manager-swift
//
//  Created by Mr. Kavinda Dilshan on 2024-07-29.
//

import XCTest

extension CRUDFilemanager_Tests {
    // MARK: - getDirectoryURL
    /// Returns a URL according to given `SearchPathDirectory`, `SearchPathDomainMask`, and `SubDirectories` in the local file storage system
    func getDirectoryURL(
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
    
    // MARK: - loopThroughDirectories
    /// Loops through all the parent directories and its subdirectories.
    /// What ever the body pass into this function gets both a parent directory and its subdirectory one at a time.
    func loopThroughDirectories(body: (_ parentDirectory: SubDirectories, _ subDirectory: SubDirectories) async -> Void) async {
        for directorySet in directories {
            guard let parentDirectory: SubDirectories = directorySet.first else {
                XCTFail("An error occurred when finding the parent directory in the `directorySet` array.")
                return
            }
            
            /// drop parent directory from the array to loop through sub directories
            for subDirectory in directorySet.dropFirst() {
                await body(parentDirectory, subDirectory)
            }
        }
    }
    
    // MARK: - removeDirectories
    /// Cleanup: Remove all previously created directory after each test case for safety purposes of each test case.
    func removeDirectories() throws {
        let fileManager: FileManager = .default
        let directories: [SubDirectories] = [.music, .pictures, .videos] // Parent directories
        
        /// no need of removing subDirectories as we remove each parent directory.
        for directory in directories {
            let directoryURL: URL = try getDirectoryURL(directory: .documentDirectory, subDirectories: [directory])
            
            do {
                /// Remove the directory if it exists
                guard fileManager.fileExists(atPath: directoryURL.path(percentEncoded: false)) else { return }
                try fileManager.removeItem(at: directoryURL)
            } catch {
                print("Failed to remove directory at: \(directoryURL.path): \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - getMockData
    func getMockData() -> Data? {
        guard let data: Data = UUID().uuidString.data(using: .utf8) else {
            XCTFail("An error occurred while encoding string to data.")
            return nil
        }
        
        return data
    }
}
