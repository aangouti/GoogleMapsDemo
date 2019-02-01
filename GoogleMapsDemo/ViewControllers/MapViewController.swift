//
//  ViewController.swift
//  GoogleMapsDemo
//
//  Created by Abbas Angouti on 5/19/18.
//  Copyright © 2018 Abbas Angouti. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreData

class MapViewController: UIViewController {
    var mapView: GMSMapView?
    
    var locations = [GeoCodeLocation]()
    var cdLocations: [NSManagedObject] = []

    var selectedLocatoinIndex = -1
    var alreadyPersisted = false {
        didSet {
            if zoomOnSingeLocation() {
                if alreadyPersisted {
                    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Delete", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.deleteLocation))
                    
                } else {
                    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.saveLocation))
                }
            }
        }
    }
    
    
    private func zoomOnSingeLocation() -> Bool {
        return selectedLocatoinIndex != -1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initiateMapView()
        
        if zoomOnSingeLocation() {
            print(fetch())
            alreadyPersisted = fetch() > 0
        }
    }

    
    private func initiateMapView() {
        mapView = GMSMapView(frame: CGRect.zero)
        view = mapView
        
        showLocations()
    }
    

    @objc func showLocations() {
        let zoom: Float = zoomOnSingeLocation() ? 6 : 1.2
        
        for (i, location) in locations.enumerated() {
            mapView?.camera = GMSCameraPosition.camera(withLatitude: location.geometry.location.latitude, longitude: location.geometry.location.longitude, zoom: zoom)
            
            let marker = GMSMarker()
            marker.position = location.geometry.location
            marker.title = location.formattedAddress
            marker.snippet = "(\(location.geometry.location.latitude) \(location.geometry.location.longitude))"
            marker.map = mapView
            if zoomOnSingeLocation() {
                if i == selectedLocatoinIndex {
                    mapView?.selectedMarker = marker
                    mapView?.camera = GMSCameraPosition.camera(withLatitude: locations[i].geometry.location.latitude, longitude: locations[i].geometry.location.longitude, zoom: zoom)
                }
            }
        }
    }
    
    @objc func saveLocation() {
        save(location: locations[selectedLocatoinIndex])
    }
    
    @objc func deleteLocation() {
        fetch(andDelete: true)
    }
}

extension MapViewController {
    func save(location: GeoCodeLocation) {
        // to avoid duplicates
        guard fetch() == 0 else {
            print("Already Saved")
            return
        }
        
        let managedContext = getContext()
        
        let entity = NSEntityDescription.entity(forEntityName: "CDLocationObject",
                                                in: managedContext)!
        
        let cdLocation = NSManagedObject(entity: entity,
                                     insertInto: managedContext)
        
        cdLocation.setValue(location.formattedAddress, forKeyPath: "formattedAddress")
        cdLocation.setValue(location.geometry.location.latitude, forKeyPath: "locationLatitude")
        cdLocation.setValue(location.geometry.location.longitude, forKeyPath: "locationLongitude")
        
        do {
            try managedContext.save()
            cdLocations.append(cdLocation)
            alreadyPersisted = true
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    
    @discardableResult
    func fetch(andDelete delete: Bool = false) -> Int {
        let currentlocation = locations[selectedLocatoinIndex]
        let managedContext = getContext()
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CDLocationObject")
        let predicateFormattedAddress = NSPredicate(format: "formattedAddress==%@", currentlocation.formattedAddress)
        fetchRequest.predicate = predicateFormattedAddress
        
        do {
            let persistedLocations = try managedContext.fetch(fetchRequest)
            let count = persistedLocations.count
            if delete {
                for persistedLocation in persistedLocations {
                    managedContext.delete(persistedLocation)
                    do {
                        try managedContext.save()
                        print("Deleted successfully")
                        DispatchQueue.main.async { [unowned self] in
                            self.alreadyPersisted = false
                        }
                    } catch let error as NSError  {
                        print("Could not save \(error), \(error.userInfo)")
                    }
                }
            }
            return count
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return 0
        }
    }
    
    
    
    
    // MARK: Get Context
    
    func getContext () -> NSManagedObjectContext {
        return CoreDataStack.managedObjectContext
    }
    
}
