//
//  ViewController.swift
//  FlightRider
//
//  Created by Tomi on 2019. 07. 19..
//  Copyright © 2019. Tomi. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    var flights = [Flight]()
    var user = User()
    var container: NSPersistentContainer!
    var fetchedResultsController: NSFetchedResultsController<Flight>!
    var fetchedUser: NSFetchedResultsController<User>!
    var uid : String = ""
    var email : String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addFlight))
        title = "Flights"
        
        
        
        setupContainer()
       // parseJson()
        checkUserData()
        loadSavedData()
        print(uid)
    }
    func setupContainer(){
        container = NSPersistentContainer(name: "FlightRider")
        
        container.loadPersistentStores { storeDescription, error in
            self.container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            
            if let error = error {
                print("Unresolved error \(error)")
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
    
    
    func createObjectsFromJson(json : JSON, flightCode : String){
        let flight = Flight(context: self.container.viewContext)
        flight.iataNumber = flightCode
        flight.checkedIn = false
        
        let departureDate = json["departureTime"].stringValue
        let dateFormat = getDate(receivedDate: departureDate)
        flight.departureDate = dateFormat
        
        
        let seat = Seat(context: self.container.viewContext)
        seat.number = "13C"
        seat.occupiedBy = "AAA"
        
        let seat2 = Seat(context: self.container.viewContext)
        seat2.number = "13F"
        seat2.occupiedBy = "BBB"
        
        if let idx = flights.firstIndex(where: {$0.iataNumber == flight.iataNumber }){
            if (!flights[idx].seats.contains(where: {$0.number == seat.number })) && (!flights[idx].seats.contains(where: {$0.number == seat2.number })){
                flight.seats.insert(seat)
                flight.seats.insert(seat2)
            }
        }
        else{
            flight.seats.insert(seat)
            flight.seats.insert(seat2)
            flights.append(flight)
            let indexPath = IndexPath(row: flights.count-1, section: 0)
            tableView.insertRows(at: [indexPath], with: .automatic)
            user.flights.append(flight.iataNumber)
        }
        
        
        
    }
    
    func checkUserData() {
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
                user = User(context: self.container.viewContext)
                user.uid = self.uid
                user.email = self.email
                user.flights = [String]()
                saveContext()
            }
            
            print(user.email)
        } catch {
            print("Fetch failed")
        }
    }
    
    func loadSavedData() {
        let request = Flight.createFetchRequest()
        let sort = NSSortDescriptor(key: "iataNumber", ascending: true)
        request.sortDescriptors = [sort]
            
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: container.viewContext, sectionNameKeyPath: "iataNumber", cacheName: nil)
        fetchedResultsController.delegate = self
        
        fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "ANY iataNumber IN %@", user.flights)
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
        cell.detailTextLabel?.text = getDateString(receivedDate: flights[indexPath.row].departureDate)
        if let img = Bundle.main.path(forResource: "Ryanair", ofType: "png"){
            cell.imageView?.image = UIImage(named: img)
        }
        return cell
    }

    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let flight = flights[indexPath.row]
        //container.viewContext.delete(flight)
        user.flights.removeAll{$0 == flight.iataNumber}
        flights.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
        saveContext()
    }
    
    
    func getDate(receivedDate : String) -> Date
    {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        let date = formatter.date(from: receivedDate) ?? Date()
        return date
    }
    
    func getDateString(receivedDate : Date) -> String
    {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
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
        let ac = UIAlertController(title: "Enter a flight number", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self, weak ac] action in
            guard let flightCode = ac?.textFields?[0].text else { return }
            self?.submit(flightCode.uppercased())
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    func submit(_ flightCode: String) { //async download needed

        let airlineIata = flightCode.prefix(2)
        let flightNumber = flightCode.suffix(flightCode.count-2)
        print(airlineIata)
        print(flightNumber)
        let urlString = "https://aviation-edge.com/v2/public/routes?key=ee252d-c24759&airlineIata=\(airlineIata)&flightNumber=\(flightNumber)"
        do{
            let data = try String(contentsOf: URL(string: urlString)!)
            let jsonData = JSON(parseJSON: data)
            let jsonArray = jsonData.arrayValue
            if jsonArray.count > 0{
                DispatchQueue.main.async { [unowned self] in
                    self.createObjectsFromJson(json : jsonArray[0], flightCode: flightCode)
                    self.saveContext()
                }
            }
            else{
                flightNotFoundError()
            }

        }
        catch{
            flightNotFoundError()
            
        }
    }
    
    func flightNotFoundError(){
        let ac = UIAlertController(title: "Error", message: "Could not found flight", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Ok", style: .cancel)
        ac.addAction(cancelAction)
        present(ac, animated: true)
    }
    
    

}

