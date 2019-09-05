//
//  ViewController.swift
//  FlightRider
//
//  Created by Tomi on 2019. 07. 19..
//  Copyright © 2019. Tomi. All rights reserved.
//

import UIKit
import CoreData
import CloudKit

class ViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    var flights = [Flight]()
    var user = User()
    var userRecord = CKRecord(recordType: "AppUsers")
    var container: NSPersistentContainer!
    var fetchedResultsController: NSFetchedResultsController<Flight>!
    var fetchedUser: NSFetchedResultsController<User>!
    var uid : String = ""
    var email : String = ""
    typealias NSManagedObjectParameter = ([NSManagedObject]) -> Void
    typealias StringValuesParameter = ([String]?) -> Void
    typealias CKRecordParameter = ([CKRecord]) -> Void
    typealias NSManagedAndCkrecordParameter = ([NSManagedObject], [CKRecord]) -> Void

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addFlight))
        title = "Flights"
        
        loadUserData(){ [unowned self] in
            
            let request = Flight.createFetchRequest() as! NSFetchRequest<NSManagedObject>
            let pred = NSPredicate(format: "ANY iataNumber IN %@", self.user.flights)
            print(self.user.flights)
            self.flights = self.makeLocalQuery(sortKey: "uid", predicate: pred, request: request) as! [Flight]
            print(self.flights)
            DispatchQueue.main.async {
                    self.tableView.reloadData()
            }
            /*//usres in local DB
            var request = User.createFetchRequest() as! NSFetchRequest<NSManagedObject>
            var pred = NSPredicate(value: true)
            var results = self.makeLocalQuery(sortKey: "uid", predicate: pred, request: request)
            for result in results!{
                let localuser = result as! User
                print(localuser.uid)
                print(localuser.email)
                print(localuser.flights)
                print(localuser.changetag)
            }
            //flights in local DB
            request = Flight.createFetchRequest() as! NSFetchRequest<NSManagedObject>
            pred = NSPredicate(value: true)
            results = self.makeLocalQuery(sortKey: "uid", predicate: pred, request: request)
            for result in results!{
                let localflight = result as! Flight
                print(localflight.uid)
                print(localflight.changetag)
                print(localflight.departureDate)
                print(localflight.iataNumber)
            }
            
            request = Seat.createFetchRequest() as! NSFetchRequest<NSManagedObject>
            pred = NSPredicate(value: true)
            results = self.makeLocalQuery(sortKey: "uid", predicate: pred, request: request)
            for result in results!{
                let localseat = result as! Seat
                print(localseat.uid)
                print(localseat.changetag)
                print(localseat.number)
                print(localseat.occupiedBy)
            }*/
            
        }

    }
    
    func loadUserData(completionHandler: @escaping () -> Void){
        syncLocalDBWithiCloud(providedObject: User.self, sortKey: "uid", sortValue: [self.uid], cloudTable: "AppUsers", saveParams: [self.uid, self.email], saveToBothDbHandler: saveUserDataToBothDb, fetchFromCloudHandler: fetchUserFromCloud, compareChangeTagHandler: compareUserChangeTag, decideIfUpdateCloudOrDeleteHandler: decideIfUpdateCloudOrDeleteUser){
                self.syncLocalDBWithiCloud(providedObject: Flight.self, sortKey: "iataNumber", sortValue: self.user.flights, cloudTable: "Flights", saveParams: nil, saveToBothDbHandler: self.doNothing, fetchFromCloudHandler: self.fetchFlightsFromCloud, compareChangeTagHandler: self.compareFlightsChangeTag, decideIfUpdateCloudOrDeleteHandler: self.deleteFlightsFromLocalDb) {
                    print(self.user.flights)
                    completionHandler()
            }
        }
    }
    //function only for loading some dummy data
    /*func parseJson(){
        if let filepath = Bundle.main.path(forResource: "test_flights", ofType: "json") {
            do {
                let data = try String(contentsOfFile: filepath)
                let jsonData = JSON(parseJSON: data)
                let jsonArray = jsonData.arrayValue
                for json in jsonArray {
                    // the following three lines are new
                    print(json["flight"]["iataNumber"].stringValue)
                    let flight = Flight(context: self.container.viewContext)
                    flight.iataNumber = json["flight"]["iataNumber"].stringValue
                    flight.checkedIn = false
                    
                    let departureDate = json["departure"]["scheduledTime"].stringValue
                    let dateFormat = getDate(receivedDate: departureDate)
                    flight.departureDate = dateFormat
                    
                    /*let seat = Seat(context: self.container.viewContext)
                     seat.number = "13C"
                     seat.occupiedBy = "AAA"
                     seat.flight = flight
                     flight.seats = [seat]*/
                }
                self.saveContext()
            } catch {
                // contents could not be loaded
            }
        } else {
            // example.txt not found!
        }
        
    }*/
    
    
    func createStringsFromJson(json : JSON, flightCode : String, departureDate : String) -> [String]{
        var result = [String]()
        result.append(flightCode)
        
        let departureDateAndTime = "\(departureDate)  \(json["departureTime"].stringValue)"
        
        
        result.append(departureDateAndTime)
        
        return result
        
    }
    
    
    /*func checkUserData() {
        let request = User.createFetchRequest()
        let sort = NSSortDescriptor(key: "uid", ascending: true)
        request.sortDescriptors = [sort]
            
        fetchedUser = NSFetchedResultsController(fetchRequest: request, managedObjectContext: container.viewContext, sectionNameKeyPath: "uid", cacheName: nil)
        fetchedUser.delegate = self
        
        fetchedUser.fetchRequest.predicate = NSPredicate(format: "uid == %@", self.uid)
        do {
            try fetchedUser.performFetch()
            let result = fetchedUser.fetchedObjects! //ok to force unwrap, because if fetch is succesful, fetchedObjects cannot be nil
            if(result.first != nil){
                
                user = result.first!
            }
            else{
                let pred = NSPredicate(format: "uid == %@", self.uid)
                let sort = NSSortDescriptor(key: "uid", ascending: true)
                let query = CKQuery(recordType: "AppUsers", predicate: pred)
                query.sortDescriptors = [sort]
                //self.showSpinner(onView: self.view)
                CKContainer.default().publicCloudDatabase.perform(query, inZoneWith: nil){ results, error in
                    //self.removeSpinner()
                    if let error = error {
                        print("Cloud Query Error - Fetch Establishments: \(error.localizedDescription)")
                        return
                    }
                    if(results != nil){
                        if(!(results!.isEmpty)){
                            
                        }
                        else{
                            let userRecord = CKRecord(recordType: "AppUsers")
                            userRecord["uid"] = self.uid as CKRecordValue
                            userRecord["email"] = self.email as CKRecordValue
                            userRecord["flights"] = [String]() as CKRecordValue

                            self.user = User(context: self.container.viewContext)
                            self.user.uid = self.uid
                            self.user.email = self.email
                            self.user.flights = [String]()
                            self.user.changetag = ""
                            
                            self.saveRecords(records: [userRecord])
                            self.saveContext()
                    }
                }
            }
        }
    }
        catch {
        print("Fetch failed")
    }
}*/
    func syncLocalDBWithiCloud(providedObject: NSManagedObject.Type, sortKey : String, sortValue : [String], cloudTable : String, saveParams: [String]?, saveToBothDbHandler: @escaping StringValuesParameter, fetchFromCloudHandler: @escaping CKRecordParameter, compareChangeTagHandler: @escaping NSManagedAndCkrecordParameter, decideIfUpdateCloudOrDeleteHandler: @escaping NSManagedObjectParameter, completionHandler: @escaping () -> Void){
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
        
        if let localResults = makeLocalQuery(sortKey: sortKey, predicate: pred, request: request){
            if(!(localResults.isEmpty)){
                let pred = NSPredicate(format: "ANY %@ = \(sortKey)", sortValue)
                makeCloudQuery(sortKey: sortKey, predicate: pred, cloudTable: cloudTable){ cloudResults in
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
    
    func makeLocalQuery(sortKey : String, predicate: NSPredicate, request: NSFetchRequest<NSManagedObject>) -> [NSManagedObject]?{
        let sort = NSSortDescriptor(key: sortKey, ascending: true)
        request.sortDescriptors = [sort]
        let fetchedObject = NSFetchedResultsController(fetchRequest: request, managedObjectContext: container.viewContext, sectionNameKeyPath: sortKey, cacheName: nil)
        fetchedObject.delegate = self
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
        /*CKContainer.default().publicCloudDatabase.save(records[0]) {result, error in
         DispatchQueue.main.async {
         if let error = error {
         print( "Error: \(error.localizedDescription)")
         } else {
         print("Done!")
         
         }
         
         }
         }*/
        
    }
        
    
    
    func loadFlightsToTableView() {
        let request = Flight.createFetchRequest()
        let sort = NSSortDescriptor(key: "uid", ascending: true)
        request.sortDescriptors = [sort]
            
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: container.viewContext, sectionNameKeyPath: "uid", cacheName: nil)
        fetchedResultsController.delegate = self
        
        fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "ANY uid IN %@", user.flights)
        do {
            try fetchedResultsController.performFetch()
            flights = fetchedResultsController.fetchedObjects! //ok to force unwrap, because if fetch is succesful, fetchedObjects cannot be nil
            tableView.reloadData()
        } catch {
            print("Fetch failed")
        }
    }
    
    func saveContext() {
        if container.viewContext.hasChanges {
            do {
                try container.viewContext.save()
            } catch {
                print("An error occurred while saving: \(error)")
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        return flights.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "Flight", for: indexPath)
        cell.textLabel?.text = flights[indexPath.row].iataNumber
        cell.detailTextLabel?.text = getDateString(receivedDate: flights[indexPath.row].departureDate, dateFormat: "YYYY-MM-dd HH:mm:ss")
        if let img = Bundle.main.path(forResource: "Ryanair", ofType: "png"){
            cell.imageView?.image = UIImage(named: img)
        }
        return cell
    }

    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let flight = flights[indexPath.row]
        for seat in flight.seats{
            container.viewContext.delete(seat)
        }
        container.viewContext.delete(flight)
        user.flights.removeAll{$0 == flight.iataNumber}
        flights.remove(at: indexPath.row)
        userRecord["flights"] = user.flights as CKRecordValue
        saveRecords(records: [userRecord]){}
        tableView.deleteRows(at: [indexPath], with: .fade)
        saveContext()
    }
    
    
    func getDate(receivedDate : String) -> Date
    {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        let date = formatter.date(from: receivedDate) ?? Date()
        return date
    }
    
    func getDateString(receivedDate : Date, dateFormat: String) -> String
    {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        let date = formatter.string(from: receivedDate)
        return date
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0{
            if let vc = storyboard?.instantiateViewController(withIdentifier: "FlightDetail") as? FlightDetailViewController{
                vc.flightNrString = flights[indexPath.row].iataNumber
                if let img = Bundle.main.path(forResource: "Ryanair", ofType: "png"){
                    vc.imageToLoad = UIImage(named: img)
                }
                navigationController?.pushViewController(vc, animated: true)
            }
        }
        else if indexPath.row == 1{
            if let vc = storyboard?.instantiateViewController(withIdentifier: "FlightDetailSelectSeats") as? FlightDetailViewControllerSelectSeats{
                vc.flightNrString = flights[indexPath.row].iataNumber
                if let img = Bundle.main.path(forResource: "Ryanair", ofType: "png"){
                    vc.imageToLoad = UIImage(named: img)
                }
                navigationController?.pushViewController(vc, animated: true)
            }
        }
        else if indexPath.row == 2{
            if let vc = storyboard?.instantiateViewController(withIdentifier: "FlightDetailCannotCheckin") as? FlightDetailViewControllerCannotCheckin{
                vc.flightNrString = flights[indexPath.row].iataNumber
                if let img = Bundle.main.path(forResource: "Ryanair", ofType: "png"){
                    vc.imageToLoad = UIImage(named: img)
                }
                navigationController?.pushViewController(vc, animated: true)
            }
        }
        else if indexPath.row == 3{
            if let vc = storyboard?.instantiateViewController(withIdentifier: "CheckSeats") as? CheckSeatsViewController{
                navigationController?.pushViewController(vc, animated: true)
            }
        }
        else if indexPath.row == 4{
            if let vc = storyboard?.instantiateViewController(withIdentifier: "ExchangeAggreement") as? FlightDetailViewControllerExchangeAggreement{
                vc.flightNrString = flights[indexPath.row].iataNumber
                if let img = Bundle.main.path(forResource: "Ryanair", ofType: "png"){
                    vc.imageToLoad = UIImage(named: img)
                }
                navigationController?.pushViewController(vc, animated: true)
            }
        }
        
    }
    
    @objc func addFlight(){
        let ac = UIAlertController(title: "Enter the departure date and the flight number", message: nil, preferredStyle: .alert)
        var selectedDate = Date()
        ac.addTextField()
        ac.addDatePicker(mode: .date, date: Date(), minimumDate: Date(), maximumDate: Calendar.current.date(byAdding: .year, value:2, to: Date())){ date in
            print(date)
            selectedDate = date
        }
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned self, unowned ac] action in
            guard let flightCode = ac.textFields?[0].text else { return }
            self.submit(flightCode.uppercased(), selectedDate)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        
        ac.addAction(submitAction)
        ac.addAction(cancelAction)
        present(ac, animated: true)
    }
    
    func submit(_ flightCode: String, _ selectedDate: Date) {
        let flightCount = user.flights.count
        let params = [flightCode, getDateString(receivedDate: selectedDate, dateFormat: "YYYY-MM-dd")]
        self.syncLocalDBWithiCloud(providedObject: Flight.self, sortKey: "iataNumber", sortValue: [flightCode], cloudTable: "Flights", saveParams: params, saveToBothDbHandler: self.saveFlightDataToBothDbAppendToFlightList, fetchFromCloudHandler: self.fetchFlightsFromCloudAndAppendToUserList, compareChangeTagHandler: self.compareFlightsChangeTagAndAppendToUserList, decideIfUpdateCloudOrDeleteHandler: self.deleteFlightsFromLocalDb){
            if(flightCount < self.user.flights.count){
                let request = Flight.createFetchRequest() as! NSFetchRequest<NSManagedObject>
                let pred = NSPredicate(format: "iataNumber = %@", flightCode)
                let newFlight = self.makeLocalQuery(sortKey: "uid", predicate: pred, request: request) as! [Flight]
                self.flights.append(newFlight.first!)
                DispatchQueue.main.async {
                    let indexPath = IndexPath(row: self.flights.count - 1, section: 0)
                    self.tableView.insertRows(at: [indexPath], with: .automatic)
                }
            }
        }
    }
    
    func flightNotFoundError(){
        DispatchQueue.main.async {
            let ac = UIAlertController(title: "Error", message: "Could not found flight", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Ok", style: .cancel)
            ac.addAction(cancelAction)
            self.present(ac, animated: true)
        }
    }
    
    

}

