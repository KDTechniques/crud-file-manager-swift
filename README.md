# iCRUD_FileManager 🗃️

`iCRUD_FileManager` is a Swift package for performing basic file operations. It provides methods to create, read, update, and delete files and directories. This package uses Swift's concurrency model with actors to handle file operations safely and efficiently.

## Features

- **Create**: Create directories and files at specified paths.
- **Read**: Read the contents of files.
- **Update**: Update the contents of existing files.
- **Delete**: Delete files and directories.

## Requirements

- Swift 5.7 or later
- iOS 16.0+ / macOS 14.0+ / other platforms supporting Swift Concurrency

## Installation

To add `iCRUD_FileManager` to your Swift project using Swift Package Manager, add the following dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/KDTechniques/iCRUD-File-Manager.git", from: "1.0.0")
]
```

## Usage

### Creating an Instance

Import the package and create an instance of `iCRUD_FileManager` with a type that conforms to `RawRepresentable & Sendable` where `RawValue` is `String`.

```swift
import iCRUD_FileManager

let fileManager = iCRUD_FileManager<YourSubDirectoriesType>()
```

Replace `YourSubDirectoriesType` with a type that meets these requirements.

### Creating a Directory

Create a directory at the specified location. This function will create the directory if it does not exist.

```swift
do {
    let directoryURL = try fileManager.createDirectory(
        directory: .documentDirectory,
        subDirectories: [.exampleSubDir]
    )
    print("Directory created at: \(directoryURL)")
} catch {
    print("Failed to create directory: \(error)")
}
```

### Creating a File

Create a file at the specified location with the given contents.

```swift
do {
    let fileURL = try fileManager.createFile(
        directory: .documentDirectory,
        subDirectories: [.exampleSubDir],
        nameWithExt: "example.txt",
        contents: Data("Hello, world!".utf8)
    )
    print("File created at: \(fileURL)")
} catch {
    print("Failed to create file: \(error)")
}
```

### Reading a File

Read the contents of a file at the specified location.

```swift
do {
    let data = try fileManager.readFile(
        directory: .documentDirectory,
        subDirectories: [.exampleSubDir],
        nameWithExt: "example.txt"
    )
    let contents = String(decoding: data, as: UTF8.self)
    print("File contents: \(contents)")
} catch {
    print("Failed to read file: \(error)")
}
```

### Updating a File

Update the contents of an existing file at the specified location.

```swift
do {
    try fileManager.updateFile(
        directory: .documentDirectory,
        subDirectories: [.exampleSubDir],
        nameWithExt: "example.txt",
        contents: Data("Updated content.".utf8)
    )
    print("File updated.")
} catch {
    print("Failed to update file: \(error)")
}
```

### Deleting a File

Delete a file at the specified location.

```swift
do {
    try fileManager.deleteFile(
        directory: .documentDirectory,
        subDirectories: [.exampleSubDir],
        nameWithExt: "example.txt"
    )
    print("File deleted.")
} catch {
    print("Failed to delete file: \(error)")
}
```

### Deleting a Directory

Delete a directory and all its contents at the specified location.

```swift
do {
    try fileManager.deleteDirectory(
        directory: .documentDirectory,
        subDirectories: [.exampleSubDir]
    )
    print("Directory deleted.")
} catch {
    print("Failed to delete directory: \(error)")
}
```

## Error Handling

The `iCRUD_FileManager` package defines custom error types in the `ErrorTypes_Enum` enum:

- `pathDoesNotExist(String)`: The path does not exist.
- `pathAlreadyExists(String)`: The path already exists.
- `fileCreationFailed(String)`: File creation failed.
- `fileReadFailed(String)`: File read failed.

These errors provide descriptive messages to help with debugging issues related to file paths and operations.

## License

This package is licensed under the MIT License. See the [LICENSE](https://github.com/KDTechniques/iCRUD-File-Manager/blob/main/LICENSE) file for more details.

---

Feel free to contribute by opening issues or pull requests. For more information, refer to the documentation and source code.
