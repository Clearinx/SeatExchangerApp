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
        }
        
    }
    
    func fetchUserFromCloud(results : [CKRecord]){
        self.userRecord = results.first!
        self.user = User(context: self.container.viewContext)
        self.user.uid = results.first!["uid"]!
        self.user.email = results.first!["email"]!
        self.user.flights = results.first!["flights"] ?? [String]()
        self.user.changetag = results.first!.recordChangeTag!
        self.saveContext()
    }
    //DIR DIR DIRI DURI KALAPIRU PURI
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
