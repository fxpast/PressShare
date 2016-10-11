//
//  ViewController.swift
//  On the Map
//
//  Created by MacbookPRV on 28/04/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//

import CoreLocation
import CoreData
import Foundation
import MapKit
import UIKit

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var IBMap: MKMapView!
    @IBOutlet weak var IBLogout: UIBarButtonItem!
    @IBOutlet weak var IBtextfieldSearch: UITextField!
    @IBOutlet weak var IBAddProduct: UIBarButtonItem!
    
    
    
    var users = [User]()
    
    var user_pseudo:String!
    var user_id:Int!
    var config = Config.sharedInstance
    var produits = Produits.sharedInstance
    var traduction = InternationalIHM.sharedInstance
    var lat:CLLocationDegrees!
    var lon:CLLocationDegrees!
    var userLat:CLLocationDegrees!
    var userLon:CLLocationDegrees!
    var flgUser=false
    var flgRegion=false
    
    let locationManager = CLLocationManager()
    
    
    
    var sharedContext: NSManagedObjectContext {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.managedObjectContext
    }
    
    
    //MARK: View Controller Delegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if config.user_pseudo == "anonymous" {
            IBAddProduct.isEnabled = false
        }
        
        flgRegion = false
        
        IBtextfieldSearch.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        
        if locationManager.responds(to: #selector(CLLocationManager.requestWhenInUseAuthorization)) {
            locationManager.requestWhenInUseAuthorization()
        }
        
        locationManager.startUpdatingLocation()
        
        user_pseudo  = config.user_pseudo
        user_id = config.user_id
        
        users = fetchAllUser()
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        navigationController?.tabBarItem.title = traduction.pam1
        IBLogout.title = traduction.pam4
        IBtextfieldSearch.placeholder = traduction.pse3
        
        flgUser = false
        
        RefreshData()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
     
        
    }
    
    
    fileprivate func fetchAllUser() -> [User] {
        
        
        users.removeAll()
        // Create the Fetch Request
        
        let request : NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "User")
        
        // Execute the Fetch Request
        do {
            return try sharedContext.fetch(request) as! [User]
        } catch _ {
            return [User]()
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if segue.identifier == "mapproduit" {
            
            let nav = segue.destination as! UINavigationController
            let controller = nav.topViewController as! ListProduitViewController
            if flgUser {
                
                controller.flgUser = true
            }
            else {
                controller.lon = lon
                controller.lat = lat
                
            }
            
            
        }
        
    }
    
    
    //MARK: textfield Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        
        let geoCode  = CLGeocoder()
        
        
        geoCode.geocodeAddressString(textField.text!, completionHandler: {(marks,error) in
            
            guard error == nil else {
                performUIUpdatesOnMain {
                    
                    self.displayAlert("error geocodeadresse", mess: error.debugDescription)
                }
                return
            }
            
            performUIUpdatesOnMain {
                
                let placemark = marks![0] as CLPlacemark
                
                //Setting Visible Area
                let regionRadius: CLLocationDistance = 1000
                let coordinateRegion = MKCoordinateRegionMakeWithDistance((placemark.location?.coordinate)!,regionRadius * 2.0, regionRadius * 2.0)
                self.IBMap.setRegion(coordinateRegion, animated: true)
                
            }
            
        })
        
        textField.endEditing(true)
        return true
        
    }
    
    
    
    //MARK: Data Networking
    @IBAction func ActionRefresh(_ sender: AnyObject) {
        
        RefreshData()
    }
    
    fileprivate func RefreshData()  {
        
        let annoArray = IBMap.annotations as [AnyObject]
        for item in annoArray {
            IBMap.removeAnnotation(item as! MKAnnotation)
        }
        
        
        
        getAllProduits(config.user_id) { (success, produitArray, errorString) in
            
            
            if success {
                
                self.produits.produitsArray = produitArray
                
                var annotations = [MKPointAnnotation]()
                
                for dictionary in self.produits.produitsArray! {
                    
                    let produit = Produit(dico: dictionary)
                    // Notice that the float values are being used to create CLLocationDegree values.
                    // This is a version of the Double type.
                    let lat = CLLocationDegrees(produit.prod_latitude)
                    let long = CLLocationDegrees(produit.prod_longitude)
                    
                    // The lat and long are used to create a CLLocationCoordinates2D instance.
                    let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    
                    // Here we create the annotation and set its coordiate, title, and subtitle properties
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate
                    annotation.title = "\(produit.prod_nom) (user:\(produit.prod_by_user))"
                    annotation.subtitle = "\(produit.prod_mapString) / \(produit.prod_comment)"
                    
                    // Finally we place the annotation in an array of annotations.
                    annotations.append(annotation)
                }
                
                var coordinateRegion=MKCoordinateRegion()
                if let _ = self.userLon, let _ = self.userLat {
                    
                    // The lat and long are used to create a CLLocationCoordinates2D instance.
                    let coordinate = CLLocationCoordinate2D(latitude: self.userLat, longitude: self.userLon)
                    
                    // Here we create the annotation and set its coordiate, title, and subtitle properties
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate
                    annotation.title = "user:"
                    annotation.subtitle = "\(self.config.user_nom) \(self.config.user_prenom) (\(self.config.user_id))"
                    
                    // Finally we place the annotation in an array of annotations.
                    annotations.append(annotation)
                    
                    //Setting Visible Area
                    let regionRadius: CLLocationDistance = 1000
                    coordinateRegion = MKCoordinateRegionMakeWithDistance(annotation.coordinate,regionRadius * 2.0, regionRadius * 2.0)
                    
                }
                
                performUIUpdatesOnMain {
                    self.IBMap.addAnnotations(annotations)
                    if let _ = self.userLon, let _ = self.userLat {
                        if !self.flgRegion {
                            self.IBMap.setRegion(coordinateRegion, animated: true)
                            self.flgRegion = true
                        }
                        
                    }
                    
                }
                
            }
            else {
                performUIUpdatesOnMain {
                    self.displayAlert("Error", mess: errorString!)
                }
            }
        }
        
    }
    
    
    @IBAction func ActionLogout(_ sender: AnyObject) {
        
        //logout
        if users.count > 0 {
            for aUser in users {
                if aUser.user_pseudo == config.user_pseudo {
                    aUser.user_logout = true
                    
                    // Save the context.
                    do {
                        try sharedContext.save()
                    } catch _ {}
                    
                    break
                }
            }
            
            users = fetchAllUser()
            
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    //MARK: Location Delegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        userLat = manager.location?.coordinate.latitude
        userLon = manager.location?.coordinate.longitude
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        print("Error while updating location \(error.localizedDescription)")
        
        
    }
    
    
    //MARK: Map View Delegate
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView?.pinTintColor = UIColor.red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        if (pinView?.annotation?.title)! == "user:" {
            pinView?.pinTintColor = UIColor.blue
        }
        else {
            pinView?.pinTintColor = UIColor.red
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == view.rightCalloutAccessoryView {
            if (view.annotation?.title)! == "user:" {
                flgUser = true
            }
            
            performSegue(withIdentifier: "mapproduit", sender: self)
            
            
            
            
        }
        
    }
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        
        if let coord = view.annotation?.coordinate {
            
            lat = coord.latitude
            lon = coord.longitude
            
        }
        
    }
    
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
    }
    
    
}

