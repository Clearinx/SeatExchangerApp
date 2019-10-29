//
//  ViewControllerExtension.swift
//  FlightRider
//
//  Created by Tomi on 2019. 08. 29..
//  Copyright © 2019. Tomi. All rights reserved.
//

import Foundation
import CloudKit
import CoreData

extension ViewController {
    
    func saveUserDataToBothDb(params: [String]?){
        self.userRecord["uid"] = self.uid as CKRecordValue
        self.userRecord["email"] = self.email as CKRecordValue
        self.userRecord["flights"] = [String]() as CKRecordValue
        let user = User(email: params![1], flights: [String](), uid: params![0], changetag: "")
        self.user = ManagedUser(context: container.viewContext)
        self.user.fromUser(user: user)
        self.saveRecords(records: [userRecord]){ [unowned self] in
            self.user.changetag = self.userRecord.recordChangeTag!
            self.saveContext(container: self.container)
            print(self.user.uid)
        }
        
    }
    
    func fetchUserFromCloud(results : [CKRecord]){
        self.userRecord = results.first!
        
        let user = User(email: results.first!["email"]!, flights: results.first!["flights"] ?? [String](), uid: results.first!["uid"]!, changetag: results.first!.recordChangeTag!)
        self.user = ManagedUser(context: self.container.viewContext)
        self.user.fromUser(user: user)
        self.saveContext(container: container)
        
        //maybe it is not neccessarry at all
        let pred = NSPredicate(format: "uid = %@", results.first!["uid"]! as String)
        let request = ManagedUser.createFetchRequest() as! NSFetchRequest<NSManagedObject>
        self.user = (makeLocalQuery(sortKey: "uid", predicate: pred, request: request, container: container, delegate: self) as! [ManagedUser]).first!
        //until this point
        
    }
    
    func compareUserChangeTag(localResults : [NSManagedObject],  cloudResults : [CKRecord]){
        self.user = localResults.first! as? ManagedUser
        self.userRecord = cloudResults.first!
        if(self.user.changetag != cloudResults.first!.recordChangeTag){
            fetchUserFromCloud(results : cloudResults)
        }
    }
    
    func decideIfUpdateCloudOrDeleteUser(results : [NSManagedObject]){
        //this should never happen in case of users
    }
    

}
