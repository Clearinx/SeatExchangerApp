//
//  ViewController.swift
//  FlightRider
//
//  Created by Tomi on 2019. 07. 19..
//  Copyright © 2019. Tomi. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UITableViewController, UIGestureRecognizerDelegate {
    
    var flights = [Flight]()
    var container: NSPersistentContainer!
    var fetchedResultsController: NSFetchedResultsController<Flight>!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addFlight))
        title = "Flights"
        
        setupContainer()
        loadSavedData()
        parseJson()
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
    
    func parseJson(){
        if let filepath = Bundle.main.path(forResource: "test_flights", ofType: "json") {
            do {
                let data = try String(contentsOfFile: filepath)
                let jsonData = JSON(parseJSON: data)
                let jsonArray = jsonData.arrayValue
                for json in jsonArray {
                    createObjectsFromJson(json : json)

                }
                self.saveContext()
            } catch {
                // contents could not be loaded
            }
        } else {
            // example.txt not found!
        }
        
    }
    
    func createObjectsFromJson(json : JSON){
        let flight = Flight(context: self.container.viewContext)
        flight.iataNumber = json["flight"]["iataNumber"].stringValue
        flight.checkedIn = false
        
        let departureDate = json["departure"]["scheduledTime"].stringValue
        let dateFormat = getDate(receivedDate: departureDate)
        flight.departureDate = dateFormat
        
        
        let seat = Seat(context: self.container.viewContext)
        seat.number = "13C"
        seat.occupiedBy = "AAA"
        
        print(flight)
        print(flights[14])
        
        let numbers = [1, 2, 3, 4]
        let contains = flight.seats.contains(where: {$0.number == "3" })
        
        let storedFlight = flights.firstIndex(of: flight)
        print(flights.count)
        flight.seats.insert(seat)
        
        
        
    }
    
    func loadSavedData() {
        let request = Flight.createFetchRequest()
        let sort = NSSortDescriptor(key: "iataNumber", ascending: false)
        request.sortDescriptors = [sort]
        
        do {
            flights = try container.viewContext.fetch(request)
            for flight in flights{
                print(flight.iataNumber)
                print(flight.departureDate)
                for element in flight.seats{
                    print(element.number)
                    print(element.occupiedBy)
                }
            }
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
    
    /*override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }*/
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
            tableView.setEditing(false, animated: false)
            flights.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .none)
    }
    
    
    func getDate(receivedDate : String) -> Date
    {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.zzz"
        let date = formatter.date(from: receivedDate)! // change this to nil colescaling!
        return date
    }
    
    func getDateString(receivedDate : Date) -> String
    {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
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
    
    /*@objc func addFlight(){
        let ac = UIAlertController(title: "Enter a flight number", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self, weak ac] action in
            guard let flight = ac?.textFields?[0].text else { return }
            self?.submit(flight)
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    func submit(_ flight: String) {
        
        /*flights.append(flight)
        let indexPath = IndexPath(row: flights.count - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)*/
    }*/
    
    /*@objc func removeFlight(idx: Int){
        if let idx = listIdx{
            flights.remove(at: idx)
            let indexPath = IndexPath(row: idx, section: 0)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            listIdx = nil
        }
    }
    
    
    func setupLongPressGesture() {
        let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress))
        longPressGesture.minimumPressDuration = 1.0
        longPressGesture.delegate = self
        self.view.addGestureRecognizer(longPressGesture)
    }
    
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == .began {
            let touchPoint = gestureRecognizer.location(in: self.view)
            if let indexPath = self.tableView.indexPathForRow(at: touchPoint) {
                //tableView.isEditing = tableView.isEditing
                tableView.setEditing(!tableView.isEditing, animated: true)
                //tableView.allowsSelectionDuringEditing = true
            }
        }
    }*/
    

}

