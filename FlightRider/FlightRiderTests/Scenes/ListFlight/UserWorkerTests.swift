//
//  UserWorkerTests.swift
//  FlightRiderTests
//
//  Created by Tomi on 2019. 11. 13..
//  Copyright © 2019. Tomi. All rights reserved.
//

@testable import FlightRider
import UIKit
import XCTest
import CoreData
import CloudKit

class UserWorkerTests: XCTestCase
{
    // MARK: - Subject under test
    
    var sut: ListFlightsViewController!
    //var context : NSManagedObjectContext!
    
    // MARK: - Test lifecycle
    
    override func setUp()
    {
        super.setUp()
        setupListFlightsViewController()
    }
    
    override func tearDown()
    {
        super.tearDown()
    }
    
    // MARK: - Test setup
    
    func setupListFlightsViewController()
    {
        sut = ListFlightsViewController(nibName: "FlightList", bundle: Bundle.main)
    }
    
    class DatabaseWorkerSpy: DatabaseWorkerProtocol
    {
        var container: NSPersistentContainer!
        
        var syncLocalDBWithiCloudCalled = false
        var deindexCalled = false
        var indexCalled = false
        var makeCloudQueryCalled = false
        var saveRecordsCalled = false
        var setupContainerCalled = false
        var makeLocalQueryCalled = false
        var saveContextCalled = false
        var getLocalDatabaseCalled = false
        
        var recordsSaved : [CKRecord]!
        var localUser : ManagedUser!
        
        var uid : String?
        var found : Bool!
        
        init() {
            container = NSPersistentContainer(name: "FlightRider")
            container.loadPersistentStores { storeDescription, error in
                self.container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                
                if let error = error {
                    print("Unresolved error \(error)")
                }
                
            }
        }
        
        func syncLocalDBWithiCloud(providedObject: NSManagedObject.Type, sortKey: String, sortValue: [String], cloudTable: String, saveParams: [String]?, container: NSPersistentContainer, delegate: NSFetchedResultsControllerDelegate, saveToBothDbHandler: @escaping SelectSeatsWorkerTests.DatabaseWorkerSpy.StringValuesParameter, fetchFromCloudHandler: @escaping SelectSeatsWorkerTests.DatabaseWorkerSpy.CKRecordParameter, compareChangeTagHandler: @escaping SelectSeatsWorkerTests.DatabaseWorkerSpy.NSManagedAndCkrecordParameter, decideIfUpdateCloudOrDeleteHandler: @escaping SelectSeatsWorkerTests.DatabaseWorkerSpy.NSManagedObjectParameter, completionHandler: @escaping () -> Void) {
            
            syncLocalDBWithiCloudCalled = true
        }
        
        func deindex(flight: ManagedFlight) {
            deindexCalled = true
        }
        
        func index(flight: ManagedFlight) {
            indexCalled = true
        }
        
        func makeCloudQuery(sortKey: String, predicate: NSPredicate, cloudTable: String, completionHandler: @escaping ([CKRecord]) -> Void) {
            makeCloudQueryCalled = true
            let flightRecord = injectCKRecord(found: found, uid: uid)
            completionHandler(flightRecord)
        }
        
        func injectCKRecord(found: Bool, uid: String?) -> [CKRecord]{
            if found{
                let flightRecord = CKRecord(recordType: "Flight")
                if let uid = uid{
                    flightRecord["uid"] = uid
                }
                return [flightRecord]
            }
            else{
                return [CKRecord]()
            }
            
        }
        
        func saveRecords(records: [CKRecord], completionHandler: @escaping () -> Void) {
            saveRecordsCalled = true
            recordsSaved = records
            completionHandler()
        }
        
        func setupContainer() {
            setupContainerCalled = true
        }
        
        func makeLocalQuery(sortKey: String, predicate: NSPredicate, request: NSFetchRequest<NSManagedObject>, container: NSPersistentContainer, delegate: NSFetchedResultsControllerDelegate) -> [NSManagedObject]? {
            makeLocalQueryCalled = true
            return [NSManagedObject]()
        }
        
        func saveContext(container: NSPersistentContainer) {
            saveContextCalled = true
        }
        
        func getUserFromLocalDatabase(sortkey: String, sortvalue: String){
            
        }
        
        func getLocalDatabase(container: NSPersistentContainer, delegate: NSFetchedResultsControllerDelegate) {
            getLocalDatabaseCalled = true
        }
    }
    
    // MARK: - Test doubles
    
    func testSaveUserDataToBothDb()
    {
        // Given
        let databaseWorkerSpy = DatabaseWorkerSpy()
        sut.databaseWorker = databaseWorkerSpy
        
        //When
        let params = ["DummyUid", "DummyEmail"]
        sut.saveUserDataToBothDb(params: params)
        
        //Then
        XCTAssert(databaseWorkerSpy.recordsSaved.first!["uid"] == "DummyUid")
        XCTAssert(databaseWorkerSpy.recordsSaved.first!["email"] == "DummyEmail")
    }
    
    func testFetchUserFromCloud()
    {
        // Given
        let databaseWorkerSpy = DatabaseWorkerSpy()
        sut.databaseWorker = databaseWorkerSpy
        
        //When
        let userRecord = CKRecord(recordType: "Dummy")
        userRecord["uid"] = "DummyUid"
        userRecord["email"] = "DummyEmail"
        userRecord["flights"] = [CKRecord.Reference]()
        sut.fetchUserFromCloud(results: [userRecord])
        
        //Then
        XCTAssert(sut.user.uid == "DummyUid")
        XCTAssert(sut.user.email == "DummyEmail")
        
    }
    
    func testCompareUserChangeTag(){
        
        // Given
        let databaseWorkerSpy = DatabaseWorkerSpy()
        sut.databaseWorker = databaseWorkerSpy
        
        //When
        let userRecord = CKRecord(recordType: "Dummy")
        userRecord["uid"] = "DummyUid"
        userRecord["email"] = "DummyEmail"
        userRecord["flights"] = [CKRecord.Reference]()
        
        let user = User(email: "DummyEmail", flights: [String](), uid: "DummyUid", changetag: "")
        databaseWorkerSpy.localUser = ManagedUser(context: databaseWorkerSpy.container.viewContext)
        databaseWorkerSpy.localUser.fromUser(user: user)
        
        sut.compareUserChangeTag(localResults: [databaseWorkerSpy.localUser], cloudResults: [userRecord])
        
        //Then
        XCTAssert(databaseWorkerSpy.saveContextCalled == false)
    }
    
    func testCompareUserChangeTagNotMatching(){
        
        // Given
        let databaseWorkerSpy = DatabaseWorkerSpy()
        sut.databaseWorker = databaseWorkerSpy
        
        //When
        let userRecord = CKRecord(recordType: "Dummy")
        userRecord["uid"] = "DummyUid"
        userRecord["email"] = "DummyEmail"
        userRecord["flights"] = [CKRecord.Reference]()
        
        let user = User(email: "DummyEmail", flights: [String](), uid: "DummyUid", changetag: "NotDummy")
        databaseWorkerSpy.localUser = ManagedUser(context: databaseWorkerSpy.container.viewContext)
        databaseWorkerSpy.localUser.fromUser(user: user)
        
        sut.compareUserChangeTag(localResults: [databaseWorkerSpy.localUser], cloudResults: [userRecord])
        
        //Then
        XCTAssert(databaseWorkerSpy.saveContextCalled == true)
    }
}
