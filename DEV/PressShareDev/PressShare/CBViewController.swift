//
//  CBViewController.swift
//  PressShare
//
//  Description : Record Credit Card
//
//  Created by MacbookPRV on 21/09/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//

//Todo: Utiliser le modèle de création de carte bancaire et compte bancaire de PayPal


//Todo :Ajouter une liste pour avoir plusieurs carte de credit
//Todo :Ajouter un bouton paypal
//Todo :Ajouter un bouton paybox
//Todo :Ajouter un bouton ajouter une carte de credit
//Todo :Supprimer le bouton de droite "OK"
//Todo :Mettre une interface date

import Foundation
import UIKit

class CBViewController: UIViewController {
    
    
    @IBOutlet weak var IBNom: UITextField!
    @IBOutlet weak var IBCarte: UITextField!
    @IBOutlet weak var IBCrypto: UITextField!
    @IBOutlet weak var IBDateVal: UITextField!
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        subscibeToKeyboardNotifications()
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
        
    }
    
    
    
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard fieldName != "" && keybordY > 0 else {
            return
        }
        
        let location = (event?.allTouches?.first?.location(in: self.view).y)! as CGFloat
        if (Double(location) < Double(keybordY)){
            
            var textField = UITextField()
            
            
            if fieldName == "IBCarte" {
                textField = IBCarte
                
                guard let _ = NumberFormatter().number(from: textField.text!) else {
                    displayAlert("Error", mess: "valeur incorrecte")
                    return
                }
                
            }
            else if fieldName == "IBCrypto" {
                textField = IBCrypto
            }
            else if fieldName == "IBDateVal" {
                textField = IBDateVal
                
                guard let _ = NumberFormatter().number(from: textField.text!) else {
                    displayAlert("Error", mess: "valeur incorrecte")
                    return
                }
                
            }
            else if fieldName == "IBNom" {
                textField = IBNom
            }
            
            
            textField.endEditing(true)
            
        }
        
    }
    
    
    
    @IBAction func actionDone(_ sender: AnyObject) {
        
        
        MDBCarteB.sharedInstance.getAllCard(userId: 1) { (success, cardArray, errorString) in
            
            if success {
                
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    self.displayAlert("info", mess: "Under construction...")
                    print(cardArray!)
                    self.dismiss(animated: true, completion: nil)
                    
                }
                
            }
            else {
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    
                    self.displayAlert("Error", mess: errorString!)
                    
                }
            }
            
        }
        
        
        
    }
    
    
    @IBAction func actionCancel(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
        
    }
    
    
    //MARK: textfield Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.isEqual(IBCarte) || textField.isEqual(IBDateVal)  {
            
            guard let _ = NumberFormatter().number(from: textField.text!) else {
                
                displayAlert("Error", mess: "valeur incorrecte")
                return false
                
            }
            
        }
        
        
        textField.endEditing(true)
        return true
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        
        if textField.isEqual(IBCarte) {
            fieldName = "IBCarte"
        }
        else if textField.isEqual(IBCrypto) {
            fieldName = "IBCrypto"
        }
        else if textField.isEqual(IBDateVal) {
            fieldName = "IBDateVal"
        }
        else if textField.isEqual(IBNom) {
            fieldName = "IBNom"
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
        
        
        if fieldName == "IBCarte" {
            textField = IBCarte
        }
        else if fieldName == "IBCrypto" {
            textField = IBCrypto
        }
        else if fieldName == "IBDateVal" {
            textField = IBDateVal
        }
        else if fieldName == "IBNom" {
            textField = IBNom
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
        
        
        if fieldName == "IBCarte" {
            textField = IBCarte
            
            guard let _ = NumberFormatter().number(from: textField.text!) else {
                displayAlert("Error", mess: "valeur incorrecte")
                return
            }
            
        }
        else if fieldName == "IBCrypto" {
            textField = IBCrypto
        }
        else if fieldName == "IBDateVal" {
            textField = IBDateVal
            
            guard let _ = NumberFormatter().number(from: textField.text!) else {
                displayAlert("Error", mess: "valeur incorrecte")
                return
            }
            
        }
        else if fieldName == "IBNom" {
            textField = IBNom
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
    
    
    
}
