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
        runBackgroundUpdates()
    }
    
    func runBackgroundUpdates() {
        _fetchDocumentsFromiCloudIfAny()
        _scaniCloudForDeletedDocumentsAndDeleteLocally()
        _deleteCallFromiCloudIfMarked()
    }
    
    // MARK: - Background task
    private func _deleteCallFromiCloudIfMarked() {
        for documentID in idsOfDocumentMarkedForDeletionFromiCloud {
            deletedDocumentFromiCloud(with: documentID)
        }
    }
    
    private func _uploadPendingDocumentToiCloudIfAny() {
        for documentID in idsOfPagesMarkedForiCloudUpload {
            //TODO: - get document based on documet Id
        }
    }
    
    private func _uploadPendingPagesToiCloudIfAny() {
        for pageId in idsOfPagesMarkedForiCloudUpload {
            //TODO: - get page and document from page id
        }
    }
    
    private func addSubscriptions() {
        let predicate = NSPredicate(value: true)
        let documentSubscriptionQuery = CKQuerySubscription(recordType: CloudKitConstants.Records.document, predicate: predicate,
                                                        options: [.firesOnRecordCreation, .firesOnRecordDeletion, .firesOnRecordUpdate])
        let pageSubscriptionQuery = CKQuerySubscription(recordType: CloudKitConstants.Records.page, predicate: predicate,
                                                       options: [.firesOnRecordCreation, .firesOnRecordUpdate])
        
        let documentNotificationInfo = CKSubscription.NotificationInfo()
        documentNotificationInfo.shouldSendContentAvailable = true
        documentNotificationInfo.desiredKeys = [CloudKitConstants.DocumentRecordFields.id]
        
        let pageNotificationInfo =  CKSubscription.NotificationInfo()
        pageNotificationInfo.shouldSendContentAvailable = true
        pageNotificationInfo.desiredKeys = [CloudKitConstants.PageRecordFields.id]
        
        documentSubscriptionQuery.notificationInfo = documentNotificationInfo
        pageSubscriptionQuery.notificationInfo = pageNotificationInfo
        
        if !UserDefaults.standard.bool(forKey: Constants.DocumentScannerDefaults.iCloudDocumentRecordSubscriptionKey) {
            ckPrivateDB.save(documentSubscriptionQuery) { subscription, error in
                guard error == nil else { return }
                guard subscription != nil else { return }
                UserDefaults.standard.set(true, forKey: Constants.DocumentScannerDefaults.iCloudDocumentRecordSubscriptionKey)
                //TODO: - Add analytics
            }
        }
        if !UserDefaults.standard.bool(forKey: Constants.DocumentScannerDefaults.iCloudPageRecordSubscriptionKey) {
            ckPrivateDB.save(pageSubscriptionQuery) { subscription, error in
                guard error == nil else { return }
                guard subscription != nil else { return }
                UserDefaults.standard.set(true, forKey: Constants.DocumentScannerDefaults.iCloudPageRecordSubscriptionKey)
                //TODO: - Add analytics
            }
        }
    }
    
    // MARK: - Document Upload
    ///Returns  id's of document already uploaded to iCloud
    var idsOfDocumentUploadedToiCloud: Set<String> {
        let userDefaultKey = Constants.DocumentScannerDefaults.idsOfDocumentUploadedToiCLoudKey
        guard let documentIDs = UserDefaults.standard.object(forKey: userDefaultKey) as? [String] else { return [] }
        return Set(documentIDs)
    }
    
    ///Saves document id of document that are uploaded to iCloud, to avoid re upload
    private func _markDocumentAsUploadedToiCloud(document: Document) {
        var documentIdSet = idsOfDocumentUploadedToiCloud
        documentIdSet.insert(document.id)
        UserDefaults.standard.setValue(Array(documentIdSet), forKey: Constants.DocumentScannerDefaults.idsOfDocumentUploadedToiCLoudKey)
        
        //removing document from list of documents marked for iCloud upload
        var documentsMarkedForUpload = idsOfDocumentMarkedForiCloudUpload
        if let index = documentsMarkedForUpload.firstIndex(of: document.id) {
            documentsMarkedForUpload.remove(at: index)
            UserDefaults.standard.setValue(Array(documentsMarkedForUpload), forKey: Constants.DocumentScannerDefaults.idsOfDocumentsMarkedForiCloudUploadKey)
        }
    }
    
    ///Returns ids of document marked for iCloud upload
    var idsOfDocumentMarkedForiCloudUpload: Set<String> {
        let userDefaultKey = Constants.DocumentScannerDefaults.idsOfDocumentsMarkedForiCloudUploadKey
        guard let documentIDs = UserDefaults.standard.object(forKey: userDefaultKey) as? [String] else { return [] }
        return Set(documentIDs)
    }

    ///Saving document ids for  iCloud upload
    private func _markDocumentForiCloudUpload(_ document: Document) {
        var documentIdSet = idsOfDocumentMarkedForiCloudUpload
        documentIdSet.insert(document.id)
        UserDefaults.standard.setValue(Array(documentIdSet), forKey: Constants.DocumentScannerDefaults.idsOfDocumentsMarkedForiCloudUploadKey)
    }
    
    // MARK: - Page Upload
    ///Returns  id's of pages already uploaded to iCloud
    var idsOfPagesUploadedToiCould: Set<String> {
        let userDefaultKey = Constants.DocumentScannerDefaults.idsOfPagesUploadedToiCloudKey
        guard let pageIDs = UserDefaults.standard.object(forKey: userDefaultKey) as? [String] else { return [] }
        return Set(pageIDs)
    }
    
    ///Caching document id of document that are uploaded to iCloud, to avoid re upload
    private func _markPageAsUploadedToiCloud(with id: [String]) {
        var pageIdSet = idsOfPagesUploadedToiCould
        var pagesMarkedForUpload = idsOfPagesMarkedForiCloudUpload
        id.forEach {
            pageIdSet.insert($0)
            //removing page from list of documents marked for iCloud upload
            if let index = pagesMarkedForUpload.firstIndex(of: $0) { pagesMarkedForUpload.remove(at: index) }
        }
        UserDefaults.standard.setValue(Array(pagesMarkedForUpload), forKey: Constants.DocumentScannerDefaults.idsOfPagesMarkedForiCloudUploadKey)
        UserDefaults.standard.setValue(Array(pageIdSet), forKey: Constants.DocumentScannerDefaults.idsOfDocumentUploadedToiCLoudKey)
    }
    
    var idsOfPagesMarkedForiCloudUpload: Set<String> {
        let userDefaultKey = Constants.DocumentScannerDefaults.idsOfPagesMarkedForiCloudUploadKey
        guard let pageIDs = UserDefaults.standard.object(forKey: userDefaultKey) as? [String] else { return [] }
        return Set(pageIDs)
    }
    
    ///Saving  ids pages  for iCloud upload
    private func _markPageForiCloudUpload(page: Page) {
        var pageIdSet = idsOfPagesMarkedForiCloudUpload
        pageIdSet.insert(page.id)
        UserDefaults.standard.setValue(Array(pageIdSet), forKey: Constants.DocumentScannerDefaults.idsOfDocumentUploadedToiCLoudKey)
    }
    
    // MARK: - Document Deletion
    ///Returns ids of document that are marked for deletion from iCloud, incase deletion failed from first attempt
    var idsOfDocumentMarkedForDeletionFromiCloud: Set<String> {
        let userDefaultKey = Constants.DocumentScannerDefaults.idsOfDocumentsMarkedForDeletionFromiCloudKey
        guard let idsOfDocument = UserDefaults.standard.object(forKey: userDefaultKey) as? [String] else { return []  }
        return Set(idsOfDocument)
    }
    
    ///Saving id of document marked for deletion from iCloud
    private func _markDocumentIDForDeletion(_ documentID: String) {
        var documentIDs = idsOfPagesMarkedForDeletionFromiCloud
        documentIDs.insert(documentID)
        UserDefaults.standard.setValue(Array(documentIDs), forKey: Constants.DocumentScannerDefaults.idsOfDocumentsMarkedForDeletionFromiCloudKey)
    }
    
    var idsOfPagesMarkedForDeletionFromiCloud: Set<String> {
        let userDefaultKey = Constants.DocumentScannerDefaults.idsOfPagesMarkedForDeletionFromiCloudKey
        guard let pageIds = UserDefaults.standard.object(forKey: userDefaultKey) as? [String] else { return [] }
        return Set(pageIds)
    }
    
    ///this function is for testing purpose only
    func deleteLocalCaches() {
        UserDefaults.standard.setValue([], forKey: Constants.DocumentScannerDefaults.idsOfDocumentUploadedToiCLoudKey)
        UserDefaults.standard.setValue([], forKey: Constants.DocumentScannerDefaults.idsOfPagesUploadedToiCloudKey)
        UserDefaults.standard.setValue([], forKey: Constants.DocumentScannerDefaults.idsOfDocumentsMarkedForDeletionFromiCloudKey)
        UserDefaults.standard.setValue([], forKey: Constants.DocumentScannerDefaults.idsOfPagesMarkedForDeletionFromiCloudKey)
    }
    
    //saves single record to iCloud
    func saveRecord(_ record: CKRecord, _ completion: @escaping CompletionHandler) {
            ckPrivateDB.save(record) { record, error in
                completion(record, error)
        }
    }
    
    func executeQuery(_ query: CKQuery, _ completion: @escaping ([CKRecord]?, Error?) -> Void) {
        ckPrivateDB.perform(query, inZoneWith: nil) { records, error in
            completion(records, error)
        }
    }
    
    func save(document: Document) {
        DispatchQueue.global(qos: .utility).async { [self] in
            
            let documentCKRecord = document.cloudKitRecord()
            var pageCKRecords: [CKRecord] = []
            
            for page in document.pages {
                guard let pageRecord =  page.cloudKitRecord(parent: documentCKRecord) else {
                    _markDocumentForiCloudUpload(document)
                    print("Failed converting pages to record")
                    return
                }
                pageCKRecords.append(pageRecord)
            }
            
            //turrning page records in to page references
            let pageRefrences = pageCKRecords.map { record in
                CKRecord.Reference(record: record, action: .none)
            }
            
            documentCKRecord.setValue(pageRefrences as NSArray, forKeyPath: CloudKitConstants.DocumentRecordFields.pages)
            
            let query = CKModifyRecordsOperation()
            //Creating records array for single document, appending document record to all its pages record
            let documentRecords = pageCKRecords + [documentCKRecord]
            query.recordsToSave = documentRecords
            query.isAtomic = true
            query.modifyRecordsCompletionBlock = { records, recordIds, error in
                guard error == nil else {
                    _markDocumentForiCloudUpload(document)
                    print(error!)
                    print("Failed whiles saving")
                    return
                }
                
                print("Succesful")
                //Document is saved properly
                _markDocumentAsUploadedToiCloud(document: document)
                
            }
            ckPrivateDB.add(query)
        }
    }
    
    func addOrUpdatePage(_ page: Page, of document: Document) {
       //check if page already exists true: update page else check record for document exists if true add page(same as modify) else add both page and document(rare case)
        
       
        DispatchQueue.global().async { [self] in
            //checking whether document exists on iCLoud or not
            let predicate = NSPredicate(format: "\(CloudKitConstants.DocumentRecordFields.id) == %@", document.id)
            let query = CKQuery(recordType: CloudKitConstants.Records.document, predicate: predicate)
            executeQuery(query) { records, error in
                guard error == nil else {
                    //Mark page for uploading to cloud later
                    _markPageForiCloudUpload(page: page)
                    return
                }
                
                guard let documentRecords = records, documentRecords.count >= 1 else {
                    //document does not exists so upload entire document to iCloud
                    save(document: document)
                    return
                }
                
                if documentRecords.count > 1 {
                    //TODO: - multiple documents scenario keep latest record delete rest (should nit occur)
                }
                
                //Document exists so upload page record to iCloud will get update or created if missing
                guard let pageRecord = page.cloudKitRecord(parent: document.cloudKitRecord()) else { return }
                _saveOrUpdatePageRecord(pageRecord, page: page)
               
            }
        }
        
    }
    
    private func _saveOrUpdatePageRecord(_ ckRecord: CKRecord, page: Page) {
        let operation = CKModifyRecordsOperation()
        operation.recordsToSave = [ckRecord]
        operation.modifyRecordsCompletionBlock = { [self] records, recordIds, error in
            guard error == nil, //no error
                  let pageRecords = records, // records are not nil
                  pageRecords.count > 0 else { // there is valid record in array
                _markPageForiCloudUpload(page: page)
                return
            }
            _markPageAsUploadedToiCloud(with: [page.id])
        }
    }
    
    
    //TODO: - also save page ids locally
    ///Checks iCloud for new document if any
    private func _fetchDocumentsFromiCloudIfAny() {
        DispatchQueue.global().async {
            let predicate = NSPredicate(format: "NOT (\(CloudKitConstants.DocumentRecordFields.id) IN %@)", self.idsOfDocumentUploadedToiCloud)
            let query = CKQuery(recordType: CloudKitConstants.Records.document, predicate: predicate)
            dump(self.idsOfDocumentUploadedToiCloud)
            print(predicate)
            self.ckPrivateDB.perform(query, inZoneWith: nil) { documentRecords, error in
                guard error == nil,
                      let documentRecords = documentRecords else {
                    print("Unable to fetch records, error: \(error!.localizedDescription)")
                    return
                }
                
                for documentRecord in documentRecords {
                    //fetching pages of documents
                    print(documentRecord)
                    let documentRecordID = documentRecord.recordID
                    let referenceRecordToMatch = CKRecord.Reference(recordID: documentRecordID, action: .deleteSelf)
                    print(referenceRecordToMatch)
                    let predicate = NSPredicate(format: "document == %@", referenceRecordToMatch)
                    print("Predicate")
                    print(predicate)
                    let query = CKQuery(recordType: "Page", predicate: predicate)
                    
                    var documentPages: [Page] = []
                    self.executeQuery(query) { [self] pages, error in
                        guard error == nil,
                              let pages = pages else {
                            // there is some error
                            return
                        }
                        for page in pages {
                            guard let pageObject = Page(record: page) else {
                                return
                            }
                            documentPages.append(pageObject)
                        }
                        
                        //creating documentObject and saving it on sucess
                        guard let document = Document(record: documentRecord, pages: documentPages) else {
                            return
                        }
                        
                        document.save()
                        _markDocumentAsUploadedToiCloud(document: document)
                        print("Document feting succesded")
                        NotificationCenter.default.post(name: .documentFetchedFromiCloudNotification, object: nil)
                    }
                }
            }
        }
    }

    func deletedDocumentFromiCloud(with id: String) {
        DispatchQueue.global().async { [self] in
            let predicate = NSPredicate(format: "\(CloudKitConstants.DocumentRecordFields.id) == %@", id)
            let query = CKQuery(recordType: CloudKitConstants.Records.document, predicate: predicate)

            executeQuery(query) { records, error in
                guard error == nil,
                      let records = records else {
                    print("Unable to fetch selected record for deletion from iCloud: \(error?.localizedDescription ?? "")")
                    _markDocumentIDForDeletion(id)
                    return
                }
                
                for record in records {
                    self.ckPrivateDB.delete(withRecordID: record.recordID) { recordId, error in
                        if let error = error {
                            print("Unable to delete record from iCloud: \(error.localizedDescription)")
                            _markDocumentIDForDeletion(id)
                        }
                        print("success")
                    }
                }
            }
        }
    }

    private func _scaniCloudForDeletedDocumentsAndDeleteLocally() {
        DispatchQueue.global().async {
            let predicate = NSPredicate(value: true)
            let query = CKQuery(recordType: CloudKitConstants.Records.document, predicate: predicate)

            self.ckPrivateDB.perform(query, inZoneWith: nil) { records, error in
                guard error == nil,
                      let records = records else {
                    print("Unable to fetch records, error: \(error!.localizedDescription)")
                    return
                }
                var documentIDsFetchedFromiCloud: Set<String> = []
                for record in records {
                    if let id = record["id"] as? String {
                        documentIDsFetchedFromiCloud.insert(id)
                    }
                }
                print(documentIDsFetchedFromiCloud)
                print(self.idsOfDocumentUploadedToiCloud)

                self.idsOfDocumentUploadedToiCloud.forEach { callId in
                    if !documentIDsFetchedFromiCloud.contains(callId) {
                        DocumentHelper.shared.deleteDocumentWithID(callId, isNotifiedFromiCloud: true)
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
                CloudKitHelper.shared._fetchDocumentsFromiCloudIfAny()
                //TODO: - Fetch newly added pages
                //TODO: - Add analytics
            case .recordUpdated:
                //TODO: - Fetch the updated data based on
                //queryNotification.recordFields
                //TODO: - Add analytics
            break
            case .recordDeleted:
                //TODO: - add analytics
                
            break
              
            @unknown default: break
            }
            NotificationCenter.default.post(name: .callsGotUpdatedInBackground, object: nil, userInfo: nil)
        }
    }
}
