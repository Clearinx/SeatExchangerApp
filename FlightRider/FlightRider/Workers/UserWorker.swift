//
//  UserWorker.swift
//  FlightRider
//
//  Created by Tomi on 2019. 08. 29..
//  Copyright © 2019. Tomi. All rights reserved.
//

import Foundation
import CloudKit
import CoreData

protocol UserWorkerProtocol: class{
    
    var databaseWorker : DatabaseWorkerProtocol! { get set }
    var user : ManagedUser! { get set }
    var userRecord : CKRecord { get set }
    var uid : String! { get set }
    var email : String! { get set }
    
    func saveUserDataToBothDb(params: [String]?)
    func fetchUserFromCloud(results : [CKRecord])
    func compareUserChangeTag(localResults : [NSManagedObject],  cloudResults : [CKRecord])
    func decideIfUpdateCloudOrDeleteUser(results : [NSManagedObject])
}

extension UserWorkerProtocol {
    
    func saveUserDataToBothDb(params: [String]?){
        self.userRecord["uid"] = params![0] as CKRecordValue
        self.userRecord["email"] = params![1] as CKRecordValue
        self.userRecord["flights"] = [String]() as CKRecordValue
        let user = User(email: params![1], flights: [String](), uid: params![0], changetag: "")
        self.user = ManagedUser(context: self.databaseWorker.container.viewContext)
        self.user.fromUser(user: user)
        self.databaseWorker.saveRecords(records: [userRecord]){ [unowned self] in
            self.user.changetag = self.userRecord.recordChangeTag ?? ""
            self.databaseWorker.saveContext(container: self.databaseWorker.container)
        }
        
    }
    
    func fetchUserFromCloud(results : [CKRecord]){
        self.userRecord = results.first!
        
        let user = User(email: results.first!["email"]!, flights: results.first!["flights"] ?? [String](), uid: results.first!["uid"]!, changetag: results.first!.recordChangeTag ?? "")
        self.user = ManagedUser(context: self.databaseWorker.container.viewContext)
        self.user.fromUser(user: user)
        self.databaseWorker.saveContext(container: self.databaseWorker.container)
        
        //maybe it is not neccessarry at all
        /*let pred = NSPredicate(format: "uid = %@", results.first!["uid"]! as String)
        let request = ManagedUser.createFetchRequest() as! NSFetchRequest<NSManagedObject>
        self.user = (databaseWorker.makeLocalQuery(sortKey: "uid", predicate: pred, request: request, container: self.databaseWorker.container, delegate: self as! NSFetchedResultsControllerDelegate) as! [ManagedUser]).first!*/
        //until this point
        
    }
    
    func compareUserChangeTag(localResults : [NSManagedObject],  cloudResults : [CKRecord]){
        self.user = localResults.first! as? ManagedUser
        self.userRecord = cloudResults.first!
        if(self.user.changetag != cloudResults.first!.recordChangeTag ?? ""){
            fetchUserFromCloud(results : cloudResults)
        }
    }
    
    func decideIfUpdateCloudOrDeleteUser(results : [NSManagedObject]){
        //this should never happen in case of users
    }
    
    
}
