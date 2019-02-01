//
//  LocationSearchViewController.swift
//  GoogleMapsDemo
//
//  Created by Abbas Angouti on 5/19/18.
//  Copyright © 2018 Abbas Angouti. All rights reserved.
//

import UIKit

class LocationSearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Properties
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var locations = [GeoCodeLocation]() {
        didSet {
            DispatchQueue.main.async { [unowned self] in
                self.tableView.reloadData()
            }
        }
    }
    
    
    // MARK: - View Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
    }
    
    
    func handleError(error: DataFetchError) {
        switch error {
        case .invalidURL:
            print("not a valid URL")
            break
        case .networkError(let message):
            print(message)
            break
        case .invalidResponse:
            print("invalid response from server")
            break
        case .serverError:
            print("unknown error received from server")
            break
        case .nilResult:
            print("unexpected nil in response")
            break
        case .invalidDataFormat:
            break
        case .jsonError(let message):
            print(message)
            break
        case .invalideDataType(let message):
            print(message)
            break
        case .unknownError:
            print("unknown error occured!")
        }
    }
    
    
    // MARK: - Table View
    func numberOfSections(in tableView: UITableView) -> Int {
        if locations.count > 1 {
            return 2
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if locations.count > 1 { // we have two sections
            if section == 0 {
                return 1
            } else {
                return locations.count
            }
        }
        return locations.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if locations.count > 1 {
            if indexPath.section == 0 {
                cell.textLabel?.text = "Display All on Map"
            } else {
                cell.textLabel!.text = locations[indexPath.row].formattedAddress
            }
        } else {
            cell.textLabel!.text = locations[indexPath.row].formattedAddress
        }
        
        return cell
    }
    
    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMap" {
            guard let mvc = segue.destination as? MapViewController else {
                return
            }
            
            guard let index = tableView.indexPathForSelectedRow else {
                return
            }
            if !(index == IndexPath(row: 0, section: 0) && locations.count > 1) { // or number of sections > 1
                mvc.selectedLocatoinIndex = index.row
            }
            mvc.locations = locations
        }
    }
}


extension LocationSearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true) // dismiss keyboard
        
        guard let text = searchBar.text, !text.isEmpty else {
            return
        }
        ApiClient.shared.getAddresses(for: text) { [unowned self] (result) in
            switch result {
            case .error(let error):
                self.handleError(error: error)
                break
            case .success(let gcr):
                if let gcr = gcr as? [GeoCodeLocation] {
                    self.locations = gcr
                }
                break
            }
        }
    }
}
