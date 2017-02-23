//
//  CreateTransViewController.swift
//  PressShare
//
//  Description : Client selects un product and create un transaction between the owner and himself.
//
//  Created by MacbookPRV on 22/11/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//


import Foundation
import UIKit

class CreateTransViewController: UIViewController {
    
    @IBOutlet weak var IBInfoContact1: UILabel!
    @IBOutlet weak var IBInfoContact2: UILabel!
    @IBOutlet weak var IBInfoProduct: UILabel!
    @IBOutlet weak var IBTrade: UISwitch!
    @IBOutlet weak var IBExchange: UISwitch!
    @IBOutlet weak var IBCancel: UIBarButtonItem!
    @IBOutlet weak var IBValidate: UIBarButtonItem!
    @IBOutlet weak var IBLabelTrade: UILabel!
    @IBOutlet weak var IBLabelExchange: UILabel!
    
    var aProduct:Product?
    
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        IBLabelTrade.text = translate.message("buy")
        IBLabelExchange.text = translate.message("exchange")
        IBValidate.title = translate.message("done")
        
        if aProduct?.prod_echange == false {
            IBExchange.isOn = false
            IBExchange.isEnabled = false
        }
        else {
            IBExchange.isOn = false
            IBTrade.isOn = false
            
        }
        
        
        IBInfoProduct.text = "\(aProduct!.prod_nom), \(BlackBox.sharedInstance.formatedAmount((aProduct?.prod_prix)!))"
        
        MDBUser.sharedInstance.getUser((aProduct?.prod_by_user)!, completionHandlerUser: {(success, usersArray, errorString) in
            
            if success {
                
                
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    
                    if (usersArray?.count)! > 0 {
                        for userDico in usersArray! {
                            
                            self.IBInfoContact1.text = "\(userDico["user_nom"]!) \(userDico["user_prenom"]!)"
                            self.IBInfoContact2.text = "\(userDico["user_ville"]!), \(userDico["user_pays"]!)"
                            
                            break
                            
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
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if config.flgReturnToTab == true {
            dismiss(animated: false, completion: nil)
        }
        
    }
    
    @IBAction func actionExchange(_ sender: Any) {
        
        IBExchange.isOn = true
        IBTrade.isOn = (IBExchange.isOn) ? false : true
        
    }
    
    @IBAction func actionTrade(_ sender: Any) {
        
        IBTrade.isOn = true
        IBExchange.isOn = (IBTrade.isOn) ? false : true
        
    }
    
    @IBAction func actionCancel(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "messagerie" {
            
            let nav = segue.destination as! UINavigationController
            let controller = nav.topViewController as! DetailMessageViewContr
            controller.aProduct = aProduct
            
        }
        
        
    }
    
    
    @IBAction func actionSave(_ sender: Any) {
        
        guard IBTrade.isOn || IBExchange.isOn else {
            BlackBox.sharedInstance.performUIUpdatesOnMain {
                self.displayAlert(self.translate.message("error"), mess: self.translate.message("errorTypeTrans"))
            }
            return
        }
        
        
        let alertController = UIAlertController(title: "Contact", message: translate.message("errorContactSeller"), preferredStyle: .alert)
        
        let actionValider = UIAlertAction(title: self.translate.message("done"), style: .destructive, handler: { (action) in
            
            guard self.config.balance >= Double(self.aProduct!.prod_prix) else {
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    self.displayAlert(self.translate.message("error"), mess: self.translate.message("errorBalanceTrans"))
                }
                return
            }
            
            
            self.config.flgReturnToTab = true
            
            var message = Message(dico: [String : AnyObject]())
            
            message.expediteur = self.config.user_id
            message.destinataire = (self.aProduct?.prod_by_user)!
            message.proprietaire = self.config.user_id
            message.client_id = self.config.user_id
            message.vendeur_id = (self.aProduct?.prod_by_user)!
            message.product_id = (self.aProduct?.prod_id)!
            
            var typetransaction = ""
            if self.IBTrade.isOn {
                
                typetransaction = self.translate.message("buy")
                message.contenu = "\(self.translate.message("emailSender")) \(self.config.user_nom!) \(self.config.user_prenom!) \n \(self.translate.message("theProduct")) \(self.IBInfoProduct.text!) \(self.translate.message("hastobechosen")) \(typetransaction). \(self.translate.message("customerFor"))"
            }
            else if self.IBExchange.isOn {
                
                typetransaction = self.translate.message("exchange")
                message.contenu = "\(self.translate.message("emailSender")) \(self.config.user_nom!) \(self.config.user_prenom!) \n \(self.translate.message("theProduct")) \(self.aProduct!.prod_nom) \(self.translate.message("hastobechosen")) \(typetransaction). \(self.translate.message("customerFor"))"
            }
            
            
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
                    
                    MDBMessage.sharedInstance.getAllMessages(self.config.user_id) { (success, messageArray, errorString) in
                        
                        if success {
                            
                            Messages.sharedInstance.MessagesArray = messageArray
                        }
                        else {
                            
                            BlackBox.sharedInstance.performUIUpdatesOnMain {
                                self.displayAlert(self.translate.message("error"), mess: errorString!)
                            }
                        }
                        
                    }
                    
                    var atransaction = Transaction(dico: [String : AnyObject]())
                    atransaction.client_id = message.client_id
                    atransaction.vendeur_id = message.vendeur_id
                    atransaction.prod_id = message.product_id
                    atransaction.proprietaire = message.proprietaire
                    atransaction.trans_wording = "transaction : \(self.aProduct!.prod_nom)"
                    
                    if self.IBTrade.isOn {
                        atransaction.trans_type = 1
                        atransaction.trans_amount = Double(self.aProduct!.prod_prix)
                        
                    }
                    else if self.IBExchange.isOn {
                        atransaction.trans_type = 2
                        atransaction.trans_amount = 0
                        
                    }
                    
                    
                    MDBTransact.sharedInstance.setAddTransaction(atransaction, completionHandlerAddTrans: { (success, errorString) in
                        
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
                            
                            var product = Product(dico: [String : AnyObject]())
                            product.prod_id = atransaction.prod_id
                            product.prod_hidden = true
                            product.prod_oth_user = self.config.user_id
                            
                            MDBProduct.sharedInstance.setUpdateProduct("ProductTrans", product) { (success, errorString) in
                                
                                if success {
                                    
                                    
                                    MDBProduct.sharedInstance.getProductsByCoord(self.config.user_id, minLon: self.config.minLongitude, maxLon: self.config.maxLongitude , minLat: self.config.minLatitude, maxLat: self.config.maxLatitude) { (success, productArray, errorString) in
                                        
                                        
                                        if success {
                                            
                                            Products.sharedInstance.productsUserArray = productArray
                                            
                                            BlackBox.sharedInstance.performUIUpdatesOnMain {                                               
                                                self.performSegue(withIdentifier: "messagerie", sender: sender)
                                                
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
                else {
                    BlackBox.sharedInstance.performUIUpdatesOnMain {
                        self.displayAlert(self.translate.message("error"), mess: errorString!)
                    }
                }
                
            })
            
            
            
            
        })
        
        let actionCancel = UIAlertAction(title: self.translate.message("cancel"), style: .destructive, handler: { (action) in
            
            
            
        })
        
        alertController.addAction(actionCancel)
        alertController.addAction(actionValider)
        
        
        present(alertController, animated: true) {
            
        }
        
        
    }
    
    
}
