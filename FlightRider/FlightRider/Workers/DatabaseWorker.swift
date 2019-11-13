//
//  CoreDataWorker.swift
//  FlightRider
//
//  Created by Tomi on 2019. 10. 29..
//  Copyright © 2019. Tomi. All rights reserved.
//

import Foundation
import CoreData
import CloudKit
import CoreSpotlight
import MobileCoreServices

protocol CoreDataWorkerProtocol{
    var container : NSPersistentContainer! { get set }
    
    func setupContainer() -> Void
    func makeLocalQuery(sortKey : String, predicate: NSPredicate, request: NSFetchRequest<NSManagedObject>, container: NSPersistentContainer, delegate : NSFetchedResultsControllerDelegate) -> [NSManagedObject]?
    func saveContext(container : NSPersistentContainer) -> Void
    func getLocalDatabase(container : NSPersistentContainer, delegate : NSFetchedResultsControllerDelegate) -> Void
    
}

protocol ICloudWorkerProtocol{
    func makeCloudQuery(sortKey : String, predicate: NSPredicate, cloudTable: String, completionHandler: @escaping (_ records: [CKRecord]) -> Void) -> Void
    func saveRecords(records : [CKRecord], completionHandler: @escaping () -> Void) -> Void
}

protocol DatabaseWorkerProtocol: class, ICloudWorkerProtocol, CoreDataWorkerProtocol{
    
    typealias NSManagedObjectParameter = ([NSManagedObject]) -> Void
    typealias StringValuesParameter = ([String]?) -> Void
    typealias CKRecordParameter = ([CKRecord]) -> Void
    typealias NSManagedAndCkrecordParameter = ([NSManagedObject], [CKRecord]) -> Void
    
    func syncLocalDBWithiCloud(providedObject: NSManagedObject.Type, sortKey : String, sortValue : [String], cloudTable : String, saveParams: [String]?, container: NSPersistentContainer, delegate: NSFetchedResultsControllerDelegate, saveToBothDbHandler: @escaping StringValuesParameter, fetchFromCloudHandler: @escaping CKRecordParameter, compareChangeTagHandler: @escaping NSManagedAndCkrecordParameter, decideIfUpdateCloudOrDeleteHandler: @escaping NSManagedObjectParameter, completionHandler: @escaping () -> Void) -> Void
    
    func deindex(flight: ManagedFlight) -> Void
    func index(flight : ManagedFlight) -> Void
}

class DatabaseWorker : DatabaseWorkerProtocol {
    var container: NSPersistentContainer!
    
    init() {
        setupContainer()
    }
    
    func setupContainer() -> Void {
        container = NSPersistentContainer (name: "FlightRider")
        
        container.loadPersistentStores { storeDescription, error in
            self.container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            
            if let error = error {
                print("Unresolved error \(error)")
            }
            
        }
    }
    
    func syncLocalDBWithiCloud(providedObject: NSManagedObject.Type, sortKey : String, sortValue : [String], cloudTable : String, saveParams: [String]?, container: NSPersistentContainer, delegate: NSFetchedResultsControllerDelegate, saveToBothDbHandler: @escaping StringValuesParameter, fetchFromCloudHandler: @escaping CKRecordParameter, compareChangeTagHandler: @escaping NSManagedAndCkrecordParameter, decideIfUpdateCloudOrDeleteHandler: @escaping NSManagedObjectParameter, completionHandler: @escaping () -> Void){
        var request = NSFetchRequest<NSManagedObject>()
        switch providedObject{
        case is ManagedUser.Type:
            request = ManagedUser.createFetchRequest() as! NSFetchRequest<NSManagedObject>
            break
        case is ManagedFlight.Type:
            request = ManagedFlight.createFetchRequest() as! NSFetchRequest<NSManagedObject>
        default:
            break
        }
        var pred = NSPredicate()
        if(sortValue.isEmpty){
            pred = NSPredicate(value: true)
        }
        else{
            pred = NSPredicate(format: "ANY \(sortKey) IN %@", sortValue)
        }
        
        if let localResults = makeLocalQuery(sortKey: sortKey, predicate: pred, request: request, container: container, delegate: delegate){
            if(!(localResults.isEmpty)){

                //Refactor duplicate code

                makeCloudQuery(sortKey: sortKey, predicate: .queryForFlifhts, cloudTable: cloudTable){cloudResults in
                    if(!(cloudResults.isEmpty)){
                        compareChangeTagHandler(localResults, cloudResults)
                    }
                    else{
                        decideIfUpdateCloudOrDeleteHandler(localResults)
                    }
                    completionHandler()
                }
            }
            else{
                pred = NSPredicate(format: "ANY %@ = \(sortKey)", sortValue)
                makeCloudQuery(sortKey: sortKey, predicate: pred, cloudTable: cloudTable){ cloudResults in
                    if(!(cloudResults.isEmpty) && !(sortValue.isEmpty)){
                        fetchFromCloudHandler(cloudResults)
                    }
                    else{
                        saveToBothDbHandler(saveParams)
                    }
                    completionHandler()
                }
                
            }
        }
        
    }
    
    func makeLocalQuery(sortKey: String, predicate: NSPredicate, request: NSFetchRequest<NSManagedObject>, container: NSPersistentContainer, delegate: NSFetchedResultsControllerDelegate) -> [NSManagedObject]? {
        let sort = NSSortDescriptor(key: sortKey, ascending: true)
        request.sortDescriptors = [sort]
        let fetchedObject = NSFetchedResultsController(fetchRequest: request, managedObjectContext: container.viewContext, sectionNameKeyPath: sortKey, cacheName: nil)
        fetchedObject.delegate = delegate
        fetchedObject.fetchRequest.predicate = predicate
        do{
            try fetchedObject.performFetch()
            return fetchedObject.fetchedObjects!
        }
        catch{
            return nil
        }
    }
    
    func makeCloudQuery(sortKey: String, predicate: NSPredicate, cloudTable: String, completionHandler: @escaping ([CKRecord]) -> Void) {
        let sort = NSSortDescriptor(key: sortKey, ascending: true)
        let query = CKQuery(recordType: cloudTable, predicate: predicate)
        query.sortDescriptors = [sort]
        
        
        CKContainer.default().publicCloudDatabase.perform(query, inZoneWith: nil){ results, error in
            if let error = error {
                print("Cloud Query Error - Fetch Establishments: \(error.localizedDescription)")
                return
            }
            else{
                if(results != nil){
                    completionHandler(results!)
                }
            }
        }
    }
    
    func saveRecords(records: [CKRecord], completionHandler: @escaping () -> Void) {
        let operation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
        operation.modifyRecordsCompletionBlock = { savedRecords, deletedRecordID, error in
            if let error = error{
                print("Error: \(error.localizedDescription)")
            }
            else{
                completionHandler()
            }
        }
        CKContainer.default().publicCloudDatabase.add(operation)
    }
    
    func saveContext(container: NSPersistentContainer) {
        if container.viewContext.hasChanges {
            do {
                try container.viewContext.save()
            } catch {
                print("An error occurred while saving: \(error)")
            }
        }
    }
    
    func deindex(flight: ManagedFlight) {
        CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: ["\(flight.iataNumber)"]) { error in
            if let error = error {
                print("Deindexing error: \(error.localizedDescription)")
            } else {
                print("Search item successfully removed!")
            }
        }
    }
    
    func index(flight: ManagedFlight) {
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
        attributeSet.title = flight.iataNumber
        let item = CSSearchableItem(uniqueIdentifier: "\(flight.uid)", domainIdentifier: "com.clearinx.FlightRider", attributeSet: attributeSet)
        CSSearchableIndex.default().indexSearchableItems([item]) { error in
            if let error = error {
                print("Indexing error: \(error.localizedDescription)")
            } else {
                print("Search item successfully indexed!")
            }
        }
    }
    
    func getLocalDatabase(container: NSPersistentContainer, delegate: NSFetchedResultsControllerDelegate) {
        var request = ManagedUser.createFetchRequest() as! NSFetchRequest<NSManagedObject>
        var pred = NSPredicate(value: true)
        var results = self.makeLocalQuery(sortKey: "uid", predicate: pred, request: request, container: container, delegate: delegate)
        for result in results!{
            print("\nUser:\n")
            let localuser = result as! ManagedUser
            print(localuser.uid)
            print(localuser.email)
            print(localuser.flights)
            print(localuser.changetag)
        }
        //flights in local DB
        request = ManagedFlight.createFetchRequest() as! NSFetchRequest<NSManagedObject>
        pred = NSPredicate(value: true)
        results = self.makeLocalQuery(sortKey: "uid", predicate: pred, request: request, container: container, delegate: delegate)
        for result in results!{
            print("\nFlight:\n")
            let localflight = result as! ManagedFlight
            print(localflight.uid)
            print(localflight.changetag)
            print(localflight.departureDate)
            print(localflight.iataNumber)
            print(localflight.airplaneType)
            print(localflight.seats.count)
        }
        
        request = ManagedSeat.createFetchRequest() as! NSFetchRequest<NSManagedObject>
        pred = NSPredicate(value: true)
        results = self.makeLocalQuery(sortKey: "uid", predicate: pred, request: request, container: container, delegate: delegate)
        for result in results!{
            print("\nSeat:\n")
            let localseat = result as! ManagedSeat
            print(localseat.uid)
            print(localseat.changetag)
            print(localseat.number)
            print(localseat.occupiedBy)
            print(localseat.flight?.iataNumber)
        }
        print(results?.count)
    }
}


extension NSPredicate {
    static var queryForFlifhts : NSPredicate {
        NSPredicate(format:"")
    }
}
