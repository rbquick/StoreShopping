//
//  Logger.swift
//  HandicappMulti
//
//  Created by Brian Quick on 2022-03-01.
//

import Foundation

class Logger {

    static private var logFile: URL? {
        // if sandboxed, this is not the users Documents directory, but app relative
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: Date())
        let fileName = "\(dateString).txt"
        return documentsDirectory.appendingPathComponent(fileName)
    }

    static func truncate() {
        guard let logFile = logFile else {
            return
        }

        if FileManager.default.fileExists(atPath: logFile.path) {
            if let fileHandle = try? FileHandle(forWritingTo: logFile) {
                fileHandle.truncateFile(atOffset: 0)
            }
        }
    }
    static func log(_ message: String) {
//#if os(iOS)
//        return
//#endif
        guard let logFile = logFile else {
            return
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        let timestamp = formatter.string(from: Date())
        guard let data = (timestamp + ": " + message + "\n").data(using: String.Encoding.utf8) else { return }

        if FileManager.default.fileExists(atPath: logFile.path) {
            if let fileHandle = try? FileHandle(forWritingTo: logFile) {
                fileHandle.seekToEndOfFile()
                fileHandle.write(data)
                fileHandle.closeFile()
            }
        } else {
            try? data.write(to: logFile, options: .atomicWrite)
        }
    }

    static func readLog() -> String {
        guard let logFile = logFile else { return "Nothing on file" }
        print(logFile)
//        let fileName = logFile.absoluteString
//        let fileContent = try? NSString(contentsOfFile: fileName, encoding: String.Encoding.utf8.rawValue)
//        let fileString: String = (fileContent ?? "Nothing on file") as String
        do {
            let text2 = try NSString(contentsOf: logFile, encoding: String.Encoding.utf8.rawValue)
            return text2 as String
            }
        catch {
            return "reading error catch"
        }
    }
}
