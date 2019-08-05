//
//  ViewController.swift
//  FlightRider
//
//  Created by Tomi on 2019. 07. 19..
//  Copyright © 2019. Tomi. All rights reserved.
//

import UIKit

class ViewController: UITableViewController, UIGestureRecognizerDelegate {
    
    var flights = [String]()
    //var listIdx : Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addFlight))
        /*navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(removeFlight))*/
        title = "Flights"
        flights.append("FR110")
        flights.append("FR111")
        flights.append("FR112")
        flights.append("FR113")
        
        //setupLongPressGesture()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        return flights.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "Flight", for: indexPath)
        cell.textLabel?.text = flights[indexPath.row]
        cell.detailTextLabel?.text = getDate()
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
    
    
    func getDate() -> String
    {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let date = formatter.string(from: Date()) // string purpose I add here
        return date
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0{
            if let vc = storyboard?.instantiateViewController(withIdentifier: "FlightDetail") as? FlightDetailViewController{
                vc.flightNrString = flights[indexPath.row]
                if let img = Bundle.main.path(forResource: "Ryanair", ofType: "png"){
                    vc.imageToLoad = UIImage(named: img)
                }
                navigationController?.pushViewController(vc, animated: true)
            }
        }
        else if indexPath.row == 1{
            if let vc = storyboard?.instantiateViewController(withIdentifier: "FlightDetailSelectSeats") as? FlightDetailViewControllerSelectSeats{
                vc.flightNrString = flights[indexPath.row]
                if let img = Bundle.main.path(forResource: "Ryanair", ofType: "png"){
                    vc.imageToLoad = UIImage(named: img)
                }
                navigationController?.pushViewController(vc, animated: true)
            }
        }
        else if indexPath.row == 2{
            if let vc = storyboard?.instantiateViewController(withIdentifier: "FlightDetailCannotCheckin") as? FlightDetailViewControllerCannotCheckin{
                vc.flightNrString = flights[indexPath.row]
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
        
    }
    
    @objc func addFlight(){
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
        
        flights.append(flight)
        let indexPath = IndexPath(row: flights.count - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
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

