//
//  InfoPostViewController.swift
//  On the Map
//
//  Created by MacbookPRV on 02/05/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//

import Foundation
import MapKit
import UIKit

class ProduitViewController : UIViewController , MKMapViewDelegate, UITextFieldDelegate {
    
    
    @IBOutlet weak var IBCancel: UIBarButtonItem!
    @IBOutlet weak var IBSave: UIBarButtonItem!
    @IBOutlet weak var IBFind: UIButton!
    @IBOutlet weak var IBMap: MKMapView!
    @IBOutlet weak var IBInfoLocation: UITextField!
    @IBOutlet weak var IBActivity: UIActivityIndicatorView!
    @IBOutlet weak var IBNom: UITextField!
    @IBOutlet weak var IBPrix: UITextField!
    @IBOutlet weak var IBComment: UITextField!
    @IBOutlet weak var IBNoimage: UIImageView!
    
    
    var aproduit:Produit?
    
    var config = Config.sharedInstance
    let traduction = InternationalIHM.sharedInstance
    
    var filePath : String {
        let manager = NSFileManager.defaultManager()
        let url = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first! as NSURL
        return url.URLByAppendingPathComponent("mapRegionArchive").path!
    }
    
    
    //MARK: View Controller Delegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        IBActivity.stopAnimating()
        
        setUIHidden(true)
        
        IBInfoLocation.text = config.mapString
        IBCancel.title = traduction.pse1
        IBSave.title = traduction.pse2
        IBInfoLocation.placeholder = traduction.pse3
        IBFind.titleLabel?.text = traduction.pse4

        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.title = "\(config.user_nom) \(config.user_prenom) (\(config.user_id))"
        if let thisproduit = aproduit {
            IBNom.text =  thisproduit.prod_nom
            IBPrix.text = String(thisproduit.prod_prix)
            IBComment.text = thisproduit.prod_comment
            IBInfoLocation.text = thisproduit.prod_mapString
            IBSave.enabled = false
            IBFind.enabled = false
        }
        
        
    }
    
    @IBAction func ActionCancel(sender: AnyObject) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    private func setUIHidden(hidden: Bool) {
        
        IBSave.enabled = !hidden
        IBMap.hidden = hidden
        IBFind.hidden = !hidden
        IBNom.hidden = !hidden
        IBPrix.hidden = !hidden
        IBComment.hidden = !hidden
        IBNoimage.hidden = !hidden
        IBInfoLocation.hidden = !hidden
        
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
        
    }
    
    
    //MARK: Data Networking
    
    @IBAction func ActionFindMap(sender: AnyObject) {
        
        
        guard IBInfoLocation.text != "" else {
            self.displayAlert("Error", mess: "localisation incorrecte")
            return
        }
        
        
        setUIHidden(false)
        
        IBActivity.startAnimating()
        config.mapString = IBInfoLocation.text
        
        let geoCode  = CLGeocoder()
        
        
        geoCode.geocodeAddressString(IBInfoLocation.text!, completionHandler: {(marks,error) in
            
            guard error == nil else {
                performUIUpdatesOnMain {
                    
                    self.setUIHidden(true)
                    self.IBActivity.stopAnimating()
                    self.displayAlert("Error", mess: "error geocodeadresse : \(error.debugDescription)")
                }
                return
            }
            
            let placemark = marks![0] as CLPlacemark
            self.config.latitude = Double((placemark.location?.coordinate.latitude)!)
            self.config.longitude = Double((placemark.location?.coordinate.longitude)!)
            
            performUIUpdatesOnMain {
                
                
                // Notice that the float values are being used to create CLLocationDegree values.
                // This is a version of the Double type.
                let lat = CLLocationDegrees(self.config.latitude)
                let long = CLLocationDegrees(self.config.longitude)
                
                // The lat and long are used to create a CLLocationCoordinates2D instance.
                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                
                // Here we create the annotation and set its coordiate, title, and subtitle properties
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = "\(self.config.user_nom) \(self.config.user_prenom)"
                annotation.subtitle = self.config.mapString
                
                self.IBMap.addAnnotation(annotation)
                
                //Setting Visible Area
                let regionRadius: CLLocationDistance = 1000
                let coordinateRegion = MKCoordinateRegionMakeWithDistance(annotation.coordinate,
                    regionRadius * 2.0, regionRadius * 2.0)
                self.IBMap.setRegion(coordinateRegion, animated: true)
                self.IBActivity.stopAnimating()
                
                
            }
            
        })
        
        
    }
    
    
    @IBAction func ActionSubmit(sender: AnyObject) {
        
        
        guard IBNom.text != "" else {
            self.displayAlert("Error", mess: "nom incorrect")
            return
        }
        
        
        guard IBPrix.text != "" else {
            self.displayAlert("Error", mess: "prix incorrect")
            return
        }
        

        IBActivity.startAnimating()
        
        
        saveMapRegion()
        
        
        
        var produit = Produit(dico: [String : AnyObject]())
        
        produit.prod_nom = IBNom.text!
        produit.prod_image = ""
        produit.prod_prix = Double(IBPrix.text!)!
        produit.prod_by_user = config.user_id
        produit.prod_longitude = config.longitude
        produit.prod_latitude = config.latitude
        produit.prod_mapString = config.mapString
        produit.prod_comment = IBComment.text!
        
        setAddProduit(produit) { (success, errorString) in
            
            if success {
                performUIUpdatesOnMain {
                    self.IBActivity.stopAnimating()
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            }
            else {
                performUIUpdatesOnMain {
                    self.IBActivity.stopAnimating()
                    self.displayAlert("Error", mess: errorString!)
                }
            }
            
        }
        
        
        
        
    }
    
    
    //MARK: Map function
    
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
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    

    
    
}