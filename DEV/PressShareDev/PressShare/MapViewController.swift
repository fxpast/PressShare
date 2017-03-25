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


import CoreLocation
import Foundation
import MapKit
import UIKit

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UITextFieldDelegate {
    
    
    @IBOutlet weak var IBMessageView: UIView!
    @IBOutlet weak var IBButtonTitle: UIButton!
    @IBOutlet weak var IBButtonAllProduct: UIButton!
    @IBOutlet weak var IBLabelLieu: UILabel!
    
    
    
    @IBOutlet weak var IBLogout: UIBarButtonItem!
    @IBOutlet weak var IBtextfieldSearch: UITextField!
    @IBOutlet weak var IBActivity: UIActivityIndicatorView!
    weak var IBMap: MKMapView!
    var IBAddProduct: UIButton!
    
    var fieldName = ""
    var keybordY:CGFloat! = 0
    
    var aProduct:Product!
    
    var userPseudo:String!
    var userId:Int!
    var config = Config.sharedInstance
    let translate = TranslateMessage.sharedInstance
    var lat:CLLocationDegrees!
    var lon:CLLocationDegrees!
    var latUser:CLLocationDegrees!
    var lonUser:CLLocationDegrees!
    var isUser = false
    var isSelect = false
    var prodIdNow = 0
  
    var shapeLayer1:CAShapeLayer!
    
    var locationManager:CLLocationManager!
    
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
        IBActivity.isHidden = true
        
        IBtextfieldSearch.delegate = self
        
        userPseudo  = config.user_pseudo
        userId = config.user_id
        
        NotificationCenter.default.addObserver(self, selector: #selector(pushProduct), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        
        IBAddProduct = UIButton()
        IBAddProduct.setImage(#imageLiteral(resourceName: "addButton"), for: UIControlState())
        IBAddProduct.addTarget(self, action: #selector(actionEpingle(_:)), for: UIControlEvents.touchUpInside)
        IBAddProduct.tag = 999
        IBAddProduct.sizeToFit()
        view.addSubview(IBAddProduct)
        
        IBAddProduct.frame = CGRect(origin: CGPoint.init(x: view.frame.size.width - IBAddProduct.frame.size.width*2, y: view.frame.size.height - IBAddProduct.frame.height*3), size: IBAddProduct.frame.size)

        if config.level <= 0 {
            IBAddProduct.isEnabled = false
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        config.isReturnToTab = false
        
    
        IBMap = MKMapView()
        IBMap.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
        view.addSubview(IBMap)
        IBMap.delegate = self
       
        IBMap.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(handleTap)))
        
 
        view.bringSubview(toFront: view.viewWithTag(999)!)
        view.bringSubview(toFront: IBAddProduct)
        
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        
        if locationManager.responds(to: #selector(CLLocationManager.requestWhenInUseAuthorization)) {
            locationManager.requestWhenInUseAuthorization()
            
        }
        locationManager.startUpdatingLocation()
        
        navigationController?.tabBarItem.title = translate.message("map")
        IBtextfieldSearch.placeholder = translate.message("tapALoc")
        
        isUser = false
        
        if config.product_maj == true {
            config.product_maj = false
            refreshData()
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        pushProduct()
        
        IBButtonAllProduct.setTitle(translate.message("seeOtherProduct"), for: UIControlState.normal)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        IBMap.delegate = nil
        IBMap.removeFromSuperview()
        IBMap = nil
    }
    
    
    
    func handleTap(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            
            if shapeLayer1 != nil && isSelect == true {
                IBMessageView.isHidden = true
                shapeLayer1.removeFromSuperlayer()
                shapeLayer1 = nil
            }
            
            
        }
        sender.cancelsTouchesInView = false
    }
    
    
    @objc private func pushProduct() {
        
        IBActivity.startAnimating()
        BlackBox.sharedInstance.pushProduct(menuBar: tabBarController) { (success, product, errorStr) in
            
            if success {
                
                MDBTransact.sharedInstance.getAllTransactions(self.config.user_id) { (success, transactionArray, errorString) in
                    
                    if success {
                        
                        Transactions.sharedInstance.transactionArray = transactionArray
                        BlackBox.sharedInstance.performUIUpdatesOnMain {
                            
                            var i = 0
                            for tran in Transactions.sharedInstance.transactionArray  {
                                
                                let tran1 = Transaction(dico: tran)
                                
                                if (tran1.trans_valid != 1 && tran1.trans_valid != 2 )  {
                                    i+=1
                                }
                                
                            }
                            if i > 0 {
                                self.config.trans_badge = i
                                
                            }
                         
                            self.aProduct = product
                            self.IBActivity.stopAnimating()
                            self.performSegue(withIdentifier: "fromMap", sender: self)
                            
                            
                        }
                    }
                    else {
                        
                        BlackBox.sharedInstance.performUIUpdatesOnMain {
                            self.displayAlert(self.translate.message("error"), mess: errorString!)
                        }
                    }
                    
                }
                
            
            }
            else {
                
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    self.IBActivity.stopAnimating()
                    if errorStr != "" {
                        self.displayAlert(self.translate.message("error"), mess: errorStr!)
                    }
                }
            }
            
        }
        
    }
    
    @IBAction func actionEpingle(_ sender: AnyObject) {
        
        aProduct = nil
        performSegue(withIdentifier: "fromMap", sender: self)
    }
    
    
    @IBAction func actionHelp(_ sender: Any) {
        
        //action info
        BlackBox.sharedInstance.showHelp("carte_liste", self)
        
    }
    
    
    @IBAction func actionAllProducts(_ sender: AnyObject) {
        
  
        self.performSegue(withIdentifier: "mapproduct", sender: self)
        
        
    }
    

    @IBAction func actionSelectProduct(_ sender: AnyObject) {
        
        performSegue(withIdentifier: "fromMap", sender: self)
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "mapproduct" {
            
            let nav = segue.destination as! UINavigationController
            let controller = nav.topViewController as! ListProductViewController
            if isUser {
                
                controller.isUser = true
                controller.typeListe = 1 //Map :0, MyList :1, Historical:2
            }
            else {
                controller.lon = lon
                controller.lat = lat
                controller.typeListe = 0 //Map :0, MyList :1, Historical:2
            }
            
        }
        else if segue.identifier == "fromMap" {
            
            if aProduct != nil {
                
                let nav = segue.destination as! UINavigationController
                let controller = nav.topViewController as! ProductTableViewContr
                
                controller.aProduct = aProduct
                controller.typeListe = 0 //Map :0, MyList :1, Historical:2
                //controller.aProduct?.prod_imageData = UIImageJPEGRepresentation(BlackBox.sharedInstance.restoreImageArchive(prod_imageUrl: (controller.aProduct!.prod_imageUrl)), 1)!
                
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
    
    
    
    
    //MARK: Data Networking
    @IBAction func actionRefresh(_ sender: AnyObject) {
        
        latUser = nil
        lonUser = nil
        Products.sharedInstance.productsArray = nil
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.stopUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        
        if locationManager.responds(to: #selector(CLLocationManager.requestWhenInUseAuthorization)) {
            locationManager.requestWhenInUseAuthorization()
            
        }
        
        locationManager.startUpdatingLocation()
        
    }
    
    private func loadPins() {
        
        let annoArray = IBMap.annotations as [AnyObject]
        for item in annoArray {
            IBMap.removeAnnotation(item as! MKAnnotation)
        }
     
        
        var annotations = [CustomPin]()
        var prod = Product(dico: [String : AnyObject]())
        
        for dictionary in Products.sharedInstance.productsArray {
            
            let product = Product(dico: dictionary)
            
                // Notice that the float values are being used to create CLLocationDegree values.
                // This is a version of the Double type.
                let lati = CLLocationDegrees(product.prod_latitude)
                let long = CLLocationDegrees(product.prod_longitude)
                
                // The lat and long are used to create a CLLocationCoordinates2D instance.
                let coordinate = CLLocationCoordinate2D(latitude: lati, longitude: long)
                
                // Here we create the annotation and set its coordiate, title, and subtitle properties
                let annotation = CustomPin()
                annotation.coordinate = coordinate
                annotation.title = "\(product.prod_nom) (user:\(product.prod_by_user))"
                annotation.subtitle = "\(product.prod_mapString) / \(product.prod_comment)"
                annotation.prod_id = product.prod_id
                
                // Finally we place the annotation in an array of annotations.
                annotations.append(annotation)
                
                if long == lon && lati == lat && lat != 0 && lon != 0 {
                    prod = product
                }
                
            
            
        }
        
        
        var coordinateRegion=MKCoordinateRegion()
        
        
        if let _ = latUser , let _ = lonUser {
            
            //Setting Visible Area
            let annotation = CustomPin()
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
        
        if isSelect == true {
            isSelect = false
            lat = prod.prod_latitude
            lon = prod.prod_longitude
            let annotation = CustomPin()
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            annotation.coordinate = coordinate
            annotation.title = "\(prod.prod_nom) (user:\(prod.prod_by_user))"
            annotation.subtitle = "\(prod.prod_mapString) / \(prod.prod_comment)"
            annotation.prod_id = prod.prod_id
            
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
                    self.displayAlert(self.translate.message("error"), mess: errorString!)
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
        
        MDBProduct.sharedInstance.getProductsByCoord(config.user_id, minLon: config.minLongitude, maxLon: config.maxLongitude , minLat: config.minLatitude, maxLat: config.maxLatitude) { (success, productArray, errorString) in
            
            if success {
                
                Products.sharedInstance.productsArray = productArray
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    
                    self.loadPins()
                }
                
            }
            else {
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    self.IBActivity.stopAnimating()
                    self.displayAlert(self.translate.message("error"), mess: errorString!)
                }
            }
        }
        
    }
    
    @IBAction func actionLogout(_ sender: AnyObject) {
        
        
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! as NSURL
        let filePath  = url.appendingPathComponent("userDico")!.path
        
        do {
            try FileManager.default.removeItem(atPath: filePath)
        } catch  {
            print("error ", filePath)
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
            
            if (produ.prod_latitude >= minimumLat && produ.prod_latitude  <= maximumLat && produ.prod_longitude  >= minimumLon && produ.prod_longitude  <= maximumLon) {
                i += 1
            }
            
            if produ.prod_id == prodIdNow {
                aProduct = produ
            }
            
            
        }
        
        return i
        
    }
    
    
    //MARK: Location Delegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if latUser == nil && lonUser == nil {
            latUser = manager.location?.coordinate.latitude
            lonUser = manager.location?.coordinate.longitude
        }
     
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
 
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        
        if shapeLayer1 != nil && isSelect == true {
            IBMessageView.isHidden = true
            shapeLayer1.removeFromSuperlayer()
            shapeLayer1 = nil
        }
        
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.pinTintColor = UIColor.red
            let customAnnot = annotation as! CustomPin
            pinView?.tag = customAnnot.prod_id
           
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

    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        
        if let coord = view.annotation?.coordinate {
            
            lat = coord.latitude
            lon = coord.longitude
            prodIdNow = view.tag
            isSelect = true
          
            if (view.annotation?.title)! == "user:" {
                isUser = true
                performSegue(withIdentifier: "mapproduct", sender: self)
            }
            else if countProduct() > 1 {
                
                IBMessageView.isHidden = false
                IBButtonTitle.setTitle((view.annotation?.title)!, for: UIControlState.normal)
                IBLabelLieu.text = (view.annotation?.subtitle)!
                
                if view.frame.origin.y < self.view.frame.size.height/2 {
                    
                    IBMessageView.frame = CGRect.init(origin: CGPoint.init(x: view.frame.origin.x - IBMessageView.frame.size.width/2, y: view.frame.origin.y + 30), size: IBMessageView.frame.size)
                    
                    self.view.bringSubview(toFront: self.view.viewWithTag(888)!)
                    self.view.bringSubview(toFront: IBMessageView)
                    createArrow(IBMessageView.frame, "bottom")
                
                }
                else {
                
                    IBMessageView.frame = CGRect.init(origin: CGPoint.init(x: view.frame.origin.x - IBMessageView.frame.size.width/2, y: view.frame.origin.y - IBMessageView.frame.size.height - 30), size: IBMessageView.frame.size)
                    
                    self.view.bringSubview(toFront: self.view.viewWithTag(888)!)
                    self.view.bringSubview(toFront: IBMessageView)
                    createArrow(IBMessageView.frame, "above")
                    
                }
                
            }
            else if countProduct() == 1 {
                performSegue(withIdentifier: "fromMap", sender: self)
            }
            
            
        }
        
    }
    
    private func createArrow(_ frame:CGRect, _ sens:String) {
        
        var x1 = CGFloat()
        var y1 = CGFloat()
        var x2 = CGFloat()
        var y2 = CGFloat()
        
        let distance:CGFloat = 30.0
        let bezierObjet = UIBezierPath()
        shapeLayer1 = CAShapeLayer()
        x1 = frame.origin.x - distance/2 + frame.size.width/2
        
        if sens == "above" {
            
            y1 = frame.origin.y + frame.size.height
            bezierObjet.move(to: CGPoint.init(x: x1, y: y1))
            
            x2 = x1 + distance/2
            x1 = x1 + distance
            y2 = y1 + distance
        }
        else if sens == "bottom" {
            
            y1 = frame.origin.y
            bezierObjet.move(to: CGPoint.init(x: x1, y: y1))
            
            x2 = x1 + distance/2
            x1 = x1 + distance
            y2 = y1 - distance
        }
        
        shapeLayer1.strokeColor = UIColor.white.cgColor
        shapeLayer1.fillColor = UIColor.white.cgColor

        bezierObjet.addCurve(to: CGPoint.init(x: x1, y: y1), controlPoint1: CGPoint.init(x: x2, y: y2), controlPoint2: CGPoint.init(x: x2, y: y2))
        
        shapeLayer1.path = bezierObjet.cgPath
        shapeLayer1.lineWidth = 1.0
       
        view.layer.addSublayer(shapeLayer1)
        
    }
    
    
}
