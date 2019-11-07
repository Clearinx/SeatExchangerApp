//
//  ListFlightsViewController.swift
//  FlightRider
//
//  Created by Tomi on 2019. 10. 31..
//  Copyright (c) 2019. Tomi. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit
import CoreData

protocol ListFlightsDisplayLogic: class, NSFetchedResultsControllerDelegate
{
    func displayUIUpdate(request: ListFlights.UIUpdate.Request)
    func fetchDataFromPreviousViewController(dataModel: Login.DataStore.ListViewDataModel)
    func pushViewModelUpdate(viewModel: ListFlights.FligthsToDisplay.ViewModel)
}

class ListFlightsViewController: UITableViewController, ListFlightsDisplayLogic
{
    var spinnerView : UIView!
    var ai : UIActivityIndicatorView!
    var viewModel = ListFlights.DataStore.ViewModel()
    
    var interactor: ListFlightsBusinessLogic?
    var router: (NSObjectProtocol & ListFlightsRoutingLogic & ListFlightsDataPassing)?

  // MARK: Object lifecycle
  
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)
    {
      super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
      setup()
    }
  
    required init?(coder aDecoder: NSCoder)
    {
      super.init(coder: aDecoder)
      setup()
    }
  
  // MARK: Setup
  
    private func setup()
    {
        let viewController = self
        let interactor = ListFlightsInteractor()
        let presenter = ListFlightsPresenter()
        let router = ListFlightsRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        interactor.worker = ListFlightsWorker()
        interactor.worker!.interactor = interactor
        interactor.worker!.databaseWorker = interactor.databaseWorker
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
  
  // MARK: Routing
  
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let scene = segue.identifier {
            let selector = NSSelectorFromString("routeTo\(scene)WithSegue:")
            if let router = router, router.responds(to: selector) {
                router.perform(selector, with: segue)
            }
        }
    }
  
  // MARK: View lifecycle
  
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setSpinnerView()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addFlight))
        title = "Flights"
        self.showSpinner(view: self.view, spinnerView: spinnerView, ai: ai)
        let request = ListFlights.UserData.EmptyRequest()
        interactor?.requestLoadUserData(request: request)
    }
    
    //MARK: - Fetch functions
    
    func fetchDataFromPreviousViewController(dataModel: Login.DataStore.ListViewDataModel) {
        interactor?.fetchDataFromPreviousViewController(dataModel: dataModel)
        viewModel.flights = [ManagedFlight]()
    }
    
    //MARK: - Push functions
    
    func pushViewModelUpdate(viewModel: ListFlights.FligthsToDisplay.ViewModel) {
        self.viewModel.flights = viewModel.flights
        self.viewModel.departureDates = viewModel.departureDates
    }
    
    //MARK: - DisplayFunctions
    
    func displayUIUpdate(request: ListFlights.UIUpdate.Request) {
        DispatchQueue.main.async {
            let range = NSMakeRange(0, self.tableView.numberOfSections)
            let sections = NSIndexSet(indexesIn: range)
            self.tableView.reloadSections(sections as IndexSet, with: .automatic)
            self.removeSpinner(spinnerView: self.spinnerView, ai: self.ai)
        }
    }
    
    //MARK: - Local functions
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        return viewModel.flights.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "Flight", for: indexPath)
        cell.textLabel?.text = viewModel.flights[indexPath.row].iataNumber
        cell.detailTextLabel?.text = viewModel.departureDates[indexPath.row]
        //temp method to display image, this does not belong here
        if let img = Bundle.main.path(forResource: "Ryanair", ofType: "png"){
            cell.imageView?.image = UIImage(named: img)
        }
        return cell
    }
    
    private func setSpinnerView(){
        spinnerView = UIView.init(frame: self.view.bounds)
        ai = UIActivityIndicatorView.init(style: .whiteLarge)
    }
    
    @objc func addFlight(){
        let ac = UIAlertController(title: "Enter the departure date and the flight number", message: nil, preferredStyle: .alert)
        var selectedDate = Date()
        ac.addTextField()
        ac.addDatePicker(mode: .date, date: Date(), minimumDate: Date(), maximumDate: Calendar.current.date(byAdding: .year, value:2, to: Date())){ date in
            selectedDate = date
        }
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned self] action in
            guard let flightCode = ac.textFields?[0].text else { return }
            self.submit(flightCode.uppercased(), selectedDate)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        ac.addAction(submitAction)
        ac.addAction(cancelAction)
        present(ac, animated: true)
    }
    
    func submit(_ flightCode: String, _ selectedDate: Date) {
        
    }
}
