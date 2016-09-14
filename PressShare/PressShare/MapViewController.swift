//
//  ViewController.swift
//  On the Map
//
//  Created by MacbookPRV on 28/04/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//


import CoreData
import Foundation
import MapKit
import UIKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var IBMap: MKMapView!
    @IBOutlet weak var IBLogout: UIBarButtonItem!
    
    
    var users = [User]()
    
    var user_pseudo:String!
    var user_id:Int!
    var config = Config.sharedInstance
    var produits = Produits.sharedInstance
    var traduction = InternationalIHM.sharedInstance
    var lat:CLLocationDegrees!
    var lon:CLLocationDegrees!
    
    
    var filePath : String {
        let manager = NSFileManager.defaultManager()
        let url = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first! as NSURL
        return url.URLByAppendingPathComponent("mapRegionArchive").path!
    }
    
    
    var sharedContext: NSManagedObjectContext {
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return delegate.managedObjectContext
    }
    
    
    //MARK: View Controller Delegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        user_pseudo  = config.user_pseudo
        user_id = config.user_id
        
        users = fetchAllUser()
        
        
    }
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        
        restoreMapRegion(false)
        RefreshData()
        
        self.navigationItem.title = "\(config.user_nom) \(config.user_prenom) (\(config.user_id))"
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.tabBarItem.title = traduction.pam1
        IBLogout.title = traduction.pam4
    }
    
    
    private func fetchAllUser() -> [User] {
        
        
        users.removeAll()
        // Create the Fetch Request
        let fetchRequest = NSFetchRequest(entityName: "User")
        
        // Execute the Fetch Request
        do {
            return try sharedContext.executeFetchRequest(fetchRequest) as! [User]
        } catch _ {
            return [User]()
        }
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        
        if segue.identifier == "mapproduit" {
            
            let nav = segue.destinationViewController as! UINavigationController
            let controller = nav.topViewController as! ListProduitViewController
            
            controller.lon = lon
            controller.lat = lat
        }
        
    }
    
    
    
    //MARK: Data Networking
    @IBAction func ActionRefresh(sender: AnyObject) {
        
        RefreshData()
    }
    
    private func RefreshData()  {
        
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
                
                performUIUpdatesOnMain {
                    self.IBMap.addAnnotations(annotations)
                }
                
            }
            else {
                performUIUpdatesOnMain {
                    self.displayAlert("Error", mess: errorString!)
                }
            }
        }
        
    }
    
    
    @IBAction func ActionLogout(sender: AnyObject) {
        
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
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    //MARK: Map function
    
    
    private func restoreMapRegion(animated: Bool) {
        
        // if we can unarchive a dictionary, we will use it to set the map back to its
        // previous center and span
        if let regionDictionary = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as? [String : AnyObject] {
            
            let longitude = regionDictionary["longitude"] as! CLLocationDegrees
            let latitude = regionDictionary["latitude"] as! CLLocationDegrees
            let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            let longitudeDelta = regionDictionary["latitudeDelta"] as! CLLocationDegrees
            let latitudeDelta = regionDictionary["longitudeDelta"] as! CLLocationDegrees
            let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
            
            let savedRegion = MKCoordinateRegion(center: center, span: span)
            
            IBMap.setRegion(savedRegion, animated: animated)
        }
    }
    
    private func saveMapRegion() {
        
        // Place the "center" and "span" of the map into a dictionary
        // The "span" is the width and height of the map in degrees.
        // It represents the zoom level of the map.
        
        let dictionary = [
            "latitude" : IBMap.region.center.latitude,
            "longitude" : IBMap.region.center.longitude,
            "latitudeDelta" : IBMap.region.span.latitudeDelta,
            "longitudeDelta" : IBMap.region.span.longitudeDelta
        ]
        
        // Archive the dictionary into the filePath
        NSKeyedArchiver.archiveRootObject(dictionary, toFile: filePath)
    }
    
    
    
    //MARK: Map View Delegate
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView?.pinTintColor = UIColor.redColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            performSegueWithIdentifier("mapproduit", sender: self)
        }
    }
    
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        
        
        if let coord = view.annotation?.coordinate {
            
            lat = coord.latitude
            lon = coord.longitude
            
        }
        
    }
    
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        saveMapRegion()
    }
    
    
}

