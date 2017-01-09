//
//  DetailAlertViewController.swift
//  PressShare
//
//  Description : Content of sent message from client. owner can reply wether necessary
//
//  Created by MacbookPRV on 23/11/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//



//Todo :Le message recu doit est cadré en haut de la zone de texte
//Todo :Le message recu ne doit est modifiable





import Foundation

class DetailAlertViewController: UIViewController , UITextViewDelegate {
    
    
    @IBOutlet weak var IBWrite: UITextView!
    @IBOutlet weak var IBRead: UITextView!
    @IBOutlet weak var IBActivity: UIActivityIndicatorView!
    @IBOutlet weak var IBSend: UIBarButtonItem!
    @IBOutlet weak var IBReturn: UIBarButtonItem!
    @IBOutlet weak var IBMessage: UILabel!
    @IBOutlet weak var IBReply: UILabel!
    
    
    var aMessage:Message?
    var aWindow:Int?
    var fieldName = ""
    var keybordY:CGFloat! = 0
    
    var config = Config.sharedInstance
   
    let translate = TranslateMessage.sharedInstance
    
    
    //MARK: Locked landscapee
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
        
        IBReturn.title = translate.cancel
        IBSend.title = translate.send
        IBMessage.text = translate.message
        IBReply.text = translate.reply
        IBRead.text = aMessage?.contenu
        
        
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
    
    //MARK: Data Message
    
    @IBAction func actionSend(_ sender: Any) {
        
        guard IBWrite.text != "" else {
            displayAlert(translate.error, mess: "message vide.")
            return
        }
        
        
        IBSend.isEnabled = false
        IBWrite.endEditing(true)
        IBRead.endEditing(true)
        var message = Message(dico: [String : AnyObject]())
        
        message.expediteur = config.user_id
        if aWindow == 1  {
            message.destinataire = (aMessage?.expediteur)!
        }
        else if aWindow == 2  {
            message.destinataire = (aMessage?.destinataire)!
        }
        
        message.proprietaire = config.user_id
        message.client_id = (aMessage?.client_id)!
        message.vendeur_id = (aMessage?.vendeur_id)!
        message.product_id = (aMessage?.product_id)!
        message.contenu = IBWrite.text
        
        MDBMessage.sharedInstance.setAddMessage(message, completionHandlerMessages: { (success, errorString) in
            
            if success {
                
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    self.IBWrite.text = ""
                    self.IBSend.isEnabled = true
                    self.config.message_maj = true
                    self.displayAlert("message", mess: self.translate.sentMessage)
                }
            }
            else {
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    self.IBSend.isEnabled = true
                    self.displayAlert(self.translate.error, mess: errorString!)
                }
            }
            
            
        })
        
        
        
        
    }
    
    
    @IBAction func actionReturn (_ sender: Any) {
        
        IBReturn.isEnabled = false
        if (aWindow == 1 && aMessage?.deja_lu_dest == false) || (aWindow == 2 && aMessage?.deja_lu_exp == false)  {
            alreadyRead()
        }
        else {
            dismiss(animated: true, completion: nil)
        }
        
    }
    
    
    private func alreadyRead() {
        
        IBActivity.isHidden = false
        IBActivity.startAnimating()
        
        
        if (aWindow == 1 && aMessage?.deja_lu_dest == false) {
            
            aMessage?.deja_lu_dest = true
            
        }
        
        if (aWindow == 2 && aMessage?.deja_lu_exp == false)  {
            
            aMessage?.deja_lu_exp = true
            
        }
        
        MDBMessage.sharedInstance.setUpdateMessage(aMessage!, completionHandlerUpdate: { (success, errorString) in
            
            if success {
                self.config.message_maj = true
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    self.IBActivity.stopAnimating()
                    self.dismiss(animated: true, completion: nil)
                }
            }
            else {
                
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    self.IBSend.isEnabled = true
                    self.IBReturn.isEnabled = true
                    self.IBActivity.stopAnimating()
                    self.displayAlert(self.translate.error, mess: errorString!)
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
        if textView.isEqual(IBWrite) {
            fieldName = "IBWrite"
        }
        else if textView.isEqual(IBRead) {
            fieldName = "IBRead"
        }
        return true
    }
    
    
    
    //MARK: keyboard function
    
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        
        guard fieldName != "" && keybordY > 0 else {
            return
        }
        
        
        var textView = UITextView()
        
        if fieldName == "IBWrite" {
            textView = IBWrite
        }
        else  if fieldName == "IBRead" {
            textView = IBRead
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
        
        
        if fieldName == "IBWrite" {
            textView = IBWrite
        }
        else if fieldName == "IBRead" {
            textView = IBRead
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
        
        
        if fieldName == "IBWrite" {
            textView = IBWrite
        }
        else if fieldName == "IBRead" {
            textView = IBRead
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
