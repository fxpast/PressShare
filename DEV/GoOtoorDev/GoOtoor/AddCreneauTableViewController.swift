//
//  AddCreneauTableViewController.swift
//  GoOtoor
//
// Description : Add slots for product
//
//  Created by MacbookPRV on 19/04/2018.
//  Copyright © 2018 Pastouret Roger. All rights reserved.
//

import Foundation
import MapKit
import UIKit
import MobileCoreServices

class AddCreneauTableViewController : UITableViewController , MKMapViewDelegate, CLLocationManagerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    
    
    @IBOutlet weak var IBActivity: UIActivityIndicatorView!
    @IBOutlet weak var IBMap: MKMapView!
    @IBOutlet weak var IBFind: UIButton!
    @IBOutlet weak var IBMyPositon: UIButton!
    @IBOutlet weak var IBDebutLabel: UILabel!
    @IBOutlet weak var IBDebut: UITextField!
    @IBOutlet weak var IBFinLabel: UILabel!
    @IBOutlet weak var IBFin: UITextField!
    @IBOutlet weak var IBInfoLabel: UILabel!
    @IBOutlet weak var IBInfoLocation: UITextField!
    @IBOutlet weak var IBCancel: UIBarButtonItem!
    @IBOutlet weak var IBSave: UIBarButtonItem!
    @IBOutlet weak var IBDebutPicker: UIDatePicker!
    @IBOutlet weak var IBFinPicker: UIDatePicker!
    @IBOutlet weak var IBNoneLabel: UILabel!
    @IBOutlet weak var IBNone: UISwitch!
    @IBOutlet weak var IBDailyLabel: UILabel!
    @IBOutlet weak var IBDaily: UISwitch!
    @IBOutlet weak var IBWeeklyLabel: UILabel!
    @IBOutlet weak var IBWeekly: UISwitch!
    
    var aProduct:Product?
    var config = Config.sharedInstance
    let translate = TranslateMessage.sharedInstance
    var isFindMe = false
    var timerBadge : Timer!
    var fieldName = ""
    
    var latUser:CLLocationDegrees!
    var lonUser:CLLocationDegrees!
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
    
    
    //MARK: table View Controller Delegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        IBActivity.isHidden = true
        IBActivity.stopAnimating()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        
        if locationManager.responds(to: #selector(CLLocationManager.requestWhenInUseAuthorization)) {
            locationManager.requestWhenInUseAuthorization()
            
        }
        locationManager.startUpdatingLocation()
        
        
        for i in 0...4 {
            tableView.scrollToRow(at: IndexPath(item: i, section: 0), at: .none, animated: false)
            tableView(tableView, cellForRowAt: IndexPath(item: i, section: 0)).backgroundColor  = UIColor.init(hexString: config.colorApp)
            tableView(tableView, cellForRowAt: IndexPath(item: i, section: 0)).backgroundView?.backgroundColor  = UIColor.init(hexString: config.colorApp)
        }
        tableView.scrollToRow(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
        
        tableView.backgroundColor = UIColor.init(hexString: config.colorApp)
        tableView.backgroundView?.backgroundColor = UIColor.init(hexString: config.colorApp)
        tableView.sectionIndexColor = UIColor.init(hexString: config.colorApp)
        
        
        title = translate.message("addtimeslot")
        IBInfoLabel.text = translate.message("tapALoc")
        IBInfoLabel.textColor = UIColor.init(hexString: config.colorAppLabel)
        IBInfoLocation.attributedPlaceholder = NSAttributedString.init(string: translate.message("tapALoc"), attributes: [NSForegroundColorAttributeName : UIColor.init(hexString: config.colorAppPlHd)])
        
        IBMyPositon.setTitleColor(UIColor.init(hexString: config.colorAppBt), for: UIControlState())
        IBMyPositon.setTitle(translate.message("myPosition"), for: UIControlState())
        
        IBFind.setTitleColor(UIColor.init(hexString: config.colorAppBt), for: UIControlState())
        IBFind.setTitle(translate.message("findOnMap"), for: UIControlState())
        
        IBInfoLocation.layer.addSublayer(MyTools.sharedInstance.createLine(frame: IBInfoLocation.frame))
        
        IBSave.title = translate.message("save")
        
        IBDebut.text = ShowDatePicker(IBDebutPicker)
        IBFin.text = ShowDatePicker(IBFinPicker)
        IBNoneLabel.text = translate.message("none")
        IBDailyLabel.text = translate.message("daily")
        IBWeeklyLabel.text = translate.message("weekly")
        IBWeekly.isOn = false
        IBDaily.isOn = false
        IBNone.isOn = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        
        timerBadge = Timer.scheduledTimer(timeInterval: config.dureeTimer, target: self, selector: #selector(routineTimer), userInfo: nil, repeats: true)
        
        config.latitude = 0
        config.longitude = 0
        
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        config.isTimer = false
        timerBadge.invalidate()
        timerBadge = nil
        
    }
    
    
    @objc private func routineTimer() {
        
        if config.isTimer == false {
            
            MyTools.sharedInstance.checkBadge(completionHdlerBadge: { (success, result) in
                
                if success == true {
                    
                    if result == "mess_badge" {
                        self.displayAlert(self.translate.message("myNotif"), mess: self.translate.message("newMessage"))
                    }
                    else if result == "trans_badge" {
                        self.displayAlert(self.translate.message("myNotif"), mess: self.translate.message("newTransaction"))
                    }
                    
                }
                else {
                    
                }
                
            })
        }
        
    }
    
    
    @IBAction func actionHelp(_ sender: Any) {
        
        //action info
        MyTools.sharedInstance.showHelp("informations_article", self)
        
    }
    
    
    @IBAction func actionDebutPicker(_ sender: Any) {
        
        IBDebut.text = ShowDatePicker(IBDebutPicker)
        
    }
    
    @IBAction func actionFinPicker(_ sender: Any) {
        
        IBFin.text = ShowDatePicker(IBFinPicker)
        
    }
    
    
    private func ShowDatePicker(_ datePicker:UIDatePicker) -> String  {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = formatter.string(from: datePicker.date)
       
        return dateString
    }
    
    
    @IBAction func actionCancel(_ sender: AnyObject) {
        
        dismiss(animated: true, completion: nil)
        
    }
    

    
    //MARK: Bouton Switch
    
    @IBAction func actionNone(_ sender: Any) {
        
        IBNone.isOn = true
        IBDaily.isOn = (IBNone.isOn == true) ? false : true
        IBWeekly.isOn = (IBNone.isOn == true) ? false : true
       
    }
    
    @IBAction func actionDaily(_ sender: Any) {
        
        IBDaily.isOn = true
        IBNone.isOn = (IBDaily.isOn == true) ? false : true
        IBWeekly.isOn = (IBDaily.isOn == true) ? false : true
        
    }
    
    @IBAction func actionWeekly(_ sender: Any) {
        
        IBWeekly.isOn = true
        IBNone.isOn = (IBWeekly.isOn == true) ? false : true
        IBDaily.isOn = (IBWeekly.isOn == true) ? false : true
        
    }
    
    
    //MARK: textfield Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.isEqual(IBDebut) {
            IBDebut.text = ShowDatePicker(IBDebutPicker)
            IBFin.becomeFirstResponder()
            
        }
        else if textField.isEqual(IBFin) {
            IBFin.text = ShowDatePicker(IBFinPicker)
            IBInfoLocation.becomeFirstResponder()
            
        }
        else if textField.isEqual(IBInfoLocation) && IBInfoLocation.text != ""  {
            actionFindMap(self)
            
        }
        
        textField.endEditing(true)
        
        return true
        
    }
    
    
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if textField.isEqual(IBDebut) {
            fieldName = "IBDebut"
        }
        else if textField.isEqual(IBFin) {
            fieldName = "IBFin"
        }
        else if textField.isEqual(IBInfoLocation) {
            fieldName = "IBInfoLocation"
        }
        
        
        return true
    }
    
    
    
    //MARK: Data Networking
    
    private func findMe() {
        
        let annoArray = IBMap.annotations as [AnyObject]
        for item in annoArray {
            IBMap.removeAnnotation(item as! MKAnnotation)
        }
        
        var annotations = [MKPointAnnotation]()
        
        //Setting Visible Area
        let annotation = MKPointAnnotation()
        let coordinate = CLLocationCoordinate2D(latitude: latUser, longitude: lonUser)
        annotation.coordinate = coordinate
        annotation.title = "user:"
        annotation.subtitle = "\(config.user_nom!) \(config.user_prenom!) (\(config.user_id!))"
        
        // Finally we place the annotation in an array of annotations.
        annotations.append(annotation)
        IBMap.addAnnotations(annotations)
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(annotation.coordinate, config.regionGeoLocat, config.regionGeoLocat)
        IBMap.setRegion(coordinateRegion, animated: true)
        config.latitude = latUser
        config.longitude = lonUser
        
        isFindMe = false
        
    }
    
    @IBAction func actionFindMe(_ sender: AnyObject) {
        
        isFindMe = true
        
        IBActivity.startAnimating()
        IBActivity.isHidden = false
        
        if let _ = latUser , let _ = lonUser {
            
            findMe()
            
        }
        else {
            
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            locationManager = nil
            
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            
            if locationManager.responds(to: #selector(CLLocationManager.requestWhenInUseAuthorization)) {
                locationManager.requestWhenInUseAuthorization()
                
            }
            locationManager.startUpdatingLocation()
            
        }
        
        
        IBActivity.stopAnimating()
        IBActivity.isHidden = true
        
    }
    
    
    @IBAction func actionFindMap(_ sender: AnyObject) {
        
        let annoArray = IBMap.annotations as [AnyObject]
        for item in annoArray {
            IBMap.removeAnnotation(item as! MKAnnotation)
        }
        
        
        guard IBInfoLocation.text != "" else {
            displayAlert(translate.message("error"), mess: translate.message("ErrorGeolocation"))
            return
        }
        
        
        IBActivity.startAnimating()
        IBActivity.isHidden = false
        
        config.mapString = IBInfoLocation.text
        
        let geoCode  = CLGeocoder()
        
        
        geoCode.geocodeAddressString(IBInfoLocation.text!, completionHandler: {(marks,error) in
            
            guard error == nil else {
                MyTools.sharedInstance.performUIUpdatesOnMain {
                    
                    self.IBActivity.stopAnimating()
                    self.IBActivity.isHidden = true
                    self.displayAlert(self.translate.message("error"), mess: self.translate.message("ErrorGeocode")) //error.debugDescription
                }
                return
            }
            
            let placemark = marks![0] as CLPlacemark
            self.config.latitude = Double((placemark.location?.coordinate.latitude)!)
            self.config.longitude = Double((placemark.location?.coordinate.longitude)!)
            
            MyTools.sharedInstance.performUIUpdatesOnMain {
                
                let annotations = self.IBMap.annotations as! [MKPointAnnotation]
                for annota in annotations {
                    self.IBMap.removeAnnotation(annota)
                }
                
                // Notice that the float values are being used to create CLLocationDegree values.
                // This is a version of the Double type.
                let lat = CLLocationDegrees(self.config.latitude)
                let long = CLLocationDegrees(self.config.longitude)
                
                // The lat and long are used to create a CLLocationCoordinates2D instance.
                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                
                // Here we create the annotation and set its coordiate, title, and subtitle properties
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = "\(self.config.user_nom!) \(self.config.user_prenom!)"
                annotation.subtitle = self.config.mapString!
                
                self.IBMap.addAnnotation(annotation)
                
                //Setting Visible Area
                
                let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate,self.config.regionGeoLocat, self.config.regionGeoLocat)
                
                self.IBMap.setRegion(coordinateRegion, animated: true)
                self.IBActivity.stopAnimating()
                self.IBActivity.isHidden = true
                
            }
            
        })
        
    }
    
    
    
    @IBAction func actionSubmit(_ sender: AnyObject) {
        
        guard IBDebut.text != "" else {
            self.displayAlert(self.translate.message("error"), mess: translate.message("dateDebut"))
            return
        }
        
        guard IBFin.text != "" else {
            self.displayAlert(self.translate.message("error"), mess: translate.message("dateFin"))
            return
        }

        guard IBInfoLocation.text != "" else {
            self.displayAlert(self.translate.message("error"), mess: translate.message("tapALoc"))
            return
        }
        
        guard config.longitude > 0 || config.latitude > 0 else {
            self.displayAlert(self.translate.message("error"), mess: translate.message("findOnMap"))
            return
        }
        
        guard IBDebutPicker.date <= IBFinPicker.date else {
            self.displayAlert(self.translate.message("error"), mess: translate.message("dateError"))
            return
        }
        
        let dayD = Calendar.current.component(.day, from: IBDebutPicker.date)
        let monthD = Calendar.current.component(.month, from: IBDebutPicker.date)
        let yearD = Calendar.current.component(.year, from: IBDebutPicker.date)
        
        let dayF = Calendar.current.component(.day, from: IBFinPicker.date)
        let monthF = Calendar.current.component(.month, from: IBFinPicker.date)
        let yearF = Calendar.current.component(.year, from: IBFinPicker.date)
        
        guard dayD == dayF && monthD == monthF && yearD == yearF && !IBNone.isOn || IBNone.isOn  else {
            self.displayAlert(self.translate.message("error"), mess: translate.message("sameday"))
            return
        }
        
        guard checkOverlap() == false else {
            self.displayAlert(self.translate.message("error"), mess: translate.message("overLapSlot"))
            return
        }
        
        
        IBActivity.isHidden = false
        IBActivity.startAnimating()
        tableView.scrollToRow(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
        
        
        IBSave.isEnabled = false
        IBFind.isEnabled = false
        IBMyPositon.isEnabled = false
        
        var creneau = Creneau(dico: [String : AnyObject]())
        
        creneau.cre_dateDebut = Date().dateToServer(IBDebutPicker.date)
        creneau.cre_dateFin = Date().dateToServer(IBFinPicker.date)
        creneau.cre_longitude = config.longitude
        creneau.cre_latitude = config.latitude
        creneau.cre_mapString = config.mapString
        creneau.prod_id = aProduct!.prod_id
        if IBNone.isOn {
            creneau.cre_repeat = 0
        } else if IBDaily.isOn {
            creneau.cre_repeat = 1
        } else if IBWeekly.isOn {
            creneau.cre_repeat = 2
        }
        
        //add creneau
        MDBCreneau.sharedInstance.setAddCreneau(creneau) { (success, errorString) in
            
            if success {
                
                MyTools.sharedInstance.performUIUpdatesOnMain {
                    self.IBSave.isEnabled = true
                    self.IBFind.isEnabled = true
                    self.IBMyPositon.isEnabled = true
                    self.dismiss(animated: true, completion: nil)
                }
                
            }
            else {
                MyTools.sharedInstance.performUIUpdatesOnMain {
                    self.IBSave.isEnabled = true
                    self.IBFind.isEnabled = true
                    self.IBMyPositon.isEnabled = true
                    self.IBActivity.isHidden = true
                    self.IBActivity.stopAnimating()
                    self.displayAlert(self.translate.message("error"), mess: errorString!)
                }
            }
            
        }
        
        
        
    }
    
    private func checkOverlap() -> Bool {
        
        var result = false
        
        for crene in  Creneaux.sharedInstance.creneauxArray  {
            
            let cren = Creneau(dico: crene)
            
            if IBDebutPicker.date > cren.cre_dateDebut && IBDebutPicker.date < cren.cre_dateFin {
                result = true
                break;
            }
            
            if cren.cre_dateDebut > IBDebutPicker.date && cren.cre_dateDebut < IBFinPicker.date {
                result = true
                break;
            }
            
        }
        
        return result
    }
    
    //MARK: Table View Controller data source
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //for selection
        
    }
    
    
    
    //MARK: Location Delegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        latUser = manager.location?.coordinate.latitude
        lonUser = manager.location?.coordinate.longitude
        
        if isFindMe == true {
            
            findMe()
        }
        
        
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
        locationManager = nil
        
        
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
    
    
    
    
}
