//
//  CloudKitHelper.swift
//  Document Scanner
//
//  Created by Sandesh on 23/06/21.
//

import Foundation
import CloudKit

class CloudKitHelper {
    
    static let shared = CloudKitHelper()
    
    typealias CompletionHandler = (CKRecord?, Error?) -> Void
    
    var ckContainer: CKContainer
    var ckPrivateDB: CKDatabase
    
    private init() {
        ckContainer = CKContainer(identifier: CloudKitConstants.containerID)
        ckPrivateDB = ckContainer.privateCloudDatabase
        addSubscriptions()
    }
    
    private func addSubscriptions() {
        let predicate = NSPredicate(value: true)
        let callSubscriptionQuery = CKQuerySubscription(recordType: CloudKitConstants.Records.document, predicate: predicate,
                                                        options: [.firesOnRecordCreation, .firesOnRecordDeletion])
        let serverFetchDateQuery = CKQuerySubscription(recordType: CloudKitConstants.Records.page, predicate: predicate,
                                                       options: [.firesOnRecordCreation, .firesOnRecordUpdate])
        
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        notificationInfo.desiredKeys = [CloudKitConstants.DocumentRecordFields.id]
        
        callSubscriptionQuery.notificationInfo = notificationInfo
        serverFetchDateQuery.notificationInfo = notificationInfo
        
//        if !UserDefaults.standard.bool(forKey: Constants.CallRecorderDefaults.subscribedToCallRecordChangesKey) {
//            ckPrivateDB.save(callSubscriptionQuery) { subscription, error in
//                guard error == nil else { return }
//                guard subscription != nil else { return }
//                UserDefaults.standard.set(true, forKey: Constants.CallRecorderDefaults.subscribedToCallRecordChangesKey)
//                AnalyticsHelper.shared.logEvent(.iCloudSubscribedToCallRecordChanges)
//            }
//        }
//        if !UserDefaults.standard.bool(forKey: Constants.CallRecorderDefaults.subscribedToServerFetchDateRecordChangesKey) {
//            ckPrivateDB.save(serverFetchDateQuery) { subscription, error in
//                guard error == nil else { return }
//                guard subscription != nil else { return }
//                UserDefaults.standard.set(true, forKey: Constants.CallRecorderDefaults.subscribedToServerFetchDateRecordChangesKey)
//                AnalyticsHelper.shared.logEvent(.iCloudSubscribedToLastServerFetchDateChange)
//            }
//        }
    }
    
    ///Getting id's of document already uploaded to iCloud
    var idsOfDocumentUploadedToiCloud: Set<String> {
        let userDefaultKey = Constants.DocumentScannerDefaults.idsOfDocumentUploadedToiCLoudKey
        guard let documentIDs = UserDefaults.standard.object(forKey: userDefaultKey) as? [String] else { return [] }
        return Set(documentIDs)
    }
    
    ///Caching document id of document that are uploaded to iCloud, to avoid re upload
    func markDocumentAsUploadedToiCloud(with id: String) {
        var documentIdSet = idsOfDocumentUploadedToiCloud
        documentIdSet.insert(id)
        UserDefaults.standard.setValue(Array(documentIdSet), forKey: Constants.DocumentScannerDefaults.idsOfDocumentUploadedToiCLoudKey)
    }

    //Getting id's of pages already uploaded to iCloud
    var idsOfPagesUploadedToiCould: Set<String> {
        let userDefaultKey = Constants.DocumentScannerDefaults.idsOfPagesUploadedToiCloudKey
        guard let pageIDs = UserDefaults.standard.object(forKey: userDefaultKey) as? [String] else { return [] }
        return Set(pageIDs)
    }
    
    ///Caching document id of document that are uploaded to iCloud, to avoid re upload
    func markPageAsUploadedToiCloud(with id: String) {
        var pageIdSet = idsOfPagesUploadedToiCould
        pageIdSet.insert(id)
        UserDefaults.standard.setValue(Array(pageIdSet), forKey: Constants.DocumentScannerDefaults.idsOfDocumentUploadedToiCLoudKey)
    }
    
    ///Getting ids of document that are marked for deletion from iCloud, incase deletion failed from first attempt
    var idsOfDocumentMarkedForDeletionFromiCloud: Set<String> {
        let userDefaultKey = Constants.DocumentScannerDefaults.idsOfDocumentsMarkedForDeletionFromiCloudKey
        guard let documentIds = UserDefaults.standard.object(forKey: userDefaultKey) as? [String] else { return [] }
        return Set(documentIds)
    }
    
    var idsOfPagesMarkedFromDeletionFromiCloud: Set<String> {
        let userDefaultKey = Constants.DocumentScannerDefaults.idsOfPagesMarkedForDeletionFromiCloud
        guard let pageIds = UserDefaults.standard.object(forKey: userDefaultKey) as? [String] else { return [] }
        return Set(pageIds)
    }
    
    ///this function is for testing purpose only
    func deleteLocalCaches() {
        UserDefaults.standard.setValue([], forKey: Constants.DocumentScannerDefaults.idsOfDocumentUploadedToiCLoudKey)
        UserDefaults.standard.setValue([], forKey: Constants.DocumentScannerDefaults.idsOfPagesUploadedToiCloudKey)
        UserDefaults.standard.setValue([], forKey: Constants.DocumentScannerDefaults.idsOfDocumentsMarkedForDeletionFromiCloudKey)
        UserDefaults.standard.setValue([], forKey: Constants.DocumentScannerDefaults.idsOfPagesMarkedForDeletionFromiCloud)
    }
    
    //saves single record to iCloud
    func saveRecord(_ record: CKRecord, _ completion: @escaping CompletionHandler) {
            ckPrivateDB.save(record) { record, error in
                completion(record, error)
        }
    }
    
    ///Checks iCloud for new documents and fetches them
    func fetchDocumentsFromiCloudIfAny() {
        DispatchQueue.global().async {
            let predicate = NSPredicate(format: "NOT (\(CloudKitConstants.DocumentRecordFields.id) IN %@)", self.idsOfDocumentUploadedToiCloud)
            let query = CKQuery(recordType: CloudKitConstants.Records.document, predicate: predicate)
            dump(self.idsOfDocumentUploadedToiCloud)
            print(predicate)
            self.ckPrivateDB.perform(query, inZoneWith: nil) { records, error in
                guard error == nil else {
                    print("Unable to fetch records, error: \(error!.localizedDescription)")
                    return
                }
                
                guard let records = records else { return }
                var document: [Document] = []
                for record in records {
                    if let call = Document(record) {
                        calls.append(call)
                        self.markCallAsStoredToiCloud(call.callId)
                        AnalyticsHelper.shared.logEvent(.iCloudCallFetched, properties: [
                                                            .recordId: record.recordID.recordName
                        ])
                    }
                }
                self._saveFetchedCallsLocally(calls)
            }
        }
    }
    
    func fetchLastServerRecordingFetchedDate() {
        DispatchQueue.global().async {
            let predicate = NSPredicate(value: true)
            let query = CKQuery(recordType: CloudKitConstants.Records.serverFetchDate, predicate: predicate)
            self.executeQuery(query) { records, error in
                guard error == nil else {
                    print("Unable to fetch records, error: \(error!.localizedDescription)")
                    return
                }
                guard let records = records, records.count > 0 else { return }
                let latestRecord: CKRecord
                latestRecord = (records.sorted { $0.creationDate ?? Date() < $1.creationDate ?? Date() }).last!
                
                guard let lastFetchedDate = latestRecord.value(forKey: CloudKitConstants.ServerFetchDateFields.date) as? Date  else { return }
                Call.setLastFetchDate(date: lastFetchedDate, fetchedFromiCloud: true)
                UserDefaults.standard.setValue(latestRecord.recordID.recordName,
                                               forKey: Constants.CallRecorderDefaults.lastFetchedDateiCloudRecordIDKey)
                AnalyticsHelper.shared.logEvent(.iCloudLastServerFetchDateFetched, properties: [
                    .recordId: latestRecord.recordID.recordName,
                    .lastFetchDate: lastFetchedDate
                ])
                NotificationCenter.default.post(name: .didFetchedServerFetchDate, object: nil)
                                
                self.fetchCallsFromCloudIfAny()
                //delete older records if any
                records.forEach { record in
                    if record.recordID != latestRecord.recordID {
                        self.ckPrivateDB.delete(withRecordID: record.recordID) { _, _ in }
                    }
                }
            }
        }
    }
    
    func executeQuery(_ query: CKQuery, _ completion: @escaping ([CKRecord]?, Error?) -> Void) {
        ckPrivateDB.perform(query, inZoneWith: nil) { records, error in
            completion(records, error)
        }
    }
    
    func deleteCallFromiCloudIfMarked() {
        for callId in callIDsOfCallsMarkedForDeletionFromiCloud {
            deleteCallFromiCloud(with: callId)
        }
    }
    
    func deleteCallFromiCloud(with callId: String) {
        DispatchQueue.global().async {
            self.callIDsOfCallsMarkedForDeletionFromiCloud.insert(callId)
            let predicate = NSPredicate(format: "\(CloudKitConstants.CallRecordFields.callID) == %@", callId)
            let query = CKQuery(recordType: CloudKitConstants.Records.call, predicate: predicate)
            
            CloudKitHelper.shared.executeQuery(query) { records, error in
                if let error = error {
                    print("Unable to fetch selected record for deletion from iCloud: \(error.localizedDescription)")
                    return
                }
                guard let records = records else {
                    return
                }
                for record in records {
                    self.ckPrivateDB.delete(withRecordID: record.recordID) { recordId, error in
                        if let error = error {
                            print("Unable to delete record from iCloud: \(error.localizedDescription)")
                        }
                        print("success")
                        AnalyticsHelper.shared.logEvent(.iCloudRecordDeleted, properties: [
                            .recordId: recordId?.recordName ?? "--",
                            .callId: callId
                        ])
                    }
                }
            }
        }
    }
    
    private func _saveFetchedCallsLocally(_ calls: [Call]) {
        Section.addCallsToSectionAndSave(calls)
    }
    
    func backupLastFetchDateToiCLoudIfNeeded(_ force: Bool = false) {
        DispatchQueue.global().async {
            if !UserDefaults.standard.bool(forKey: Constants.CallRecorderDefaults.lastFetchDateBackupStatusKey) || force {
                guard let date = Call.lastFetchDate() else { return }
                if let lastFectchedDateiCloudRecordID = Call.lastFetchdeDateiCloudRecordID() {
                    // record existe need to  update it
                    self.ckPrivateDB.fetch(withRecordID: lastFectchedDateiCloudRecordID) { [self] record, error in
                        guard error == nil else {
                            print("Unable to update last fetch date error: \(error!.localizedDescription)")
                            UserDefaults.standard.set(false, forKey: Constants.CallRecorderDefaults.lastFetchDateBackupStatusKey)
                            return
                        }
                        guard let record = record else { return }
                        record.setValue(date, forKey: CloudKitConstants.ServerFetchDateFields.date)
                        self.saveRecord(record) { record, error in
                            guard error == nil else {
                                print("Unable to update last fetch date record, error: \(error!.localizedDescription)")
                                UserDefaults.standard.set(false, forKey: Constants.CallRecorderDefaults.lastFetchDateBackupStatusKey)
                                return
                            }
                            guard let record = record else { return }
                            AnalyticsHelper.shared.logEvent(.iCloudUpdatedLastFetchedDate, properties: [
                                                                .recordId: record.recordID.recordName,
                                                                .lastFetchDate: date])
                        }
                        UserDefaults.standard.set(true, forKey: Constants.CallRecorderDefaults.lastFetchDateBackupStatusKey)
                    }
                } else {
                    //add new entry
                    let lastFetchRecord = CKRecord(recordType: CloudKitConstants.Records.serverFetchDate)
                    lastFetchRecord.setValue(date as NSDate, forKey: CloudKitConstants.ServerFetchDateFields.date)
                    CloudKitHelper.shared.saveRecord(lastFetchRecord) { record, error in
                        guard error == nil else {
                            print("Unable to save record \(lastFetchRecord), error: \(error!.localizedDescription)")
                            UserDefaults.standard.set(false, forKey: Constants.CallRecorderDefaults.lastFetchDateBackupStatusKey)
                            return
                        }
                        guard let record = record else { return }
                        let lastFetchDateRecordIdKey = Constants.CallRecorderDefaults.lastFetchedDateiCloudRecordIDKey
                        UserDefaults.standard.setValue(record.recordID.recordName, forKey: lastFetchDateRecordIdKey)
                        UserDefaults.standard.set(true, forKey: Constants.CallRecorderDefaults.lastFetchDateBackupStatusKey)
                        AnalyticsHelper.shared.logEvent(.iCloudUpdatedLastFetchedDate, properties: [
                                                            .recordId: record.recordID.recordName,
                                                            .lastFetchDate: date])
                    }
                }
            }
        }
    }
    
    func scaniCloudForDeletedRecordsAndDeleteLocally() {
        DispatchQueue.global().async {
            let predicate = NSPredicate(value: true)
            let query = CKQuery(recordType: CloudKitConstants.Records.call, predicate: predicate)
            let operation = CKQueryOperation(query: query)
            operation.desiredKeys = ["callID"]
            
            self.ckPrivateDB.perform(query, inZoneWith: nil) { records, error in
                guard error == nil else {
                    print("Unable to fetch records, error: \(error!.localizedDescription)")
                    return
                }
                guard let records = records else { return }
                var callIdFetchedFromServer: Set<String> = []
                for record in records {
                    if let id = record["callID"] as? String {
                        callIdFetchedFromServer.insert(id)
                    }
                }
                print(callIdFetchedFromServer)
                print(self.callIDsOfCallsUploadedToiCloud)
                
                self.callIDsOfCallsUploadedToiCloud.forEach { callId in
                    if !callIdFetchedFromServer.contains(callId) {
                        Section.deleteCall(with: callId)
                    }
                }
            }
        }
    }
    
    func handleCloudKit(notification: CKNotification) {
        if notification.notificationType == .query {
            guard let queryNotification = notification as? CKQueryNotification else { return }
            switch queryNotification.queryNotificationReason {
            case .recordCreated:
                CloudKitHelper.shared.fetchCallsFromCloudIfAny()
                CloudKitHelper.shared.fetchLastServerRecordingFetchedDate()
                AnalyticsHelper.shared.logEvent(.iCloudReceivedRecordCreationNotification, properties: [
                    .recordId: queryNotification.recordID?.recordName ?? "--"
                ])
            case .recordUpdated:
                CloudKitHelper.shared.fetchLastServerRecordingFetchedDate()
                AnalyticsHelper.shared.logEvent(.iCloudReceivedLastServerFetchDateChangeNotification, properties: [
                    .recordId: queryNotification.recordID?.recordName ?? "--"
                ])
            case .recordDeleted:
                AnalyticsHelper.shared.logEvent(.iCloudReceivedRecordDeleteNotification, properties: [
                    .recordId: queryNotification.recordID?.recordName ?? "--"
                ])
                guard  let recordFields = queryNotification.recordFields,
                       let callID = recordFields[CloudKitConstants.CallRecordFields.callID] as? String else { return }
                Section.deleteCall(with: callID)
            @unknown default: break
            }
            NotificationCenter.default.post(name: .callsGotUpdatedInBackground, object: nil, userInfo: nil)
        }
    }
}
