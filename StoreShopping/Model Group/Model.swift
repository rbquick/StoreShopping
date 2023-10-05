
import CloudKit
class Model {
    // MARK: - iCloud Info
    let container: CKContainer
    let publicDB: CKDatabase
    let privateDB: CKDatabase
    init() {
        container = CKContainer(identifier: "iCloud.com.codewithbrian.StoreShopping")
        publicDB = container.publicCloudDatabase
        privateDB = container.privateCloudDatabase
    }
}







////
////  Model.swift
////  icloudMACOS
////
////  Created by Brian Quick on 2021-07-03.
////
//
//
//import CloudKit
//
//class Model {
//  // MARK: - iCloud Info
//  let container: CKContainer
//  let publicDB: CKDatabase
//  let privateDB: CKDatabase
//    init() {
//      container = CKContainer(identifier: "iCloud.com.codewithbrian.icloudMACOS")
//      publicDB = container.publicCloudDatabase
//      privateDB = container.privateCloudDatabase
//    }
//    // MARK: - errors
//
//    enum ModelFunctions {
//        case initial
//        case add
//        case delete
//        case change
//    }
//
//
//    var lastCount = 0
//    var processingCount = false
//
//  static var currentModel = Model()
//
//
//    func fetchAll(
//        query: CKQuery, resultsLimit: Int = 100, timeout: TimeInterval = 60,
//        completion: @escaping (Result<[CKRecord], Error>) -> Void
//    ) {
//        DispatchQueue.global().async { [unowned self] in
//            let semaphore = DispatchSemaphore(value: 0)
//            var records = [CKRecord]()
//            var error: Error?
//
//            var operation = CKQueryOperation(query: query)
//            operation.resultsLimit = resultsLimit
//            operation.recordFetchedBlock = { records.append($0) }
//            operation.queryCompletionBlock = { (cursor, err) in
//                guard err == nil, let cursor = cursor else {
//                    error = err
//                    semaphore.signal()
//                    return
//                }
//                let newOperation = CKQueryOperation(cursor: cursor)
//                newOperation.resultsLimit = operation.resultsLimit
//                newOperation.recordMatchedBlock = operation.recordMatchedBlock
//                newOperation.queryResultBlock = operation.queryResultBlock
//                operation = newOperation
//                publicDB.add(newOperation)
//            }
//            publicDB.add(operation)
//
//            _ = semaphore.wait(timeout: .now() + 60)
//
//            if let error = error {
//                completion(.failure(error))
//            } else {
//                completion(.success(records))
//            }
//        }
//    }
//    func fetchRecord(recordID: CKRecord.ID, _ perRecordCompletion: @escaping (CKRecord?, Error?) -> Void) {
//
//        let fetchRecordsOperation = CKFetchRecordsOperation(recordIDs: [recordID])
//
//        //var perRecordResultBlock: ((_ recordID: CKRecord.ID, _ recordResult: Result<CKRecord, Error>) -> Void)? { get set }
////        fetchRecordsOperation.perRecordResultBlock = { ( _, recordResult: result<CKRecord, Error>); result; in
////            // Continue if there are no errors
////                switch recordResult {
////                case .success(let record):
////                    print("\(record.id)")
////                case .failure(let error):
////                    print(error.localizedDescription)
////                }
////            }
//                //open var perRecordCompletionBlock: ((CKRecord?, CKRecord.ID?, Error?) -> Void)?
//                fetchRecordsOperation.perRecordCompletionBlock = { (record: CKRecord?, recordID: CKRecord.ID?, error: Error?) -> Void in
//            DispatchQueue.main.async {
//                guard error == nil else {
//                    perRecordCompletion(nil, error)
//                    return
//                }
//                perRecordCompletion(record, error)
//                return
//            }
//        }
//        publicDB.add(fetchRecordsOperation)
//    }
//    func modifyARecord(record: CKRecord, _ perRecordCompletion: @escaping (CKRecord?, Error?) -> Void) {
//
//        let modifyRecordsOperation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: [])
//        //var modifyRecordsCompletionBlock: (([CKRecord]?, [CKRecord.ID]?, Error?) -> Void)? { get set }
//        modifyRecordsOperation.modifyRecordsCompletionBlock = { _, _, error  in
//
//            // Continue if there are no errors
//            DispatchQueue.main.async {
//                guard error == nil else {
//                    perRecordCompletion(nil, error)
//                    return
//                }
//                perRecordCompletion(nil, error)
//                return
//            }
//        }
//        publicDB.add(modifyRecordsOperation)
//    }
//    func modifyRecords(records: [CKRecord], _ perRecordCompletion: @escaping (CKRecord?, Error?) -> Void) {
//
//        let modifyRecordsOperation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: [])
//
//        modifyRecordsOperation.modifyRecordsCompletionBlock = { _, _, error  in
//            // Continue if there are no errors
//            DispatchQueue.main.async {
//            guard error == nil else {
//                perRecordCompletion(nil, error)
//                return
//            }
//             perRecordCompletion(nil, error)
//            return
//        }
//        }
//        publicDB.add(modifyRecordsOperation)
//    }
//    func deleteARecord(recordID: CKRecord.ID, _ perRecordCompletion: @escaping ( Error?) -> Void) {
//
//        let modifyRecordsOperation = CKModifyRecordsOperation(recordsToSave: [], recordIDsToDelete: [recordID])
//
//        modifyRecordsOperation.modifyRecordsCompletionBlock = { ( _, _, error) -> Void in
//            // Continue if there are no errors
//            DispatchQueue.main.async {
//            guard error == nil else {
//                perRecordCompletion(error)
//                return
//            }
//             perRecordCompletion(error)
//            return
//        }
//        }
//        publicDB.add(modifyRecordsOperation)
//    }
//    func deleteRecords(recordID: [CKRecord.ID], _ perRecordCompletion: @escaping ( Error?) -> Void) {
//
//        let modifyRecordsOperation = CKModifyRecordsOperation(recordsToSave: [], recordIDsToDelete: recordID)
//
//        modifyRecordsOperation.modifyRecordsCompletionBlock = { ( _, _, error) -> Void in
//            // Continue if there are no errors
//            DispatchQueue.main.async {
//            guard error == nil else {
//                perRecordCompletion(error)
//                return
//            }
//             perRecordCompletion(error)
//            return
//        }
//        }
//        publicDB.add(modifyRecordsOperation)
//    }
//    public func save(record: CKRecord, completion: @escaping (Error?) -> Void)
//        {
//            let modifyRecordsOperation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: [])
//            modifyRecordsOperation.modifyRecordsCompletionBlock = { _, _, error in
//                DispatchQueue.main.async {
//                guard error == nil else {
//                    guard let ckerror = error as? CKError else {
//                        completion(error)
//                        return
//                    }
//                    if ckerror.code == .partialFailure {
//                        // This is a multiple-issue error. Check the underlying array
//                        // of errors to see if it contains a match for the error in question.
//                        guard let errors = ckerror.partialErrorsByItemID else {
//                            completion(error)
//                            return
//                        }
//                        for (_, error) in errors {
//                            if let currentError = error as? CKError {
//                                if currentError.code == CKError.zoneNotFound {
//                                    completion(error)
//                                    return
//                                }
//                            }
//                        }
//                    }
//                    completion(error)
//                    return
//                }
//                }
//                // The record has been saved without errors
//                completion(nil)
//            }
//            publicDB.add(modifyRecordsOperation)
//        }
//
//    // https://developer.apple.com/forums/thread/131992
//        func saveAllRecords(_ records: [CKRecord]) -> String {
//            let maxNumberOfRecordsToModify = 50
//
//                    if records.count > maxNumberOfRecordsToModify {
//                        let sliceOfRecords = Array(records[0 ..< maxNumberOfRecordsToModify])
//                        let leftOverRecords = Array(records[maxNumberOfRecordsToModify ... records.count - 1])
//                        let operation = CKModifyRecordsOperation(recordsToSave: sliceOfRecords, recordIDsToDelete: nil)
//                        operation.savePolicy = CKModifyRecordsOperation.RecordSavePolicy.allKeys
//                        operation.qualityOfService = QualityOfService.userInitiated
//                        operation.modifyRecordsCompletionBlock = { savedRecords, deletedRecordIDs, error in
//                            if error == nil {
//                                print("Batch greater saved records!")
//                                _ = self.saveAllRecords(leftOverRecords)
//                            } else {
//                                if let err = error as? CKError, let time = err.retryAfterSeconds {
//                                    print(err)
//                                    DispatchQueue.main.asyncAfter(deadline: .now() + time) {
//                                        _ = self.saveAllRecords(sliceOfRecords)
//                                    }
//                                } else {
//                                    print(error!)
//                                }
//                            }
//                        }
//                        publicDB.add(operation)
//                    } else {
//                        let operation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
//                        operation.savePolicy = CKModifyRecordsOperation.RecordSavePolicy.allKeys
//                        operation.qualityOfService = QualityOfService.userInitiated
//                        operation.modifyRecordsCompletionBlock = { savedRecords, deletedRecordIDs, error in
//                            if error == nil {
//                                print("Batch total saved records!")
////                                if savedRecords?.count ?? 0 > 0 {
////                                    self.printNumberOfRecords(recordType: (savedRecords?[0].recordType)!)
////                                }
//                            } else {
//                                if let err = error as? CKError, let time = err.retryAfterSeconds {
//                                    print(err)
//                                    DispatchQueue.main.asyncAfter(deadline: .now() + time) {
//                                        _ = self.saveAllRecords(records)
//                                    }
//                                } else {
//                                    print(error!)
//                                }
//                            }
//                        }
//                        publicDB.add(operation)
//                    }
//                return "records saved."
//            }
//    func NumberOfRecords(recordType: String, predicate: NSPredicate) {
//
//        let query = CKQuery(recordType: recordType, predicate: predicate)
//        let op = CKQueryOperation(query: query)
//        lastCount = 0
//        processingCount = true
//        func getChunk(_ op: CKQueryOperation, _ chunkNum: Int) {
//        op.recordFetchedBlock = { rec in
//                self.lastCount += 1
//            }
//            op.queryCompletionBlock = { cursor, error in
//                print("finished chunk \(chunkNum). Count so far: \(self.lastCount)")
//                if let error = error {
//                    print(error)
//                } else if let c = cursor {
//                    let op = CKQueryOperation(cursor: c)
//                    getChunk(op, chunkNum+1)
//                } else {
//                    self.processingCount = false
//                    print("Done. Record count = \(self.lastCount)")
//                }
//            }
//            publicDB.add(op)
//        }
//        getChunk(op, 1)
//
//    }
//
//}
