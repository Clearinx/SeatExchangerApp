
import Foundation
import CoreData
import CloudKit

protocol UserWorkerProtocol{
    var databaseWorker : DatabaseWorker! { get set }
    var interactor : ListFlightsInteractor? { get set }
    
    func compareUserChangeTag(localResults : [NSManagedObject],  cloudResults : [CKRecord])
    func decideIfUpdateCloudOrDeleteUser(results : [NSManagedObject])
    func fetchUserFromCloud(results : [CKRecord])
    func saveUserDataToBothDb(params: [String]?)
}

extension UserWorkerProtocol{
    func saveUserDataToBothDb(params: [String]?){
        let cloudUser = CloudUser(email: params![1], uid: params![0], flights: [String]())
        let user = User(email: params![1], flights: [String](), uid: params![0], changetag: "")
        let managedUser = ManagedUser(context: databaseWorker.container.viewContext)
        managedUser.fromUser(user: user)
        self.databaseWorker.saveRecords(records: [cloudUser.userRecord]){
            managedUser.changetag = cloudUser.userRecord.recordChangeTag!
            self.databaseWorker.saveContext(container: self.databaseWorker.container)
            let response = ListFlights.UserData.Response(localUser: managedUser, cloudUser: cloudUser)
            self.interactor?.pushDatabaseObjectsToDataStore(response: response)
            
        }
    }
    
    func fetchUserFromCloud(results : [CKRecord]){
        let cloudUser = CloudUser(record: results.first!)
        let user = User(email: cloudUser.email, flights: cloudUser.flights, uid: cloudUser.uid, changetag: cloudUser.userRecord.recordChangeTag!)
        let managedUser = ManagedUser(context: self.databaseWorker.container.viewContext)
        managedUser.fromUser(user: user)
        self.databaseWorker.saveContext(container: self.databaseWorker.container)
        let response = ListFlights.UserData.Response(localUser: managedUser, cloudUser: cloudUser)
        self.interactor?.pushDatabaseObjectsToDataStore(response: response)
        //maybe it is not neccessarry at all
        /*let pred = NSPredicate(format: "uid = %@", results.first!["uid"]! as String)
         let request = ManagedUser.createFetchRequest() as! NSFetchRequest<NSManagedObject>
         managedUser = (databaseWorker.makeLocalQuery(sortKey: "uid", predicate: pred, request: request, container: self.databaseWorker.container, delegate: self) as! [ManagedUser]).first!*/
        //until this point
    }
    
    func compareUserChangeTag(localResults : [NSManagedObject],  cloudResults : [CKRecord]){
        let managedUser = localResults.first! as? ManagedUser
        let cloudUser = CloudUser(record: cloudResults.first!)
        if(managedUser?.changetag != cloudUser.userRecord.recordChangeTag){
            fetchUserFromCloud(results : cloudResults)
        }
        else{
            let response = ListFlights.UserData.Response(localUser: managedUser, cloudUser: cloudUser)
            self.interactor?.pushDatabaseObjectsToDataStore(response: response)
        }
    }
    
    func decideIfUpdateCloudOrDeleteUser(results : [NSManagedObject]){
        //this should never happen in case of users
    }
}
