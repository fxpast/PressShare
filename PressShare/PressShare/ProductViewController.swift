//
//  InfoPostViewController.swift
//  PressShare
//
//  Description : Manage, buy or exchange a product
//
//  Created by MacbookPRV on 02/05/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//

//Todo : check error on update presentation landscape

import Foundation
import MapKit
import UIKit
import MobileCoreServices

class ProductViewController : UIViewController , MKMapViewDelegate , UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
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
    @IBOutlet weak var IBAlert: UIBarButtonItem!
    @IBOutlet weak var IBTransact: UIBarButtonItem!
    
    var fieldName = ""
    var keybordY:CGFloat! = 0
    var star=0
    var client=false
    var flgBeganPin = false
    var flgMajImage = false
    
    var aProduct:Product?
    var aTransaction:Transaction?
    var config = Config.sharedInstance
    let translate = TranslateMessage.sharedInstance
    
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
        
        
        setUIHidden(true)
        
        if let thisproduct = aProduct {
            
            if thisproduct.prod_image == "" {
                IBAddImage.image = #imageLiteral(resourceName: "noimage")
            }
            else {
                IBAddImage.image = UIImage(data:thisproduct.prod_imageData)
            }
            
            IBNom.text =  thisproduct.prod_nom
            
            IBPrix.text = BlackBox.sharedInstance.formatedAmount(thisproduct.prod_prix)
            
            IBComment.text = thisproduct.prod_comment
            IBTemps.text = thisproduct.prod_tempsDispo
            star = thisproduct.prod_etat
            if star == 1 {
                actionStar1(IBStar1)
            }
            else if star == 2 {
                actionStar2(IBStar2)
            }
            else if star == 3 {
                actionStar3(IBStar3)
            }
            else if star == 4 {
                actionStar4(IBStar4)
            }
            else if star == 5 {
                actionStar5(IBStar5)
            }
            IBInfoLocation.text = thisproduct.prod_mapString
            config.mapString = thisproduct.prod_mapString
            config.latitude = thisproduct.prod_latitude
            config.longitude = thisproduct.prod_longitude
            
            if config.user_id == thisproduct.prod_by_user {
                client=false
                setUIEnabled(true)
            }
            else {
                
                if config.level <= 0 {
                    IBSave.isEnabled = false
                    IBAlert.isEnabled = false
                    IBTransact.isEnabled = false
                    client=false
                }
                else {
                    client=true
                }
                
                setUIEnabled(false)
                
            }
            
            
        }
        else {
            IBAddImage.image = #imageLiteral(resourceName: "noimage")
        }
        
        
        IBActivity.stopAnimating()
        
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        subscibeToKeyboardNotifications()
        
        if client {
            
            IBSave.title = translate.exchangeBuy
            
            for trans in Transactions.sharedInstance.transactionArray {
                
                let tran = Transaction(dico: trans)
                
                if tran.prod_id == aProduct?.prod_id {
                    
                    aTransaction = tran
                    IBSave.isEnabled = false
                    break
                    
                }
            }
            
        }
        else {
            
            IBSave.title = translate.save
            
        }
        IBInfoLocation.placeholder = translate.tapALoc
        IBFind.setTitle(translate.findOnMap, for: UIControlState())
        IBNom.placeholder = translate.description
        IBPrix.placeholder = translate.price
        IBComment.placeholder = translate.comment
        IBTemps.placeholder = translate.availableTime
        IBEtat.text = translate.state
        IBTransact.title = translate.devise
        
        if config.vendeur_maj == true {
            config.vendeur_maj = false
            dismiss(animated: true, completion: nil)
        }
        
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
        
    }
    
    @IBAction func actionTransact(_ sender: Any) {
        
        if aTransaction != nil {
            performSegue(withIdentifier: "detailtransaction", sender: sender)
        }
        
        
    }
    
    @IBAction func actionAlert(_ sender: Any) {
        
        
        for mess in Messages.sharedInstance.MessagesArray {
            
            let message = Message(dico: mess)
            
            if message.product_id == aProduct?.prod_id {
                performSegue(withIdentifier: "messagerie", sender: sender)
                break
            }
            
        }
        
    }
    
    @IBAction func actionCancel(_ sender: AnyObject) {
        
        if IBMap.isHidden == true {
            config.product_maj = false
            dismiss(animated: true, completion: nil)
        }
        else {
            self.setUIHidden(true)
        }
        
        
    }
    
    
    private func setUIEnabled(_ enabled: Bool) {
        
        
        IBNom.isEnabled = enabled
        IBPrix.isEnabled = enabled
        IBComment.isEnabled = enabled
        IBTemps.isEnabled = enabled
        
        IBStar1.isEnabled = enabled
        IBStar2.isEnabled = enabled
        IBStar3.isEnabled = enabled
        IBStar4.isEnabled = enabled
        IBStar5.isEnabled = enabled
        
        IBInfoLocation.isEnabled = enabled
        
        IBFind.isEnabled = enabled
        
        
    }
    
    private func setUIHidden(_ hidden: Bool) {
        
        
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
        
        IBAddImage.isHidden = !hidden
        IBInfoLocation.isHidden = !hidden
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if segue.identifier == "seller" {
            
            let nav = segue.destination as! UINavigationController
            let controller = nav.topViewController as! CreateTransViewController
            controller.aProduct = aProduct
        }
        else if segue.identifier == "messagerie" {
                
                let nav = segue.destination as! UINavigationController
                let controller = nav.topViewController as! DetailMessageViewContr
                controller.aProduct = aProduct

            
        }
        else if segue.identifier == "detailtransaction" {
            
            let nav = segue.destination as! UINavigationController
            let controller = nav.topViewController as! DetailTransViewController
            controller.aTransaction = aTransaction
            
            
        }
    
        
    }
    
    
    //MARK: Image placeholder
    private func addImage() {
        
        
        guard UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) == true else {
            
            imageFromCamera(camera: false)
            return
        }
        
        let alertController = UIAlertController(title: translate.takePicture, message: translate.makeChoice, preferredStyle: .alert)
        
        let actionBiblio = UIAlertAction(title: "Photo", style: .destructive, handler: { (action) in
            BlackBox.sharedInstance.performUIUpdatesOnMain {
                
                self.imageFromCamera(camera: false)
                
            }
            
        })
        
        let actionCamera = UIAlertAction(title: "Camera", style: .destructive, handler: { (action) in
            
            BlackBox.sharedInstance.performUIUpdatesOnMain {
                
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let point = (event?.allTouches?.first?.location(in: IBMap))
        let xD = (point?.x)! - 5
        let xF = (point?.x)! + 5
        let yD = (point?.y)! - 5
        let yF = (point?.y)! + 30
        
        let pointPin = IBMap.convert(CLLocationCoordinate2D.init(latitude: config.latitude, longitude: config.longitude), toPointTo: IBMap)
        
        if pointPin.x >= xD && pointPin.x <= xF && pointPin.y >= yD && pointPin.y <= yF {
            flgBeganPin = true
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if flgBeganPin == true && IBMap.isHidden == false {
            
            var annotations = IBMap.annotations as! [MKPointAnnotation]
            let point = (event?.allTouches?.first?.location(in: IBMap))
            
            let coordinate = IBMap.convert(point!, toCoordinateFrom: IBMap) as CLLocationCoordinate2D
            
            let annotation = annotations[0]
            if annotation.coordinate.latitude   == config.latitude  && annotation.coordinate.longitude  == config.longitude {
                annotation.coordinate = coordinate
                IBMap.addAnnotations(annotations)
                config.latitude = coordinate.latitude
                config.longitude = coordinate.longitude
                
            }
            
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        flgBeganPin = false
        if IBMap.isHidden == true {
            
            if let thisproduct = aProduct {
                
                if config.user_id != thisproduct.prod_by_user {
                    
                    return
                }
            }
            
            let location = (event?.allTouches?.first?.location(in: self.view))
            
            if (location?.x)! > IBAddImage.frame.origin.x && (location?.x)! < IBAddImage.frame.size.width && (location?.y)! > IBAddImage.frame.origin.y  && (location?.y)! < (IBStar1.frame.origin.y+IBNom.frame.origin.y)/2{
                
                addImage()
            }
            
            guard fieldName != "" && keybordY > 0 else {
                return
            }
            
            if Double((location?.y)!) < Double(keybordY) {
                
                var textField = UITextField()
                
                if fieldName == "IBNom" {
                    textField = IBNom
                }
                else if fieldName == "IBPrix" {
                    textField = IBPrix
                    
                    textField.text = textField.text!.replacingOccurrences(of: translate.devise!, with: "")
                    textField.text = textField.text!.replacingOccurrences(of: " ", with: "")
                    if textField.text == "0.0" || textField.text == "0"  {
                        textField.text = ""
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
        
    }
    
    
    //MARK: star placeholder
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
    
    
    @IBAction func actionStar1(_ sender: AnyObject) {
        star = 1
        
        initStar()
        changeStar(sender as! UIButton)
    }
    
    
    @IBAction func actionStar2(_ sender: AnyObject) {
        star = 2
        initStar()
        changeStar(sender as! UIButton)
        changeStar(IBStar1)
    }
    
    
    @IBAction func actionStar3(_ sender: AnyObject) {
        star = 3
        initStar()
        changeStar(sender as! UIButton)
        changeStar(IBStar2)
        changeStar(IBStar1)
    }
    
    
    @IBAction func actionStar4(_ sender: AnyObject) {
        star = 4
        initStar()
        changeStar(sender as! UIButton)
        changeStar(IBStar3)
        changeStar(IBStar2)
        changeStar(IBStar1)
    }
    
    
    @IBAction func actionStar5(_ sender: AnyObject) {
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
        
        flgMajImage = true
        IBAddImage.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        IBAddImage.contentMode = UIViewContentMode.scaleAspectFit
        
        dismiss(animated: true, completion: nil)
    }
    
    
    //MARK: textfield Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.endEditing(true)
        
        if textField == IBInfoLocation && IBInfoLocation.text != "" {
            actionFindMap(self)
        }
        
        return true
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField.isEqual(IBPrix) {
            
            var finalValue = textField.text!.replacingOccurrences(of: translate.devise!, with: "")
            finalValue = finalValue.replacingOccurrences(of: " ", with: "")
            if finalValue == "0.0" || finalValue == "0"  {
                finalValue = ""
            }
            
            guard let prix = BlackBox.sharedInstance.formatedAmount(finalValue) else {
                displayAlert(translate.error, mess: translate.ErrorPrice)
                return
            }
            
            if prix == 0 {
                textField.text = ""
            }
            else {
                textField.text = BlackBox.sharedInstance.formatedAmount(prix)
            }
            
            
        }
        
    }
    
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        
        
        if textField.isEqual(IBNom) {
            fieldName = "IBNom"
        }
        else if textField.isEqual(IBPrix) {
            fieldName = "IBPrix"
            textField.text = textField.text?.replacingOccurrences(of: translate.devise!, with: "")
            textField.text = textField.text?.replacingOccurrences(of: " ", with: "")
            
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
        
        
        return true
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
        
        IBSave.isEnabled = false
        
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
        
        IBSave.isEnabled = true
        
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
    
    @IBAction func actionFindMap(_ sender: AnyObject) {
        
        
        guard IBInfoLocation.text != "" else {
            displayAlert(translate.error, mess: translate.ErrorGeolocation)
            return
        }
        
        guard let _ = BlackBox.sharedInstance.formatedAmount(IBPrix.text!) else {
            
            displayAlert(translate.error, mess: translate.ErrorPrice)
            return
            
        }
        
        setUIHidden(false)
        
        IBActivity.startAnimating()
        config.mapString = IBInfoLocation.text
        
        let geoCode  = CLGeocoder()
        
        
        geoCode.geocodeAddressString(IBInfoLocation.text!, completionHandler: {(marks,error) in
            
            guard error == nil else {
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    
                    self.setUIHidden(true)
                    self.IBActivity.stopAnimating()
                    self.displayAlert(self.translate.error, mess: self.translate.ErrorGeocode) //error.debugDescription
                }
                return
            }
            
            let placemark = marks![0] as CLPlacemark
            self.config.latitude = Double((placemark.location?.coordinate.latitude)!)
            self.config.longitude = Double((placemark.location?.coordinate.longitude)!)
            
            BlackBox.sharedInstance.performUIUpdatesOnMain {
                
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
                let regionRadius: CLLocationDistance = 1000
                let coordinateRegion = MKCoordinateRegionMakeWithDistance(annotation.coordinate,
                                                                          regionRadius * 2.0, regionRadius * 2.0)
                self.IBMap.setRegion(coordinateRegion, animated: true)
                self.IBActivity.stopAnimating()
                
                
            }
            
        })
        
        
    }
    
    
    @IBAction func actionSubmit(_ sender: AnyObject) {
        
        
        guard IBNom.text != "" else {
            self.displayAlert(self.translate.error, mess: translate.ErrorDescription)
            return
        }
        
        
        guard IBPrix.text != "" else {
            self.displayAlert(self.translate.error, mess: translate.ErrorPrice)
            return
        }
        
        
        func actionClient() {
            
            performSegue(withIdentifier: "seller", sender: self)
            
        }
        
        func actionUser() {
            
            
            config.product_maj = false
            config.product_add = false
            IBActivity.startAnimating()
            
            IBSave.isEnabled = false
            IBFind.isEnabled = false
            
            
            var product = Product(dico: [String : AnyObject]())
            
            if aProduct != nil {
                product.prod_image = (aProduct?.prod_image)! == "" ? "xxxxxxx" : (aProduct?.prod_image)!
            }
            
            if (IBAddImage.image?.isEqual(#imageLiteral(resourceName: "noimage")))! {
                product.prod_image = ""
            }
            else {
                if flgMajImage == true {
                    product.prodImageOld = product.prod_image
                    product.prod_image = "photo-\(config.user_id!)\(NSUUID().uuidString)"
                    product.prod_imageData = UIImageJPEGRepresentation(IBAddImage.image!, 1)!
                }
                
            }
            
            var finalValue = IBPrix.text!.replacingOccurrences(of: translate.devise!, with: "")
            finalValue = finalValue.replacingOccurrences(of:  " ", with: "")
            if finalValue == "0.0" || finalValue == "0"  {
                finalValue = ""
            }
            
            if aProduct != nil {
                product.prod_id = (aProduct?.prod_id)!                
            }
            product.prod_prix = BlackBox.sharedInstance.formatedAmount(finalValue)!
            product.prod_nom = IBNom.text!
            product.prod_by_user = config.user_id
            product.prod_longitude = config.longitude
            product.prod_latitude = config.latitude
            product.prod_mapString = config.mapString
            product.prod_comment = IBComment.text!
            product.prod_tempsDispo = IBTemps.text!
            product.prod_etat = star
            product.prod_hidden = false
            
            if aProduct != nil {
                
                //update product
                MDBProduct.sharedInstance.setUpdateProduct("Product", product) { (success, errorString) in
                    
                    if success {
                        
                        MDBProduct.sharedInstance.getAllProducts(self.config.user_id) { (success, productArray, errorString) in
                            
                            if success {
                                
                                Products.sharedInstance.productsArray = productArray
                                
                                self.config.product_maj = true
                                self.config.product_add = false
                                BlackBox.sharedInstance.performUIUpdatesOnMain {
                                    self.IBSave.isEnabled = true
                                    self.IBFind.isEnabled = true
                                    self.IBActivity.stopAnimating()
                                    self.dismiss(animated: true, completion: nil)
                                }
                                
                            }
                            else {
                                BlackBox.sharedInstance.performUIUpdatesOnMain {
                                    self.displayAlert(self.translate.error, mess: errorString!)
                                }
                            }
                        }
                        
                        
                        
                    }
                    else {
                        BlackBox.sharedInstance.performUIUpdatesOnMain {
                            
                            BlackBox.sharedInstance.performUIUpdatesOnMain {
                                self.IBSave.isEnabled = true
                                self.IBFind.isEnabled = true
                                self.IBActivity.stopAnimating()
                                self.displayAlert(self.translate.error, mess: errorString!)
                            }
                        }
                    }
                    
                }
                
            }
            else {
                
                //add product
                MDBProduct.sharedInstance.setAddProduct(product) { (success, errorString) in
                    
                    if success {
                        
                        MDBProduct.sharedInstance.getAllProducts(self.config.user_id) { (success, productArray, errorString) in
                            
                            if success {
                                
                                Products.sharedInstance.productsArray = productArray
                                
                                self.config.product_add = true
                                self.config.product_maj = false
                                BlackBox.sharedInstance.performUIUpdatesOnMain {
                                    self.IBSave.isEnabled = true
                                    self.IBFind.isEnabled = true
                                    self.IBActivity.stopAnimating()
                                    self.dismiss(animated: true, completion: nil)
                                }
                                
                            }
                            else {
                                BlackBox.sharedInstance.performUIUpdatesOnMain {
                                    self.displayAlert(self.translate.error, mess: errorString!)
                                }
                            }
                        }
                        
                    }
                    else {
                        BlackBox.sharedInstance.performUIUpdatesOnMain {
                            self.IBSave.isEnabled = true
                            self.IBFind.isEnabled = true
                            self.IBActivity.stopAnimating()
                            self.displayAlert(self.translate.error, mess: errorString!)
                        }
                    }
                    
                }
                
            }
            
            
            
        }
        
        
        if client {
            actionClient()
        }
        else {
            actionUser()
        }
        
        
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
