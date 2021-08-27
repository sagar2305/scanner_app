//
//  CloudKitHelper.swift
//  Document Scanner
//
//  Created by Sandesh on 23/06/21.
//

import UIKit
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
 
        if idsOfPagesMarkedForiCloudUpload.isEmpty &&
            idsOfDocumentMarkedForiCloudUpload.isEmpty &&
            idsOfDocumentMarkedForDeletionFromiCloud.isEmpty &&
            idsOfDocumentMarkedForUpdate.isEmpty {
            _updateWithiCloud()
        } else {
            _runBackgroundUpdates()
        }
    }
    
    private func _runBackgroundUpdates() {
        print("=======> Starting background task")
        _deleteDocumentFromiCloudIfMarked()
        _uploadPendingDocumentToiCloudIfAny()
        _uploadPendingPagesToiCloudIfAny()
    }
    
    // MARK: - Background tasks
    private func _deleteDocumentFromiCloudIfMarked() {
        for documentID in idsOfDocumentMarkedForDeletionFromiCloud {
            deletedDocumentFromiCloud(with: documentID)
        }
    }

    private func _uploadPendingDocumentToiCloudIfAny() {
        for documentID in idsOfDocumentMarkedForiCloudUpload {
            if idsOfDocumentUploadedToiCloud.contains(documentID) { return }
            guard let document = DocumentHelper.shared.getDocument(with: documentID) else { return }
            self.saveToCloud(document: document)
        }
    }
    
    private func _updatePendingDocumentsIfAny() {
        for documentID in idsOfDocumentMarkedForUpdate {
            guard let document = DocumentHelper.shared.getDocument(with: documentID) else { return }
            self.update(document: document)
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
                AnalyticsHelper.shared.saveUserProperty(.subscribedToDocumentRecordChanges, value: "Yes")
            }
        }
        if !UserDefaults.standard.bool(forKey: Constants.DocumentScannerDefaults.iCloudPageRecordSubscriptionKey) {
            ckPrivateDB.save(pageSubscriptionQuery) { subscription, error in
                guard error == nil else { return }
                guard subscription != nil else { return }
                UserDefaults.standard.set(true, forKey: Constants.DocumentScannerDefaults.iCloudPageRecordSubscriptionKey)
                AnalyticsHelper.shared.saveUserProperty(.subscribedToPageRecordChanges, value: "Yes")
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
    
    private func _markDocumentForUpdateOniCloud(document: Document) {
        var documentIdSet = idsOfDocumentMarkedForUpdate
        documentIdSet.insert(document.id)
        UserDefaults.standard.setValue(Array(documentIdSet), forKey: Constants.DocumentScannerDefaults.idsOfDocumentMarkedForUpdateKey)

    }
    
    var idsOfDocumentMarkedForUpdate: Set<String> {
        let userDefaultKey = Constants.DocumentScannerDefaults.idsOfDocumentMarkedForUpdateKey
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
    
    ///this function is for testing purpose only, should never call in production
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
    
    // MARK: - Save document to cloud
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
                    AnalyticsHelper.shared.logEvent(.documentSavingFailed, properties: [
                                                        .documentID: document.id,
                                                        .reason: error?.localizedDescription ?? "--"])
                    return
                }
                
                AnalyticsHelper.shared.logEvent(.documentUploadedToCloud, properties: [
                                                    .documentID: document.id,
                                                    .numberOfDocumentPages: document.pages.count]
                )
                _markDocumentAsUploadedToiCloud(document: document)
                //setting pages as uploaded
                let pageIDs = document.pages.map { return $0.id }
                _markPageAsUploadedToiCloud(with: pageIDs)
            }
            ckPrivateDB.add(query)
        }
    }
    
    // MARK: - Updating document i.e either document is remaned or tagged with folder
    func update(document: Document) {
        DispatchQueue.global(qos: .utility).async { [self] in
            let predicate = NSPredicate(format: "\(CloudKitConstants.DocumentRecordFields.id) == %@", document.id)
            let query = CKQuery(recordType: CloudKitConstants.Records.document, predicate: predicate)
            executeQuery(query) { records, error in
                guard error == nil else {
                    print("ERROR: While getting document record")
                    _markDocumentForUpdateOniCloud(document: document)
                    AnalyticsHelper.shared.logEvent(.documentRenamingFailed, properties: [
                                                        .documentID: document.id,
                                                        .reason: error?.localizedDescription ?? "--"])
                    return
                }
                
                guard let documentRecord = records?.first else {
                    //document not available on iCloud
                    return
                }
                
                documentRecord.setValue(document.name as NSString, forKey: CloudKitConstants.DocumentRecordFields.name)
                documentRecord.setValue(document.tag as NSString, forKey: CloudKitConstants.DocumentRecordFields.tag)
                saveRecord(documentRecord) { record, error in
                    guard error == nil else  {
                        _markDocumentForUpdateOniCloud(document: document)
                        AnalyticsHelper.shared.logEvent(.documentRenamingFailed, properties: [
                                                            .documentID: document.id,
                                                            .reason: error?.localizedDescription ?? "--"])
                        return
                    }
                    AnalyticsHelper.shared.logEvent(.documentRenamed, properties: [
                                                        .documentID: document.id ])
                    var idsOfDocumentMarkedForUpdates = idsOfDocumentMarkedForUpdate
                    idsOfDocumentMarkedForUpdates.remove(document.id)
                    UserDefaults.standard.setValue(Array(idsOfDocumentMarkedForUpdates), forKey: Constants.DocumentScannerDefaults.idsOfDocumentMarkedForUpdateKey)
                }
            }
        }
    }
    
    // MARK: - Adding new page or updating edited image
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
                        AnalyticsHelper.shared.logEvent(.pageUpdateFailed, properties: [.pageID: page.id,
                                                                                        .documentID: document.id,
                                                                                        .reason: error?.localizedDescription ?? "--"])
                        return
                    }
                    print("Successfully uploaded edited image")
                    AnalyticsHelper.shared.logEvent(.updatedDocumentPage, properties: [.pageID: page.id,
                                                                                    .documentID: document.id])
                }
            }
        }
        
    }
    
    //Adds a page to existing document on iCloud
    private func add(page: Page, document record: CKRecord) {
        guard var documentPageReferences = record[CloudKitConstants.DocumentRecordFields.pages] as? [CKRecord.Reference],
              let pageRecord = page.cloudKitRecord(parent: record) else {
            _markPageForiCloudUpload(page: page)
            AnalyticsHelper.shared.logEvent(.pageUploadFailed, properties: [.pageID: page.id,
                                                                            .reason: "Unable to create page ckrecord"])
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
                AnalyticsHelper.shared.logEvent(.pageUploadFailed, properties: [.pageID: page.id,
                                                                                .reason: error?.localizedDescription ?? "--"])
                return
            }
            
            AnalyticsHelper.shared.logEvent(.addedNewPageToDocument, properties: [.pageID: page.id,
                                                                            .reason: error?.localizedDescription ?? "--"])
            self._markPageAsUploadedToiCloud(with: [page.id])
            
        }
        ckPrivateDB.add(query)
    }
    
    //Below function works as temporary solution to update the local documents with any changes changes
    //made to document on cloud from another devices. Might be time consuming and inefficient when the
    //numbers of document owned by user is large. So use _fetchDataBaseChangesIfAny to fetch changes.
    ///Fetches all the documents from iCloud and replaces the  local cached documents with updated cloud version
    private func _updateWithiCloud() {
        DispatchQueue.global().async {
            let predicate = NSPredicate(value: true)
            let query = CKQuery(recordType: CloudKitConstants.Records.document, predicate: predicate)
            self.ckPrivateDB.perform(query, inZoneWith: nil) { documentRecords, error in
                guard error == nil,
                      let documentRecords = documentRecords else {
                    print("Unable to fetch records, error: \(error!.localizedDescription)")
                    return
                }
                
                var allDocuments: [Document] = [] {
                    didSet {
                        if allDocuments.count == documentRecords.count {
                            UserDefaults.standard.save(allDocuments, forKey: Constants.DocumentScannerDefaults.documentsListKey)
                            NotificationCenter.default.post(name: .documentFetchedFromiCloudNotification, object: nil)
                        }
                    }
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
                        allDocuments.append(document)
                       
                        print("Document fetching succeeded")
                    }
                }
                
            }
        }
    }
    
    
    private func _generateAndSaveDocument(from record: CKRecord) {
        DispatchQueue.global().async {
            let documentRecordID = record.recordID
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
                guard let document = Document(record: record, pages: documentPages) else {
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
    
    func deletedDocumentFromiCloud(with id: String) {
        DispatchQueue.global().async { [self] in
            let predicate = NSPredicate(format: "\(CloudKitConstants.DocumentRecordFields.id) == %@", id)
            let query = CKQuery(recordType: CloudKitConstants.Records.document, predicate: predicate)
            
            executeQuery(query) { records, error in
                guard error == nil,
                      let records = records else {
                    print("Unable to fetch selected record for deletion from iCloud: \(error?.localizedDescription ?? "")")
                    _markDocumentIDForDeletion(id)
                    AnalyticsHelper.shared.logEvent(.documentDeletionFailed, properties: [
                                                        .documentID: id])
                    return
                }
                
                for record in records {
                    self.ckPrivateDB.delete(withRecordID: record.recordID) { recordId, error in
                        if let error = error {
                            print("Unable to delete record from iCloud: \(error.localizedDescription)")
                            _markDocumentIDForDeletion(id)
                            AnalyticsHelper.shared.logEvent(.documentDeletionFailed, properties: [
                                                                .documentID: id])
                        }
                        print("success")
                        //removing document id from list of marked document for deletion
                        var updatedIdsList = self.idsOfDocumentMarkedForDeletionFromiCloud
                        updatedIdsList.remove(id)
                        UserDefaults.standard.setValue(Array(updatedIdsList), forKey: Constants.DocumentScannerDefaults.idsOfDocumentsMarkedForDeletionFromiCloudKey)
                        AnalyticsHelper.shared.logEvent(.deletedDocument, properties: [
                                                            .documentID: id])
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
            var reason: String
            switch queryNotification.queryNotificationReason.rawValue {
            case 1: reason = "Created"
            case 2: reason = "Updated"
            case 3: reason = "Deleted"
            default: reason = "UnKnown"
            }
            
            AnalyticsHelper.shared.logEvent(.recievedCloudNotification, properties: [
                .notificationType: reason,
                .recordId: queryNotification.recordID ?? "--"
                
            ])
            _fetchDataBaseChangesIfAny()
        }
    }
    
    private func _fetchDataBaseChangesIfAny() {
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            
            let configuration = CKFetchRecordZoneChangesOperation.ZoneConfiguration()
            configuration.previousServerChangeToken = serverChangeToken
            
            let zoneChangeOperation = CKFetchRecordZoneChangesOperation(recordZoneIDs: [.default], configurationsByRecordZoneID: [.default: configuration])
            zoneChangeOperation.fetchAllChanges = true
            
            zoneChangeOperation.recordChangedBlock = { record in
                print(record.recordType)
                if record.recordType == CloudKitConstants.Records.document {
                    guard let documentID = record[CloudKitConstants.DocumentRecordFields.id] as? String else { return }
                    //Check if document exists locally
                    if let document = DocumentHelper.shared.getDocument(with: documentID) {
                        //check if document name was updated
                        if record.changedKeys().contains(CloudKitConstants.DocumentRecordFields.name) {
                            guard let name = record[CloudKitConstants.DocumentRecordFields.name] as? String else { return }
                            document.rename(new: name, updatedFromCloud: true)
                            
                            if record.changedKeys().contains(CloudKitConstants.DocumentRecordFields.tag) {
                                guard let name = record[CloudKitConstants.DocumentRecordFields.name] as? String else { return }
                                document.updateTag(new: name, updatedFromCloud: true)
                                
                                
                            }
                        } else {
                            //save the document locally
                            self._generateAndSaveDocument(from: record)
                        }
                    } else if record.recordType == CloudKitConstants.Records.page {
                        guard let pageID = record[CloudKitConstants.PageRecordFields.id] as? String else { return }
                        let pageAndDocument = DocumentHelper.shared.getPageAndDocumentContainingPage(with: pageID)
                        //check if page and document exists locally
                        if pageAndDocument.page != nil && pageAndDocument.document != nil {
                            //page exists locally check id edited image was changes
                            if record.changedKeys().contains(CloudKitConstants.PageRecordFields.editedImage) {
                                guard let editedImageAsset = record[CloudKitConstants.PageRecordFields.editedImage] as? CKAsset,
                                      let editedImageURL = editedImageAsset.fileURL,
                                      let editedImage = UIImage(contentsOfFile: editedImageURL.path) else { return }
                                _ = DocumentHelper.shared.updateEditedImage(editedImage,
                                                                            for: pageAndDocument.page!,
                                                                            of: pageAndDocument.document!,
                                                                            fromCloud: true)
                            }
                        } else {
                            //page and document not exist
                            //1. get parent document and check if document exist locally
                            guard let parentDoc = record[CloudKitConstants.PageRecordFields.document]  as? CKRecord.Reference else { return }
                            let predicate = NSPredicate(format: "name == %@",parentDoc.recordID)
                            print(parentDoc.recordID)
                            let query = CKQuery(recordType: "Document", predicate: predicate)
                            
                            self.executeQuery(query) { records, error in
                                guard let _ = error else { return }
                                guard let parentDocumentRecord = records?.first else {
                                    print("No records were found of parent")
                                    return
                                }
                                guard let parentDocumentId = parentDocumentRecord[CloudKitConstants.DocumentRecordFields.id] as? String else { return }
                                if let document = DocumentHelper.shared.getDocument(with: parentDocumentId) {
                                    //document exist locally, add page to document
                                    guard let page = Page(record: record) else { return }
                                    DocumentHelper.shared.addPages([page], to: document, fromCloud: true)
                                } else {
                                    //document does not exist so fetch it from iCloud
                                    self._generateAndSaveDocument(from: parentDocumentRecord)
                                }
                            }
                        }
                    }
                    NotificationCenter.default.post(name: .documentFetchedFromiCloudNotification, object: nil )
                }
                
                zoneChangeOperation.recordZoneChangeTokensUpdatedBlock = { zoneID, token, _ in
                    if let changeToken = token {
                        print(zoneID)
                        self.serverChangeToken = changeToken
                    }
                }
                
                zoneChangeOperation.recordZoneFetchCompletionBlock =  { zoneID, token, data, hasChanges, error in
                    if let changeToken = token {
                        print(zoneID)
                        self.serverChangeToken = changeToken
                    }
                }
                
                zoneChangeOperation.qualityOfService = .userInitiated
                self.ckPrivateDB.add(zoneChangeOperation)
            }
        }
}
