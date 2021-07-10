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
        //_deleteLocalCaches() //Use only for testing purpose
        addSubscriptions()
        runBackgroundUpdates()
    }
    
    func runBackgroundUpdates() {
        print("=======> Starting background task")
        _fetchDocumentsFromiCloudIfAny()
        _scaniCloudForDeletedDocumentsAndDeleteLocally()
        _deleteCallFromiCloudIfMarked()
        _uploadPendingDocumentToiCloudIfAny()
        _uploadPendingPagesToiCloudIfAny()
    }
    
    // MARK: - Background task
    private func _deleteCallFromiCloudIfMarked() {
        for documentID in idsOfDocumentMarkedForDeletionFromiCloud {
            deletedDocumentFromiCloud(with: documentID)
        }
    }
    
    private func _uploadPendingDocumentToiCloudIfAny() {
        print("======> Uploading pending document")
        print("********** already uploaded => \(idsOfDocumentUploadedToiCloud)")
        for documentID in idsOfDocumentMarkedForiCloudUpload {
            if idsOfDocumentUploadedToiCloud.contains(documentID) {
               
                return
            }
            guard let document = DocumentHelper.shared.getDocument(with: documentID) else { return }
            self.saveToCloud(document: document)
        }
    }
    
    private func _uploadPendingPagesToiCloudIfAny() {
        DispatchQueue.global().async { [self] in
            for pageId in idsOfPagesMarkedForiCloudUpload {
                let pageAndDocument = DocumentHelper.shared.getPageAndDocumentContainingPage(with: pageId)
                guard let page = pageAndDocument.page,
                      let document = pageAndDocument.document else {
                    return
                }
                self.addOrUpdatePage(page, of: document)
            }
        }
    }
    
    // MARK: - Subscriptions
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
    
    // MARK: - Server Change token
    
    private var serverChangeToken: CKServerChangeToken? {
        set(newValue) {
            guard let token = newValue else { return }
            guard let tokenData = try? NSKeyedArchiver.archivedData(withRootObject: token, requiringSecureCoding: false) else {
                fatalError("ERROR: Unable to archive server change token")
                
            }
            UserDefaults.standard.setValue(tokenData, forKey: Constants.DocumentScannerDefaults.iCloudDBChangeTokenKey)
        }
        
        get {
            guard let data = UserDefaults.standard.data(forKey: Constants.DocumentScannerDefaults.iCloudDBChangeTokenKey) else {
                return nil
            }
            let token = try? NSKeyedUnarchiver.unarchivedObject(ofClass: CKServerChangeToken.self, from: data)
            return token
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
        print("Document uploaded to iCLous: => \(document.printIDS())")
        documentIdSet.insert(document.id)
        UserDefaults.standard.setValue(Array(documentIdSet), forKey: Constants.DocumentScannerDefaults.idsOfDocumentUploadedToiCLoudKey)
        
        //removing document from list of documents marked for iCloud upload
        var documentsMarkedForUpload = idsOfDocumentMarkedForiCloudUpload
        documentsMarkedForUpload.remove(document.id)
        UserDefaults.standard.setValue(Array(documentsMarkedForUpload), forKey: Constants.DocumentScannerDefaults.idsOfDocumentsMarkedForiCloudUploadKey)
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
            pagesMarkedForUpload.remove($0)
        }
        UserDefaults.standard.setValue(Array(pagesMarkedForUpload), forKey: Constants.DocumentScannerDefaults.idsOfPagesMarkedForiCloudUploadKey)
        UserDefaults.standard.setValue(Array(pageIdSet), forKey: Constants.DocumentScannerDefaults.idsOfPagesUploadedToiCloudKey)
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
        UserDefaults.standard.setValue(Array(pageIdSet), forKey: Constants.DocumentScannerDefaults.idsOfPagesMarkedForiCloudUploadKey)
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
    private func _deleteLocalCaches() {
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
    
    func saveToCloud(document: Document) {
        DispatchQueue.global(qos: .utility).async { [self] in
            if CloudKitHelper.shared.idsOfDocumentUploadedToiCloud.contains(document.id) { return }
            _markDocumentForiCloudUpload(document)
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
            query.savePolicy = .allKeys
            query.isAtomic = true
            query.modifyRecordsCompletionBlock = { records, recordIds, error in
                guard error == nil else {
                    _markDocumentForiCloudUpload(document)
                    print(error!)
                    print("Failed whiles saving" )
                    return
                }
                
                print("Succesful")
                //Document is saved properly
                _markDocumentAsUploadedToiCloud(document: document)
                //setting pages as uploaded
                let pageIDs = document.pages.map { return $0.id }
                _markPageAsUploadedToiCloud(with: pageIDs)
            }
            ckPrivateDB.add(query)
        }
    }
    
    func addOrUpdatePage(_ page: Page, of document: Document) {
       //check if page already exists on iCloud true: update page else
        // check if parent document is marked for iCloud update then upload document again else
        // assume document was deleted from iCloud**************
        DispatchQueue.global().async { [self] in
            //checking whether page exists on iCLoud or not
            let predicate = NSPredicate(format: "\(CloudKitConstants.PageRecordFields.id) == %@", page.id)
            let query = CKQuery(recordType: CloudKitConstants.Records.page, predicate: predicate)
            executeQuery(query) { records, error in
                guard error == nil else {
                    print("ERROR: While getting page record")
                    _markPageForiCloudUpload(page: page)
                    return
                }
                
                guard let pageRecord = records?.first else {
                    //record no matching record found on iCloud
                    //check if parent document is present in marked list of document for iCloud upload
                     if self.idsOfDocumentMarkedForiCloudUpload.contains(document.id) {
                         saveToCloud(document: document)
                     } else {
                         //check if parent doc is available on iCloud if true then create new page record and save it
                         //add page to document
                        let predicate = NSPredicate(format: "\(CloudKitConstants.DocumentRecordFields.id) == %@", document.id)
                        let query = CKQuery(recordType: CloudKitConstants.Records.document, predicate: predicate)
                        executeQuery(query) { records, error in
                            guard error == nil else {
                                print("ERROR: While getting document record")
                                _markPageForiCloudUpload(page: page)
                                return
                            }
                            
                            guard let record = records?.first else {
                                print("Document not available at cloud")
                                return
                            }
                            add(page: page, document: record)
                        }
                     }
                    return
                }
                
                guard let editedImageURL = FileHelper.shared.fileURL(for: page.editedImageName) else {
                    return
                }
                let editedImageAsset = CKAsset(fileURL: editedImageURL)
                pageRecord.setValue(editedImageAsset, forKey: CloudKitConstants.PageRecordFields.editedImage)
               
                saveRecord(pageRecord) { record, error in
                    guard error == nil else  {
                        _markPageForiCloudUpload(page: page)
                        return
                    }
                    print("Successfully uploaded edited image")
                    //TODO: - Save record success
                }
            }
        }
        
    }
    
    //Adds a page to existing document on iCloud
    private func add(page: Page, document record: CKRecord) {
        guard var documentPageReferences = record[CloudKitConstants.DocumentRecordFields.pages] as? [CKRecord.Reference],
              let pageRecord = page.cloudKitRecord(parent: record) else {
            _markPageForiCloudUpload(page: page)
            return
        }
        documentPageReferences.append(CKRecord.Reference(record: record, action: .none))
        record.setValue(documentPageReferences as NSArray, forKeyPath: CloudKitConstants.DocumentRecordFields.pages)
        let recordsToSave = [record, pageRecord]
        
        let query = CKModifyRecordsOperation()
        query.recordsToSave = recordsToSave
        query.savePolicy = .changedKeys
        query.isAtomic = true
        query.modifyRecordsCompletionBlock = { records, recordIds, error in
            guard error == nil else {
                self._markPageForiCloudUpload(page: page)
                print(error!)
                print("Failed whiles saving" )
                return
            }
            
            print("Succesful")
            //Document is saved properly
            self._markPageAsUploadedToiCloud(with: [page.id])

        }
        ckPrivateDB.add(query)
    }
    
    
    //TODO: - also save page ids locally
    ///Checks iCloud for new document if any
    private func _fetchDocumentsFromiCloudIfAny(with id: String? = nil) {
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
                        
                        print("*******************Document fetched from iCloud")
                        dump(document)
                        _markDocumentAsUploadedToiCloud(document: document)
                        document.save()
                        print("Document fetching succeeded")
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
                        //removing document id from list of marked document for deletion
                        var updatedIdsList = self.idsOfDocumentMarkedForDeletionFromiCloud
                        updatedIdsList.remove(id)
                        UserDefaults.standard.setValue(Array(updatedIdsList), forKey: Constants.DocumentScannerDefaults.idsOfDocumentsMarkedForDeletionFromiCloudKey)
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
                let idsOfDocumentStoredLocally = DocumentHelper.shared.documents.map { $0.id }

                idsOfDocumentStoredLocally.forEach { id in
                    //local document id is not in ids fetched from iCloud and also not in ids marked for iCloud upload
                    //so delete the document locally as well
                    if !documentIDsFetchedFromiCloud.contains(id) && !self.idsOfDocumentMarkedForiCloudUpload.contains(id) {
                        DocumentHelper.shared.deleteDocumentWithID(id, isNotifiedFromiCloud: true)
                    }
                }
            }
        }
    }

    // MARK: - Hanadling cloud notification
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
    
    private func _fetchDataBaseChangesIfAny() {
        let configuration = CKFetchRecordZoneChangesOperation.ZoneConfiguration()
        configuration.previousServerChangeToken = serverChangeToken
        let zoneChangeOperation = CKFetchRecordZoneChangesOperation(recordZoneIDs: [.default], configurationsByRecordZoneID: [.default: configuration])
        
        zoneChangeOperation.recordChangedBlock = { record in
            if record.recordType == CloudKitConstants.Records.document {
                //TODO: - check if document name key way changes
                //If pages reference was changes then fetch perticular document from cloud and resave
            } else if record.recordType == CloudKitConstants.Records.page {
                //TODO: - if edited image field was change then get local page with id and updated edited image
            }
        }
        
        zoneChangeOperation.recordZoneChangeTokensUpdatedBlock = { zoneID, token, _ in
            
        }
        
        zoneChangeOperation.qualityOfService = .userInitiated
        ckPrivateDB.add(zoneChangeOperation)
        
    }
}
