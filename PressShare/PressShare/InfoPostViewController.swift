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

class InfoPostViewController : UIViewController , MKMapViewDelegate, UITextFieldDelegate {
    
    
    @IBOutlet weak var IBSave: UIBarButtonItem!
    @IBOutlet weak var IBFind: UIButton!
    @IBOutlet weak var IBMap: MKMapView!
    @IBOutlet weak var IBInfoLocation: UITextField!
    @IBOutlet weak var IBActivity: UIActivityIndicatorView!
    
    var config:Config!
   
    
    //MARK: View Controller Delegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        config = Config.sharedInstance
       
        IBMap.delegate = self
        IBInfoLocation.delegate = self
        
        IBActivity.stopAnimating()
        
        setUIHidden(true)
        
        IBInfoLocation.text = config.mapString
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationItem.title = "\(config.user_nom) \(config.user_prenom)"
    }
    
    @IBAction func ActionCancel(sender: AnyObject) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    private func setUIHidden(hidden: Bool) {
        
        IBSave.enabled = !hidden
        IBMap.hidden = hidden
        IBFind.hidden = !hidden
        IBInfoLocation.hidden = !hidden
        
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
        
    }
    
    
    //MARK: Data Networking
    
    @IBAction func ActionFindMap(sender: AnyObject) {
        
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
            self.config.latitude = Float((placemark.location?.coordinate.latitude)!)
            self.config.longitude = Float((placemark.location?.coordinate.longitude)!)
            
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
        
        
        IBActivity.startAnimating()
        
        
        var user = User(dico: [String : AnyObject]())
        user.user_longitude = config.longitude
        user.user_latitude = config.latitude
        user.user_pseudo = config.user_pseudo
        user.user_mapString = config.mapString
        
        setLocation(user) { (success, errorString) in
            
            
            
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

            
        }
    }
    
    
}