//
//  VendeurViewController.swift
//  PressShare
//
//  Created by MacbookPRV on 22/11/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//

import Foundation
import UIKit

class VendeurViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var IBMessage: UITextView!
    @IBOutlet weak var IBInfoContact1: UILabel!
    @IBOutlet weak var IBInfoContact2: UILabel!
    @IBOutlet weak var IBInfoProduit: UILabel!
    
    var aproduit:Produit?
    
    var config = Config.sharedInstance
    let traduction = InternationalIHM.sharedInstance
    
    var fieldName = ""
    var keybordY:CGFloat! = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        IBInfoProduit.text = "\(aproduit!.prod_nom), \(FormaterMontant((aproduit?.prod_prix)!)) \(traduction.devise!)"
        getUser((aproduit?.prod_by_user)!, completionHandlerUser: {(success, usersArray, errorString) in
            
            if success {
                
                
                performUIUpdatesOnMain {
                    
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
                performUIUpdatesOnMain {
                    self.displayAlert("Error", mess: errorString!)
                }
            }
            
            
        })
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        subscibeToKeyboardNotifications()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
        
    }
    
    
    @IBAction func ActionCancel(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    
    @IBAction func ActionSave(_ sender: Any) {
        
        self.IBMessage.endEditing(true)
        
        let alertController = UIAlertController(title: "Acheter", message: "Confirmer votre achat", preferredStyle: .alert)
        
        let actionValider = UIAlertAction(title: "Valider", style: .destructive, handler: { (action) in
            
            guard self.config.solde >= Double(self.aproduit!.prod_prix) else {
                performUIUpdatesOnMain {
                    self.displayAlert("Error", mess: "solde insuffisant!")
                }
                return
            }
            
            
            self.config.vendeur_maj = true
            self.config.solde = self.config.solde - Double(self.aproduit!.prod_prix)
            
            var capital = Capital(dico: [String : AnyObject]())
            capital.solde = self.config.solde
            capital.user_id = self.config.user_id
            
            
            var operation = Operation(dico: [String : AnyObject]())
            operation.user_id = self.config.user_id
            operation.op_type = 2
            operation.op_montant = Double(self.aproduit!.prod_prix)
            operation.op_libelle = "achat produit"
            
            setUpdateCapital(capital, completionHandlerUpdate: { (success, errorString) in
                
                if success {
                    
                    setAddOperation(operation, completionHandlerAddOp: {(success, errorString) in
                        
                        if success {
                            
                            Operations.sharedInstance.operationArray = nil
                            performUIUpdatesOnMain {
                                
                                self.IBMessage.text = "Le produit : \(self.IBInfoProduit.text!) vient d'être acheté. Prenez contact avec le client pour la suite..."
                                self.ActionSend(self)
                                self.dismiss(animated: true, completion: nil)
                                self.dismiss(animated: true, completion: nil)
                            }
                            
                        }
                        else {
                            performUIUpdatesOnMain {
                                
                                self.displayAlert("Error", mess: errorString!)
                            }
                        }
                        
                        
                    })
                    
                    
                    
                }
                else {
                    performUIUpdatesOnMain {
                        
                        self.displayAlert("Error", mess: errorString!)
                    }
                }
                
                
            })

    
        })
        
        let actionCancel = UIAlertAction(title: "Annuler", style: .destructive, handler: { (action) in
            
            
            
        })
        
        alertController.addAction(actionCancel)
        alertController.addAction(actionValider)
        
        
        present(alertController, animated: true) {
            
        }
        
        
        
        
    }
    
    
    @IBAction func ActionSend(_ sender: Any) {
        
        guard IBMessage.text != "" else {
            displayAlert("Error", mess: "message vide.")
            return
        }
        
        
        var message = Message(dico: [String : AnyObject]())
        
        message.expediteur = config.user_id
        message.destinataire = (aproduit?.prod_by_user)!
        message.proprietaire = config.user_id
        message.client_id = config.user_id
        message.vendeur_id = (aproduit?.prod_by_user)!
        message.produit_id = (aproduit?.prod_id)!
        message.contenu = IBMessage.text
        
        setAddMessage(message, completionHandlerMessages: { (success, errorString) in
            
            if success {
                
                performUIUpdatesOnMain {
                    self.IBMessage.text = ""
                    self.displayAlert("message", mess: "message envoyé au vendeur.")
                }
            }
            else {
                performUIUpdatesOnMain {
                    self.displayAlert("Error", mess: errorString!)
                }
            }
            
        })
        
        
    }
    
    
    //MARK: textfield Delegate
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        
        textView.endEditing(true)
        return true
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView.isEqual(IBMessage) {
            fieldName = "IBMessage"
        }
        return true
    }
    
    
    
    //MARK: keyboard function
    
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        
        guard fieldName != "" && keybordY > 0 else {
            return
        }
        
        
        var textView = UITextView()
        
        if fieldName == "IBMessage" {
            textView = IBMessage
        }
        
        textView.endEditing(true)
        
        
        
    }
    
    
    func  subscibeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    
    
    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        
    }
    
    
    func keyboardWillShow(notification:NSNotification) {
        
        
        var textView = UITextView()
        
        
        if fieldName == "IBMessage" {
            textView = IBMessage
        }
        
        if textView.isFirstResponder {
            keybordY = view.frame.size.height - getkeyboardHeight(notification: notification)
            if keybordY < (textView.frame.origin.y + textView.frame.size.height/2)  {
                view.frame.origin.y = keybordY - textView.frame.origin.y - textView.frame.size.height
            }
            
            
        }
        
        
    }
    
    
    func keyboardWillHide(notification:NSNotification) {
        
        var textView = UITextView()
        
        
        if fieldName == "IBMessage" {
            textView = IBMessage
        }
        
        
        if textView.isFirstResponder {
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
    
    
    
    
    
}
