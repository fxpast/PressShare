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
    
    @IBOutlet weak var IBConfirm: UISwitch!
    @IBOutlet weak var IBCancel: UISwitch!
    
    @IBOutlet weak var IBOtherText: UITextField!
    @IBOutlet weak var IBOther: UISwitch!
    
    @IBOutlet weak var IBMyAbsent: UISwitch!
    @IBOutlet weak var IBLabelMyAbsent: UILabel!
    @IBOutlet weak var IBCompliant: UISwitch!
    @IBOutlet weak var IBCompliantLabel: UILabel!
    @IBOutlet weak var IBInterlo: UISwitch!
    @IBOutlet weak var IBLabelInterlo: UILabel!
    
    
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
        

      IBCancel.isOn = false
      IBConfirm.isOn = false
        
        setUIHidden(true)
        
        
        //La transaction a été annulée
        if aTransaction?.trans_valid == 1 {
            IBCancel.isOn = true
            actionCancel(self)
        
        }
        else if aTransaction?.trans_valid == 2  {
            //La transaction est confirmée
            IBConfirm.isOn = true
            actionConfirm(self)
            
        }
        
        if aTransaction?.trans_avis == "interlocuteur" {
            IBInterlo.isOn = true //l'interlocuteur était absent
            actionInterlo(self)
        }
        else if aTransaction?.trans_avis == "absence" {
            IBMyAbsent.isOn = true //Je n'ai pu etre au rendez-vous
            actionMyAbsent(self)
        }
        else if aTransaction?.trans_avis == "conformite" {
            IBCompliant.isOn = true //le produit vendu ou echangé n'était pas conforme à l'annonce
            actionCompliant(self)
        }
        else {
            IBOther.isOn = true
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
            IBOther.isEnabled = false
            IBMyAbsent.isEnabled = false
            IBCompliant.isEnabled = false
            IBInterlo.isEnabled = false
            IBConfirm.isEnabled = false
            IBCancel.isEnabled = false
            
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
        
        subscibeToKeyboardNotifications()
        
        IBButtonCancelr.title = translate.message("cancel")
        IBEnded.title = translate.message("done")
        IBLabelConfirm.text = translate.message("confirm")
        IBLabelCancel.text = translate.message("cancel")
        IBCompliantLabel.text = translate.message("compliant")
        IBLabelMyAbsent.text = translate.message("myAbsence")
        IBOtherText.placeholder = translate.message("other")
        navigationItem.title = translate.message("validerTransact")
         
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
        
    }
    
    
    @IBAction func actionHelp(_ sender: Any) {
        
        //action info
        BlackBox.sharedInstance.showHelp("DetailTransViewController", self)
        
    }
    
    
    @IBAction func actionButtonCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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
            var operation = Operation(dico: [String : AnyObject]())
            
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
                    MDBOperation.sharedInstance.setAddOperation(operation, completionHandlerAddOp: {(success, errorString) in
                        
                        if success {
                            
                            MDBOperation.sharedInstance.getAllOperations(self.config.user_id, completionHandlerOperations: {(success, operationArray, errorString) in
                                
                                if success {
                                    
                                    Operations.sharedInstance.operationArray = operationArray
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
                                            MDBOperation.sharedInstance.setAddOperation(operation, completionHandlerAddOp: {(success, errorString) in
                                                
                                                if success {
                                                    
                                                    MDBOperation.sharedInstance.getAllOperations(self.config.user_id, completionHandlerOperations: {(success, operationArray, errorString) in
                                                        
                                                        if success {
                                                            
                                                            Operations.sharedInstance.operationArray = operationArray
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
        
        
        guard IBConfirm.isOn || IBCancel.isOn else {
            displayAlert(translate.message("error"), mess: translate.message("errorAcceptReject"))
            return
        }
        
        
        let alertController = UIAlertController(title: "Transaction", message: translate.message("errorEndedTrans"), preferredStyle: .alert)
        
        let actionValider = UIAlertAction(title: translate.message("done"), style: .destructive, handler: { (action) in
            
            if self.IBOther.isOn {
                self.aTransaction?.trans_avis = self.IBOtherText.text!
                
            }
            else if self.IBInterlo.isOn {
                self.aTransaction?.trans_avis = "interlocuteur" //l'interlocuteur était absent
                
            }
            else if self.IBCompliant.isOn {
                self.aTransaction?.trans_avis = "conformite" //le produit vendu ou echangé n'était pas conforme à l'annonce
                
            }
            else if self.IBMyAbsent.isOn {
                self.aTransaction?.trans_avis = "absence" //Je n'ai pu etre au rendez-vous
                
            }
            
            
            if self.IBCancel.isOn {
                
                self.aTransaction?.trans_valid = 1 //La transaction a été annulée
                
            }
            else if self.IBConfirm.isOn {
                
                self.aTransaction?.trans_valid = 2 //La transaction est confirmée
                
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
        IBConfirm.isOn = true
        IBCancel.isOn = (IBConfirm.isOn == true) ? false : true
        setUIHidden(!IBCancel.isOn)
    }
    
    @IBAction func actionCancel(_ sender: Any) {
        //annuler la transaction
        IBCancel.isOn = true
        IBConfirm.isOn = (IBCancel.isOn == true) ? false : true
        setUIHidden(!IBCancel.isOn)
        
    }
    
    @IBAction func actionOther(_ sender: Any) {
        //Autre cause d'annulation de la transaction
        IBOther.isOn = true
        IBInterlo.isOn = (IBOther.isOn == true) ? false : true
        IBMyAbsent.isOn = (IBOther.isOn == true) ? false : true
        IBCompliant.isOn = (IBOther.isOn == true) ? false : true
        
        IBOtherText.isEnabled = IBOther.isOn
        
    }
    
    @IBAction func actionCompliant(_ sender: Any) {
        //Cause d'annulation : produit non conforme
        IBCompliant.isOn = true
        IBInterlo.isOn = (IBCompliant.isOn == true) ? false : true
        IBMyAbsent.isOn = (IBCompliant.isOn == true) ? false : true
        IBOther.isOn = (IBCompliant.isOn == true) ? false : true
        
        IBOtherText.isEnabled = IBOther.isOn
        
    }
    
    @IBAction func actionMyAbsent(_ sender: Any) {
        //Cause d'annulation : je suis absent
        IBMyAbsent.isOn = true
        IBInterlo.isOn = (IBMyAbsent.isOn == true) ? false : true
        IBCompliant.isOn = (IBMyAbsent.isOn == true) ? false : true
        IBOther.isOn = (IBMyAbsent.isOn == true) ? false : true
        
        IBOtherText.isEnabled = IBOther.isOn
        
    }
    
    @IBAction func actionInterlo(_ sender: Any) {
        //Cause d'annulation : mon interlocuteur est absent
        IBInterlo.isOn = true
        IBMyAbsent.isOn = (IBInterlo.isOn == true) ? false : true
        IBCompliant.isOn = (IBInterlo.isOn == true) ? false : true
        IBOther.isOn = (IBInterlo.isOn == true) ? false : true
        
        IBOtherText.isEnabled = IBOther.isOn
        
        
    }
    
    private func setUIHidden(_ hidden: Bool) {
        
        IBOther.isHidden = hidden
        IBInterlo.isHidden = hidden
        IBCompliant.isHidden = hidden
        IBMyAbsent.isHidden = hidden
        
        IBOtherText.isHidden = hidden
        IBOtherText.isEnabled = !hidden
        
        IBLabelInterlo.isHidden = hidden
        IBCompliantLabel.isHidden = hidden
        IBLabelMyAbsent.isHidden = hidden
        
        IBOther.isOn = false
        IBMyAbsent.isOn = false
        IBCompliant.isOn = false
        IBInterlo.isOn = false
        
        
        
    }
    
}
