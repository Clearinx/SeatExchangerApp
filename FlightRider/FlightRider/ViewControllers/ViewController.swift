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
    var user : User!
    var userRecord = CKRecord(recordType: "AppUsers")
    var container: NSPersistentContainer!
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
            
            let flightRequest = Flight.createFetchRequest() as! NSFetchRequest<NSManagedObject>
            let flightPred = NSPredicate(format: "ANY iataNumber IN %@", self.user.flights)
            self.flights = self.makeLocalQuery(sortKey: "iataNumber", predicate: flightPred, request: flightRequest, container: self.container, delegate: self) as! [Flight]
            print(self.flights)
            let elapsedTime = CFAbsoluteTimeGetCurrent() - starttime
            print(elapsedTime)
            DispatchQueue.main.async {
                    let range = NSMakeRange(0, self.tableView.numberOfSections)
                    let sections = NSIndexSet(indexesIn: range)
                    self.tableView.reloadSections(sections as IndexSet, with: .automatic) 
                    self.removeSpinner(spinnerView: self.spinnerView, ai: self.ai)
            }
            //usres in local DB
            /*var request = User.createFetchRequest() as! NSFetchRequest<NSManagedObject>
            var pred = NSPredicate(value: true)
            var results = self.makeLocalQuery(sortKey: "uid", predicate: pred, request: request, container: self.container, delegate: self)
            for result in results!{
                print("\nUser:\n")
                let localuser = result as! User
                print(localuser.uid)
                print(localuser.email)
                print(localuser.flights)
                print(localuser.changetag)
            }
            //flights in local DB
            request = Flight.createFetchRequest() as! NSFetchRequest<NSManagedObject>
            pred = NSPredicate(value: true)
            results = self.makeLocalQuery(sortKey: "uid", predicate: pred, request: request, container: self.container, delegate: self)
            for result in results!{
                print("\nFlight:\n")
                let localflight = result as! Flight
                print(localflight.uid)
                print(localflight.changetag)
                print(localflight.departureDate)
                print(localflight.iataNumber)
                print(localflight.airplaneType)
                print(localflight.seats.count)
            }
            
            request = Seat.createFetchRequest() as! NSFetchRequest<NSManagedObject>
            pred = NSPredicate(value: true)
            results = self.makeLocalQuery(sortKey: "uid", predicate: pred, request: request, container: self.container, delegate: self)
            for result in results!{
                print("\nSeat:\n")
                let localseat = result as! Seat
                print(localseat.uid)
                print(localseat.changetag)
                print(localseat.number)
                print(localseat.occupiedBy)
                print(localseat.flight.iataNumber)
            }
            print(results?.count)*/
            
        }

    }
    
    func loadUserData(completionHandler: @escaping () -> Void){
        syncLocalDBWithiCloud(providedObject: User.self, sortKey: "uid", sortValue: [self.uid], cloudTable: "AppUsers", saveParams: [self.uid, self.email], container: container, delegate: self, saveToBothDbHandler: saveUserDataToBothDb, fetchFromCloudHandler: fetchUserFromCloud, compareChangeTagHandler: compareUserChangeTag, decideIfUpdateCloudOrDeleteHandler: decideIfUpdateCloudOrDeleteUser){ [unowned self] in
            self.syncLocalDBWithiCloud(providedObject: Flight.self, sortKey: "iataNumber", sortValue: self.user.flights, cloudTable: "Flights", saveParams: nil, container: self.container, delegate: self, saveToBothDbHandler: self.doNothing, fetchFromCloudHandler: self.fetchFlightsFromCloud, compareChangeTagHandler: self.compareFlightsChangeTag, decideIfUpdateCloudOrDeleteHandler: self.deleteFlightsFromLocalDb) {
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
            container.viewContext.delete(seat)
        }
        deindex(flight: flight)
        
        unregisterFromFlightOnCloudDb(flight: flight)
        container.viewContext.delete(flight)
        user.flights.removeAll{$0 == flight.iataNumber}
        flights.remove(at: indexPath.row)
        userRecord["flights"] = user.flights as CKRecordValue
        tableView.deleteRows(at: [indexPath], with: .fade)
        saveContext(container: container)
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
        let seatRequest = Seat.createFetchRequest() as! NSFetchRequest<NSManagedObject>
        let seatPred = NSPredicate(format: "flight = %@ AND occupiedBy = %@", flight, self.user.email)
        let occupiedSeats = (self.makeLocalQuery(sortKey: "number", predicate: seatPred, request: seatRequest, container: self.container, delegate: self) as? [Seat]) ?? [Seat]()
        if(occupiedSeats.isEmpty){
            if(Calendar.current.date(byAdding: .day, value:2, to: Date())! > flight.departureDate){
                if let vc = storyboard?.instantiateViewController(withIdentifier: "FlightDetailSelectSeats") as? FlightDetailViewControllerSelectSeats{
                    vc.flight = flight
                    vc.user = self.user
                    vc.userRecord = self.userRecord
                    vc.container = container
                    if let img = Bundle.main.path(forResource: "Ryanair", ofType: "png"){
                        vc.imageToLoad = UIImage(named: img)
                    }
                    navigationController?.pushViewController(vc, animated: true)
                }
            }
            else{
                if let vc = storyboard?.instantiateViewController(withIdentifier: "FlightDetailCannotCheckin") as? FlightDetailViewControllerCannotCheckin{
                    vc.flightNrString = flight.iataNumber
                    vc.departureDate = flight.departureDate
                    if let img = Bundle.main.path(forResource: "Ryanair", ofType: "png"){
                        vc.imageToLoad = UIImage(named: img)
                    }
                    navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
        else{
            if let vc = storyboard?.instantiateViewController(withIdentifier: "CheckSeats") as? CheckSeatsViewController{
                vc.flight = flight
                vc.user = user
                vc.justSelectedSeat = false
                navigationController?.pushViewController(vc, animated: true)
            }
        }
        /*if indexPath.row == 0{
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
        }*/
        
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
        if (!user.flights.contains(flightCode)){
            let flightCount = user.flights.count
            let params = [flightCode, getDateString(receivedDate: selectedDate, dateFormat: "YYYY-MM-dd")]
            self.syncLocalDBWithiCloud(providedObject: Flight.self, sortKey: "iataNumber", sortValue: [flightCode], cloudTable: "Flights", saveParams: params, container: container, delegate: self, saveToBothDbHandler: self.saveFlightDataToBothDbAppendToFlightList, fetchFromCloudHandler: self.fetchFlightsFromCloudAndAppendToUserList, compareChangeTagHandler: self.compareFlightsChangeTagAndAppendToUserList, decideIfUpdateCloudOrDeleteHandler: self.deleteFlightsFromLocalDb){ [unowned self] in
                if(flightCount < self.user.flights.count){
                    let request = Flight.createFetchRequest() as! NSFetchRequest<NSManagedObject>
                    let pred = NSPredicate(format: "iataNumber = %@", flightCode)
                    let newFlight = self.makeLocalQuery(sortKey: "uid", predicate: pred, request: request, container: self.container, delegate: self) as! [Flight]
                    self.flights.append(newFlight.first!)
                    self.index(flight: newFlight.first!)
                    DispatchQueue.main.async {
                        let indexPath = IndexPath(row: self.flights.count - 1, section: 0)
                        self.tableView.insertRows(at: [indexPath], with: .automatic)
                    }
                }
            }
        }
        else{
            flightAlreadyAdded()
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
    
    /*override func viewWillAppear(_ animated: Bool) {
        //self.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
        super.viewWillAppear(animated)
        
        // Add a background view to the table view
        let backgroundImage = UIImage(named: "flight1")
        let imageView = UIImageView(image: backgroundImage)
        imageView.contentMode = .scaleAspectFill
        self.tableView.backgroundView = imageView
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
    }*/
    
    

}

