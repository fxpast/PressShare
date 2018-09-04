//
//  InfoPostViewController.swift
//  PressShare
//
//  Description : Manage, buy or exchange a product
//
//  Created by MacbookPRV on 02/05/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//


import Foundation
import UIKit
import MobileCoreServices

class ProductTableViewContr : UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    
    
    @IBOutlet weak var IBEchangeLabel: UILabel!
    @IBOutlet weak var IBEchangeChoice: UISwitch!
    @IBOutlet weak var IBActivity: UIActivityIndicatorView!
    @IBOutlet weak var IBAddImage: UIImageView!
    @IBOutlet weak var IBNomLabel: UILabel!
    @IBOutlet weak var IBNom: UITextField!
    @IBOutlet weak var IBPrixLabel: UILabel!
    @IBOutlet weak var IBPrix: UITextField!
    @IBOutlet weak var IBCommentLabel: UILabel!
    @IBOutlet weak var IBComment: UITextField!
    @IBOutlet weak var IBStar1: UIButton!
    @IBOutlet weak var IBStar2: UIButton!
    @IBOutlet weak var IBStar3: UIButton!
    @IBOutlet weak var IBStar4: UIButton!
    @IBOutlet weak var IBStar5: UIButton!
    @IBOutlet weak var IBEtat: UILabel!
    @IBOutlet weak var IBCancel: UIBarButtonItem!
    @IBOutlet weak var IBSave: UIBarButtonItem!
    @IBOutlet weak var IBAlert: UIBarButtonItem!
    @IBOutlet weak var IBAddCreneau: UIButton!

    
    var IBTransact: UIButton!
    
    var star=0
    var client=false
    var isMajImage = false
    var fieldName = ""
    var aProduct:Product?
    var aTransaction:Transaction?
    var config = Config.sharedInstance
    let translate = TranslateMessage.sharedInstance
    var isFirst = true
    var isFindMe = false
    var typeListe = 0 //Map :0, MyList:1, Historical:2
    var timerBadge : Timer!

 
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
        
        
   
        tableView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(handleTap)))
        if let thisproduct = aProduct {
            
            if thisproduct.prod_closed == false {
                if Transactions.sharedInstance.transactionArray != nil {
                    
                    for trans in Transactions.sharedInstance.transactionArray {
                        let tran = Transaction(dico: trans)
                        if tran.prod_id == aProduct?.prod_id {
                            //0 : La transaction en cours. 1 : La transaction a été annulée. 2 : La transaction est confirmée.
                            if tran.trans_valid == 0 {
                                
                                IBTransact = UIButton()
                                IBTransact.setTitle(translate.message("validerTransact"), for: UIControlState.normal)
                                IBTransact.titleLabel?.textColor = UIColor.white
                                IBTransact.titleLabel?.backgroundColor = UIColor.red
                                IBTransact.titleLabel?.font = UIFont.boldSystemFont(ofSize: 25.0)
                                IBTransact.titleLabel?.textAlignment = .center
                                IBTransact.addTarget(self, action: #selector(actionTransact(_:)), for: UIControlEvents.touchUpInside)
                                IBTransact.tag = 999
                                IBTransact.sizeToFit()
                                tableView.addSubview(IBTransact)
                                
                            }
                        }
                    }
                    
                }
                
            }
            
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        IBActivity.isHidden = true
        IBActivity.stopAnimating()
        
        
        if config.isReturnToTab == true {
            dismiss(animated: false, completion: nil)
        }
        
        
   
        
        for i in 0...5 {
            tableView.scrollToRow(at: IndexPath(item: i, section: 0), at: .none, animated: false)            
            tableView(tableView, cellForRowAt: IndexPath(item: i, section: 0)).backgroundColor  = UIColor.init(hexString: config.colorApp)
            tableView(tableView, cellForRowAt: IndexPath(item: i, section: 0)).backgroundView?.backgroundColor  = UIColor.init(hexString: config.colorApp)
        }
        tableView.scrollToRow(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
        
        tableView.backgroundColor = UIColor.init(hexString: config.colorApp)
        tableView.backgroundView?.backgroundColor = UIColor.init(hexString: config.colorApp)
        tableView.sectionIndexColor = UIColor.init(hexString: config.colorApp)
        
         IBAddCreneau.setTitle(translate.message("timeslot"), for: UIControlState.normal)
        
        if aProduct == nil   {
            IBAddCreneau.isEnabled = false
        }
        
        if isFirst == true {
            
            if let thisproduct = aProduct {
               
                if Messages.sharedInstance.MessagesArray != nil {
                    
                    for mess in Messages.sharedInstance.MessagesArray {
                        
                        let message = Message(dico: mess)
                        
                        if message.product_id == aProduct?.prod_id {
                            IBAlert.isEnabled = true
                            break
                        }
                        
                    }
                    
                }
                
                if thisproduct.prod_imageUrl == "" {
                    IBAddImage.image = #imageLiteral(resourceName: "noimage")
                }
                else {
                    IBAddImage.image =  MyTools.sharedInstance.restoreImageArchive(prod_imageUrl: thisproduct.prod_imageUrl)
                }
                
                IBEchangeChoice.isOn = thisproduct.prod_echange
                
                IBNom.text =  thisproduct.prod_nom
                IBNom.textColor = UIColor.init(hexString: config.colorAppText)
                
                IBPrix.text = MyTools.sharedInstance.formatedAmount(thisproduct.prod_prix)
                IBPrix.textColor = UIColor.init(hexString: config.colorAppText)
                
                IBComment.text = thisproduct.prod_comment
                IBComment.textColor = UIColor.init(hexString: config.colorAppText)
                
      
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
           
                
                config.mapString = thisproduct.prod_mapString
                config.latitude = thisproduct.prod_latitude
                config.longitude = thisproduct.prod_longitude
                
                if config.user_id == thisproduct.prod_by_user  {
                    client=false
                    if thisproduct.prod_closed == false {
                        setUIEnabled(true)
                    }
                    else {
                        IBSave.isEnabled = false
                        setUIEnabled(false)
                        
                    }
                    
                    
                }
                else {
                    
                    if config.level <= 0 {
                        IBSave.isEnabled = false
                        IBAlert.isEnabled = false
                        client=false
                    }
                    else {
                        client=true
                    }
                    
                    if thisproduct.prod_closed == true {
                        IBSave.isEnabled = false
                    }
                    setUIEnabled(false)
                }
                
            }
            else {
                
                IBEchangeChoice.isOn = false
                IBAddImage.image = #imageLiteral(resourceName: "noimage")
                IBAlert.isEnabled = false
                IBPrix.text = MyTools.sharedInstance.formatedAmount(0.0)
                IBEchangeChoice.isOn = true
                
                
            }
            
        
            IBNomLabel.textColor = UIColor.init(hexString: config.colorAppLabel)
            IBNomLabel.text = translate.message("description")
            IBNom.attributedPlaceholder = NSAttributedString.init(string: translate.message("description"), attributes: [NSForegroundColorAttributeName : UIColor.init(hexString: config.colorAppPlHd)])
            
            IBPrixLabel.textColor = UIColor.init(hexString: config.colorAppLabel)
            IBPrixLabel.text = translate.message("price")
            IBPrix.attributedPlaceholder = NSAttributedString.init(string: translate.message("price"), attributes: [NSForegroundColorAttributeName : UIColor.init(hexString: config.colorAppPlHd)])
            
            IBCommentLabel.textColor = UIColor.init(hexString: config.colorAppLabel)
            IBCommentLabel.text = translate.message("comment")
            IBComment.attributedPlaceholder = NSAttributedString.init(string: translate.message("comment"), attributes: [NSForegroundColorAttributeName : UIColor.init(hexString: config.colorAppPlHd)])
      
            IBEtat.text = translate.message("state")
            IBEtat.textColor = UIColor.init(hexString: config.colorAppLabel)

            IBEchangeLabel.textColor = UIColor.init(hexString: config.colorAppLabel)
            IBEchangeLabel.text = translate.message("allowExch")
            
            IBNom.layer.addSublayer(MyTools.sharedInstance.createLine(frame: IBNom.frame))
            IBPrix.layer.addSublayer(MyTools.sharedInstance.createLine(frame: IBPrix.frame))
            IBComment.layer.addSublayer(MyTools.sharedInstance.createLine(frame: IBComment.frame))
          
        }
        
        isFirst = false
        
        if client {
            IBSave.title = translate.message("exchangeBuy")
            
        }
        else {
            IBSave.title = translate.message("save")
        }
      
        if let thisproduct = aProduct {
            
            if thisproduct.prod_closed == false {
                
                var isRunning = false
                if Transactions.sharedInstance.transactionArray != nil {
                    
                    for trans in Transactions.sharedInstance.transactionArray {
                        let tran = Transaction(dico: trans)
                        if tran.prod_id == aProduct?.prod_id {
                            //0 : La transaction en cours. 1 : La transaction a été annulée. 2 : La transaction est confirmée.
                            
                            if tran.trans_valid == 0 {
                                isRunning = true
                            }
                            
                            if tran.trans_valid == 0 || tran.trans_valid == 2 {
                                aTransaction = tran
                                IBSave.isEnabled = false
                                
                            }
                            
                        }
                    }
                    
                }
                
                if  IBTransact != nil && isRunning == false {
                    IBTransact.removeFromSuperview()
                    IBTransact = nil
                }
                
            }
            
            //setup table view creneau
            
        
            
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)

        
        timerBadge = Timer.scheduledTimer(timeInterval: config.dureeTimer, target: self, selector: #selector(routineTimer), userInfo: nil, repeats: true)
        
        
        
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
    
    
    
    @IBAction func actionTransact(_ sender: Any) {
        
        IBTransact.isEnabled = false
        
        if aTransaction != nil {
            performSegue(withIdentifier: "detailtransaction", sender: sender)
        }
        
    }
    
    @IBAction func actionAlert(_ sender: Any) {
        
        IBAlert.isEnabled = false
        
        for mess in Messages.sharedInstance.MessagesArray {
            
            let message = Message(dico: mess)
            
            if message.product_id == aProduct?.prod_id {
                performSegue(withIdentifier: "messagerie", sender: sender)
                break
            }
            
        }
        
    }
    
   
    
    
    @IBAction func actionHelp(_ sender: Any) {
        
        //action info
        MyTools.sharedInstance.showHelp("informations_article", self)
        
    }
    
    
    @IBAction func actionCancel(_ sender: AnyObject) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    
    func handleTap(sender: UITapGestureRecognizer) {
        
        if sender.state == .ended {
            
            let location = sender.location(in: tableView)
            let indexPath = tableView.indexPathForRow(at:location)
            
            let zx = location.x
            let cell = tableView.cellForRow(at: indexPath!)
            let zy = location.y - (cell?.frame.origin.y)!
            
            if indexPath?.row == 0 && indexPath?.section == 0 {
                
                let xw1 = IBAddImage.frame.origin.x + IBAddImage.frame.size.width
                let yh1 = IBAddImage.frame.origin.y + IBAddImage.frame.size.height
                if zx <= xw1 && zx >= IBAddImage.frame.origin.x && zy  <= yh1 && zy >= IBAddImage.frame.origin.y && client == false && config.level > 0 {
                    
                    actionAddImage()
                }
                else {
                    tableView.endEditing(true)
                }
            }
            else {
                tableView.endEditing(true)
            }
            
        }
        sender.cancelsTouchesInView = false
    }
    
    
    
    private func setUIEnabled(_ enabled: Bool) {
        
        
        IBNom.isEnabled = enabled
        IBPrix.isEnabled = enabled
        IBComment.isEnabled = enabled
       
        IBStar1.isEnabled = enabled
        IBStar2.isEnabled = enabled
        IBStar3.isEnabled = enabled
        IBStar4.isEnabled = enabled
        IBStar5.isEnabled = enabled
        IBEchangeChoice.isEnabled = enabled
        
        if aProduct == nil  {
            IBAddCreneau.isEnabled = false
        }
       
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
            IBAlert.isEnabled = true
            
            
        }
        else if segue.identifier == "detailtransaction" {
            
            let nav = segue.destination as! UINavigationController
            let controller = nav.topViewController as! DetailTransViewController
            controller.aTransaction = aTransaction
            IBTransact.isEnabled = true
            
        }
        else if segue.identifier == "listcreneau" {
            
            let nav = segue.destination as! UINavigationController
            let controller = nav.topViewController as! CreneauTableViewController
             controller.aProduct = aProduct
             controller.client = client
            
        }
        
    }
    
    
    private func actionAddImage() {
        
        guard UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) == true else {
            
            imageFromCamera(camera: false, type: nil)
            return
        }
        
        let alertController = UIAlertController(title: translate.message("takePicture"), message: translate.message("makeChoice"), preferredStyle: .alert)
        
        let actionBiblio = UIAlertAction(title: translate.message("library"), style: .destructive, handler: { (action) in
            MyTools.sharedInstance.performUIUpdatesOnMain {
                
                self.imageFromCamera(camera: false, type: nil)
                
            }
            
        })
        
        let actionCameraFront = UIAlertAction(title: translate.message("cameraFront"), style: .destructive, handler: { (action) in
            
            MyTools.sharedInstance.performUIUpdatesOnMain {
                
                self.imageFromCamera(camera: true, type: UIImagePickerControllerCameraDevice.front)
                
            }
        })
        
        let actionCameraRear = UIAlertAction(title: translate.message("cameraRear"), style: .destructive, handler: { (action) in
            
            MyTools.sharedInstance.performUIUpdatesOnMain {
                
                self.imageFromCamera(camera: true, type: UIImagePickerControllerCameraDevice.rear)
                
            }
        })
        
        let actionAnnuler = UIAlertAction(title: translate.message("cancel"), style: .destructive, handler: { (action) in
            
            
            //no action
            
        })
        
        alertController.addAction(actionBiblio)
        alertController.addAction(actionCameraFront)
        alertController.addAction(actionCameraRear)
        alertController.addAction(actionAnnuler)
        
        
        self.present(alertController, animated: true) {
            
        }
        
        
        
    }
    
    
    private func imageFromCamera(camera:Bool, type:UIImagePickerControllerCameraDevice?) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.modalPresentationStyle = UIModalPresentationStyle.currentContext;
        imagePicker.mediaTypes = [kUTTypeImage as String]
        
        if camera {
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.cameraDevice = type!
        }
        else {
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        }
        
        show(imagePicker, sender: self)
        
        
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
        
        isMajImage = true
        IBAddImage.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        IBAddImage.contentMode = .scaleAspectFit
        
        
        let maxSize : CGFloat = 1024.0
        let width : CGFloat = (IBAddImage.image?.size.width)!
        let height : CGFloat = (IBAddImage.image?.size.height)!
        var newWidth : CGFloat = width
        var newHeight : CGFloat = height
        
        // If any side exceeds the maximun size, reduce the greater side to 1200px and proportionately the other one
        if (width > maxSize || height > maxSize) {
            if (width > height) {
                newWidth = maxSize;
                newHeight = (height*maxSize)/width;
            } else {
                newHeight = maxSize;
                newWidth = (width*maxSize)/height;
            }
        }
        
        // Resize the image
        let newSize = CGSize.init(width: newWidth, height: newHeight)
        UIGraphicsBeginImageContext(newSize)
        IBAddImage.image?.draw(in: CGRect.init(origin: CGPoint.init(x: 0, y: 0), size: newSize))
        IBAddImage.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Set maximun compression in order to decrease file size and enable faster uploads & downloads
        let imageData = UIImageJPEGRepresentation(IBAddImage.image!, 0.0)!
        IBAddImage.image = UIImage(data: imageData)
        
        dismiss(animated: true, completion: nil)
    }
    
    
    //MARK: textfield Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.isEqual(IBNom) {
            IBPrix.becomeFirstResponder()
            
        }
        else if textField.isEqual(IBPrix) {
             IBComment.becomeFirstResponder()
            
        }
        
        
        textField.endEditing(true)
        
        return true
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField.isEqual(IBPrix) {
            
            var finalValue = textField.text!.replacingOccurrences(of: translate.message("devise"), with: "")
            finalValue = finalValue.replacingOccurrences(of: " ", with: "")
            if finalValue == "0.0" || finalValue == "0"  {
                finalValue = "0"
            }
            
            guard let prix = MyTools.sharedInstance.formatedAmount(finalValue) else {
                displayAlert(translate.message("error"), mess: translate.message("ErrorPrice"))
                return
            }
            
            
            if prix == 0 {
                IBEchangeChoice.isOn = true
            }
        
            textField.text = MyTools.sharedInstance.formatedAmount(prix)
            
            
        }
        
    }
    
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if textField.isEqual(IBNom) {
            fieldName = "IBNom"
        }
        else if textField.isEqual(IBPrix) {
            fieldName = "IBPrix"
            textField.text = textField.text?.replacingOccurrences(of: translate.message("devise"), with: "")
            textField.text = textField.text?.replacingOccurrences(of: " ", with: "")
            
        }
        else if textField.isEqual(IBComment) {
            fieldName = "IBComment"
        }
       
        
        return true
    }
    
    
    
    //MARK: Data Networking

    
    @IBAction func actionSubmit(_ sender: AnyObject) {
        
        guard IBNom.text != "" else {
            self.displayAlert(self.translate.message("error"), mess: translate.message("ErrorDescription"))
            return
        }
        
        guard IBPrix.text != "" else {
            self.displayAlert(self.translate.message("error"), mess: translate.message("ErrorPrice"))
            return
        }
        
        IBActivity.isHidden = false
        IBActivity.startAnimating()
        tableView.scrollToRow(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
        
        var priceValue = IBPrix.text!.replacingOccurrences(of: translate.message("devise"), with: "")
        priceValue = priceValue.replacingOccurrences(of:  " ", with: "")
        if (priceValue == "0.0" || priceValue == "0") && IBEchangeChoice.isOn == false  {
            IBEchangeChoice.isOn = true
        }
        
        
        func actionClient() {
            
            performSegue(withIdentifier: "seller", sender: self)
            
        }
        
        func actionUser() {
            
            
            IBSave.isEnabled = false
            
            var product = Product(dico: [String : AnyObject]())
            
            if aProduct != nil {
                product.prod_imageUrl = (aProduct?.prod_imageUrl)! == "" ? "xxxxxxx" : (aProduct?.prod_imageUrl)!
            }
            
            
            if (IBAddImage.image?.isEqual(#imageLiteral(resourceName: "noimage")))! {
                product.prod_imageUrl = ""
            }
            else {
                if isMajImage == true {
                    product.prodImageOld = product.prod_imageUrl
                    product.prod_imageUrl = "photo-\(config.user_id!)\(NSUUID().uuidString)"
                    product.prod_image = IBAddImage.image!
                }
                
            }
            
            var finalValue = IBPrix.text!.replacingOccurrences(of: translate.message("devise"), with: "")
            finalValue = finalValue.replacingOccurrences(of:  " ", with: "")
            if finalValue == "0.0" || finalValue == "0"  {
                finalValue = "0"
            }
            
            if aProduct != nil {
                product.prod_id = (aProduct?.prod_id)!
            }
            product.prod_prix = MyTools.sharedInstance.formatedAmount(finalValue)!
            product.prod_nom = IBNom.text!
            product.prod_by_user = config.user_id
            product.prod_comment = IBComment.text!
            product.prod_etat = star
            product.prod_hidden = false
            product.prod_closed = false
            product.prod_echange = IBEchangeChoice.isOn
            
            if aProduct != nil {
                
                //update product
                MDBProduct.sharedInstance.setUpdateProduct("Product", product) { (success, errorString) in
                    
                    if success {
                        
                        //Map :0, MyList:1, Historical:2
                        if self.typeListe == 1 {
                            MDBProduct.sharedInstance.getProductsByUser(self.config.user_id) { (success, productArray, errorString) in
                                
                                if success {
                                    
                                    Products.sharedInstance.productsUserArray = productArray
                                    
                                    MyTools.sharedInstance.performUIUpdatesOnMain {
                                        self.IBSave.isEnabled = true
                                        self.dismiss(animated: true, completion: nil)
                                    }
                                    
                                }
                                else {
                                    MyTools.sharedInstance.performUIUpdatesOnMain {
                                        self.IBActivity.isHidden = true
                                        self.IBActivity.stopAnimating()
                                        self.displayAlert(self.translate.message("error"), mess: errorString!)
                                    }
                                }
                            }
                            
                        }
                        else if self.typeListe == 0 {
                            MDBProduct.sharedInstance.getProductsByCoord(self.config.user_id, minLon: self.config.minLongitude, maxLon: self.config.maxLongitude , minLat: self.config.minLatitude, maxLat: self.config.maxLatitude) { (success, productArray, errorString) in
                                
                                if success {
                                    
                                    Products.sharedInstance.productsArray = productArray
                                    
                                    MyTools.sharedInstance.performUIUpdatesOnMain {
                                        self.IBSave.isEnabled = true
                                        self.dismiss(animated: true, completion: nil)
                                    }
                                    
                                }
                                else {
                                    MyTools.sharedInstance.performUIUpdatesOnMain {
                                        self.IBActivity.isHidden = true
                                        self.IBActivity.stopAnimating()
                                        self.displayAlert(self.translate.message("error"), mess: errorString!)
                                    }
                                }
                            }
                            
                        }
                        else if self.typeListe == 2 {
                            MDBProduct.sharedInstance.getProductsByTrader(self.config.user_id) { (success, productArray, errorString) in
                                
                                if success {
                                    
                                    Products.sharedInstance.productsTraderArray = productArray

                                    MyTools.sharedInstance.performUIUpdatesOnMain {
                                        self.IBSave.isEnabled = true
                                        self.dismiss(animated: true, completion: nil)
                                    }
                                    
                                }
                                else {
                                    MyTools.sharedInstance.performUIUpdatesOnMain {
                                        self.IBActivity.isHidden = true
                                        self.IBActivity.stopAnimating()
                                        self.displayAlert(self.translate.message("error"), mess: errorString!)
                                    }
                                }
                            }
                            
                        }
                        
                    }
                    else {
                        MyTools.sharedInstance.performUIUpdatesOnMain {
                            
                            MyTools.sharedInstance.performUIUpdatesOnMain {
                                self.IBSave.isEnabled = true
                                self.IBActivity.isHidden = true
                                self.IBActivity.stopAnimating()
                                self.displayAlert(self.translate.message("error"), mess: errorString!)
                            }
                        }
                    }
                    
                }
                
            }
            else {
                
                //add product
                MDBProduct.sharedInstance.setAddProduct(product) { (success, errorString) in
                    
                    if success {
                        
                        //Map :0, MyList:1, Historical:2
                        if self.typeListe == 1 {
                            MDBProduct.sharedInstance.getProductsByUser(self.config.user_id) { (success, productArray, errorString) in
                                
                                if success {
                                    
                                    Products.sharedInstance.productsUserArray = productArray
          
                                    MyTools.sharedInstance.performUIUpdatesOnMain {
                                        self.IBSave.isEnabled = true
                                        self.dismiss(animated: true, completion: nil)
                                    }
                                    
                                }
                                else {
                                    MyTools.sharedInstance.performUIUpdatesOnMain {
                                        self.IBActivity.isHidden = true
                                        self.IBActivity.stopAnimating()
                                        self.displayAlert(self.translate.message("error"), mess: errorString!)
                                    }
                                }
                            }
                            
                        }
                        else if self.typeListe == 0 {
                            MDBProduct.sharedInstance.getProductsByCoord(self.config.user_id, minLon: self.config.minLongitude, maxLon: self.config.maxLongitude , minLat: self.config.minLatitude, maxLat: self.config.maxLatitude) { (success, productArray, errorString) in
                                
                                if success {
                                    
                                    Products.sharedInstance.productsArray = productArray
              
                                    MyTools.sharedInstance.performUIUpdatesOnMain {
                                        self.IBSave.isEnabled = true
                                        self.dismiss(animated: true, completion: nil)
                                    }
                                    
                                }
                                else {
                                    MyTools.sharedInstance.performUIUpdatesOnMain {
                                        self.IBActivity.isHidden = true
                                        self.IBActivity.stopAnimating()
                                        self.displayAlert(self.translate.message("error"), mess: errorString!)
                                    }
                                }
                            }
                            
                        }
                        else if self.typeListe == 2 {
                            MDBProduct.sharedInstance.getProductsByTrader(self.config.user_id) { (success, productArray, errorString) in
                                
                                if success {
                                    
                                    Products.sharedInstance.productsTraderArray = productArray
               
                                    MyTools.sharedInstance.performUIUpdatesOnMain {
                                        self.IBSave.isEnabled = true
                                        self.dismiss(animated: true, completion: nil)
                                    }
                                    
                                }
                                else {
                                    MyTools.sharedInstance.performUIUpdatesOnMain {
                                        self.IBActivity.isHidden = true
                                        self.IBActivity.stopAnimating()
                                        self.displayAlert(self.translate.message("error"), mess: errorString!)
                                    }
                                }
                            }
                            
                        }
                        
                        
                        
                    }
                    else {
                        MyTools.sharedInstance.performUIUpdatesOnMain {
                            self.IBSave.isEnabled = true
                            self.IBActivity.isHidden = true
                            self.IBActivity.stopAnimating()
                            self.displayAlert(self.translate.message("error"), mess: errorString!)
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
    
    
    //MARK: Table View Controller data source
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if IBTransact != nil {
            
            IBTransact.frame = CGRect(origin: CGPoint.init(x: tableView.frame.size.width/2 - IBTransact.frame.size.width/2 , y: scrollView.contentOffset.y + tableView.frame.size.height - IBTransact.frame.size.height), size: IBTransact.frame.size)
            
            view.bringSubview(toFront: view.viewWithTag(999)!)
            view.bringSubview(toFront: IBTransact)
            
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //for selection
        
    }
    
    
    
    
    
    
}
