//
//  DetailTransViewController.swift
//  PressShare
//
//  Description : List of transaction
//
//  Created by MacbookPRV on 06/12/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//


// Todo: Faire un scripte php de traitement de fin de journée pour verifier et confirmer/infirmer les transaction en mode arbitrage humain

//Todo: Faire un scripte php de traitment de fin de journée pour : à partir de MAX JOUR le compteur de rejet est incrémenté pour celui qui n'a rien décidé sur sa transaction alors que l'autre l'a annulé.

//Todo: Faire un scripte php de traitment de fin de journée pour : à partir de MAX JOUR une commission de 5% est débité pour celui qui n'a rien décidé sur sa transaction alors que l'autre l'a confirmé.


//Todo: Si la transaction est annulé alors remettre le produit en ligne.
//Todo: detail option annuler non affiché en consultation

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
    let commissionPrice = 0.05  //5% of product price
    
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
        
        if (aTransaction?.trans_valide == 1 || aTransaction?.trans_valide == 2 )  {
          IBEnded.isEnabled = false
        }
        else if (aTransaction?.trans_type == 1 && aTransaction?.vendeur_id == aTransaction?.proprietaire)  {
            IBEnded.isEnabled = false
        }
        else {
            IBEnded.isEnabled = true
        }
        
        
        IBConfirm.isOn = false
        IBCancel.isOn = false
        
       
        
        //La transaction a été annulée
        if aTransaction?.trans_valide == 1 {
            IBCancel.isOn = true
        
        }
        else if aTransaction?.trans_valide == 2  {
            //La transaction est confirmée
            IBConfirm.isOn = true
            
        }
        
        if aTransaction?.trans_avis == "interlocuteur" {
            IBInterlo.isOn = true //l'interlocuteur était absent
        }
        else if aTransaction?.trans_avis == "absence" {
            IBMyAbsent.isOn = true //Je n'ai pu etre au rendez-vous
        }
        else if aTransaction?.trans_avis == "conformite" {
            IBCompliant.isOn = true //le produit vendu ou echangé n'était pas conforme à l'annonce
        }
        else {
            IBOther.isOn = true
            IBOtherText.text = aTransaction?.trans_avis
        }
        
        
        setUIHidden(true)
        
        
        IBWording.text = "\(translate.wording!) \(aTransaction!.trans_wording)"
        IBAmount.text = "\(translate.amount!) \(BlackBox.sharedInstance.formatedAmount(aTransaction!.trans_amount))"
        
        
  
        if aTransaction?.trans_type == 1 {
            IBLabelType.text = "\(IBLabelType.text!) \(translate.trade!)"
        }
        else if aTransaction?.trans_type == 2 {
            IBLabelType.text = "\(IBLabelType.text!) \(translate.exchange!)"
            
        }
        
        
        
        
        IBActivity.isHidden = false
        IBActivity.startAnimating()
        let paramId = (aTransaction?.client_id == aTransaction?.proprietaire) ? aTransaction?.vendeur_id : aTransaction?.client_id
        
        
        MDBUser.sharedInstance.getUser(paramId!, completionHandlerUser: {(success, usersArray, errorString) in
            
            if success {
                
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    
                    if (usersArray?.count)! > 0 {
                        for userDico in usersArray! {
                            self.IBClient.text = (self.aTransaction?.client_id == self.aTransaction?.proprietaire) ? self.translate.seller: self.translate.customer
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
                    self.displayAlert(self.translate.error, mess: errorString!)
                }
            }
            
            
        })
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        subscibeToKeyboardNotifications()
        
        IBButtonCancelr.title = translate.cancel
        IBEnded.title = translate.done
        IBLabelConfirm.text = translate.confirm
        IBLabelCancel.text = translate.cancel
        IBCompliantLabel.text = translate.compliant
        IBLabelMyAbsent.text = translate.myAbsence
        IBOtherText.placeholder = translate.other
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
        
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
            
            config.balance = config.balance - Double(aTransaction!.trans_amount)
            config.balance = config.balance - commissionPrice * Double(aTransaction!.trans_amount)
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
                    commission.com_amount = self.commissionPrice * Double(self.aTransaction!.trans_amount)
                    
                    //Création d'une commission d'achat pour le client
                    MDBCommission.sharedInstance.setAddCommission(commission, self.config.balance, completionHandlerCommission: { (success, errorString) in
                        
                        if success {
                            
                            //OK
                        }
                        else {
                            BlackBox.sharedInstance.performUIUpdatesOnMain {
                                
                                self.displayAlert(self.translate.error, mess: errorString!)
                            }
                        }
                        
                        
                        
                    })
                    
                    operation.user_id = self.aTransaction!.proprietaire
                    operation.op_type = 3 //c'est une operation d'achat de produit
                    operation.op_amount = -1 * Double(self.aTransaction!.trans_amount)
                    operation.op_wording = "\(self.translate.buy!) \(self.translate.product!)"
                    
                    //Création d'un operation d'achat pour le client
                    MDBOperation.sharedInstance.setAddOperation(operation, completionHandlerAddOp: {(success, errorString) in
                        
                        if success {
                            
                            Operations.sharedInstance.operationArray = nil
                            
                            
                            //Le compte du vendeur est consulté
                            MDBCapital.sharedInstance.getCapital(self.aTransaction!.vendeur_id, completionHandlerCapital: {(success, capitalArray, errorString) in
                                
                                if success {
                                    
                                    
                                    for dictionary in capitalArray!{
                                        let cap = Capital(dico: dictionary)
                                        capital.balance = cap.balance + Double(self.aTransaction!.trans_amount)
                                        capital.balance = capital.balance - self.commissionPrice * Double(self.aTransaction!.trans_amount)
                                        capital.user_id = cap.user_id
                                        capital.failure_count = cap.failure_count
                                    }
                                    
                                    //Le compte du vendeur est crédité
                                    MDBCapital.sharedInstance.setUpdateCapital(capital, completionHandlerUpdate: { (success, errorString) in
                                        
                                        if success {
                                            
                                            var commission = Commission(dico: [String : AnyObject]())
                                            
                                            commission.user_id = self.aTransaction!.vendeur_id
                                            commission.product_id = self.aTransaction!.prod_id
                                            commission.com_amount = self.commissionPrice * Double(self.aTransaction!.trans_amount)
                                            
                                            //Création d'une commission d'achat pour le client
                                            MDBCommission.sharedInstance.setAddCommission(commission, capital.balance,  completionHandlerCommission: { (success, errorString) in
                                                
                                                if success {
                                                    
                                                    //OK
                                                }
                                                else {
                                                    BlackBox.sharedInstance.performUIUpdatesOnMain {
                                                        
                                                        self.displayAlert(self.translate.error, mess: errorString!)
                                                    }
                                                }
                                                
                                                
                                                
                                            })
                                            
                                            operation.user_id = self.aTransaction!.vendeur_id
                                            operation.op_type = 4 //C'est une opération de vente de produit
                                            operation.op_amount = Double(self.aTransaction!.trans_amount)
                                            operation.op_wording = "\(self.translate.sell!) \(self.translate.product!)"
                                            
                                            //Création d'un operation de vente pour le vendeur
                                            MDBOperation.sharedInstance.setAddOperation(operation, completionHandlerAddOp: {(success, errorString) in
                                                
                                                if success {
                                                    
                                                    BlackBox.sharedInstance.performUIUpdatesOnMain {
                                                        self.IBActivity.stopAnimating()
                                                        self.dismiss(animated: true, completion: nil)
                                                    }
                                                    
                                                }
                                                else {
                                                    BlackBox.sharedInstance.performUIUpdatesOnMain {
                                                        
                                                        self.displayAlert(self.translate.error, mess: errorString!)
                                                    }
                                                }
                                                
                                                
                                            })
                                            
                                            
                                            
                                        }
                                        else {
                                            BlackBox.sharedInstance.performUIUpdatesOnMain {
                                                
                                                self.displayAlert(self.translate.error, mess: errorString!)
                                            }
                                        }
                                        
                                        
                                    })
                                    
                                    
                                    
                                }
                                else {
                                    
                                    BlackBox.sharedInstance.performUIUpdatesOnMain {
                                        self.IBActivity.stopAnimating()
                                        self.displayAlert(self.translate.error, mess: errorString!)
                                    }
                                }
                                
                                
                            })
                            
                            
                        }
                        else {
                            BlackBox.sharedInstance.performUIUpdatesOnMain {
                                
                                self.displayAlert(self.translate.error, mess: errorString!)
                            }
                        }
                        
                        
                    })
                    
                    
                    
                }
                else {
                    BlackBox.sharedInstance.performUIUpdatesOnMain {
                        
                        self.displayAlert(self.translate.error, mess: errorString!)
                    }
                }
                
                
            })
            
        }
        
        func tradeCancelTransact() {
            
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
                    
                    MDBProduct.sharedInstance.setUpdateProduct(product) { (success, errorString) in
                        
                        if success {
                            
                            BlackBox.sharedInstance.performUIUpdatesOnMain {
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
                        
                        self.displayAlert(self.translate.error, mess: errorString!)
                    }
                }
                
            })
            
            
        }
        
        func exchangeConfirmTransact() {
            
            var commission = Commission(dico: [String : AnyObject]())
            //l'utilisateur confirme l'echange
            config.balance = config.balance - commissionPrice
            
            
            commission.user_id = aTransaction!.proprietaire
            commission.product_id = aTransaction!.prod_id
            commission.com_amount = commissionPrice * Double(aTransaction!.trans_amount)
            
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
                        
                        self.displayAlert(self.translate.error, mess: errorString!)
                    }
                }
                
                
                
            })
            
        }
        
        func exchangeCancelTransact() {
            
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
                    
                    MDBProduct.sharedInstance.setUpdateProduct(product) { (success, errorString) in
                        
                        if success {
                            
                            BlackBox.sharedInstance.performUIUpdatesOnMain {
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
                        
                        self.displayAlert(self.translate.error, mess: errorString!)
                    }
                }
                
            })
            
        }
        
        
        guard IBConfirm.isOn || IBCancel.isOn else {
            displayAlert(translate.error, mess: translate.errorAcceptReject)
            return
        }
        
        
        let alertController = UIAlertController(title: "Transaction", message: translate.errorEndedTrans, preferredStyle: .alert)
        
        let actionValider = UIAlertAction(title: translate.done, style: .destructive, handler: { (action) in
            
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
                
                self.aTransaction?.trans_valide = 1 //La transaction a été annulée
                
            }
            else if self.IBConfirm.isOn {
                
                self.aTransaction?.trans_valide = 2 //La transaction est confirmée
                
            }
            
            if self.aTransaction?.trans_type == 2 && self.aTransaction?.trans_valide == 1 {
                //Transaction d'echange annulée
                self.aTransaction?.trans_arbitrage = true
            }
            else {
                self.aTransaction?.trans_arbitrage = false
            }
            
            
            MDBTransact.sharedInstance.setUpdateTransaction(self.aTransaction!, completionHandlerUpdTrans: { (success, errorString) in
                
                if success {
                    
                    self.config.trans_badge = self.config.trans_badge - 1
                    self.config.transaction_maj = true
            
                    
                    if self.aTransaction?.trans_type == 1 && self.aTransaction?.trans_valide == 2 && self.aTransaction?.client_id == self.aTransaction?.proprietaire {
                        //Cas où le client confirme la transaction commerciale. Alors son compte est debité produit + la commission
                        tradeConfirmTransact()
                        
                    }
                    else if self.aTransaction?.trans_type == 1 && self.aTransaction?.trans_valide == 1 && self.aTransaction?.client_id == self.aTransaction?.proprietaire   {
                        //Cas où le client annule la transaction commerciale. alors son compte n'est pas debité et le compteur rejet est incrémenté
                        tradeCancelTransact()
                        
                    }
                    else if self.aTransaction?.trans_type == 2 && self.aTransaction?.trans_valide == 2 {
                        //Cas où l'utilisateur confirme la transaction d'echange. Alors son compte est debité de la commission
                        exchangeConfirmTransact()
                        
                        
                    }
                    else if self.aTransaction?.trans_type == 2 && self.aTransaction?.trans_valide == 1 {
                        //Cas où l'utilisateur annule la transaction d'echange. alors son compte n'est pas debité et le compteur rejet est incrémenté
                        exchangeCancelTransact()
                        
                    }
                    
                    
                }
                else {
                    
                    BlackBox.sharedInstance.performUIUpdatesOnMain {
                        
                        self.IBActivity.stopAnimating()
                        self.displayAlert(self.translate.error, mess: errorString!)
                    }
                }
                
            })
            
            
            
            
        })
        
        let actionCancel = UIAlertAction(title: translate.cancel, style: .destructive, handler: { (action) in
            
        })
        
        alertController.addAction(actionCancel)
        alertController.addAction(actionValider)
        
        
        present(alertController, animated: true) {
            
        }
        
        
    }
    
    
    //MARK: Bouton Switch
    
    @IBAction func actionConfirm(_ sender: Any) {
        //confirmer la transaction
        IBCancel.isOn = (IBConfirm.isOn == true) ? false : true
        setUIHidden(!IBCancel.isOn)
    }
    
    @IBAction func actionCancel(_ sender: Any) {
        //annuler la transaction
        IBConfirm.isOn = (IBCancel.isOn == true) ? false : true
        setUIHidden(!IBCancel.isOn)
        
    }
    
    @IBAction func actionOther(_ sender: Any) {
        //Autre cause d'annulation de la transaction
        IBInterlo.isOn = (IBOther.isOn == true) ? false : true
        IBMyAbsent.isOn = (IBOther.isOn == true) ? false : true
        IBCompliant.isOn = (IBOther.isOn == true) ? false : true
        
        IBOtherText.isEnabled = IBOther.isOn
        
    }
    
    @IBAction func actionCompliant(_ sender: Any) {
        //Cause d'annulation : produit non conforme
        IBInterlo.isOn = (IBCompliant.isOn == true) ? false : true
        IBMyAbsent.isOn = (IBCompliant.isOn == true) ? false : true
        IBOther.isOn = (IBCompliant.isOn == true) ? false : true
        
        IBOtherText.isEnabled = IBOther.isOn
        
    }
    
    @IBAction func actionMyAbsent(_ sender: Any) {
        //Cause d'annulation : je suis absent
        IBInterlo.isOn = (IBMyAbsent.isOn == true) ? false : true
        IBCompliant.isOn = (IBMyAbsent.isOn == true) ? false : true
        IBOther.isOn = (IBMyAbsent.isOn == true) ? false : true
        
        IBOtherText.isEnabled = IBOther.isOn
        
    }
    
    @IBAction func actionInterlo(_ sender: Any) {
        //Cause d'annulation : mon interlocuteur est absent
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
        
        
        
    }
    
}
