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

//Todo: factoriser le code pour les fonctions pushProduct(), saveImageArchive(prod_image:String), restoreImageArchive(prod_image:String)
//Todo: donner la possibilité d'étendre la superficie d'affichage des produits


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
    
    //MARK: Locked portrait
    open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation{
        get {
            return .portrait
        }
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        get {
            return .portrait
        }
    }
    
    open override var shouldAutorotate: Bool {
        get {
            return false
        }
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(pushProduct), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        
        
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
        
        pushProduct()
        
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
    
    
    @objc private func pushProduct() {
        
        
        let manager = FileManager.default
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first! as NSURL
        let filePath  = url.appendingPathComponent("aps_dico")!.path
        
        if let aps = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as? [String:AnyObject] {
            
            IBActivity.startAnimating()
            
            do {
                try FileManager.default.removeItem(atPath: filePath)
            } catch  {
                print("error ", filePath)
            }
            
            
            MDBMessage.sharedInstance.getAllMessages(config.user_id) { (success, messageArray, errorString) in
                
                if success {
                    
                    Messages.sharedInstance.MessagesArray = messageArray
                }
                else {
                    
                    BlackBox.sharedInstance.performUIUpdatesOnMain {
                        self.displayAlert(self.translate.error, mess: errorString!)
                    }
                }
                
            }
            
            
            let productId = Int(aps["product_id"] as! String)!
            let badge =  Int(aps["badge"] as! String)!
            print("badge = ", badge)
            UIApplication.shared.applicationIconBadgeNumber = badge
            
            tabBarController?.tabBar.items![1].badgeValue = "\(badge)"
            config.mess_badge = badge
            
            MDBProduct.sharedInstance.getProduct(productId, completionHandlerProduct: { (success, productArray, errorString) in
                
                if success {
                    
                    for prod in productArray! {
                        
                        let produ = Product(dico: prod)
                        self.aProduct = produ
                    }
                    
                    BlackBox.sharedInstance.performUIUpdatesOnMain {
                        self.IBActivity.stopAnimating()
                        self.performSegue(withIdentifier: "fromMap", sender: self)
                    }
                    
                }
                else {
                    BlackBox.sharedInstance.performUIUpdatesOnMain {
                        self.IBActivity.stopAnimating()
                        self.displayAlert(self.translate.error, mess: errorString!)
                    }
                }
                
                
            })
            
            
        }
        
        
        
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
                let coordinateRegion = MKCoordinateRegionMakeWithDistance((placemark.location?.coordinate)!,self.config.regionGeoLocat, self.config.regionGeoLocat)
                self.IBMap.setRegion(coordinateRegion, animated: true)
                self.latUser = placemark.location?.coordinate.latitude
                self.lonUser = placemark.location?.coordinate.longitude
                self.refreshData()
                textField.text = ""
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
        
        
        if let _ = latUser , let _ = lonUser {
            
            //Setting Visible Area
            let annotation = MKPointAnnotation()
            let coordinate = CLLocationCoordinate2D(latitude: latUser, longitude: lonUser)
            annotation.coordinate = coordinate
            annotation.title = "user:"
            annotation.subtitle = "\(config.user_nom!) \(config.user_prenom!) (\(config.user_id!))"
            
            // Finally we place the annotation in an array of annotations.
            annotations.append(annotation)
            IBMap.addAnnotations(annotations)
            coordinateRegion = MKCoordinateRegionMakeWithDistance(annotation.coordinate, config.regionGeoLocat, config.regionGeoLocat)
            
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
            
            coordinateRegion = MKCoordinateRegionMakeWithDistance(annotation.coordinate, config.regionGeoLocat, config.regionGeoLocat)
            
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
        
        
        if let _ = latUser , let _ = lonUser {
            //Setting search Area
            // The lat and long are used to create a CLLocationCoordinates2D instance.
            
            let coordinate = CLLocationCoordinate2D(latitude: latUser, longitude: lonUser)
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate,config.regionProduct, config.regionProduct)
            
            config.minLongitude = coordinateRegion.center.longitude - coordinateRegion.span.longitudeDelta
            config.maxLongitude = coordinateRegion.center.longitude + coordinateRegion.span.longitudeDelta
            config.minLatitude = coordinateRegion.center.latitude - coordinateRegion.span.latitudeDelta
            config.maxLatitude = coordinateRegion.center.latitude + coordinateRegion.span.latitudeDelta
            
        }
        
        MDBProduct.sharedInstance.getAllProducts(config.user_id, minLon: config.minLongitude, maxLon: config.maxLongitude , minLat: config.minLatitude, maxLat: config.maxLatitude) { (success, productArray, errorString) in
            
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
        
         //Setting search Area
        
        // The lat and long are used to create a CLLocationCoordinates2D instance.
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate,config.distanceProduct, config.distanceProduct)
        
        let minimumLon = coordinateRegion.center.longitude - coordinateRegion.span.longitudeDelta
        let maximumLon = coordinateRegion.center.longitude + coordinateRegion.span.longitudeDelta
        let minimumLat = coordinateRegion.center.latitude - coordinateRegion.span.latitudeDelta
        let maximumLat = coordinateRegion.center.latitude + coordinateRegion.span.latitudeDelta
        
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
    
    
    private func saveImageArchive(prod_image:String) -> String {
        
        let manager = FileManager.default
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first! as NSURL
        let filePath  = url.appendingPathComponent(prod_image)!.path
        let fileListPath = url.appendingPathComponent("listProdImage")!.path
        
        var prodImage = ""
        
        if (NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as? Data) != nil {
            prodImage = prod_image
        }
        else {
            
            let imageURL = URL(string: "http://pressshare.fxpast.com/images/\(prod_image).jpg")
            
            do {
                NSKeyedArchiver.archiveRootObject(try Data(contentsOf: imageURL!), toFile: filePath)
                prodImage = prod_image
                
                if (NSKeyedUnarchiver.unarchiveObject(withFile: fileListPath) as? [String]) != nil {
                    var arrayImage =  NSKeyedUnarchiver.unarchiveObject(withFile: fileListPath) as! [String]
                    
                    let dateText = arrayImage[0].replacingOccurrences(of: "+0000", with: "")
                    let aDate = Date().dateFromString(dateText, format: "yyyy-MM-dd HH:mm:ss")
                    let futureDate = Calendar.current.date(byAdding: .day, value: 7, to: aDate)
                    let resultCompare = Date().compare(futureDate!)
                    
                    if resultCompare == ComparisonResult.orderedDescending {
                        
                        for index in 1...arrayImage.count-1 {
                            do {
                                try FileManager.default.removeItem(atPath: arrayImage[index])
                            } catch  {
                                print("error ", arrayImage[index])
                            }
                        }
                        
                        do {
                            try FileManager.default.removeItem(atPath: fileListPath)
                        } catch  {
                            print("error ", fileListPath)
                        }
                        
                        var arrayImage = [String]()
                        arrayImage.append("\(Date())")
                        arrayImage.append(filePath)
                        NSKeyedArchiver.archiveRootObject(arrayImage, toFile: fileListPath)
                    }
                    else {
                        arrayImage.append(filePath)
                        NSKeyedArchiver.archiveRootObject(arrayImage, toFile: fileListPath)
                    }
                    
                }
                else {
                    var arrayImage = [String]()
                    arrayImage.append("\(Date())")
                    arrayImage.append(filePath)
                    NSKeyedArchiver.archiveRootObject(arrayImage, toFile: fileListPath)
                }
                
                
            }
            catch {
                prodImage = ""
                
            }
            
        }
        
        return prodImage
        
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
