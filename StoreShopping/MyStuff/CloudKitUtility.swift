//
//  CloudKitUtility.swift
//  SwiftfulThinkingAdvancedLearning
//
//  Created by Nick Sarno on 11/4/21.
//
// from YouTube 
// Creating a reusable utility class for CloudKit code | Advanced Learning #25
// https://youtu.be/OD_FDJOv-Ek

import Foundation
import CloudKit
import Combine

protocol CloudKitableProtocol {
    init?(record: CKRecord)
    var record: CKRecord { get }
}

class CloudKitUtility {


    @Published var isSignedIntoIcloud: Bool = false
    @Published var error: String = ""
    var cancellables = Set<AnyCancellable>()
//    let container: CKContainer
//    let publicDB: CKDatabase
//    let privateDB: CKDatabase
//      init() {
//        container = CKContainer(identifier: "iCloud.com.codewithbrian.icloudMACOS")
//        publicDB = container.publicCloudDatabase
//        privateDB = container.privateCloudDatabase
//      }


    enum CloudKitError: String, LocalizedError {
        case iCloudAccountNotFound
        case iCloudAccountNotDetermined
        case iCloudAccountRestricted
        case iCloudAccountUnknown
        case iCloudApplicationPermissionNotGranted
        case iCloudCouldNotFetchUserRecordID
        case iCloudCouldNotDiscoverUser
    }
    static func getDocumentsDirectory() -> URL {
//        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let dbURL = URL(fileURLWithPath: "")
        do {
         return try FileManager.default
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        } catch {

        }
        return dbURL
    }
    static func writeATextFile(str: String) {
        
        let filename = getDocumentsDirectory().appendingPathComponent("output.txt")

        do {
            try str.write(to: filename, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            // failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding
        }
    }
    init() {
        Logger.log("CloudKitUtility.init")
        if !isSignedIntoIcloud {
        CloudKitUtility.getiCloudStatus()
                        .receive(on: DispatchQueue.main)
                        .sink { c in
                            switch c {
                            case .finished:
                                self.isSignedIntoIcloud = true
                            case .failure(let error):
                                self.isSignedIntoIcloud = false
                                self.error = error.localizedDescription
                                print(self.error)
                            }

                        } receiveValue: { success in
                            self.isSignedIntoIcloud = true
                        }
                        .store(in: &cancellables)
        }
    }


// MARK: USER FUNCTIONS


    static private func getiCloudStatus(completion: @escaping (Result<Bool, Error>) -> ()) {
        CKContainer.default().accountStatus { returnedStatus, returnedError in
            switch returnedStatus {
            case .available:
                completion(.success(true))
            case .noAccount:
                completion(.failure(CloudKitError.iCloudAccountNotFound))
            case .couldNotDetermine:
                completion(.failure(CloudKitError.iCloudAccountNotDetermined))
            case .restricted:
                completion(.failure(CloudKitError.iCloudAccountRestricted))
            default:
                completion(.failure(CloudKitError.iCloudAccountUnknown))
            }
        }
    }
    
    static func getiCloudStatus() -> Future<Bool, Error> {
        Future { promise in
            CloudKitUtility.getiCloudStatus { result in
                promise(result)
            }
        }
    }
    
    static private func requestApplicationPermission(completion: @escaping (Result<Bool, Error>) -> ()) {
        CKContainer.default().requestApplicationPermission([.userDiscoverability]) { returnedStatus, returnedError in
            if returnedStatus == .granted {
                completion(.success(true))
            } else {
                completion(.failure(CloudKitError.iCloudApplicationPermissionNotGranted))
            }
        }
    }
    
    static func requestApplicationPermission() -> Future<Bool, Error> {
        Future { promise in
            CloudKitUtility.requestApplicationPermission { result in
                promise(result)
            }
        }
    }
    
    static private func fetchUserRecordID(completion: @escaping (Result<CKRecord.ID, Error>) -> ()) {
        CKContainer.default().fetchUserRecordID { returnedID, returnedError in
            if let id = returnedID {
                completion(.success(id))
            } else if let error = returnedError {
                completion(.failure(error))
            } else {
                completion(.failure(CloudKitError.iCloudCouldNotFetchUserRecordID))
            }
        }
    }
    
    static private func discoverUserIdentity(id: CKRecord.ID, completion: @escaping (Result<String, Error>) -> ()) {
        CKContainer.default().discoverUserIdentity(withUserRecordID: id) { returnedIdentity, returnedError in
            if let name = returnedIdentity?.nameComponents?.givenName {
                completion(.success(name))
            } else {
                completion(.failure(CloudKitError.iCloudCouldNotDiscoverUser))
            }
        }
    }
    
    static private func discoverUserIdentity(completion: @escaping (Result<String, Error>) -> ()) {
        fetchUserRecordID { fetchCompletion in
            switch fetchCompletion {
            case .success(let recordID):
                CloudKitUtility.discoverUserIdentity(id: recordID, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    static func discoverUserIdentity() -> Future<String, Error> {
        Future { promise in
            CloudKitUtility.discoverUserIdentity { result in
                promise(result)
            }
        }
    }



}


// MARK: CRUD FUNCTIONS

extension CloudKitUtility {
    
    static func fetchOne<T:CloudKitableProtocol>(
        predicate: NSPredicate,
        recordType: CKRecord.RecordType,
        sortDescriptions: [NSSortDescriptor]? = nil,
        resultsLimit: Int? = nil
    ) -> Future<[T], Error> {
        Future { promise in
            CloudKitUtility.fetchOne(predicate: predicate, recordType: recordType, sortDescriptions: sortDescriptions, resultsLimit: resultsLimit) { (items: [T]) in
                promise(.success(items))
            }
        }
    }
    
    static private func fetchOne<T:CloudKitableProtocol>(
        predicate: NSPredicate,
        recordType: CKRecord.RecordType,
        sortDescriptions: [NSSortDescriptor]? = nil,
        resultsLimit: Int? = nil,
        completion: @escaping (_ items: [T]) -> ()) {

        // Create operation
        let operation = createOperation(predicate: predicate, recordType: recordType, sortDescriptions: sortDescriptions, resultsLimit: resultsLimit)

        // Get items in query
        var returnedItems: [T] = []
            if #available(iOS 15.0, *) {
                operation.recordMatchedBlock = { (returnedRecordID, returnedResult) in
                    switch returnedResult {
                    case .success(let record):
                        guard let item = T(record: record) else { return }
                        returnedItems.append(item)
                        completion(returnedItems)
                    case .failure:
                        break
                    }
                }
            } else {
                operation.recordFetchedBlock = { (returnedRecord) in
                    guard let item = T(record: returnedRecord) else { return }
                    returnedItems.append(item)
                    completion(returnedItems)
                }
            }
//        addRecordMatchedBlock(operation: operation) { item in
//            returnedItems.append(item)
//        }

        // Query completion
        addQueryResultBlock(operation: operation) { finished in
//            print("fetch returing \(returnedItems.count)")
            completion(returnedItems)
        }

        // Execute operation
        add(operation: operation)
    }
    
    static private func createOperation(
        predicate: NSPredicate,
        recordType: CKRecord.RecordType,
        sortDescriptions: [NSSortDescriptor]? = nil,
        resultsLimit: Int? = nil) -> CKQueryOperation {
            let query = CKQuery(recordType: recordType, predicate: predicate)
            query.sortDescriptors = sortDescriptions
            let queryOperation = CKQueryOperation(query: query)
            if let limit = resultsLimit {
                queryOperation.resultsLimit = limit
            }
            return queryOperation
        }
    
    static private func addRecordMatchedBlock<T:CloudKitableProtocol>(operation: CKQueryOperation, completion: @escaping (_ item: T) -> ()) {
        if #available(iOS 15.0, *) {
            operation.recordMatchedBlock = { (returnedRecordID, returnedResult) in
                switch returnedResult {
                case .success(let record):
                    guard let item = T(record: record) else { return }
                    completion(item)
                case .failure:
                    break
                }
            }
        } else {
            operation.recordFetchedBlock = { (returnedRecord) in
                guard let item = T(record: returnedRecord) else { return }
                completion(item)
            }
        }
    }
    
    static private func addQueryResultBlock(operation: CKQueryOperation, completion: @escaping (_ finished: Bool) -> ()) {
        if #available(iOS 15.0, *) {
            operation.queryResultBlock = { returnedResult in
                print(returnedResult)
                completion(true)
            }
        } else {
            operation.queryCompletionBlock = { (returnedCursor, returnedError) in
                completion(true)
            }
        }
    }

    static private func add(operation: CKDatabaseOperation) {
        // TODO: why not this
        Model().publicDB.add(operation)
       // CKContainer.default().publicCloudDatabase.add(operation)
    }
    
    
    static func add<T:CloudKitableProtocol>(item: T, completion: @escaping (Result<Bool, Error>) -> ()) {
        
        // Get record
        let record = item.record
        
        // Save to CloudKit
        save(record: record, completion: completion)
    }

    static func update<T:CloudKitableProtocol>(item: T) -> Future<Bool, Error> {
        Future { promise in
            CloudKitUtility.add(item: item, completion: promise)
        }

    }
//    static private func update<T:CloudKitableProtocol>(item: T, completion: @escaping (Result<Bool, Error>) -> ()) {
//        add(item: item, completion: completion)
//    }
    
    static private func save(record: CKRecord, completion: @escaping (Result<Bool, Error>) -> ()) {
        Model().publicDB.save(record) { returnedRecord, returnedError in
            if let error = returnedError {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
    }
    
    static func delete<T:CloudKitableProtocol>(item: T) -> Future<Bool, Error> {
        Future { promise in
            CloudKitUtility.delete(item: item, completion: promise)
        }
    }
    
    static private func delete<T:CloudKitableProtocol>(item: T, completion: @escaping (Result<Bool, Error>) -> ()) {
        CloudKitUtility.delete(record: item.record, completion: completion)
    }
    
    static private func delete(record: CKRecord, completion: @escaping (Result<Bool, Error>) -> ()) {
        Model().publicDB.delete(withRecordID: record.recordID) { returnedRecordID, returnedError in
            if let error = returnedError {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
    }
    

    static func saveAllRecords(_ records: [CKRecord]) {
    let maxNumberOfRecordsToModify = 100

            if records.count > maxNumberOfRecordsToModify {
                let sliceOfRecords = Array(records[0 ..< maxNumberOfRecordsToModify])
                let leftOverRecords = Array(records[maxNumberOfRecordsToModify ... records.count - 1])
                let operation = CKModifyRecordsOperation(recordsToSave: sliceOfRecords, recordIDsToDelete: nil)
                operation.savePolicy = CKModifyRecordsOperation.RecordSavePolicy.allKeys
                operation.qualityOfService = QualityOfService.userInitiated
                operation.modifyRecordsResultBlock = { results in
                    switch results {
                    case .failure(let error):
                        if let err = error as? CKError, let time = err.retryAfterSeconds {
                            Logger.log("saveAllRecords error retry \(error.localizedDescription) ")
                            DispatchQueue.main.asyncAfter(deadline: .now() + time) {
                                self.saveAllRecords(sliceOfRecords)
                            }
                        } else {
                            Logger.log("saveAllRecords error  \(error.localizedDescription) ")
                        }
                    case .success():
                        Logger.log("saveAllRecords continuing with \(leftOverRecords.count)")
                        self.saveAllRecords(leftOverRecords)
                    }
                }

                //operation.modifyRecordsCompletionBlock = { savedRecords, deletedRecordIDs, error in
//                    if error == nil {
//                        print("Batch saved records!")
//                        self.saveAllRecords(leftOverRecords)
//                    } else {
//                        if let err = error as? CKError, let time = err.retryAfterSeconds {
//                            print(err)
//                            DispatchQueue.main.asyncAfter(deadline: .now() + time) {
//                                self.saveAllRecords(sliceOfRecords)
//                            }
//                        } else {
//                            print(error!)
//                        }
//                    }
//                }
               // publicDB.add(operation)
                Model().publicDB.add(operation)
            } else {
                let operation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
                operation.savePolicy = CKModifyRecordsOperation.RecordSavePolicy.allKeys
                operation.qualityOfService = QualityOfService.userInitiated
                operation.modifyRecordsResultBlock = { results in
                    switch results {
                    case .failure(let error):
                        Logger.log("saveAllRecords error \(error.localizedDescription)")
                    case .success():
                        Logger.log("saveAllRecords success")
                    }
                }
//                operation.modifyRecordsCompletionBlock = { savedRecords, deletedRecordIDs, error in
//                    if error == nil {
//                        print("Batch saved records!")
//                    } else {
//                        if let err = error as? CKError, let time = err.retryAfterSeconds {
//                            print(err)
//                            DispatchQueue.main.asyncAfter(deadline: .now() + time) {
//                                self.saveAllRecords(records)
//                            }
//                        } else {
//                            print(error!)
//                        }
//                    }
//                }
               // publicDB.add(operation)
                Model().publicDB.add(operation)
            }
    }
    static func fetchAll<T:CloudKitableProtocol>(
        predicate: NSPredicate,
        recordType: CKRecord.RecordType,
        sortDescriptions: [NSSortDescriptor]? = nil,
        resultsLimit: Int? = nil
    ) -> Future<[T], Error> {
        Future { promise in
            CloudKitUtility.fetchAll(predicate: predicate, recordType: recordType, sortDescriptions: sortDescriptions, resultsLimit: resultsLimit) { (items: [T]) in
                promise(.success(items))
            }
        }
    }
    static private func fetchAll<T:CloudKitableProtocol>(
        predicate: NSPredicate,
        recordType: CKRecord.RecordType,
        sortDescriptions: [NSSortDescriptor]? = nil,
        resultsLimit: Int? = nil,
        completion: @escaping (_ items: [T]) -> ()) {
        var returnedItems: [T] = []
        let op = createOperation(predicate: predicate, recordType: recordType, sortDescriptions: sortDescriptions, resultsLimit: resultsLimit)
        func getChunk(_ op: CKQueryOperation, _ chunkNum: Int) {
            addRecordMatchedBlock(operation: op) { item in
                returnedItems.append(item)
            }
            op.queryResultBlock = { result in
                switch result {
                case .success(let cursor):
                    if let c = cursor {
                        if let limit = resultsLimit {
                            Logger.log("fetchAll Cursor with limit of \(limit) and records of \(returnedItems.count)")
                            if returnedItems.count >= limit {
                                completion(returnedItems)
                            } else {
                                let op = CKQueryOperation(cursor: c)
                                getChunk(op, chunkNum+1)
                            }
                        } else {
                        let op = CKQueryOperation(cursor: c)
                        getChunk(op, chunkNum+1)
                        }
                    } else {
                        completion(returnedItems)
                    }

                case .failure(let error):
                    Logger.log("fetchAll \(error.localizedDescription)")
                }
            }
            Model().publicDB.add(op)
        }
        getChunk(op, 1)
    }
    static func getAllRecordsAndDelete<T:CloudKitableProtocol>(
        predicate: NSPredicate,
        recordType: CKRecord.RecordType,
        sortDescriptions: [NSSortDescriptor]? = nil,
        resultsLimit: Int? = nil
            ) -> Future<[T], Error> {
                Future { promise in
                    CloudKitUtility.fetchAll(predicate: predicate, recordType: recordType, sortDescriptions: sortDescriptions, resultsLimit: resultsLimit) { (items: [T]) in
                        var myArray = [CKRecord.ID]()
                        for i in 0..<items.count {
                            myArray.append(items[i].record.recordID)

                        }
                         deleteAllRecords(myArray)
                        promise(.success(items))

                    }
                }
        }
    static private func deleteAllRecords(_ records: [CKRecord.ID]) {
        let maxNumberOfRecordsToModify = 400
                if records.count > maxNumberOfRecordsToModify {
                    let sliceOfRecords = Array(records[0 ..< maxNumberOfRecordsToModify])
                    let leftOverRecords = Array(records[maxNumberOfRecordsToModify ... records.count - 1])
                    let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: sliceOfRecords)
                    operation.savePolicy = CKModifyRecordsOperation.RecordSavePolicy.allKeys
                    operation.qualityOfService = QualityOfService.userInitiated
                    operation.modifyRecordsResultBlock = { results in
                        switch results {
                        case .failure(let error):
                            if let err = error as? CKError, let time = err.retryAfterSeconds {
                                Logger.log("deleteAllRecords error retry \(error.localizedDescription) ")
                                DispatchQueue.main.asyncAfter(deadline: .now() + time) {
                                    self.deleteAllRecords(sliceOfRecords)
                                }
                            } else {
                                Logger.log("deleteAllRecords error  \(error.localizedDescription) ")
                            }
                        case .success():
                            Logger.log("deleteAllRecords continuing with \(leftOverRecords.count)")
                            self.deleteAllRecords(leftOverRecords)
                        }

                    }
                    Model().publicDB.add(operation)
                } else {
                    let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: records)
                    operation.savePolicy = CKModifyRecordsOperation.RecordSavePolicy.allKeys
                    operation.qualityOfService = QualityOfService.userInitiated
                    operation.modifyRecordsResultBlock = { results in
                        switch results {
                        case .failure(let error):
                            if let err = error as? CKError, let time = err.retryAfterSeconds {
                                Logger.log("deleteAllRecords error retry \(error.localizedDescription) ")
                                DispatchQueue.main.asyncAfter(deadline: .now() + time) {
                                    self.deleteAllRecords(records)
                                }
                            } else {
                                Logger.log("deleteAllRecords error  \(error.localizedDescription) ")
                            }
                        case .success():
                            Logger.log("deleteAllRecords Done with \(records.count)")
                        }

                    }

                    Model().publicDB.add(operation)
                }
        }
}
