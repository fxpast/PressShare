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

//Todo :Par defaut afficher les products selon la zone géolocalisée du l'utilisateur
//Todo :Zoomer/Dezoomer sur la carte permet de reduire/augmenter le nombre de products sur la carte.


import CoreLocation
import CoreData
import Foundation
import MapKit
import UIKit

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UITextFieldDelegate {
    
    
    @IBOutlet weak var IBLogout: UIBarButtonItem!
    @IBOutlet weak var IBtextfieldSearch: UITextField!
    @IBOutlet weak var IBAddProduct: UIBarButtonItem!
    @IBOutlet weak var IBActivity: UIActivityIndicatorView!
    
    weak var IBMap: MKMapView!
    var fieldName = ""
    var keybordY:CGFloat! = 0
    
    var users = [User]()
    var aProduct:Product!
    
    var userPseudo:String!
    var userId:Int!
    var config = Config.sharedInstance
    let translate = TranslateMessage.sharedInstance
    var lat:CLLocationDegrees!
    var lon:CLLocationDegrees!
    var latUser:CLLocationDegrees!
    var lonUser:CLLocationDegrees!
    var flgUser = false
    var flgSelect = false
    
    var locationManager:CLLocationManager!
    
    var sharedContext: NSManagedObjectContext {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.managedObjectContext
    }
    
    
    //MARK: View Controller Delegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        IBActivity.stopAnimating()
        
        if config.level <= 0 {
            IBAddProduct.isEnabled = false
        }
        
        IBtextfieldSearch.delegate = self
        
        userPseudo  = config.user_pseudo
        userId = config.user_id
        
        users = fetchAllUser()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        IBMap = MKMapView()
        IBMap.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
        view.addSubview(IBMap)
        IBMap.delegate = self
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        
        if locationManager.responds(to: #selector(CLLocationManager.requestWhenInUseAuthorization)) {
            locationManager.requestWhenInUseAuthorization()
            
        }
        locationManager.startUpdatingLocation()
        
        
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        unsubscribeFromKeyboardNotifications()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        IBMap.delegate = nil
        IBMap.removeFromSuperview()
        IBMap = nil
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
        else if segue.identifier == "fromMap" {
            
            let nav = segue.destination as! UINavigationController
            let controller = nav.topViewController as! ProductViewController
            
            controller.aProduct = aProduct
            controller.aProduct?.prod_imageData = UIImageJPEGRepresentation(restoreImageArchive(prod_image: (controller.aProduct!.prod_image)), 1)!
            
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
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.stopUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        
        if locationManager.responds(to: #selector(CLLocationManager.requestWhenInUseAuthorization)) {
            locationManager.requestWhenInUseAuthorization()
            
        }
        
        locationManager.startUpdatingLocation()
        
        
        Products.sharedInstance.productsArray = nil
        
    }
    
    private func loadPins() {
        
        let annoArray = IBMap.annotations as [AnyObject]
        for item in annoArray {
            IBMap.removeAnnotation(item as! MKAnnotation)
        }
        
        var annotations = [MKPointAnnotation]()
        var prod = Product(dico: [String : AnyObject]())
        
        for dictionary in Products.sharedInstance.productsArray {
            
            let product = Product(dico: dictionary)
            if product.prod_hidden == false {
                // Notice that the float values are being used to create CLLocationDegree values.
                // This is a version of the Double type.
                let lati = CLLocationDegrees(product.prod_latitude)
                let long = CLLocationDegrees(product.prod_longitude)
                
                // The lat and long are used to create a CLLocationCoordinates2D instance.
                let coordinate = CLLocationCoordinate2D(latitude: lati, longitude: long)
                
                // Here we create the annotation and set its coordiate, title, and subtitle properties
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = "\(product.prod_nom) (user:\(product.prod_by_user))"
                annotation.subtitle = "\(product.prod_mapString) / \(product.prod_comment)"
                
                // Finally we place the annotation in an array of annotations.
                annotations.append(annotation)
                
                if long == lon && lati == lat && lat != 0 && lon != 0 {
                    prod = product
                }
                
            }
            
        }
        
        
        var coordinateRegion=MKCoordinateRegion()
        
        //Setting Visible Area
        let regionRadius: CLLocationDistance = 1000
        

        if let _ = latUser , let _ = lonUser {
            
            let annotation = MKPointAnnotation()
            let coordinate = CLLocationCoordinate2D(latitude: latUser, longitude: lonUser)
            annotation.coordinate = coordinate
            annotation.title = "user:"
            annotation.subtitle = "\(config.user_nom!) \(config.user_prenom!) (\(config.user_id!))"
            
            // Finally we place the annotation in an array of annotations.
            annotations.append(annotation)
            IBMap.addAnnotations(annotations)
            coordinateRegion = MKCoordinateRegionMakeWithDistance(annotation.coordinate,regionRadius * 2.0, regionRadius * 2.0)
            
        }
        else {
            IBMap.addAnnotations(annotations)
        }
        
        if flgSelect == true {
            flgSelect = false
            lat = prod.prod_latitude
            lon = prod.prod_longitude
            let annotation = MKPointAnnotation()
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            annotation.coordinate = coordinate
            annotation.title = "\(prod.prod_nom) (user:\(prod.prod_by_user))"
            annotation.subtitle = "\(prod.prod_mapString) / \(prod.prod_comment)"
            
            coordinateRegion = MKCoordinateRegionMakeWithDistance(annotation.coordinate,regionRadius * 2.0, regionRadius * 2.0)
            
            IBMap.setRegion(coordinateRegion, animated: true)
        }
        else {
            if let _ = latUser , let _ = lonUser {
                IBMap.setRegion(coordinateRegion, animated: true)
            }
        }
        
        IBActivity.stopAnimating()
        
    }
    
    private func refreshData()  {
        
        IBActivity.startAnimating()

        MDBCapital.sharedInstance.getCapital(config.user_id, completionHandlerCapital: {(success, capitalArray, errorString) in
            
            if success {
                
                Capitals.sharedInstance.capitalsArray = capitalArray
                for dictionary in Capitals.sharedInstance.capitalsArray {
                    let capital = Capital(dico: dictionary)
                    self.config.balance = capital.balance
                    self.config.failure_count = capital.failure_count
                }
            }
            else {
                
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    self.IBActivity.stopAnimating()
                    self.displayAlert(self.translate.error, mess: errorString!)
                }
            }
            
        })
        
        MDBProduct.sharedInstance.getAllProducts(config.user_id) { (success, productArray, errorString) in
            
            if success {
                
                Products.sharedInstance.productsArray = productArray
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    
                    self.loadPins()
                }
                
            }
            else {
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    self.IBActivity.stopAnimating()
                    self.displayAlert(self.translate.error, mess: errorString!)
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
    
    
    private func countProduct() -> Int {
        
        //Constants
        let SearchBBoxHalfWidth = 1.0
        let SearchBBoxHalfHeight = 1.0
        let SearchLatRange = (-90.0, 90.0)
        let SearchLonRange = (-180.0, 180.0)
        
        let minimumLon = max(Double(lon!) - SearchBBoxHalfWidth, SearchLonRange.0)
        let minimumLat = max(Double(lat!) - SearchBBoxHalfHeight, SearchLatRange.0)
        let maximumLon = min(Double(lon!) + SearchBBoxHalfWidth, SearchLonRange.1)
        let maximumLat = min(Double(lat!) + SearchBBoxHalfHeight, SearchLatRange.1)
        
        var i = 0
        
        for prod in Products.sharedInstance.productsArray {
            
            let produ = Product(dico: prod)
            if (produ.prod_latitude >= minimumLat && produ.prod_latitude  <= maximumLat && produ.prod_longitude  >= minimumLon && produ.prod_longitude  <= maximumLon && produ.prod_hidden == false) {
                aProduct = produ
                i += 1
            }
        }
        
        return i
        
    }
    
    
    private func restoreImageArchive(prod_image:String) -> UIImage {
        
        let manager = FileManager.default
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first! as NSURL
        let filePath  = url.appendingPathComponent(prod_image)!.path
        
        if let imagData = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as? Data {
            return UIImage(data:imagData)!
        }
        else {
            return #imageLiteral(resourceName: "noimage")
        }
        
    }
    
    
    //MARK: Location Delegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        latUser = manager.location?.coordinate.latitude
        lonUser = manager.location?.coordinate.longitude
        
        if let _ = Products.sharedInstance.productsArray {
            loadPins()
        }
        else {
            refreshData()
        }
        
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
        locationManager = nil
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        refreshData()
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
                performSegue(withIdentifier: "mapproduct", sender: self)
            }
            else if countProduct() > 1 {
                
                performSegue(withIdentifier: "mapproduct", sender: self)
            }
            else if countProduct() == 1 {
                performSegue(withIdentifier: "fromMap", sender: self)
            }
            
            
        }
        
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        
        if let coord = view.annotation?.coordinate {
            
            lat = coord.latitude
            lon = coord.longitude
            flgSelect = true
            
        }
        
    }
    
    
}
