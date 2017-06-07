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
    @IBOutlet weak var IBisTrade: UISwitch!
    @IBOutlet weak var IBisExchange: UISwitch!
    @IBOutlet weak var IBCancel: UIBarButtonItem!
    @IBOutlet weak var IBValidate: UIBarButtonItem!
    @IBOutlet weak var IBLabelTrade: UILabel!
    @IBOutlet weak var IBLabelExchange: UILabel!
    @IBOutlet weak var IBActivity: UIActivityIndicatorView!
    
    var aProduct:Product?
    var timerBadge : Timer!

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
        
        IBInfoContact1.textColor = UIColor.init(hexString: config.colorAppLabel)
        IBInfoContact2.textColor = UIColor.init(hexString: config.colorAppLabel)
        IBInfoProduct.textColor = UIColor.init(hexString: config.colorAppLabel)
        IBLabelTrade.textColor = UIColor.init(hexString: config.colorAppLabel)
        IBLabelExchange.textColor = UIColor.init(hexString: config.colorAppLabel)

        IBInfoContact1.text = ""
        IBInfoContact2.text = ""
        IBInfoProduct.text = ""
        IBLabelTrade.text = ""
        IBLabelExchange.text = ""
        
        IBActivity.isHidden = false
        IBActivity.startAnimating()
        
        IBInfoProduct.numberOfLines = 2
        
        IBLabelTrade.text = translate.message("buy")
        IBLabelExchange.text = translate.message("exchange")
        IBValidate.title = translate.message("done")
        
        if aProduct?.prod_echange == false {
            IBisExchange.isOn = false
            IBisExchange.isEnabled = false
        }
        else {
            IBisExchange.isOn = false
            IBisTrade.isOn = false
        }
        
        if aProduct?.prod_prix == 0 {
            IBisTrade.isEnabled = false
        }
        title = translate.message("exchangeBuy")
        
        IBInfoProduct.text = "\(translate.message("product")): \(aProduct!.prod_nom), \(translate.message("price")): \(BlackBox.sharedInstance.formatedAmount((aProduct?.prod_prix)!))"
        
        MDBUser.sharedInstance.getUser((aProduct?.prod_by_user)!, completionHandlerUser: {(success, usersArray, errorString) in
            
            if success {
                
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    
                    self.IBActivity.isHidden = true
                    self.IBActivity.stopAnimating()
        
                    
                    if (usersArray?.count)! > 0 {
                        for userDico in usersArray! {
                            
                            if userDico["user_nom"] as! String != "" || userDico["user_prenom"] as! String != "" {
                               self.IBInfoContact1.text = "\(userDico["user_nom"]!) \(userDico["user_prenom"]!) (\(self.translate.message("userNote")) \(userDico["user_note"]!) \(self.translate.message("star")))"
                            }
                            
                            if userDico["user_ville"] as! String != "" || userDico["user_pays"] as! String != "" {
                                self.IBInfoContact2.text = "\(userDico["user_ville"]!) \(userDico["user_pays"]!)"
                            }
                            
                            break
                            
                        }
                    }
                }
            }
            else {
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    self.displayAlert(self.translate.message("error"), mess: errorString!)
                    self.IBActivity.isHidden = true
                    self.IBActivity.stopAnimating()
                    
                }
            }
            
            
        })
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        view.backgroundColor =  UIColor.init(hexString: config.colorApp)
        
        if config.isReturnToTab == true {
            dismiss(animated: false, completion: nil)
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        timerBadge = Timer.scheduledTimer(timeInterval: config.dureeTimer, target: self, selector: #selector(routineTimer), userInfo: nil, repeats: true)
        
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
    
    
    
    @IBAction func actionExchange(_ sender: Any) {
        
        IBisExchange.isOn = true
        IBisTrade.isOn = (IBisExchange.isOn) ? false : true
        
    }
    
    @IBAction func actionTrade(_ sender: Any) {
        
        IBisTrade.isOn = true
        IBisExchange.isOn = (IBisTrade.isOn) ? false : true
        
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
    
    @IBAction func actionHelp(_ sender: Any) {
        
        //action info
        BlackBox.sharedInstance.showHelp("transactions", self)
        
    }
    
    
    @IBAction func actionSave(_ sender: Any) {
        
        guard IBisTrade.isOn || IBisExchange.isOn else {
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
            
            self.IBActivity.isHidden = false
            self.IBActivity.startAnimating()
            
            self.config.isReturnToTab = true
            
            var message = Message(dico: [String : AnyObject]())
            
            message.expediteur = self.config.user_id
            message.destinataire = (self.aProduct?.prod_by_user)!
            message.proprietaire = self.config.user_id
            message.client_id = self.config.user_id
            message.vendeur_id = (self.aProduct?.prod_by_user)!
            message.product_id = (self.aProduct?.prod_id)!
            
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = .none
            dateFormatter.dateStyle = .medium
            dateFormatter.locale = Locale.current
            dateFormatter.doesRelativeDateFormatting = true
            let dateExpire = Calendar.current.date(byAdding: Calendar.Component.day, value: self.config.maxDayTrigger, to: Date())
            let dateExpireString = dateFormatter.string(from: dateExpire!).lowercased()
            
            var typetransaction = ""
            if self.IBisTrade.isOn {
                
                typetransaction = self.translate.message("buy").lowercased()
                message.contenu = "\(self.translate.message("emailSender")) \(self.config.user_nom!) \(self.config.user_prenom!) \n \(self.translate.message("theProduct")) \(self.IBInfoProduct.text!) \(self.translate.message("hastobechosen")) \(typetransaction). \(self.translate.message("customerFor")) \(self.translate.message("transactExpire")) \(dateExpireString)"
            }
            else if self.IBisExchange.isOn {
                
                typetransaction = self.translate.message("exchange").lowercased()
                message.contenu = "\(self.translate.message("emailSender")) \(self.config.user_nom!) \(self.config.user_prenom!) \n \(self.translate.message("theProduct")) \(self.aProduct!.prod_nom) \(self.translate.message("hastobechosen")) \(typetransaction). \(self.translate.message("customerFor")) \(self.translate.message("transactExpire")) \(dateExpireString)"
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
                    
                    if self.IBisTrade.isOn {
                        atransaction.trans_type = 1
                        atransaction.trans_amount = Double(self.aProduct!.prod_prix)
                        
                    }
                    else if self.IBisExchange.isOn {
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
                                                self.performSegue(withIdentifier: "messagerie", sender: sender)
                                                self.IBActivity.isHidden = true
                                                self.IBActivity.stopAnimating()
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
