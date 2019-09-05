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
        self.user = User(context: self.container.viewContext)
        self.user.uid = params![0]
        self.user.email = params![1]
        self.user.flights = [String]()
        self.saveRecords(records: [userRecord]){
            self.user.changetag = self.userRecord.recordChangeTag!
            self.saveContext()
            print(self.user.uid)
        }
        
    }
    
    func fetchUserFromCloud(results : [CKRecord]){
        self.userRecord = results.first!
        self.user = User(context: self.container.viewContext)
        self.user.uid = results.first!["uid"]!
        self.user.email = results.first!["email"]!
        self.user.flights = results.first!["flights"] ?? [String]()
        self.user.changetag = results.first!.recordChangeTag!
        print(self.user.uid)
        self.saveContext()
        let pred = NSPredicate(format: "uid = %@", results.first!["uid"]! as String)
        let request = User.createFetchRequest() as! NSFetchRequest<NSManagedObject>
        self.user = (makeLocalQuery(sortKey: "uid", predicate: pred, request: request) as! [User]).first!
        print(self.user.uid)
        
    }
    
    func compareUserChangeTag(localResults : [NSManagedObject],  cloudResults : [CKRecord]){
        self.user = localResults.first! as! User
        self.userRecord = cloudResults.first!
        if(self.user.changetag != cloudResults.first!.recordChangeTag){
            fetchUserFromCloud(results : cloudResults)
        }
    }
    
    func decideIfUpdateCloudOrDeleteUser(results : [NSManagedObject]){
        //this should never happen in case of users
    }
    

}
