//
//  ViewController.swift
//  PressShare
//
//  Description : Map all products according the selected area. It is possible to look for a city or place.
//                  The user is geolocalized by a blue pin on the map.
//
//  Created by MacbookPRV on 28/04/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//


//Todo: Tous les produits d'un utilisateur resilié sont masqués
//Todo :Par defaut afficher les products selon la zone géolocalisée du l'utilisateur
//Todo :Zoomer/Dezoomer sur la carte permet de reduire/augmenter le nombre de products sur la carte.




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
    @IBOutlet weak var IBActivity: UIActivityIndicatorView!
    
    var fieldName = ""
    var keybordY:CGFloat! = 0
    
    var users = [User]()
    
    var userPseudo:String!
    var userId:Int!
    var config = Config.sharedInstance
    var products = Products.sharedInstance
    var translate = InternationalIHM.sharedInstance
    var lat:CLLocationDegrees!
    var lon:CLLocationDegrees!
    var userLat:CLLocationDegrees!
    var userLon:CLLocationDegrees!
    var flgUser=false
    var flgRegion=false
    var flgFirst=false
    
    let locationManager = CLLocationManager()
    
    var sharedContext: NSManagedObjectContext {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.managedObjectContext
    }
    
    
    //MARK: View Controller Delegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        IBActivity.stopAnimating()
        
        if config.level == 0 {
            IBAddProduct.isEnabled = false
        }
        
        flgRegion = false
        
        IBtextfieldSearch.delegate = self
        locationManager.delegate = self
        
        userPseudo  = config.user_pseudo
        userId = config.user_id
        
        users = fetchAllUser()
        
        
        refreshData()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        
        if locationManager.responds(to: #selector(CLLocationManager.requestWhenInUseAuthorization)) {
            locationManager.requestWhenInUseAuthorization()
            
        }
        
        locationManager.startUpdatingLocation()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        subscibeToKeyboardNotifications()
        
        navigationController?.tabBarItem.title = translate.map
        IBLogout.image = #imageLiteral(resourceName: "eteindre")
        IBLogout.title = ""
        IBtextfieldSearch.placeholder = translate.tapALoc
        
        flgUser = false
        
        if config.product_maj == true {
            config.product_maj = false
            refreshData()
        }
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    //MARK: coreData function
    
    private func fetchAllUser() -> [User] {
        
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
        
        if segue.identifier == "mapproduct" {
            
            let nav = segue.destination as! UINavigationController
            let controller = nav.topViewController as! ListProductViewController
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
        
        guard textField.text != "" else {
            textField.endEditing(true)
            return true
        }
        
        let geoCode  = CLGeocoder()
        
        geoCode.geocodeAddressString(textField.text!, completionHandler: {(marks,error) in
            
            guard error == nil else {
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    
                    self.displayAlert("error geocodeadresse", mess: error?.localizedDescription)
                }
                return
            }
            
            BlackBox.sharedInstance.performUIUpdatesOnMain {
                
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
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField.isEqual(IBtextfieldSearch) {
            fieldName = "IBtextfieldSearch"
        }
    }
    
    //MARK: keyboard function
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard fieldName != "" && keybordY > 0 else {
            return
        }
        
        let location = (event?.allTouches?.first?.location(in: self.view).y)! as CGFloat
        
        if (Double(location) < Double(keybordY)) {
            
            var textField = UITextField()
            
            
            if fieldName == "IBtextfieldSearch" {
                textField = IBtextfieldSearch
            }
            
            
            textField.endEditing(true)
            
        }
        
    }
    
    func  subscibeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    func keyboardWillShow(notification:NSNotification) {
        
        var textField = UITextField()
        
        if fieldName == "IBtextfieldSearch" {
            textField = IBtextfieldSearch
        }
        
        if textField.isFirstResponder {
            keybordY = view.frame.size.height - getkeyboardHeight(notification: notification)
            if keybordY < textField.frame.origin.y {
                view.frame.origin.y = keybordY - textField.frame.origin.y - textField.frame.size.height
            }
            
        }
        
    }
    
    func keyboardWillHide(notification:NSNotification) {
        
        var textField = UITextField()
        
        if fieldName == "IBtextfieldSearch" {
            textField = IBtextfieldSearch
        }
        
        
        if textField.isFirstResponder {
            view.frame.origin.y = 0
        }
        
        fieldName = ""
        keybordY = 0
        
    }
    
    func getkeyboardHeight(notification:NSNotification)->CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
        
    }
    
    //MARK: Data Networking
    @IBAction func actionRefresh(_ sender: AnyObject) {
        
        refreshData()
    }
    
    private func refreshData()  {
        
        IBActivity.startAnimating()
        
        MDBCapital.sharedInstance.getCapital(config.user_id, completionHandlerCapital: {(success, capitalArray, errorString) in
            
            if success {
                
                Capitals.sharedInstance.capitalsArray = capitalArray
                for dictionary in Capitals.sharedInstance.capitalsArray {
                    let capital = Capital(dico: dictionary)
                    self.config.balance = capital.balance
                }
            }
            else {
                
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    self.IBActivity.stopAnimating()
                    self.displayAlert("Error", mess: errorString!)
                }
            }
            
            
        })
        
        
        MDBProduct.sharedInstance.getAllProducts(config.user_id) { (success, productArray, errorString) in
            
            if success {
                
                self.products.productsArray = productArray
                
                var annotations = [MKPointAnnotation]()
                
                for dictionary in self.products.productsArray! {
                    
                    let product = Product(dico: dictionary)
                    // Notice that the float values are being used to create CLLocationDegree values.
                    // This is a version of the Double type.
                    let lat = CLLocationDegrees(product.prod_latitude)
                    let long = CLLocationDegrees(product.prod_longitude)
                    
                    // The lat and long are used to create a CLLocationCoordinates2D instance.
                    let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    
                    // Here we create the annotation and set its coordiate, title, and subtitle properties
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate
                    annotation.title = "\(product.prod_nom) (user:\(product.prod_by_user))"
                    annotation.subtitle = "\(product.prod_mapString) / \(product.prod_comment)"
                    
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
                    annotation.subtitle = "\(self.config.user_nom!) \(self.config.user_prenom!) (\(self.config.user_id!))"
                    
                    // Finally we place the annotation in an array of annotations.
                    annotations.append(annotation)
                    
                    //Setting Visible Area
                    let regionRadius: CLLocationDistance = 1000
                    coordinateRegion = MKCoordinateRegionMakeWithDistance(annotation.coordinate,regionRadius * 2.0, regionRadius * 2.0)
                    
                }
                
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    
                    let annoArray = self.IBMap.annotations as [AnyObject]
                    for item in annoArray {
                        self.IBMap.removeAnnotation(item as! MKAnnotation)
                    }
                    
                    self.IBMap.addAnnotations(annotations)
                    if let _ = self.userLon, let _ = self.userLat {
                        if !self.flgRegion {
                            self.IBMap.setRegion(coordinateRegion, animated: true)
                            self.flgRegion = true
                        }
                        
                    }
                    self.IBActivity.stopAnimating()
                    
                }
                
            }
            else {
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    self.IBActivity.stopAnimating()
                    self.displayAlert("Error", mess: errorString!)
                }
            }
        }
        
    }
    
    @IBAction func actionLogout(_ sender: AnyObject) {
        
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
        
        if flgFirst==false {
            flgFirst=true
            refreshData()
        }
        
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
            
            performSegue(withIdentifier: "mapproduct", sender: self)
            
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

