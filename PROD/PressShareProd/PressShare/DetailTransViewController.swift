//
//  DetailTransViewController.swift
//  PressShare
//
//  Description : List of transaction
//
//  Created by MacbookPRV on 06/12/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//


//Todo: aide DetailTransViewController ne fonctionne pas


import Foundation
import UIKit

class DetailTransViewController: UIViewController {
    
    @IBOutlet weak var IBNote: UILabel!
    @IBOutlet weak var IBStar1: UIButton!
    @IBOutlet weak var IBStar2: UIButton!
    @IBOutlet weak var IBStar3: UIButton!
    @IBOutlet weak var IBStar4: UIButton!
    @IBOutlet weak var IBStar5: UIButton!
    
    @IBOutlet weak var IBActivity: UIActivityIndicatorView!
    @IBOutlet weak var IBInfoContact: UILabel!
    @IBOutlet weak var IBClient: UILabel!
    @IBOutlet weak var IBWording: UILabel!
    @IBOutlet weak var IBAmount: UILabel!
    
    @IBOutlet weak var IBLabelConfirm: UILabel!
    @IBOutlet weak var IBLabelCancel: UILabel!
    
    @IBOutlet weak var IBLabelType: UILabel!
    
    @IBOutlet weak var IBButtonCancelr: UIBarButtonItem!
    @IBOutlet weak var IBEnded: UIBarButtonItem!
    
    @IBOutlet weak var IBisConfirm: UISwitch!
    @IBOutlet weak var IBisCancel: UISwitch!
    
    @IBOutlet weak var IBOtherText: UITextField!
    @IBOutlet weak var IBisOther: UISwitch!
    
    @IBOutlet weak var IBisMyAbsent: UISwitch!
    @IBOutlet weak var IBLabelMyAbsent: UILabel!
    @IBOutlet weak var IBisCompliant: UISwitch!
    @IBOutlet weak var IBCompliantLabel: UILabel!
    @IBOutlet weak var IBisInterlo: UISwitch!
    @IBOutlet weak var IBLabelInterlo: UILabel!
    
    
    var timerBadge : Timer!
    var star=0

    let config = Config.sharedInstance
    let translate = TranslateMessage.sharedInstance
    var aTransaction:Transaction?
    var fieldName = ""
    var keybordY:CGFloat! = 0
   
    
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
        

        
        star = (aTransaction?.trans_note)!
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

        
      IBisCancel.isOn = false
      IBisConfirm.isOn = false
        
        setUIHidden(true)
        
        
        //La transaction a été annulée
        if aTransaction?.trans_valid == 1 {
            IBisCancel.isOn = true
            actionCancel(self)
        
        }
        else if aTransaction?.trans_valid == 2  {
            //La transaction est confirmée
            IBisConfirm.isOn = true
            actionConfirm(self)
            
        }
        
        if aTransaction?.trans_avis == "interlocuteur" {
            IBisInterlo.isOn = true //l'interlocuteur était absent
            actionInterlo(self)
        }
        else if aTransaction?.trans_avis == "absence" {
            IBisMyAbsent.isOn = true //Je n'ai pu etre au rendez-vous
            actionMyAbsent(self)
        }
        else if aTransaction?.trans_avis == "conformite" {
            IBisCompliant.isOn = true //le produit vendu ou echangé n'était pas conforme à l'annonce
            actionCompliant(self)
        }
        else {
            IBisOther.isOn = true
            IBOtherText.text = aTransaction?.trans_avis
            actionOther(self)
        }
        
        
        
        IBWording.text = "\(translate.message("wording")) \(aTransaction!.trans_wording)"
        IBAmount.text = "\(translate.message("amount")) \(BlackBox.sharedInstance.formatedAmount(aTransaction!.trans_amount))"
        
        
  
        if aTransaction?.trans_type == 1 {
            IBLabelType.text = "\(IBLabelType.text!) \(translate.message("buy"))"
        }
        else if aTransaction?.trans_type == 2 {
            IBLabelType.text = "\(IBLabelType.text!) \(translate.message("exchange"))"
            
        }
        
        
        if (aTransaction?.trans_valid == 1 || aTransaction?.trans_valid == 2 || (aTransaction?.trans_type == 1 && aTransaction?.vendeur_id == aTransaction?.proprietaire))  {
            
            IBEnded.isEnabled = false
            IBisOther.isEnabled = false
            IBisMyAbsent.isEnabled = false
            IBisCompliant.isEnabled = false
            IBisInterlo.isEnabled = false
            IBisConfirm.isEnabled = false
            IBisCancel.isEnabled = false
            
        }
        else {
            IBEnded.isEnabled = true
        }
        
        
        IBActivity.isHidden = false
        IBActivity.startAnimating()
        
        let paramId = (aTransaction?.client_id == aTransaction?.proprietaire) ? aTransaction?.vendeur_id : aTransaction?.client_id
        
        
        MDBUser.sharedInstance.getUser(paramId!, completionHandlerUser: {(success, usersArray, errorString) in
            
            if success {
                
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    
                    if (usersArray?.count)! > 0 {
                        for userDico in usersArray! {
                            self.IBClient.text = (self.aTransaction?.client_id == self.aTransaction?.proprietaire) ? self.translate.message("seller"): self.translate.message("customer")
                            self.IBClient.text = "\(self.IBClient.text!) \(userDico["user_nom"]!) \(userDico["user_prenom"]!) (\(paramId!))"
                            self.IBInfoContact.text = "\(self.IBInfoContact.text!) \(userDico["user_ville"]!), \(userDico["user_pays"]!))"
                            
                            break
                            
                        }
                    }
                    
                    self.IBActivity.stopAnimating()
                    self.IBActivity.isHidden = true
                    
                }
            }
            else {
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    self.IBActivity.stopAnimating()
                    self.IBActivity.isHidden = true
                    self.displayAlert(self.translate.message("error"), mess: errorString!)
                }
            }
            
            
        })
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        view.backgroundColor =  UIColor.init(hexString: config.colorApp)
        
        subscibeToKeyboardNotifications()
        
        IBButtonCancelr.title = translate.message("cancel")
        IBEnded.title = translate.message("done")
        IBLabelConfirm.text = translate.message("confirm")
        IBLabelCancel.text = translate.message("cancel")
        IBCompliantLabel.text = translate.message("compliant")
        IBLabelMyAbsent.text = translate.message("myAbsence")
        IBOtherText.placeholder = translate.message("other")
        IBNote.text = translate.message("transactNote")
        navigationItem.title = translate.message("validerTransact")
         
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        timerBadge = Timer.scheduledTimer(timeInterval: config.dureeTimer, target: self, selector: #selector(routineTimer), userInfo: nil, repeats: true)
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        config.isTimer = false
        timerBadge.invalidate()
        timerBadge = nil
        
    }

    
    @objc private func routineTimer() {
        
        if config.isTimer == false {
            
            BlackBox.sharedInstance.checkBadge(completionHdlerBadge: { (success, result) in
                
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
        BlackBox.sharedInstance.showHelp("DetailTransViewController", self)
        
    }
    
    
    @IBAction func actionButtonCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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
    

    
    //MARK: textfield Delegate
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard fieldName != "" && keybordY > 0 else {
            return
        }
        
        let location = (event?.allTouches?.first?.location(in: self.view).y)! as CGFloat
        if (Double(location) < Double(keybordY)) {
            
            var textField = UITextField()
            
            
            if fieldName == "IBOtherText" {
                textField = IBOtherText
            }
            
            textField.endEditing(true)
            
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField.isEqual(IBOtherText) {
            fieldName = "IBOtherText"
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
        
        
        if fieldName == "IBOtherText" {
            textField = IBOtherText
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
        
        
        if fieldName == "IBOtherText" {
            textField = IBOtherText
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
    
    //MARK: Data Transaction
    
    @IBAction func actionEnded(_ sender: Any) {
        
        func tradeConfirmTransact() {
            
            var message = Message(dico: [String : AnyObject]())
            
            message.expediteur = config.user_id
            message.destinataire = aTransaction!.vendeur_id
            message.proprietaire = config.user_id
            message.client_id =  aTransaction!.client_id
            message.vendeur_id = aTransaction!.vendeur_id
            message.product_id = aTransaction!.prod_id
            
            message.contenu = "\(translate.message("emailSender")) \(config.user_nom!) \(config.user_prenom!) \n \(translate.message("theProduct")) \(aTransaction!.trans_wording) \(translate.message("buyConfirmed"))"
            
            MDBMessage.sharedInstance.setAddMessage(message, completionHandlerMessages: { (success, errorString) in
                
                if success {
                    
                    MDBMessage.sharedInstance.setPushNotification(message, completionHandlerPush: { (success, errorString) in
                        
                        if success {
                            
                            //ok
                        }
                        else {
                            
                            BlackBox.sharedInstance.performUIUpdatesOnMain {
                                self.displayAlert(self.translate.message("error"), mess: errorString!)
                            }
                        }
                    })
                    
                    
                    
                }
                else {
                    BlackBox.sharedInstance.performUIUpdatesOnMain {
                        self.displayAlert(self.translate.message("error"), mess: errorString!)
                    }
                }
                
            })
            
            
            var product = Product(dico: [String : AnyObject]())
            product.prod_id = (self.aTransaction?.prod_id)!
            product.prod_hidden = true
            product.prod_oth_user = (self.aTransaction?.proprietaire)!
            product.prod_closed = true
            
            MDBProduct.sharedInstance.setUpdateProduct("ProductTrans", product) { (success, errorString) in
                
                if success {
                    
                    //Menu Carte
                    MDBProduct.sharedInstance.getProductsByCoord(self.config.user_id, minLon: self.config.minLongitude, maxLon: self.config.maxLongitude , minLat: self.config.minLatitude, maxLat: self.config.maxLatitude) { (success, productArray, errorString) in
                        
                        if success {
                            
                            Products.sharedInstance.productsArray = productArray
                            
                        }
                        else {
                            BlackBox.sharedInstance.performUIUpdatesOnMain {
                                self.displayAlert(self.translate.message("error"), mess: errorString!)
                            }
                        }
                    }
                    
                    //Menu Historique
                    MDBProduct.sharedInstance.getProductsByTrader(self.config.user_id) { (success, productArray, errorString) in
                        
                        if success {
                            
                            Products.sharedInstance.productsTraderArray = productArray
                        }
                        else {
                            BlackBox.sharedInstance.performUIUpdatesOnMain {
                                self.displayAlert(self.translate.message("error"), mess: errorString!)
                            }
                        }
                        
                    }
                    
                    //Menu MaListe
                    MDBProduct.sharedInstance.getProductsByUser(self.config.user_id) { (success, productArray, errorString) in
                        
                        if success {
                            
                            Products.sharedInstance.productsUserArray = productArray
                            
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
                        
                        self.displayAlert(self.translate.message("error"), mess: errorString!)
                    }
                }
                
            }
            
            
            config.balance = config.balance - Double(aTransaction!.trans_amount)
            config.balance = config.balance - config.commisPourcBuy * Double(aTransaction!.trans_amount)
            var capital = Capital(dico: [String : AnyObject]())
            var operation = PressOperation(dico: [String : AnyObject]())
            
            //Acheteur confirme la transaction commerciale
            
            capital.balance = config.balance
            capital.user_id = aTransaction!.proprietaire
            capital.failure_count = config.failure_count
            
            MDBCapital.sharedInstance.setUpdateCapital(capital, completionHandlerUpdate: { (success, errorString) in
                
                if success {
                    
                    var commission = Commission(dico: [String : AnyObject]())
                    
                    commission.user_id = self.aTransaction!.proprietaire
                    commission.product_id = self.aTransaction!.prod_id
                    commission.com_amount = self.config.commisPourcBuy * Double(self.aTransaction!.trans_amount)
                    
                    //Création d'une commission d'achat pour le client
                    MDBCommission.sharedInstance.setAddCommission(commission, self.config.balance, completionHandlerCommission: { (success, errorString) in
                        
                        if success {
                            
                            //OK
                        }
                        else {
                            BlackBox.sharedInstance.performUIUpdatesOnMain {
                                
                                self.displayAlert(self.translate.message("error"), mess: errorString!)
                            }
                        }
                        
                        
                        
                    })
                    
                    operation.user_id = self.aTransaction!.proprietaire
                    operation.op_type = 3 //c'est une operation d'achat de produit
                    operation.op_amount = -1 * Double(self.aTransaction!.trans_amount)
                    operation.op_wording = "\(self.translate.message("buy")) \(self.translate.message("product"))"
                    
                    //Création d'un operation d'achat pour le client
                    MDBPressOperation.sharedInstance.setAddOperation(operation, completionHandlerAddOp: {(success, errorString) in
                        
                        if success {
                            
                            MDBPressOperation.sharedInstance.getAllOperations(self.config.user_id, completionHandlerOperations: {(success, operationArray, errorString) in
                                
                                if success {
                                    
                                    PressOperations.sharedInstance.operationArray = operationArray
                                }
                                else {
                                    
                                    BlackBox.sharedInstance.performUIUpdatesOnMain {
                                        self.displayAlert(self.translate.message("error"), mess: errorString!)
                                    }
                                }
                                
                            })
                            
                            //Le compte du vendeur est consulté
                            MDBCapital.sharedInstance.getCapital(self.aTransaction!.vendeur_id, completionHandlerCapital: {(success, capitalArray, errorString) in
                                
                                if success {
                                    
                                    
                                    for dictionary in capitalArray!{
                                        let cap = Capital(dico: dictionary)
                                        capital.balance = cap.balance + Double(self.aTransaction!.trans_amount)
                                        capital.balance = capital.balance - self.config.commisPourcBuy * Double(self.aTransaction!.trans_amount)
                                        capital.user_id = cap.user_id
                                        capital.failure_count = cap.failure_count
                                    }
                                    
                                    //Le compte du vendeur est crédité
                                    MDBCapital.sharedInstance.setUpdateCapital(capital, completionHandlerUpdate: { (success, errorString) in
                                        
                                        if success {
                                            
                                            var commission = Commission(dico: [String : AnyObject]())
                                            
                                            commission.user_id = self.aTransaction!.vendeur_id
                                            commission.product_id = self.aTransaction!.prod_id
                                            commission.com_amount = self.config.commisPourcBuy * Double(self.aTransaction!.trans_amount)
                                            
                                            //Création d'une commission d'achat pour le client
                                            MDBCommission.sharedInstance.setAddCommission(commission, capital.balance,  completionHandlerCommission: { (success, errorString) in
                                                
                                                if success {
                                                    
                                                    //OK
                                                }
                                                else {
                                                    BlackBox.sharedInstance.performUIUpdatesOnMain {
                                                        
                                                        self.displayAlert(self.translate.message("error"), mess: errorString!)
                                                    }
                                                }
                                                
                                                
                                                
                                            })
                                            
                                            operation.user_id = self.aTransaction!.vendeur_id
                                            operation.op_type = 4 //C'est une opération de vente de produit
                                            operation.op_amount = Double(self.aTransaction!.trans_amount)
                                            operation.op_wording = "\(self.translate.message("sell")) \(self.translate.message("product"))"
                                            
                                            //Création d'un operation de vente pour le vendeur
                                            MDBPressOperation.sharedInstance.setAddOperation(operation, completionHandlerAddOp: {(success, errorString) in
                                                
                                                if success {
                                                    
                                                    MDBPressOperation.sharedInstance.getAllOperations(self.config.user_id, completionHandlerOperations: {(success, operationArray, errorString) in
                                                        
                                                        if success {
                                                            
                                                            PressOperations.sharedInstance.operationArray = operationArray
                                                        }
                                                        else {
                                                            
                                                            BlackBox.sharedInstance.performUIUpdatesOnMain {
                                                                self.displayAlert(self.translate.message("error"), mess: errorString!)
                                                            }
                                                        }
                                                        
                                                    })
                        
                                                    BlackBox.sharedInstance.performUIUpdatesOnMain {
                                                        self.IBActivity.stopAnimating()
                                                        self.dismiss(animated: true, completion: nil)
                                                    }
                                                    
                                                }
                                                else {
                                                    BlackBox.sharedInstance.performUIUpdatesOnMain {
                                                        
                                                        self.displayAlert(self.translate.message("error"), mess: errorString!)
                                                    }
                                                }
                                                
                                                
                                            })
                                            
                                            
                                            
                                        }
                                        else {
                                            BlackBox.sharedInstance.performUIUpdatesOnMain {
                                                
                                                self.displayAlert(self.translate.message("error"), mess: errorString!)
                                            }
                                        }
                                        
                                        
                                    })
                                    
                                    
                                    
                                }
                                else {
                                    
                                    BlackBox.sharedInstance.performUIUpdatesOnMain {
                                        self.IBActivity.stopAnimating()
                                        self.displayAlert(self.translate.message("error"), mess: errorString!)
                                    }
                                }
                                
                                
                            })
                            
                            
                        }
                        else {
                            BlackBox.sharedInstance.performUIUpdatesOnMain {
                                
                                self.displayAlert(self.translate.message("error"), mess: errorString!)
                            }
                        }
                        
                        
                    })
                    
                    
                    
                }
                else {
                    BlackBox.sharedInstance.performUIUpdatesOnMain {
                        
                        self.displayAlert(self.translate.message("error"), mess: errorString!)
                    }
                }
                
                
            })
            
        }
        
        func tradeCancelTransact() {
            
            
            var message = Message(dico: [String : AnyObject]())
            
            message.expediteur = config.user_id
            message.destinataire = aTransaction!.vendeur_id
            message.proprietaire = config.user_id
            message.client_id =  aTransaction!.client_id
            message.vendeur_id = aTransaction!.vendeur_id
            message.product_id = aTransaction!.prod_id
            
            message.contenu = "\(translate.message("emailSender")) \(config.user_nom!) \(config.user_prenom!) \n \(translate.message("theProduct")) \(aTransaction!.trans_wording) \(translate.message("buyCanceled"))"
            
            MDBMessage.sharedInstance.setAddMessage(message, completionHandlerMessages: { (success, errorString) in
                
                if success {
                    
                    MDBMessage.sharedInstance.setPushNotification(message, completionHandlerPush: { (success, errorString) in
                        
                        if success {
                            
                            //ok
                        }
                        else {
                            
                            BlackBox.sharedInstance.performUIUpdatesOnMain {
                                self.displayAlert(self.translate.message("error"), mess: errorString!)
                            }
                        }
                    })
                    
                    
                    
                }
                else {
                    BlackBox.sharedInstance.performUIUpdatesOnMain {
                        self.displayAlert(self.translate.message("error"), mess: errorString!)
                    }
                }
                
            })
            
            
            
            config.failure_count = config.failure_count + 1
            
            var capital = Capital(dico: [String : AnyObject]())
            
            //Acheteur annule
            
            capital.balance = config.balance
            capital.user_id = aTransaction!.proprietaire
            capital.failure_count = config.failure_count
            
            MDBCapital.sharedInstance.setUpdateCapital(capital, completionHandlerUpdate: { (success, errorString) in
                
                if success {
                    
       
                    var product = Product(dico: [String : AnyObject]())
                    product.prod_id = (self.aTransaction?.prod_id)!
                    product.prod_hidden = false
                    product.prod_oth_user = 0
                    product.prod_closed = false
                    
                    MDBProduct.sharedInstance.setUpdateProduct("ProductTrans", product) { (success, errorString) in
                        
                        if success {
                            
                            //Menu Carte
                            MDBProduct.sharedInstance.getProductsByCoord(self.config.user_id, minLon: self.config.minLongitude, maxLon: self.config.maxLongitude , minLat: self.config.minLatitude, maxLat: self.config.maxLatitude) { (success, productArray, errorString) in
                                
                                if success {
                                    
                                    Products.sharedInstance.productsArray = productArray
                                    
                                }
                                else {
                                    BlackBox.sharedInstance.performUIUpdatesOnMain {
                                        self.displayAlert(self.translate.message("error"), mess: errorString!)
                                    }
                                }
                            }
                            
                            //Menu Historique
                            MDBProduct.sharedInstance.getProductsByTrader(self.config.user_id) { (success, productArray, errorString) in
                                
                                if success {
                                    
                                    Products.sharedInstance.productsTraderArray = productArray
                                }
                                else {
                                    BlackBox.sharedInstance.performUIUpdatesOnMain {
                                        self.displayAlert(self.translate.message("error"), mess: errorString!)
                                    }
                                }
                                
                            }
                            
                            //Menu MaListe
                            MDBProduct.sharedInstance.getProductsByUser(self.config.user_id) { (success, productArray, errorString) in
                                
                                if success {
                                    
                                    Products.sharedInstance.productsUserArray = productArray
                                    
                                    BlackBox.sharedInstance.performUIUpdatesOnMain {
                                        self.IBActivity.stopAnimating()
                                        self.dismiss(animated: true, completion: nil)
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
                                
                                self.displayAlert(self.translate.message("error"), mess: errorString!)
                            }
                        }
                        
                    }
                
                }
                else {
                    BlackBox.sharedInstance.performUIUpdatesOnMain {
                        
                        self.displayAlert(self.translate.message("error"), mess: errorString!)
                    }
                }
                
            })
            
            
        }
        
        func exchangeConfirmTransact() {
            
            var message = Message(dico: [String : AnyObject]())
            
            message.expediteur = config.user_id
            if aTransaction?.proprietaire == aTransaction?.client_id {
                message.destinataire = aTransaction!.vendeur_id
                
            }
            else if aTransaction?.proprietaire == aTransaction?.vendeur_id {
                message.destinataire = aTransaction!.client_id
            }
            
            message.proprietaire = config.user_id
            message.client_id = aTransaction!.client_id
            message.vendeur_id = aTransaction!.vendeur_id
            message.product_id = aTransaction!.prod_id
            
            message.contenu = "\(translate.message("emailSender")) \(config.user_nom!) \(config.user_prenom!) \n \(translate.message("theProduct")) \(aTransaction!.trans_wording) \(translate.message("exchangeConfirmed"))"
            
            MDBMessage.sharedInstance.setAddMessage(message, completionHandlerMessages: { (success, errorString) in
                
                if success {
                    
                    MDBMessage.sharedInstance.setPushNotification(message, completionHandlerPush: { (success, errorString) in
                        
                        if success {
                            
                            //ok
                        }
                        else {
                            
                            BlackBox.sharedInstance.performUIUpdatesOnMain {
                                self.displayAlert(self.translate.message("error"), mess: errorString!)
                            }
                        }
                    })
                    
                    
                    
                }
                else {
                    BlackBox.sharedInstance.performUIUpdatesOnMain {
                        self.displayAlert(self.translate.message("error"), mess: errorString!)
                    }
                }
                
            })
            
            
            var commission = Commission(dico: [String : AnyObject]())
            //l'utilisateur confirme l'echange
            config.balance = config.balance - config.commisFixEx
            
            
            commission.user_id = aTransaction!.proprietaire
            commission.product_id = aTransaction!.prod_id
            commission.com_amount = config.commisFixEx
            
            //Création d'une commission d'achat pour le client
            MDBCommission.sharedInstance.setAddCommission(commission, config.balance, completionHandlerCommission: { (success, errorString) in
                
                if success {
                    
                    BlackBox.sharedInstance.performUIUpdatesOnMain {
                        self.IBActivity.stopAnimating()
                        self.dismiss(animated: true, completion: nil)
                    }
                }
                else {
                    BlackBox.sharedInstance.performUIUpdatesOnMain {
                        
                        self.displayAlert(self.translate.message("error"), mess: errorString!)
                    }
                }
                
                
                
            })
            
        }
        
        func exchangeCancelTransact() {
            
            var message = Message(dico: [String : AnyObject]())
            
            message.expediteur = config.user_id
            if aTransaction?.proprietaire == aTransaction?.client_id {
                message.destinataire = aTransaction!.vendeur_id
                
            }
            else if aTransaction?.proprietaire == aTransaction?.vendeur_id {
                message.destinataire = aTransaction!.client_id
            }
            
            message.proprietaire = config.user_id
            message.client_id = aTransaction!.client_id
            message.vendeur_id = aTransaction!.vendeur_id
            message.product_id = aTransaction!.prod_id
            
            message.contenu = "\(translate.message("emailSender")) \(config.user_nom!) \(config.user_prenom!) \n \(translate.message("theProduct")) \(aTransaction!.trans_wording) \(translate.message("exchangeCanceled"))"
            
            MDBMessage.sharedInstance.setAddMessage(message, completionHandlerMessages: { (success, errorString) in
                
                if success {
                    
                    MDBMessage.sharedInstance.setPushNotification(message, completionHandlerPush: { (success, errorString) in
                        
                        if success {
                            
                            //ok
                        }
                        else {
                            
                            BlackBox.sharedInstance.performUIUpdatesOnMain {
                                self.displayAlert(self.translate.message("error"), mess: errorString!)
                            }
                        }
                    })
                    
                    
                    
                }
                else {
                    BlackBox.sharedInstance.performUIUpdatesOnMain {
                        self.displayAlert(self.translate.message("error"), mess: errorString!)
                    }
                }
                
            })
            
            
            config.failure_count = config.failure_count + 1
            
            var capital = Capital(dico: [String : AnyObject]())
            
            //Acheteur annule
            
            capital.balance = config.balance
            capital.user_id = aTransaction!.proprietaire
            capital.failure_count = config.failure_count
            
            MDBCapital.sharedInstance.setUpdateCapital(capital, completionHandlerUpdate: { (success, errorString) in
                
                if success {
           
                    var product = Product(dico: [String : AnyObject]())
                    product.prod_id = (self.aTransaction?.prod_id)!
                    product.prod_hidden = false
                    product.prod_oth_user = 0
                    product.prod_closed = false
                    
                    MDBProduct.sharedInstance.setUpdateProduct("ProductTrans", product) { (success, errorString) in
                        
                        if success {
                            
                            //Menu Carte
                            MDBProduct.sharedInstance.getProductsByCoord(self.config.user_id, minLon: self.config.minLongitude, maxLon: self.config.maxLongitude , minLat: self.config.minLatitude, maxLat: self.config.maxLatitude) { (success, productArray, errorString) in
                                
                                if success {
                                    
                                    Products.sharedInstance.productsArray = productArray
                                  
                                }
                                else {
                                    BlackBox.sharedInstance.performUIUpdatesOnMain {
                                        self.displayAlert(self.translate.message("error"), mess: errorString!)
                                    }
                                }
                            }
                            
                            //Menu Historique
                            MDBProduct.sharedInstance.getProductsByTrader(self.config.user_id) { (success, productArray, errorString) in
                                
                                if success {
                                    
                                    Products.sharedInstance.productsTraderArray = productArray
                                }
                                else {
                                    BlackBox.sharedInstance.performUIUpdatesOnMain {
                                        self.displayAlert(self.translate.message("error"), mess: errorString!)
                                    }
                                }
                                
                            }
                            
                            //Menu MaListe
                            MDBProduct.sharedInstance.getProductsByUser(self.config.user_id) { (success, productArray, errorString) in
                                
                                if success {
                                    
                                    Products.sharedInstance.productsUserArray = productArray
                                  
                                    BlackBox.sharedInstance.performUIUpdatesOnMain {
                                        self.IBActivity.stopAnimating()
                                        self.dismiss(animated: true, completion: nil)
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
                                
                                self.displayAlert(self.translate.message("error"), mess: errorString!)
                            }
                        }
                        
                    }
                    
                }
                else {
                    BlackBox.sharedInstance.performUIUpdatesOnMain {
                        
                        self.displayAlert(self.translate.message("error"), mess: errorString!)
                    }
                }
                
            })
            
        }
        
        
        guard IBisConfirm.isOn || IBisCancel.isOn else {
            displayAlert(translate.message("error"), mess: translate.message("errorAcceptReject"))
            return
        }
        
        if IBisConfirm.isOn == true {
            let minAmount = config.minimumAmount + (self.aTransaction?.trans_amount)!            
            guard self.config.balance >= minAmount else {
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    self.displayAlert(self.translate.message("error"), mess: self.translate.message("errorBalanceTrans"))
                }
                return
            }
            
        }
        
        let alertController = UIAlertController(title: "Transaction", message: translate.message("errorEndedTrans"), preferredStyle: .alert)
        
        let actionValider = UIAlertAction(title: translate.message("done"), style: .destructive, handler: { (action) in
            
            if self.IBisOther.isOn {
                self.aTransaction?.trans_avis = self.IBOtherText.text!
                
            }
            else if self.IBisInterlo.isOn {
                self.aTransaction?.trans_avis = "interlocuteur" //l'interlocuteur était absent
                
            }
            else if self.IBisCompliant.isOn {
                self.aTransaction?.trans_avis = "conformite" //le produit vendu ou echangé n'était pas conforme à l'annonce
                
            }
            else if self.IBisMyAbsent.isOn {
                self.aTransaction?.trans_avis = "absence" //Je n'ai pu etre au rendez-vous
                
            }
            
            
            if self.IBisCancel.isOn {
                
                self.aTransaction?.trans_valid = 1 //La transaction a été annulée
                
            }
            else if self.IBisConfirm.isOn {
                
                self.aTransaction?.trans_valid = 2 //La transaction est confirmée
                
            }
            
            self.aTransaction?.trans_note = self.star
            
            if self.star > 0 {
                
                self.config.user_countNote = self.config.user_countNote + 1
                
                self.config.user_note = (self.config.user_note + self.star) / self.config.user_countNote
                
                MDBUser.sharedInstance.setUpdUserStar(self.config, self.aTransaction!, completionHandlerUpdate: { (success, errorString) in
                    
                    if success {
                        
                      //Ok
                        
                    }
                    else {
                        BlackBox.sharedInstance.performUIUpdatesOnMain {
                            
                            self.IBActivity.stopAnimating()
                            self.displayAlert(self.translate.message("error"), mess: errorString!)
                        }
                    }
                    
                })
            }
            
            MDBTransact.sharedInstance.setUpdateTransaction(self.aTransaction!, completionHandlerUpdTrans: { (success, errorString) in
                
                if success {
                    
                    
                    MDBTransact.sharedInstance.getAllTransactions(self.config.user_id, completionHandlerTransactions: {(success, transactionArray, errorString) in
                        
                        
                        if success {
                            Transactions.sharedInstance.transactionArray = transactionArray
                        }
                        else {
                            
                            BlackBox.sharedInstance.performUIUpdatesOnMain {
                                self.displayAlert(self.translate.message("error"), mess: errorString!)
                            }
                        }
                        
                    })
                    
                    
                    self.config.trans_badge = self.config.trans_badge - 1
                    self.config.transaction_maj = true
            
                    
                    if self.aTransaction?.trans_type == 1 && self.aTransaction?.trans_valid == 2 && self.aTransaction?.client_id == self.aTransaction?.proprietaire {
                        //Cas où le client confirme la transaction commerciale. Alors son compte est debité produit + la commission
                        tradeConfirmTransact()
                        
                    }
                    else if self.aTransaction?.trans_type == 1 && self.aTransaction?.trans_valid == 1 && self.aTransaction?.client_id == self.aTransaction?.proprietaire   {
                        //Cas où le client annule la transaction commerciale. alors son compte n'est pas debité et le compteur rejet est incrémenté
                        tradeCancelTransact()
                        
                    }
                    else if self.aTransaction?.trans_type == 2 && self.aTransaction?.trans_valid == 2 {
                        //Cas où l'utilisateur confirme la transaction d'echange. Alors son compte est debité de la commission
                        exchangeConfirmTransact()
                        
                        
                    }
                    else if self.aTransaction?.trans_type == 2 && self.aTransaction?.trans_valid == 1 {
                        //Cas où l'utilisateur annule la transaction d'echange. alors son compte n'est pas debité et le compteur rejet est incrémenté
                        exchangeCancelTransact()
                        
                    }
                    
                    
                }
                else {
                    
                    BlackBox.sharedInstance.performUIUpdatesOnMain {
                        
                        self.IBActivity.stopAnimating()
                        self.displayAlert(self.translate.message("error"), mess: errorString!)
                    }
                }
                
            })
            
            
            
            
        })
        
        let actionCancel = UIAlertAction(title: translate.message("cancel"), style: .destructive, handler: { (action) in
            
        })
        
        alertController.addAction(actionCancel)
        alertController.addAction(actionValider)
        
        
        present(alertController, animated: true) {
            
        }
        
        
    }
    
    
    //MARK: Bouton Switch
    
    @IBAction func actionConfirm(_ sender: Any) {
        //confirmer la transaction
        IBisConfirm.isOn = true
        IBisCancel.isOn = (IBisConfirm.isOn == true) ? false : true
        setUIHidden(!IBisCancel.isOn)
    }
    
    @IBAction func actionCancel(_ sender: Any) {
        //annuler la transaction
        IBisCancel.isOn = true
        IBisConfirm.isOn = (IBisCancel.isOn == true) ? false : true
        setUIHidden(!IBisCancel.isOn)
        
    }
    
    @IBAction func actionOther(_ sender: Any) {
        //Autre cause d'annulation de la transaction
        IBisOther.isOn = true
        IBisInterlo.isOn = (IBisOther.isOn == true) ? false : true
        IBisMyAbsent.isOn = (IBisOther.isOn == true) ? false : true
        IBisCompliant.isOn = (IBisOther.isOn == true) ? false : true
        
        IBOtherText.isEnabled = IBisOther.isOn
        
    }
    
    @IBAction func actionCompliant(_ sender: Any) {
        //Cause d'annulation : produit non conforme
        IBisCompliant.isOn = true
        IBisInterlo.isOn = (IBisCompliant.isOn == true) ? false : true
        IBisMyAbsent.isOn = (IBisCompliant.isOn == true) ? false : true
        IBisOther.isOn = (IBisCompliant.isOn == true) ? false : true
        
        IBOtherText.isEnabled = IBisOther.isOn
        
    }
    
    @IBAction func actionMyAbsent(_ sender: Any) {
        //Cause d'annulation : je suis absent
        IBisMyAbsent.isOn = true
        IBisInterlo.isOn = (IBisMyAbsent.isOn == true) ? false : true
        IBisCompliant.isOn = (IBisMyAbsent.isOn == true) ? false : true
        IBisOther.isOn = (IBisMyAbsent.isOn == true) ? false : true
        
        IBOtherText.isEnabled = IBisOther.isOn
        
    }
    
    @IBAction func actionInterlo(_ sender: Any) {
        //Cause d'annulation : mon interlocuteur est absent
        IBisInterlo.isOn = true
        IBisMyAbsent.isOn = (IBisInterlo.isOn == true) ? false : true
        IBisCompliant.isOn = (IBisInterlo.isOn == true) ? false : true
        IBisOther.isOn = (IBisInterlo.isOn == true) ? false : true
        
        IBOtherText.isEnabled = IBisOther.isOn
        
        
    }
    
    private func setUIHidden(_ hidden: Bool) {
        
        IBisOther.isHidden = hidden
        IBisInterlo.isHidden = hidden
        IBisCompliant.isHidden = hidden
        IBisMyAbsent.isHidden = hidden
        
        IBOtherText.isHidden = hidden
        IBOtherText.isEnabled = !hidden
        
        IBLabelInterlo.isHidden = hidden
        IBCompliantLabel.isHidden = hidden
        IBLabelMyAbsent.isHidden = hidden
        
        IBisOther.isOn = false
        IBisMyAbsent.isOn = false
        IBisCompliant.isOn = false
        IBisInterlo.isOn = false
        
        
        
    }
    
}
