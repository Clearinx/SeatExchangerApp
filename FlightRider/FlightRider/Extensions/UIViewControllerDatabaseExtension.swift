//
//  ViewControllerDatabaseExtension.swift
//  FlightRider
//
//  Created by Tomi on 2019. 09. 05..
//  Copyright © 2019. Tomi. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CloudKit
import CoreSpotlight
import MobileCoreServices

extension UIViewController {
    
    typealias NSManagedObjectParameter = ([NSManagedObject]) -> Void
    typealias StringValuesParameter = ([String]?) -> Void
    typealias CKRecordParameter = ([CKRecord]) -> Void
    typealias NSManagedAndCkrecordParameter = ([NSManagedObject], [CKRecord]) -> Void
    
    func setupContainer() -> NSPersistentContainer {
        let container = NSPersistentContainer (name: "FlightRider")
        
        container.loadPersistentStores { storeDescription, error in
            container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            
            if let error = error {
                print("Unresolved error \(error)")
            }
            
        }
        return container
    }
    
    func syncLocalDBWithiCloud(providedObject: NSManagedObject.Type, sortKey : String, sortValue : [String], cloudTable : String, saveParams: [String]?, container: NSPersistentContainer, delegate: NSFetchedResultsControllerDelegate, saveToBothDbHandler: @escaping StringValuesParameter, fetchFromCloudHandler: @escaping CKRecordParameter, compareChangeTagHandler: @escaping NSManagedAndCkrecordParameter, decideIfUpdateCloudOrDeleteHandler: @escaping NSManagedObjectParameter, completionHandler: @escaping () -> Void){
        var request = NSFetchRequest<NSManagedObject>()
        switch providedObject{
        case is User.Type:
            request = User.createFetchRequest() as! NSFetchRequest<NSManagedObject>
            break
        case is Flight.Type:
            request = Flight.createFetchRequest() as! NSFetchRequest<NSManagedObject>
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
                let pred = NSPredicate(format: "ANY %@ = \(sortKey)", sortValue)
                makeCloudQuery(sortKey: sortKey, predicate: pred, cloudTable: cloudTable){cloudResults in
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
                let pred = NSPredicate(format: "ANY %@ = \(sortKey)", sortValue)
                makeCloudQuery(sortKey: sortKey, predicate: pred, cloudTable: cloudTable){ cloudResults in
                    if(!(cloudResults.isEmpty)){
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
    
    func makeLocalQuery(sortKey : String, predicate: NSPredicate, request: NSFetchRequest<NSManagedObject>, container: NSPersistentContainer, delegate : NSFetchedResultsControllerDelegate) -> [NSManagedObject]?{
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
    
    func makeCloudQuery(sortKey : String, predicate: NSPredicate, cloudTable: String, completionHandler: @escaping (_ records: [CKRecord]) -> Void){
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
    
    func saveRecords(records : [CKRecord], completionHandler: @escaping () -> Void){
        let operation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
        operation.modifyRecordsCompletionBlock = { savedRecords, deletedRecordID, error in
            if let error = error{
                print("Error: \(error.localizedDescription)")
            }
            else{
                print("success")
                completionHandler()
            }
        }
        CKContainer.default().publicCloudDatabase.add(operation)
        
    }
    
    func saveContext(container : NSPersistentContainer) {
        if container.viewContext.hasChanges {
            do {
                try container.viewContext.save()
            } catch {
                print("An error occurred while saving: \(error)")
            }
        }
    }
    
    func deindex(flight: Flight) {
        CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: ["\(flight.iataNumber)"]) { error in
            if let error = error {
                print("Deindexing error: \(error.localizedDescription)")
            } else {
                print("Search item successfully removed!")
            }
        }
    }
    
    func index(flight : Flight){
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
}
