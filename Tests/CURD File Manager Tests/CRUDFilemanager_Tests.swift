//
//  CRUDFilemanager_Tests.swift
//  crud-file-manager-swift
//
//  Created by Mr. Kavinda Dilshan on 2024-07-28.
//

import XCTest
@testable import CRUDFileManager

final class CRUDFilemanager_Tests: XCTestCase {
    // MARK: - PROPERTIES
    enum SubDirectories: String, Sendable {
        // MUSIC
        case music = "Music" // Parent Directory
        case electronicDanceMusic = "EDM" // Sub Directory
        case english = "English" // Sub Directory
        case rap = "Rap" // Sub Directory
        
        // PICTURES
        case pictures = "Pictures" // Parent Directory
        case mixPictures = "Mix Pictures" // Sub Directory
        case myPictures = "My Pictures" // Sub Directory
        
        // VIDEOS
        case videos = "Videos" // Parent Directory
        case myVideos = "My Videos" // Sub Directory
        case musicVideos = "Music Videos" // Sub Directory
    }
    
    let fileManager = CRUDFileManager<SubDirectories>()
    
    let directories: [[SubDirectories]] = [ /// first being the parent directory and the rest being only the sub directories of the parent
        [.music, .electronicDanceMusic, .english, .rap],
        [.pictures, .mixPictures, .myPictures],
        [.videos, .myVideos, .musicVideos]
    ]
    
    let errorTypes = CRUDFileManager<SubDirectories>.ErrorTypes_Enum.self
    let fileName: String = "TestFile.txt"
    
    // MARK: - FUNCTIONS
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        
        /// Essential for ensuring tests don't affect each other.
        try removeDirectories()
    }
    
    // MARK: - TEST CASES
    
    // MARK: - CREATE OPERATION CASES
    
    // MARK: - test_iCRUD_FileManager_createDirectory_shouldReturnURL
    /// Create parent directories with each sub directory combinations and always return the URL even if the path exists or not.
    func test_iCRUD_FileManager_createDirectory_shouldReturnURL() async {
        // Given
        let maxAttempts: Range<Int> = 0..<100
        
        for _ in maxAttempts {
            await loopThroughDirectories { parentDirectory, subDirectory in
                do {
                    // When
                    let directoryURL: URL = try await fileManager.createDirectory(
                        directory: .documentDirectory,
                        subDirectories: [parentDirectory, subDirectory]
                    )
                    
                    let directoryPathString: String = directoryURL.path(percentEncoded: false)
                    
                    // Then
                    XCTAssertTrue(FileManager.default.fileExists(atPath: directoryPathString), "Directory should exist at: \(directoryPathString)")
                } catch {
                    XCTFail("An error occurred but was not expected: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - test_iCRUD_FileManager_createFile_shouldReturnURL
    /// First we create the directories.
    /// Then create files at the created paths, so it must return URLs.
    func test_iCRUD_FileManager_createFile_shouldReturnURLOrThrowPathExistError() async {
        // Given
        await test_iCRUD_FileManager_createDirectory_shouldReturnURL()
        guard let data: Data = getMockData() else { return }
        
        await loopThroughDirectories { parentDirectory, subDirectory in
            do {
                // When
                let url: URL = try await fileManager.createFile(
                    directory: .documentDirectory,
                    subDirectories:[parentDirectory, subDirectory],
                    nameWithExt: fileName,
                    contents: data
                )
                
                let directoryPathString: String = url.path(percentEncoded: false)
                
                // Then
                XCTAssertTrue(FileManager.default.fileExists(atPath: directoryPathString), "Directory should exist at: \(directoryPathString)")
            } catch {
                XCTFail("An error occurred but was not expected: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - test_iCRUD_FileManager_createFile_shouldThrowPathExistError
    /// First, we create directories and files.
    /// Then we attempt to create files at the same paths which already exist, so it must throw a `pathAlreadyExists` error.
    func test_iCRUD_FileManager_createFile_shouldThrowPathExistError() async {
        // Given
        await test_iCRUD_FileManager_createFile_shouldReturnURLOrThrowPathExistError()
        guard let data: Data = getMockData() else { return }
        
        await loopThroughDirectories { parentDirectory, subDirectory in
            do {
                // Attempt to create the same file again
                let subDirectories: [SubDirectories] = [parentDirectory, subDirectory]
                let directoryURL: URL = try getDirectoryURL(directory: .documentDirectory, subDirectories: subDirectories)
                let filePathString: String = directoryURL.appending(path: fileName).path(percentEncoded: false)
                
                do {
                    // When
                    // Attempt to create a file on the same path again
                    _ = try await fileManager.createFile(
                        directory: .documentDirectory,                        subDirectories: subDirectories,
                        nameWithExt: fileName,
                        contents: data
                    )
                    
                    XCTFail("Expected error not thrown when file already exists.")
                } catch {
                    // Then
                    XCTAssertEqual(error.localizedDescription, errorTypes.pathAlreadyExists(filePathString).localizedDescription)
                }
            } catch {
                XCTFail("An error occurred but was not expected: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - READ OPERATION CASES
    
    // MARK: - test_iCRUD_FileManager_readFile_shouldReturnData
    /// We create directories and files in each and read files so it must return data.
    func test_iCRUD_FileManager_readFile_shouldReturnData() async {
        // Given
        await test_iCRUD_FileManager_createFile_shouldReturnURLOrThrowPathExistError()
        
        await loopThroughDirectories { parentDirectory, subDirectory in
            do {
                // When
                let data: Data = try await fileManager.readFile(
                    directory: .documentDirectory,
                    subDirectories: [parentDirectory, subDirectory],
                    nameWithExt: fileName
                )
                
                // Then
                XCTAssertFalse(data.isEmpty)
            } catch {
                XCTFail("An error occurred but was not expected: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - test_iCRUD_FileManager_readFile_shouldThrowPathDoesntExistError
    /// All directories must have been removed prior to calling this function.
    /// Then we attempt to read files which don't exist, so it must throw `pathDoesNotExist` error.
    func test_iCRUD_FileManager_readFile_shouldThrowPathDoesntExistError() async {
        // Given
        await loopThroughDirectories { parentDirectory, subDirectory in
            do {
                // When
                // Attempt to read a file that doesn't exist
                _ = try await fileManager.readFile(directory: .documentDirectory, subDirectories: [parentDirectory, subDirectory], nameWithExt: fileName)
                XCTFail("Expected error not thrown when file doesn't exists.")
            } catch {
                do {
                    let directoryURL: URL = try getDirectoryURL(directory: .documentDirectory, subDirectories: [parentDirectory, subDirectory])
                    let filePathString: String = directoryURL.appending(path: fileName).path(percentEncoded: false)
                    
                    // Then
                    XCTAssertEqual(error.localizedDescription, errorTypes.pathDoesNotExist(filePathString).localizedDescription)
                } catch {
                    XCTFail("An error occurred but was not expected: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - test_iCRUD_FileManager_readFile_shouldReturnData2
    /// We create directories and files in each and read files so it must return data.
    func test_iCRUD_FileManager_readFile_shouldReturnData2() async {
        // Given
        await test_iCRUD_FileManager_createFile_shouldReturnURLOrThrowPathExistError()
        
        await loopThroughDirectories { parentDirectory, subDirectory in
            do {
                let directoryURL: URL = try getDirectoryURL(directory: .documentDirectory, subDirectories: [parentDirectory,  subDirectory])
                let filePathURL: URL = directoryURL.appending(path: fileName)
                
                // When
                let data: Data = try await fileManager.readFile(url: filePathURL)
                
                // Then
                XCTAssertFalse(data.isEmpty)
            } catch {
                XCTFail("An error occurred but was not expected: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - test_iCRUD_FileManager_readFile_shouldThrowPathDoesntExistError2
    /// All directories must have been removed prior to calling this function.
    /// Then we attempt to read files which don't exist, so it must throw `pathDoesNotExist` error.
    func test_iCRUD_FileManager_readFile_shouldThrowPathDoesntExistError2() async {
        // Given
        await loopThroughDirectories { parentDirectory, subDirectory in
            do {
                let directoryURL: URL = try getDirectoryURL(directory: .documentDirectory, subDirectories: [parentDirectory,  subDirectory])
                let filePathURL: URL = directoryURL.appending(path: fileName)
                let filePathString: String = filePathURL.path(percentEncoded: false)
                
                do {
                    // When
                    // Attempt to read a file that doesn't exist
                    _ = try await fileManager.readFile(url: filePathURL)
                    XCTFail("Expected error not thrown when file doesn't exists.")
                } catch {
                    // Then
                    XCTAssertEqual(error.localizedDescription, errorTypes.pathDoesNotExist(filePathString).localizedDescription)
                }
            } catch {
                XCTFail("An error occurred but was not expected: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - UPDATE OPERATION CASES
    
    // MARK: - test_iCRUD_FileManager_updateFile_shouldNotThrow
    /// We create directories and files in each and update files so it must not throw.
    func test_iCRUD_FileManager_updateFile_shouldNotThrow() async {
        // Given
        await test_iCRUD_FileManager_createFile_shouldReturnURLOrThrowPathExistError()
        
        // When
        await loopThroughDirectories { parentDirectory, subDirectory in
            do {
                guard let data: Data = getMockData() else { return }
                
                // Then
                try await fileManager.updateFile(
                    directory: .documentDirectory,
                    subDirectories: [parentDirectory, subDirectory],
                    nameWithExt: fileName,
                    contents: data
                )
            } catch {
                XCTFail("An error occurred but was not expected: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - test_iCRUD_FileManager_updateFile_shouldThrowPathDoesntExistError
    /// All directories must have been removed prior to calling this function.
    /// Then we attempt to update files which don't exist, so it must throw `pathDoesNotExist` error.
    func test_iCRUD_FileManager_updateFile_shouldThrowPathDoesntExistError() async {
        // Given
        await loopThroughDirectories { parentDirectory, subDirectory in
            do {
                let directoryURL: URL = try getDirectoryURL(directory: .documentDirectory, subDirectories: [parentDirectory, subDirectory])
                let filePathString: String = directoryURL.appending(path: fileName).path(percentEncoded: false)
                
                do {
                    guard let data: Data = getMockData() else { return }
                    
                    // When
                    // Attempt to update a file that doesn't exist
                    try await fileManager.updateFile(
                        directory: .documentDirectory,
                        subDirectories: [parentDirectory, subDirectory],
                        nameWithExt: fileName,
                        contents: data
                    )
                    
                    XCTFail("Expected error not thrown when file doesn't exists.")
                } catch {
                    // Then
                    XCTAssertEqual(error.localizedDescription, errorTypes.pathDoesNotExist(filePathString).localizedDescription)
                }
            } catch {
                XCTFail("An error occurred but was not expected: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - test_iCRUD_FileManager_updateFile_shouldNotThrow2
    /// We create directories and files in each and update files so it must not throw.
    func test_iCRUD_FileManager_updateFile_shouldNotThrow2() async {
        // Given
        await test_iCRUD_FileManager_createFile_shouldReturnURLOrThrowPathExistError()
        
        // When
        await loopThroughDirectories { parentDirectory, subDirectory in
            do {
                guard let data: Data = getMockData() else { return }
                let directoryURL: URL = try getDirectoryURL(directory: .documentDirectory, subDirectories: [parentDirectory, subDirectory])
                let fileURL: URL = directoryURL.appending(path: fileName)
                
                // Then
                try await fileManager.updateFile(url: fileURL, contents: data)
            } catch {
                XCTFail("An error occurred but was not expected: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - test_iCRUD_FileManager_updateFile_shouldThrowPathDoesntExistError
    /// All directories must have been removed prior to calling this function.
    /// Then we attempt to update files which don't exist, so it must throw `pathDoesNotExist` error.
    func test_iCRUD_FileManager_updateFile_shouldThrowPathDoesntExistError2() async {
        // Given
        await loopThroughDirectories { parentDirectory, subDirectory in
            do {
                let directoryURL: URL = try getDirectoryURL(directory: .documentDirectory, subDirectories: [parentDirectory, subDirectory])
                let fileURL: URL = directoryURL.appending(path: fileName)
                let filePathString: String = fileURL.path(percentEncoded: false)
                
                do {
                    guard let data: Data = getMockData() else { return }
                    
                    // When
                    // Attempt to update a file that doesn't exist
                    try await fileManager.updateFile(url: fileURL, contents: data)
                    XCTFail("Expected error not thrown when file doesn't exists.")
                } catch {
                    // Then
                    XCTAssertEqual(error.localizedDescription, errorTypes.pathDoesNotExist(filePathString).localizedDescription)
                }
            } catch {
                XCTFail("An error occurred but was not expected: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - DELETE OPERATION CASES
    
    // MARK: - test_iCRUD_FileManager_deleteFile_shouldNotThrow
    /// First we create directories and files.
    /// Then we delete all the files so it must not throw an error.
    func test_iCRUD_FileManager_deleteFile_shouldNotThrow() async {
        // Given
        await test_iCRUD_FileManager_createFile_shouldThrowPathExistError()
        
        await loopThroughDirectories { parentDirectory, subDirectory in
            do {
                // When
                let directoryURL: URL = try getDirectoryURL(directory: .documentDirectory, subDirectories: [parentDirectory, subDirectory])
                let filePathString: String = directoryURL.appending(path: fileName).path(percentEncoded: false)
                
                try await fileManager.deleteFile(directory: .documentDirectory, subDirectories: [parentDirectory, subDirectory], nameWithExt: fileName)
                
                // Then
                XCTAssertFalse(FileManager.default.fileExists(atPath: filePathString))
            } catch {
                XCTFail("An error occurred but was not expected: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - test_iCRUD_FileManager_deleteFile_shouldThrow
    /// First we create directories, and don't create files in those directories.
    /// Then we attempt to delete all the files in all the directories which don't exist, so it must throw `pathDoesNotExist` error.
    func test_iCRUD_FileManager_deleteFile_shouldThrow() async {
        // Given
        await test_iCRUD_FileManager_createDirectory_shouldReturnURL()
        
        await loopThroughDirectories { parentDirectory, subDirectory in
            do {
                let directoryURL: URL = try getDirectoryURL(directory: .documentDirectory, subDirectories: [parentDirectory, subDirectory])
                let filePathString: String = directoryURL.appending(path: fileName).path(percentEncoded: false)
                
                do {
                    // When
                    try await fileManager.deleteFile(directory: .documentDirectory, subDirectories: [parentDirectory, subDirectory], nameWithExt: fileName)
                    XCTFail("Expected error not thrown when file doesn't exists.")
                } catch {
                    // Then
                    XCTAssertFalse(FileManager.default.fileExists(atPath: filePathString))
                    XCTAssertEqual(error.localizedDescription, errorTypes.pathDoesNotExist(filePathString).localizedDescription)
                }
            } catch {
                XCTFail("An error occurred but was not expected: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - test_iCRUD_FileManager_deleteFile_shouldNotThrow2
    /// First we create directories and files.
    /// Then we delete all the files so it must not throw an error.
    func test_iCRUD_FileManager_deleteFile_shouldNotThrow2() async {
        // Given
        await test_iCRUD_FileManager_createFile_shouldThrowPathExistError()
        
        
        await loopThroughDirectories { parentDirectory, subDirectory in
            do {
                let directoryURL: URL = try getDirectoryURL(directory: .documentDirectory, subDirectories: [parentDirectory, subDirectory])
                let fileURL: URL = directoryURL.appending(path: fileName)
                let filePathString: String = directoryURL.appending(path: fileName).path(percentEncoded: false)
                
                // When
                try await fileManager.deleteFile(url: fileURL)
                
                // Then
                XCTAssertFalse(FileManager.default.fileExists(atPath: filePathString))
                XCTAssertFalse(FileManager.default.fileExists(atPath: filePathString))
            } catch {
                XCTFail("An error occurred but was not expected: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - test_iCRUD_FileManager_deleteFile_shouldThrow2
    /// First we create directories, and don't create files in those directories.
    /// Then we attempt to delete all the files in all the directories which don't exist, so it must throw `pathDoesNotExist` error.
    func test_iCRUD_FileManager_deleteFile_shouldThrow2() async {
        // Given
        await test_iCRUD_FileManager_createDirectory_shouldReturnURL()
        
        await loopThroughDirectories { parentDirectory, subDirectory in
            do {
                let directoryURL: URL = try getDirectoryURL(directory: .documentDirectory, subDirectories: [parentDirectory, subDirectory])
                let fileURL: URL = directoryURL.appending(path: fileName)
                let filePathString: String = fileURL.path(percentEncoded: false)
                
                do {
                    // When
                    try await fileManager.deleteFile(url: fileURL)
                    XCTFail("Expected error not thrown when file doesn't exists.")
                } catch {
                    // Then
                    XCTAssertFalse(FileManager.default.fileExists(atPath: filePathString))
                    XCTAssertEqual(error.localizedDescription, errorTypes.pathDoesNotExist(filePathString).localizedDescription)
                }
            } catch {
                XCTFail("An error occurred but was not expected: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - test_iCRUD_FileManager_deleteDirectory_shouldNotThrow
    /// First, we create directories and files.
    /// Then we remove directories, so it must not throw an error
    func test_iCRUD_FileManager_deleteDirectory_shouldNotThrow() async {
        // Given
        await test_iCRUD_FileManager_createFile_shouldThrowPathExistError()
        
        await loopThroughDirectories { parentDirectory, subDirectory in
            do {
                // When
                try await fileManager.deleteDirectory(directory: .documentDirectory, subDirectories: [parentDirectory, subDirectory])
                
                let directoryPathString: String = try getDirectoryURL(directory: .documentDirectory, subDirectories: [parentDirectory, subDirectory]).path(percentEncoded: false)
                
                // Then
                XCTAssertFalse(FileManager.default.fileExists(atPath: directoryPathString))
            } catch {
                XCTFail("An error occurred but was not expected: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - test_iCRUD_FileManager_deleteDirectory_shouldThrow
    /// We attempt to delete directories that never created, so it must throw `pathDoesNotExist` error.
    func test_iCRUD_FileManager_deleteDirectory_shouldThrow() async {
        // Given
        await loopThroughDirectories { parentDirectory, subDirectory in
            do {
                let directoryPathString: String = try getDirectoryURL(directory: .documentDirectory, subDirectories: [parentDirectory, subDirectory]).path(percentEncoded: false)
                
                do {
                    // When
                    try await fileManager.deleteDirectory(directory: .documentDirectory, subDirectories: [parentDirectory, subDirectory])
                    XCTFail("Expected error not thrown when file doesn't exists.")
                } catch {
                    // Then
                    XCTAssertFalse(FileManager.default.fileExists(atPath: directoryPathString))
                    XCTAssertEqual(error.localizedDescription, errorTypes.pathDoesNotExist(directoryPathString).localizedDescription)
                }
            } catch {
                XCTFail("An error occurred but was not expected: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - test_iCRUD_FileManager_deleteDirectory_shouldNotThrow2
    /// First, we create directories and files.
    /// Then we remove directories, so it must not throw an error
    func test_iCRUD_FileManager_deleteDirectory_shouldNotThrow2() async {
        // Given
        await test_iCRUD_FileManager_createFile_shouldThrowPathExistError()
        
        await loopThroughDirectories { parentDirectory, subDirectory in
            do {
                let directoryURL: URL = try getDirectoryURL(directory: .documentDirectory, subDirectories: [parentDirectory, subDirectory])
                let directoryPathString: String = directoryURL.path(percentEncoded: false)
                
                // When
                try await fileManager.deleteDirectory(url: directoryURL)
                
                // Then
                XCTAssertFalse(FileManager.default.fileExists(atPath: directoryPathString))
            } catch {
                XCTFail("An error occurred but was not expected: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - test_iCRUD_FileManager_deleteDirectory_shouldThrow2
    /// We attempt to delete directories that never created, so it must throw `pathDoesNotExist` error.
    func test_iCRUD_FileManager_deleteDirectory_shouldThrow2() async {
        // Given
        await loopThroughDirectories { parentDirectory, subDirectory in
            do {
                let directoryURL: URL = try getDirectoryURL(directory: .documentDirectory, subDirectories: [parentDirectory, subDirectory])
                let directoryPathString: String = directoryURL.path(percentEncoded: false)
                
                do {
                    // When
                    try await fileManager.deleteDirectory(url: directoryURL)
                    XCTFail("Expected error not thrown when file doesn't exists.")
                } catch {
                    // Then
                    XCTAssertFalse(FileManager.default.fileExists(atPath: directoryPathString))
                    XCTAssertEqual(error.localizedDescription, errorTypes.pathDoesNotExist(directoryPathString).localizedDescription)
                }
            } catch {
                XCTFail("An error occurred but was not expected: \(error.localizedDescription)")
            }
        }
    }
}
