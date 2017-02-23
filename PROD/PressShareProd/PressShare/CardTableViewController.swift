//
//  CBViewController.swift
//  PressShare
//
//  Description : Record Credit Card
//
//  Created by MacbookPRV on 21/09/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//


import Foundation
import UIKit

class CardTableViewController: UITableViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var IBDone: UIBarButtonItem!
    @IBOutlet weak var IBImageCard: UIImageView!
    @IBOutlet weak var IBImageCardLabel: UILabel!
    @IBOutlet weak var IBTypeCardLabel: UILabel!
    @IBOutlet weak var IBNumberLabel: UILabel!
    @IBOutlet weak var IBNumber: UITextField!
    @IBOutlet weak var IBOwnerLabel: UILabel!
    @IBOutlet weak var IBOwner: UITextField!
    @IBOutlet weak var IBDateLabel: UILabel!
    @IBOutlet weak var IBDate: UITextField!
    @IBOutlet weak var IBDatePicker: UIDatePicker!
    
    @IBOutlet weak var IBCryptoLabel: UILabel!
    @IBOutlet weak var IBCrypto: UITextField!
    
    
    let translate = TranslateMessage.sharedInstance
    let config = Config.sharedInstance
    var aindex = 0
    var aCard: Card!

    
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
        aCard = Card(dico: [String : AnyObject]())
        
        tableView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(handleTap)))
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        
        for i in 0...4 {
            tableView.scrollToRow(at: IndexPath(item: i, section: 0), at: .none, animated: false)
        }
        tableView.scrollToRow(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
  
        
        IBDone.title = translate.message("done")
        
   
        
        IBTypeCardLabel.text = translate.message("typeOfPay")
        
        if  config.typeCard_id != 0 {
            
            for typeCd in TypeCards.sharedInstance.typeCardsArray  {
                
                let typeC = TypeCard(dico: typeCd)
                if typeC.typeCard_id == config.typeCard_id {
                    
                    aCard.typeCard_id = config.typeCard_id
                    config.typeCard_id = 0
                    
                    do {
                        let url = URL(string: "\(CommunRequest.sharedInstance.urlServer)/images_cb/\(typeC.typeCard_ImageUrl)")!
                        let data = try Data(contentsOf: url)
                        IBImageCard.image = UIImage(data: data)
                    } catch  {
                        print("error url : ", typeC.typeCard_ImageUrl)
                    }
                    
                    IBImageCardLabel.text = typeC.typeCard_Wording
                    
                }
                
            }
        }
        
        
        
        IBNumber.placeholder = translate.message("CBNumber")
        IBNumberLabel.text = translate.message("CBNumber")
        IBNumber.layer.addSublayer(BlackBox.sharedInstance.createLine(frame: IBNumber.frame))
        
        IBOwner.placeholder = translate.message("cardOwner")
        IBOwnerLabel.text = translate.message("cardOwner")
        IBOwner.layer.addSublayer(BlackBox.sharedInstance.createLine(frame: IBOwner.frame))
        
        IBDateLabel.text = translate.message("expiryDate")
        IBDate.layer.addSublayer(BlackBox.sharedInstance.createLine(frame: IBDate.frame))
        
        IBCryptoLabel.text = translate.message("cryptogram")
        IBCrypto.layer.addSublayer(BlackBox.sharedInstance.createLine(frame: IBCrypto.frame))
        
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        
    }
    
    
    @IBAction func actionDone(_ sender: AnyObject) {
        
       
        //type card
        guard aCard.typeCard_id != 0 else {
            self.displayAlert(self.translate.message("error"), mess: "error card type")
            return
        }

        
        //number card
        guard IBNumber.text != "" else {
            self.displayAlert(self.translate.message("error"), mess: "error card number")
            return
        }
        
        aCard.card_number = IBNumber.text!
        
        let range = aCard.card_number.index(aCard.card_number.endIndex, offsetBy: -4)..<aCard.card_number.endIndex
        aCard.card_lastNumber = aCard.card_number.substring(with: range)
  
        
        //owner
        
        guard IBOwner.text != "" else {
            self.displayAlert(self.translate.message("error"), mess: "error owner")
            return
        }
        
        aCard.card_owner = IBOwner.text!
        
        
        //date
        guard IBDate.text != "" else {
            self.displayAlert(self.translate.message("error"), mess: "error expiry date")
            return
        }
        
        aCard.card_date = IBDate.text!
        
        //crypto
        guard IBCrypto.text != "" else {
            self.displayAlert(self.translate.message("error"), mess: "error crypto")
            return
        }
        
        aCard.card_crypto = IBCrypto.text!
        
        //user_id
        aCard.user_id = config.user_id
        
        MDBCard.sharedInstance.setAddCard(aCard, completionHandlerCard: { (success, errorString) in
            
            if success {
              Cards.sharedInstance.cardsArray = nil
                BlackBox.sharedInstance.performUIUpdatesOnMain {
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
    
    
    @IBAction func actionCancel(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
        
    }
    
    func handleTap(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            tableView.endEditing(true)
        }
        sender.cancelsTouchesInView = false
    }
    
    //MARK: textfield Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.isEqual(IBNumber) {
            IBOwner.becomeFirstResponder()
        }
        else if textField.isEqual(IBOwner) {
            IBCrypto.becomeFirstResponder()
        }
        else if textField.isEqual(IBCrypto) {
             actionDone(self)
        }
   
        
        

        textField.endEditing(true)
        return true
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        
    }
    
    
    @IBAction func actionDatePicker(_ sender: Any) {
        
        let month = Calendar.current.component(.month, from: IBDatePicker.date)
        let year = Calendar.current.component(.year, from: IBDatePicker.date)
        
        let index = "\(year)".index("\(year)".startIndex, offsetBy: 2)
        let yy = "\(year)".substring(from: index)
        
        if month < 10 {
            
            IBDate.text = "0\(month)/\(yy)"
            
        }
        else {
            IBDate.text = "\(month)/\(yy)"
        }
        
        
        
        
    }
    
    
    //MARK: Table View Controller data source
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        aindex = (indexPath as NSIndexPath).row
        
        
    }
    
    
    
}
