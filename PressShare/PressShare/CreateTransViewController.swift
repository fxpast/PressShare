//
//  CreateTransViewController.swift
//  PressShare
//
//  Description : Client selects un product and create un transaction between the owner and himself.
//
//  Created by MacbookPRV on 22/11/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//


//Todo :Améliorer le texte du message. ajouter un style courtois.




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
    
    
    //Bloquer le mode paysage
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
        
        IBLabelTrade.text = translate.trade
        IBLabelExchange.text = translate.exchange
        IBCancel.title = translate.cancel
        IBValidate.title = translate.done
        
        IBExchange.isOn = false
        IBTrade.isOn = false
        
        IBInfoProduct.text = "\(aProduct!.prod_nom), \(BlackBox.sharedInstance.formatedAmount((aProduct?.prod_prix)!)) \(translate.devise!)"
        
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
                    self.displayAlert(self.translate.error, mess: errorString!)
                }
            }
            
            
        })
        
    }
    
    @IBAction func actionExchange(_ sender: Any) {
        
        IBTrade.isOn = (IBExchange.isOn) ? false : true
        
    }
    
    @IBAction func actionTrade(_ sender: Any) {
        
        IBExchange.isOn = (IBTrade.isOn) ? false : true
        
    }
    
    @IBAction func actionCancel(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    
    @IBAction func actionSave(_ sender: Any) {
        
        guard IBTrade.isOn || IBExchange.isOn else {
            BlackBox.sharedInstance.performUIUpdatesOnMain {
                self.displayAlert(self.translate.error, mess: self.translate.errorTypeTrans)
            }
            return
        }
        
        
        let alertController = UIAlertController(title: "Contact", message: translate.errorContactSeller, preferredStyle: .alert)
        
        let actionValider = UIAlertAction(title: self.translate.done, style: .destructive, handler: { (action) in
            
            guard self.config.balance >= Double(self.aProduct!.prod_prix) else {
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    self.displayAlert(self.translate.error, mess: self.translate.errorBalanceTrans)
                }
                return
            }
            
            
            self.config.vendeur_maj = true
            
            var message = Message(dico: [String : AnyObject]())
            
            message.expediteur = self.config.user_id
            message.destinataire = (self.aProduct?.prod_by_user)!
            message.proprietaire = self.config.user_id
            message.client_id = self.config.user_id
            message.vendeur_id = (self.aProduct?.prod_by_user)!
            message.product_id = (self.aProduct?.prod_id)!
            
            var typetransaction = ""
            if self.IBTrade.isOn {
                
                typetransaction = self.translate.buy
            }
            else if self.IBExchange.isOn {
                
                typetransaction = self.translate.exchange
            }
            
            message.contenu = "\(self.translate.theProduct!) \(self.IBInfoProduct.text!) \(self.translate.hastobechosen!) \(typetransaction). \(self.translate.customerFor!)"
            
            
            MDBMessage.sharedInstance.setAddMessage(message, completionHandlerMessages: { (success, errorString) in
                
                if success {
                    
                    var atransaction = Transaction(dico: [String : AnyObject]())
                    atransaction.client_id = message.client_id
                    atransaction.vendeur_id = message.vendeur_id
                    atransaction.prod_id = message.product_id
                    atransaction.proprietaire = message.proprietaire
                    atransaction.trans_wording = "transaction : \(self.aProduct!.prod_nom)"
                    atransaction.trans_amount = Double(self.aProduct!.prod_prix)
                    
                    if self.IBTrade.isOn {
                        atransaction.trans_type = 1
                    }
                    else if self.IBExchange.isOn {
                        atransaction.trans_type = 2
                    }
                    
                    
                    MDBTransact.sharedInstance.setAddTransaction(atransaction, completionHandlerAddTrans: { (success, errorString) in
                        
                        if success {
                            
                            BlackBox.sharedInstance.performUIUpdatesOnMain {
                                
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
            
            
            
            
        })
        
        let actionCancel = UIAlertAction(title: self.translate.cancel, style: .destructive, handler: { (action) in
            
            
            
        })
        
        alertController.addAction(actionCancel)
        alertController.addAction(actionValider)
        
        
        present(alertController, animated: true) {
            
        }
        
        
    }
    
    
}
