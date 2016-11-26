//
//  DetailAlertViewController.swift
//  PressShare
//
//  Created by MacbookPRV on 23/11/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//

import Foundation

class DetailAlertViewController: UIViewController , UITextViewDelegate {
 
    
    @IBOutlet weak var IBEcrire: UITextView!
    @IBOutlet weak var IBLire: UITextView!
    @IBOutlet weak var IBActivity: UIActivityIndicatorView!
    @IBOutlet weak var IBSend: UIBarButtonItem!
    @IBOutlet weak var IBRetour: UIBarButtonItem!
    
   
    var aMessage:Message?
    var fenetre:Int?
    var fieldName = ""
    var keybordY:CGFloat! = 0
    
    var config = Config.sharedInstance
   
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        IBLire.text = aMessage?.contenu
        
     
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IBActivity.stopAnimating()
        IBActivity.isHidden = true
        
        subscibeToKeyboardNotifications()
        
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
        
    }
    
    
    @IBAction func ActionEnvoyer(_ sender: Any) {
        
        guard IBEcrire.text != "" else {
            displayAlert("Error", mess: "message vide.")
            return
        }
        
        
        IBSend.isEnabled = false
        IBEcrire.endEditing(true)
        IBLire.endEditing(true)
        var message = Message(dico: [String : AnyObject]())
        
        message.expediteur = config.user_id
        if fenetre == 1  {
            message.destinataire = (aMessage?.expediteur)!
        }
        else if fenetre == 2  {
            message.destinataire = (aMessage?.destinataire)!
        }
        
        message.proprietaire = config.user_id
        message.client_id = (aMessage?.client_id)!
        message.vendeur_id = (aMessage?.vendeur_id)!
        message.produit_id = (aMessage?.produit_id)!
        message.contenu = IBEcrire.text
        
        setAddMessage(message, completionHandlerMessages: { (success, errorString) in
            
            if success {
                
                performUIUpdatesOnMain {
                    self.IBEcrire.text = ""
                    self.IBSend.isEnabled = true
                    self.config.message_maj = true
                    self.displayAlert("message", mess: "message envoyé.")
                }
            }
            else {
                performUIUpdatesOnMain {
                    self.IBSend.isEnabled = true
                    self.displayAlert("Error", mess: errorString!)
                }
            }
            
        })
        
        
        
        
    }
    
    @IBAction func IBRetour(_ sender: Any) {
        
        IBRetour.isEnabled = false
        if (fenetre == 1 && aMessage?.deja_lu_dest == false) || (fenetre == 2 && aMessage?.deja_lu_exp == false)  {
            dejalu()
        }
        else {
            dismiss(animated: true, completion: nil)
        }
        
    }
    
    
    private func dejalu() {
        
        IBActivity.isHidden = false
        IBActivity.startAnimating()
        
        
        if (fenetre == 1 && aMessage?.deja_lu_dest == false) {
            
            aMessage?.deja_lu_dest = true
            
        }

        if (fenetre == 2 && aMessage?.deja_lu_exp == false)  {
            
            aMessage?.deja_lu_exp = true
            
        }
        
        setUpdateMessage(aMessage!, completionHandlerUpdate: { (success, errorString) in
            
            if success {
                self.config.message_maj = true
                performUIUpdatesOnMain {
                    self.IBActivity.stopAnimating()
                    self.dismiss(animated: true, completion: nil)
                }
            }
            else {
                
                performUIUpdatesOnMain {
                    self.IBSend.isEnabled = true
                    self.IBRetour.isEnabled = true
                    self.IBActivity.stopAnimating()
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
        if textView.isEqual(IBEcrire) {
            fieldName = "IBEcrire"
        }
        else if textView.isEqual(IBLire) {
            fieldName = "IBLire"
        }
        return true
    }
    
    
    
    //MARK: keyboard function
    
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        
        guard fieldName != "" && keybordY > 0 else {
            return
        }
        
        
        var textView = UITextView()
        
        if fieldName == "IBEcrire" {
            textView = IBEcrire
        }
        else  if fieldName == "IBLire" {
            textView = IBLire
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
        
        
        if fieldName == "IBEcrire" {
            textView = IBEcrire
        }
        else if fieldName == "IBLire" {
            textView = IBLire
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
        
        
        if fieldName == "IBEcrire" {
            textView = IBEcrire
        }
        else if fieldName == "IBLire" {
            textView = IBLire
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
