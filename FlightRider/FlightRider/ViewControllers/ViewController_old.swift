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
    
    var databaseWorker = DatabaseWorker()
    var flights = [ManagedFlight]()
    var user : ManagedUser!
    var userRecord = CKRecord(recordType: "AppUsers")
    //var container: NSPersistentContainer!
    var uid : String!
    var email : String!
    
    var spinnerView : UIView!
    var ai : UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        spinnerView = UIView.init(frame: self.view.bounds)
        ai = UIActivityIndicatorView.init(style: .whiteLarge)
        let starttime = CFAbsoluteTimeGetCurrent()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addFlight))
        title = "Flights"
        self.showSpinner(view: self.view, spinnerView: spinnerView, ai: ai)
        loadUserData(){ [unowned self] in
            
            let flightRequest = ManagedFlight.createFetchRequest() as! NSFetchRequest<NSManagedObject>
            let flightPred = NSPredicate(format: "ANY uid IN %@", self.user.flights)
            let managedFlights = self.databaseWorker.makeLocalQuery(sortKey: "uid", predicate: flightPred, request: flightRequest, container: self.databaseWorker.container, delegate: self) as! [ManagedFlight]
            self.flights = [ManagedFlight]()
            for managedFlight in managedFlights{
                self.flights.append(managedFlight)
            }
            self.flights.sort(by: { $1.departureDate > $0.departureDate })
            print(self.flights)
            let elapsedTime = CFAbsoluteTimeGetCurrent() - starttime
            print(elapsedTime)
            DispatchQueue.main.async {
                    let range = NSMakeRange(0, self.tableView.numberOfSections)
                    let sections = NSIndexSet(indexesIn: range)
                    self.tableView.reloadSections(sections as IndexSet, with: .automatic) 
                    self.removeSpinner(spinnerView: self.spinnerView, ai: self.ai)
                print(self.user.flights)
                self.databaseWorker.getLocalDatabase(container: self.databaseWorker.container, delegate: self)
            }
            
        }

    }
    
    func loadUserData(completionHandler: @escaping () -> Void){
        databaseWorker.syncLocalDBWithiCloud(providedObject: ManagedUser.self, sortKey: "uid", sortValue: [self.uid], cloudTable: "AppUsers", saveParams: [self.uid, self.email], container: self.databaseWorker.container, delegate: self, saveToBothDbHandler: saveUserDataToBothDb, fetchFromCloudHandler: fetchUserFromCloud, compareChangeTagHandler: compareUserChangeTag, decideIfUpdateCloudOrDeleteHandler: decideIfUpdateCloudOrDeleteUser){ [unowned self] in
            self.databaseWorker.syncLocalDBWithiCloud(providedObject: ManagedFlight.self, sortKey: "uid", sortValue: self.user.flights, cloudTable: "Flights", saveParams: nil, container: self.databaseWorker.container, delegate: self, saveToBothDbHandler: self.doNothing, fetchFromCloudHandler: self.fetchFlightsFromCloud, compareChangeTagHandler: self.compareFlightsChangeTag, decideIfUpdateCloudOrDeleteHandler: self.deleteFlightsFromLocalDb) {
                    completionHandler()
            }
        }
    }
    
    func createStringsFromJson(json : JSON, flightCode : String, departureDate : String) -> [String]{
        var result = [String]()
        result.append(flightCode)
        let departureDateAndTime = "\(departureDate)  \(json["departureTime"].stringValue)"
        result.append(departureDateAndTime)
        return result
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
            self.databaseWorker.container.viewContext.delete(seat)
        }
        databaseWorker.deindex(flight: flight)
        unregisterFromFlightOnCloudDb(flight: flight)
        self.databaseWorker.container.viewContext.delete(flight)
        user.flights.removeAll{$0 == flight.uid}
        flights.remove(at: indexPath.row)
        userRecord["flights"] = user.flights as CKRecordValue
        tableView.deleteRows(at: [indexPath], with: .fade)
        self.databaseWorker.saveContext(container: self.databaseWorker.container)
        self.databaseWorker.getLocalDatabase(container: self.databaseWorker.container, delegate: self)
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
        let flight = flights[indexPath.row]
        let seatRequest = ManagedSeat.createFetchRequest() as! NSFetchRequest<NSManagedObject>
        let seatPred = NSPredicate(format: "flight = %@ AND occupiedBy = %@", flight, self.user.email)
        let occupiedSeats = (self.databaseWorker.makeLocalQuery(sortKey: "number", predicate: seatPred, request: seatRequest, container: self.databaseWorker.container, delegate: self) as? [ManagedSeat]) ?? [ManagedSeat]()
        if(occupiedSeats.isEmpty){
            if(Calendar.current.date(byAdding: .day, value:2, to: Date())! > flight.departureDate){
                if let vc = storyboard?.instantiateViewController(withIdentifier: "SelectSeats") as? SelectSeatsViewController{
                    /*vc.flight = flight
                    vc.user = self.user
                    vc.userRecord = self.userRecord
                    //vc.container = self.databaseWorker.container
                    vc.databaseWorker = self.databaseWorker
                    if let img = Bundle.main.path(forResource: "Ryanair", ofType: "png"){
                        vc.imageToLoad = UIImage(named: img)
                    }*/
                    var imgToLoad : UIImage?
                    if let img = Bundle.main.path(forResource: "Ryanair", ofType: "png"){
                        imgToLoad = UIImage(named: img)
                    }
                    let dependencies = ListFlights.SelectSeatsData.ViewModel(flight: flight, user: user, userRecord: userRecord, image: imgToLoad, databaseWorker: databaseWorker)
                    vc.fetchDataFromPreviousViewController(viewModel: dependencies)
                    navigationController?.pushViewController(vc, animated: true)
                }
            }
            else{
                if let vc = storyboard?.instantiateViewController(withIdentifier: "CannotCheckin") as? CannotCheckInViewController{
                    var imgToLoad : UIImage?
                    if let img = Bundle.main.path(forResource: "Ryanair", ofType: "png"){
                        imgToLoad = UIImage(named: img)
                    }
                    let dependencies = ListFlights.CannotCheckinData.ViewModel(iataNumber: flight.iataNumber, departureDate: flight.departureDate, imageToLoad: imgToLoad)
                    vc.fetchDataFromPreviousViewController(viewModel: dependencies)
                    navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
        else{
            if let vc = storyboard?.instantiateViewController(withIdentifier: "CheckSeats") as? CheckSeatsViewController{
                let dataModel = ListFlights.CheckSeatsData.DataStore(flight: flight, user: user, justSelectedSeat: false)
                vc.fetchDataFromPreviousViewController(viewModel: dataModel)
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
        if (flightCode != ""){
            
            let flightCount = user.flights.count
            
            let startDate = self.getDateString(receivedDate: selectedDate, dateFormat: "YYYY-MM-dd 00:00:00 Z")
            let finishDate = self.getDateString(receivedDate: selectedDate, dateFormat: "YYYY-MM-dd 23:59:59 Z")

            
            let formatter = DateFormatter()
            formatter.dateFormat = "YYYY-MM-dd HH:mm:ss Z"
            let nsStartDate = formatter.date(from: startDate)! as NSDate
            let nsFinishDate = formatter.date(from: finishDate)! as NSDate
            
            let value = self.flights.filter{$0.iataNumber == flightCode && $0.departureDate >= (nsStartDate as Date) && $0.departureDate <= (nsFinishDate as Date)}
            
            if(value.isEmpty){
                let flightPredicate = NSPredicate(format: "iataNumber = %@ AND departureDate >= %@ AND departureDate <= %@", flightCode, nsStartDate, nsFinishDate)
                databaseWorker.makeCloudQuery(sortKey: "iataNumber", predicate: flightPredicate, cloudTable: "Flights"){[unowned self] results in
                    var flightUid : String?
                    if(results.count == 1){
                        print(results.first!)
                        flightUid = results.first!["uid"]
                    }
                    let params = [flightCode, self.getDateString(receivedDate: selectedDate, dateFormat: "YYYY-MM-dd")]
                    self.databaseWorker.syncLocalDBWithiCloud(providedObject: ManagedFlight.self, sortKey: "uid", sortValue: [flightUid ?? "not found"], cloudTable: "Flights", saveParams: params, container: self.databaseWorker.container, delegate: self, saveToBothDbHandler: self.saveFlightDataToBothDbAppendToFlightList, fetchFromCloudHandler: self.fetchFlightsFromCloudAndAppendToUserList, compareChangeTagHandler: self.compareFlightsChangeTagAndAppendToUserList, decideIfUpdateCloudOrDeleteHandler: self.deleteFlightsFromLocalDb){ [unowned self] in
                        if(flightCount < self.user.flights.count){
                            let request = ManagedFlight.createFetchRequest() as! NSFetchRequest<NSManagedObject>
                            let newFlight = self.databaseWorker.makeLocalQuery(sortKey: "uid", predicate: flightPredicate, request: request, container: self.databaseWorker.container, delegate: self) as! [ManagedFlight]
                            self.flights.append(newFlight.first!)
                            self.databaseWorker.index(flight: newFlight.first!)
                            DispatchQueue.main.async {
                                let indexPath = IndexPath(row: self.flights.count - 1, section: 0)
                                self.tableView.insertRows(at: [indexPath], with: .automatic)
                            }
                        }
                    }
                }
            }
            else{
                flightAlreadyAdded()
            }
            
        }
        else{
            flightNumberIsEmpty()
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
    
    func flightAlreadyAdded(){
        DispatchQueue.main.async {
            let ac = UIAlertController(title: "Error", message: "The flight is already contained by the list", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Ok", style: .cancel)
            ac.addAction(cancelAction)
            self.present(ac, animated: true)
        }
    }
    
    func flightNumberIsEmpty(){
        DispatchQueue.main.async {
            let ac = UIAlertController(title: "Error", message: "The flight you specified is empty!", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Ok", style: .cancel)
            ac.addAction(cancelAction)
            self.present(ac, animated: true)
        }
    }
}
