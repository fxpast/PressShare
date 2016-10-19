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
import MobileCoreServices




class ProduitViewController : UIViewController , MKMapViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    
    @IBOutlet weak var IBCancel: UIBarButtonItem!
    @IBOutlet weak var IBSave: UIBarButtonItem!
    @IBOutlet weak var IBFind: UIButton!
    @IBOutlet weak var IBMap: MKMapView!
    @IBOutlet weak var IBInfoLocation: UITextField!
    @IBOutlet weak var IBActivity: UIActivityIndicatorView!
    @IBOutlet weak var IBNom: UITextField!
    @IBOutlet weak var IBPrix: UITextField!
    @IBOutlet weak var IBComment: UITextField!
    @IBOutlet weak var IBStar1: UIButton!
    @IBOutlet weak var IBStar2: UIButton!
    @IBOutlet weak var IBStar3: UIButton!
    @IBOutlet weak var IBStar4: UIButton!
    @IBOutlet weak var IBStar5: UIButton!
    @IBOutlet weak var IBTemps: UITextField!
    @IBOutlet weak var IBEtat: UILabel!
    @IBOutlet weak var IBAddImage: UIImageView!
    @IBOutlet weak var IBAddImageButton: UIButton!
    
    var fieldName = ""
    var keybordY:CGFloat! = 0
    var star=0
    
    
    var aproduit:Produit?
    
    var config = Config.sharedInstance
    let traduction = InternationalIHM.sharedInstance
    
    var filePath : String {
        let manager = FileManager.default
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first! as URL
        return url.appendingPathComponent("mapRegionArchive").path
    }
    
    
    //MARK: View Controller Delegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        IBActivity.stopAnimating()
        setUIHidden(true)
        
 
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        subscibeToKeyboardNotifications()
        
        IBInfoLocation.text = config.mapString
        IBCancel.title = traduction.pse1
        IBSave.title = traduction.pse2
        IBInfoLocation.placeholder = traduction.pse3
        IBFind.setTitle(traduction.pse4, for: UIControlState())
        IBNom.placeholder = traduction.pse5
        IBPrix.placeholder = traduction.pse6
        IBComment.placeholder = traduction.pse7
        IBTemps.placeholder = traduction.pse8
        IBEtat.text = traduction.pse9
        
        
        if let thisproduit = aproduit {
            
            IBAddImage.image = UIImage(data:thisproduit.prod_imageData)
            IBNom.text =  thisproduit.prod_nom
            IBNom.isEnabled = false
            IBPrix.text = String(thisproduit.prod_prix)
            IBPrix.isEnabled = false
            IBComment.text = thisproduit.prod_comment
            IBComment.isEnabled = false
            IBTemps.text = thisproduit.prod_tempsDispo
            IBTemps.isEnabled = false
            
            star = thisproduit.prod_etat
            if star == 1 {
                ActionStar1(IBStar1)
            }
            else if star == 2 {
                ActionStar2(IBStar2)
            }
            else if star == 3 {
                ActionStar3(IBStar3)
            }
            else if star == 4 {
                ActionStar4(IBStar4)
            }
            else if star == 5 {
                ActionStar5(IBStar5)
            }
            IBAddImageButton.isEnabled = false
            IBStar1.isEnabled = false
            IBStar2.isEnabled = false
            IBStar3.isEnabled = false
            IBStar4.isEnabled = false
            IBStar5.isEnabled = false
            
            IBInfoLocation.text = thisproduit.prod_mapString
            IBInfoLocation.isEnabled = false
            IBSave.isEnabled = false
            IBFind.isEnabled = false
        }
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
        
    }
    

    @IBAction func ActionAddImage(_ sender: AnyObject) {
   
        guard UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) == true else {
            
            imageFromCamera(camera: false)
            return
        }
 
        let alertController = UIAlertController(title: "Capture photo", message: "Faites votre choix :", preferredStyle: .alert)
        
        let actionBiblio = UIAlertAction(title: "Photo", style: .destructive, handler: { (action) in
            performUIUpdatesOnMain {
                
                self.imageFromCamera(camera: false)
                
            }
            
        })
        
        let actionCamera = UIAlertAction(title: "Camera", style: .destructive, handler: { (action) in
            
            performUIUpdatesOnMain {
                
                self.imageFromCamera(camera: true)
                
            }
        })
        
        alertController.addAction(actionBiblio)
        alertController.addAction(actionCamera)
    
        
        self.present(alertController, animated: true) {
            
        }
        
      
    }
    
    
    private func imageFromCamera(camera:Bool) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.modalPresentationStyle = UIModalPresentationStyle.currentContext;
        imagePicker.mediaTypes = [kUTTypeImage as String]
        
        if camera {
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
        }
        else {
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        }
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    @IBAction func ActionCancel(_ sender: AnyObject) {
        
        if IBMap.isHidden == true {
            dismiss(animated: true, completion: nil)
        }
        else {
            self.setUIHidden(true)
        }
        
    
    }
    
    
    fileprivate func setUIHidden(_ hidden: Bool) {
        
        
        IBSave.isEnabled = !hidden
        IBMap.isHidden = hidden
        IBFind.isHidden = !hidden
        IBNom.isHidden = !hidden
        IBPrix.isHidden = !hidden
        IBComment.isHidden = !hidden
        IBEtat.isHidden = !hidden
        IBTemps.isHidden = !hidden
        IBStar1.isHidden = !hidden
        IBStar2.isHidden = !hidden
        IBStar3.isHidden = !hidden
        IBStar4.isHidden = !hidden
        IBStar5.isHidden = !hidden
        IBAddImageButton.isHidden = !hidden
        
        IBAddImage.isHidden = !hidden
        IBInfoLocation.isHidden = !hidden
        
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard fieldName != "" && keybordY > 0 else {
            return
        }
        
        let location = (event?.allTouches?.first?.location(in: self.view).y)! as CGFloat
        if (location < keybordY) {
            
            var textField = UITextField()
            
            
            if fieldName == "IBNom" {
                textField = IBNom
            }
            else if fieldName == "IBPrix" {
                textField = IBPrix
                
                guard let _ = NumberFormatter().number(from: textField.text!) else {
                    displayAlert("Error", mess: "valeur incorrecte")
                    return
                }
                
            }
            else if fieldName == "IBComment" {
                textField = IBComment
            }
            else if fieldName == "IBTemps" {
                textField = IBTemps
            }
            else if fieldName == "IBInfoLocation" {
                textField = IBInfoLocation
            }
            
            textField.endEditing(true)
            
        }
        
    }
    
    private func changeStar(_ sender: UIButton) {
        
        if sender.currentImage == #imageLiteral(resourceName: "whiteStar") {
            sender.setImage(#imageLiteral(resourceName: "blackStar"), for: UIControlState.normal)
            
        }
        else {
            sender.setImage(#imageLiteral(resourceName: "whiteStar"), for: UIControlState.normal)
        }
        
    }
    
    private func initStar() {
        
        IBStar1.setImage(#imageLiteral(resourceName: "whiteStar"), for: UIControlState.normal)
        IBStar2.setImage(#imageLiteral(resourceName: "whiteStar"), for: UIControlState.normal)
        IBStar3.setImage(#imageLiteral(resourceName: "whiteStar"), for: UIControlState.normal)
        IBStar4.setImage(#imageLiteral(resourceName: "whiteStar"), for: UIControlState.normal)
        IBStar5.setImage(#imageLiteral(resourceName: "whiteStar"), for: UIControlState.normal)
        
    }
    
    
    @IBAction func ActionStar1(_ sender: AnyObject) {
        star = 1
    
        initStar()
        changeStar(sender as! UIButton)
    }
    
    
    @IBAction func ActionStar2(_ sender: AnyObject) {
        star = 2
        initStar()
        changeStar(sender as! UIButton)
        changeStar(IBStar1)
    }
    
    
    @IBAction func ActionStar3(_ sender: AnyObject) {
        star = 3
        initStar()
        changeStar(sender as! UIButton)
        changeStar(IBStar2)
        changeStar(IBStar1)
    }
    
    
    @IBAction func ActionStar4(_ sender: AnyObject) {
        star = 4
        initStar()
        changeStar(sender as! UIButton)
        changeStar(IBStar3)
        changeStar(IBStar2)
        changeStar(IBStar1)
    }
    
    
    @IBAction func ActionStar5(_ sender: AnyObject) {
        star = 5
        initStar()
        changeStar(sender as! UIButton)
        changeStar(IBStar4)
        changeStar(IBStar3)
        changeStar(IBStar2)
        changeStar(IBStar1)
    }
    
    

    //MARK: Image Picker Delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    
        
        IBAddImage.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        IBAddImage.contentMode = UIViewContentMode.scaleAspectFit
        
        dismiss(animated: true, completion: nil)
    }
    
    

    
    //MARK: textfield Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        
        if textField.isEqual(IBPrix) {
            
            guard let _ = NumberFormatter().number(from: IBPrix.text!) else {
                
                displayAlert("Error", mess: "valeur incorrecte")
                return false
                
            }
            
        }
        
        textField.endEditing(true)
        return true
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        
        if textField.isEqual(IBNom) {
            fieldName = "IBNom"
        }
        else if textField.isEqual(IBPrix) {
            fieldName = "IBPrix"
        }
        else if textField.isEqual(IBComment) {
            fieldName = "IBComment"
        }
        else if textField.isEqual(IBTemps) {
            fieldName = "IBTemps"
        }
        else if textField.isEqual(IBInfoLocation) {
            fieldName = "IBInfoLocation"
        }
        
        
    }
    
    
    
    //MARK: keyboard function
    
    
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
        
        
        if fieldName == "IBNom" {
            textField = IBNom
        }
        else if fieldName == "IBPrix" {
            textField = IBPrix
        }
        else if fieldName == "IBComment" {
            textField = IBComment
        }
        else if fieldName == "IBTemps" {
            textField = IBTemps
        }
        else if fieldName == "IBInfoLocation" {
            textField = IBInfoLocation
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
        
        
        if fieldName == "IBNom" {
            textField = IBNom
        }
        else if fieldName == "IBPrix" {
            textField = IBPrix
            guard let _ = NumberFormatter().number(from: textField.text!) else {
                displayAlert("Error", mess: "valeur incorrecte")
                return
            }
        }
        else if fieldName == "IBComment" {
            textField = IBComment
        }
        else if fieldName == "IBTemps" {
            textField = IBTemps
        }
        else if fieldName == "IBInfoLocation" {
            textField = IBInfoLocation
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
    
    @IBAction func ActionFindMap(_ sender: AnyObject) {
        
        
        guard IBInfoLocation.text != "" else {
            displayAlert("Error", mess: "localisation incorrecte")
            return
        }
        
        guard let _ = NumberFormatter().number(from: IBPrix.text!) else {
            
            displayAlert("Error", mess: "valeur prix incorrecte")
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
                    self.displayAlert("Error", mess: "error geocodeadresse : invalid address") //error.debugDescription
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
                annotation.title = "\(self.config.user_nom!) \(self.config.user_prenom!)"
                annotation.subtitle = self.config.mapString!
                
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
    
    
    @IBAction func ActionSubmit(_ sender: AnyObject) {
        
        
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
        produit.prod_image = "photo-\(NSUUID().uuidString)"
        produit.prod_imageData = UIImageJPEGRepresentation(IBAddImage.image!, 1)!
        produit.prod_prix = Double(IBPrix.text!)!
        produit.prod_by_user = config.user_id
        produit.prod_longitude = config.longitude
        produit.prod_latitude = config.latitude
        produit.prod_mapString = config.mapString
        produit.prod_comment = IBComment.text!
        produit.prod_tempsDispo = IBTemps.text!
        produit.prod_etat = star
        
        setAddProduit(produit) { (success, errorString) in
            
            if success {
                performUIUpdatesOnMain {
                    self.IBActivity.stopAnimating()
                    self.dismiss(animated: true, completion: nil)
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
    
    fileprivate func saveMapRegion() {
        
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
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView?.pinTintColor = UIColor.red
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    
    
    
}
