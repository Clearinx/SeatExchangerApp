//
//  ViewController.swift
//  FlightRider
//
//  Created by Tomi on 2019. 07. 19..
//  Copyright © 2019. Tomi. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    var flights = [String]()
    var listIdx : Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addFlight))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(removeFlight))
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return flights.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Flight", for: indexPath)
        cell.textLabel?.text = flights[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        listIdx = indexPath.row
    }
    
    @objc func addFlight(){
        let ac = UIAlertController(title: "Enter a flight number", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self, weak ac] action in
            guard let answer = ac?.textFields?[0].text else { return }
            self?.submit(answer)
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    func submit(_ answer: String) {
        
        flights.append(answer)
        let indexPath = IndexPath(row: flights.count - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    @objc func removeFlight(){
        if let idx = listIdx{
            flights.remove(at: idx)
            let indexPath = IndexPath(row: idx, section: 0)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            listIdx = nil
        }
    }


}

