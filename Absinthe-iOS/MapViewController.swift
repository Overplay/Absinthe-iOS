//
//  MapViewController.swift
//  Belashi-iOS
//
//  Created by Noah on 8/4/16.
//  Copyright © 2016 AppDelegates. All rights reserved.
//

import UIKit
import MapKit
import MMDrawerController
import CoreLocation
import SwiftyJSON

class MapViewController : LeftSideSubViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    
    var annotations = [MKAnnotation]()
    
    var currentLocation: CLLocation!
    
    func processVenues( inboundVenueJson: JSON ){
        
        guard let venueArray = inboundVenueJson.array else {
            log.debug("No venues found!")
            return
        }
        
        var existingLocations = [String]()
        
        // val is one restaurant object
        for venue in venueArray {
            
            let address = venue["address"]
            let name  = venue["name"].stringValue
            
            // WTF is this??? MAK
//            if name != "" && address.count != 4 {
//                continue
//            }
            
            // Address components compiled into one human readable string
            let location = String(format: "%@, %@, %@, %@", address["street"].stringValue, address["city"].stringValue, address["state"].stringValue, address["zip"].stringValue)
            
            // There were some duplicates in the database so I'm filtering those out here. We don't really need this in the future though because that's more a database issue
            if existingLocations.contains(location) {
                continue
            }else {
                existingLocations.append(location)
            }
            let geocoder: CLGeocoder = CLGeocoder()
            // Convert address into coordinates for visual map items
            geocoder.geocodeAddressString(location,completionHandler: {(placemarks: [CLPlacemark]?, error: NSError?) -> Void in
                if (placemarks?.count > 0) {
                    let topResult: CLPlacemark = (placemarks?[0])!
                    let placemark = MKPlacemark(placemark: topResult)
                    let pointAnnotation = MKPointAnnotation()
                    pointAnnotation.coordinate = placemark.coordinate
                    pointAnnotation.title = name
                    pointAnnotation.subtitle = location
                    self.mapView.addAnnotation(pointAnnotation)
                }
            })
        }

        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        let recenterBarButton = UIBarButtonItem(title: "Recenter", style: .Plain, target: self, action: #selector(recenter))
        self.navigationItem.rightBarButtonItem = recenterBarButton
        
        self.mapView.delegate = self
        
        Asahi.sharedInstance.getVenues()
            
            .then { response -> Void in
                log.debug("Got venues!")
                self.processVenues(response)
            }
            
            .error{ err -> Void in
                log.error("Error getting venues")
                print(err)
        }
    }
    
    func recenter() {
        // Zoom in on current location
        // 0.3 is some number. The smaller it is, the smaller the frame (huh, makes sense right?)
        self.mapView.setRegion(MKCoordinateRegionMake(self.currentLocation.coordinate, MKCoordinateSpanMake(0.3, 0.3)), animated: true)
    }
    
}

extension MapViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.annotations.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("OGMapItemCell") as UITableViewCell?
        
        if cell == nil {
            cell = UITableViewCell(style: .Subtitle, reuseIdentifier: "OGMapItemCell")
            cell?.backgroundColor = UIColor(white: 51/255, alpha: 1.0)
            cell?.textLabel?.textColor = UIColor.whiteColor()
            cell?.detailTextLabel?.textColor = UIColor( white: 1.0, alpha: 0.7)
        }
        
        let annotation = self.annotations[indexPath.row]
        
        
        
        cell!.textLabel!.text = annotation.title!
        
        if cell!.textLabel!.text! == "Current Location" {
            cell!.textLabel!.font = UIFont.boldSystemFontOfSize(cell!.textLabel!.font!.pointSize)
            cell!.detailTextLabel!.text = ""
        }else {
            cell!.textLabel!.font = UIFont.systemFontOfSize(cell!.textLabel!.font!.pointSize)
            cell!.detailTextLabel!.text = annotation.subtitle!
        }
        
        return cell!
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    // On select or deselect of row, select or deselect that pin (aka annotation)
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let annotation = self.annotations[indexPath.row]
        if self.mapView.viewForAnnotation(annotation)!.selected {
            self.mapView.deselectAnnotation(annotation, animated: true)
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }else {
            self.mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
}

extension MapViewController : MKMapViewDelegate {
    
    // When the map view updates the current location, update the class variable.
    // But only recenter it upon getting this location the very first time, hence,
    // currentLocation would be nil to start off. If the user moves around, we don't
    // want to just zoom them back in or they can't look around
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        let shouldCenter = self.currentLocation == nil
        self.currentLocation = userLocation.location!
        if shouldCenter {
            recenter()
        }
    }
    
    // Requested when creating the pin (aka annotation) view
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.title! != "Current Location" {
            let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "OurglasserPin")
            pinAnnotationView.animatesDrop = true
            // This is the green color RGB for Ourglass logo
            pinAnnotationView.pinTintColor = UIColor(red: (57.0/255.0), green: (172.0/255.0), blue: (72.0/255.0), alpha: 1.0)
            pinAnnotationView.canShowCallout = true
            // Make clickable
            let button = UIButton(type: .DetailDisclosure)
            pinAnnotationView.rightCalloutAccessoryView = button
            return pinAnnotationView
        }else {
            return nil
        }
    }
    
    // Link deselection of pin (aka annotation) to table view
    func mapView(mapView: MKMapView, didDeselectAnnotationView view: MKAnnotationView) {
        let annotation = view.annotation!
        let index = self.annotations.indexOf({
            $0.title! == annotation.title!
        })!
        self.tableView.deselectRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0), animated: true)
    }
    
    // Link selection of pin (aka annotation) to table view
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        let annotation = view.annotation!
        let index = self.annotations.indexOf({
            $0.title! == annotation.title!
        })!
        self.tableView.selectRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0), animated: true, scrollPosition: .Middle)
    }
    
    // If the region changes, we want to remove what's in the table view
    // For one, if you try to open an annotation view that isn't on screen,
    // it crashes. But also it helps the user to see what's around them, and
    // if they zoom out, they can see more. You can make this zoom out to fit
    // if the annotation isn't in view if you want, but I thought this worked nicely.
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        // Order annotations by distance from user
        let visibleAnnotations = (Array(self.mapView.annotationsInMapRect(self.mapView.visibleMapRect)) as NSArray) as! [MKAnnotation]
        self.annotations = [MKAnnotation]()
        self.annotations = visibleAnnotations.sort({ (ann1: MKAnnotation, ann2: MKAnnotation) -> Bool in
            // Always order Current Location first
            // Also, if currentLocation isn't set yet, it will crash trying to determine distance, obviously.
            // This method is called once when location is found beacuse map recents and the region changes, so
            // the list will reload anyways.
            if ann1.title! == "Current Location" || self.currentLocation == nil {
                return true
            }
            let coordLoc1 = CLLocation(latitude: ann1.coordinate.latitude, longitude: ann1.coordinate.longitude)
            let dist1 = self.currentLocation.distanceFromLocation(coordLoc1)
            let coordLoc2 = CLLocation(latitude: ann2.coordinate.latitude, longitude: ann2.coordinate.longitude)
            let dist2 = self.currentLocation.distanceFromLocation(coordLoc2)
            return dist1 < dist2
        })
        self.tableView.reloadData()
    }
    
    // Order annotations when they are first added to map
    func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView]) {
        // Order annotations by distance from user
        let visibleAnnotations = (Array(self.mapView.annotationsInMapRect(self.mapView.visibleMapRect)) as NSArray) as! [MKAnnotation]
        self.annotations = [MKAnnotation]()
        self.annotations = visibleAnnotations.sort({ (ann1: MKAnnotation, ann2: MKAnnotation) -> Bool in
            if ann1.title! == "Current Location" || self.currentLocation == nil {
                return true
            }
            let coordLoc1 = CLLocation(latitude: ann1.coordinate.latitude, longitude: ann1.coordinate.longitude)
            let dist1 = self.currentLocation.distanceFromLocation(coordLoc1)
            let coordLoc2 = CLLocation(latitude: ann2.coordinate.latitude, longitude: ann2.coordinate.longitude)
            let dist2 = self.currentLocation.distanceFromLocation(coordLoc2)
            return dist1 < dist2
        })
        self.tableView.reloadData()
    }
    
    // Open in apple maps! My favorite...
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        // Make restaurant map item
        let placemark = MKPlacemark(coordinate: view.annotation!.coordinate, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = view.annotation!.title!
        mapItem.openInMapsWithLaunchOptions([MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving])
    }
    
}
