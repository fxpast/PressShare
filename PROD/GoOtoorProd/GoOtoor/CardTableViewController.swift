//
//  CBViewController.swift
//  GoOtoor
//
//  Description : Record Credit Card
//
//  Created by MacbookPRV on 21/09/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//

import Foundation
import UIKit

import BraintreeCore
import BraintreeCard
import BraintreePayPal


class CardTableViewController: UITableViewController, UITextFieldDelegate, BTViewControllerPresentingDelegate, BTAppSwitchDelegate {
    
    
    @IBOutlet weak var IBActivity: UIActivityIndicatorView!
    @IBOutlet weak var IBDone: UIBarButtonItem!
    @IBOutlet weak var IBImageCard: UIImageView!
    @IBOutlet weak var IBImageCardLabel: UILabel!
    @IBOutlet weak var IBTypeCardLabel: UILabel!
    @IBOutlet weak var IBNumberLabel: UILabel!
    @IBOutlet weak var IBNumber: UITextField!
    @IBOutlet weak var IBDateLabel: UILabel!
    @IBOutlet weak var IBDate: UITextField!
    @IBOutlet weak var IBDatePicker: UIDatePicker!
    
    var timerBadge : Timer!

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
        
        IBActivity.isHidden = true
        IBActivity.stopAnimating()
        
        for i in 0...2 {
            tableView.scrollToRow(at: IndexPath(item: i, section: 0), at: .none, animated: false)
            tableView(tableView, cellForRowAt: IndexPath(item: i, section: 0)).backgroundColor  = UIColor.init(hexString: config.colorApp)
            tableView(tableView, cellForRowAt: IndexPath(item: i, section: 0)).backgroundView?.backgroundColor  = UIColor.init(hexString: config.colorApp)
        }
        tableView.scrollToRow(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
  
        tableView.backgroundColor = UIColor.init(hexString: config.colorApp)
        tableView.backgroundView?.backgroundColor = UIColor.init(hexString: config.colorApp)
        tableView.sectionIndexColor = UIColor.init(hexString: config.colorApp)
        
        
        IBDone.title = translate.message("done")
        
   
        
        IBTypeCardLabel.textColor = UIColor.init(hexString: config.colorAppLabel)
        IBTypeCardLabel.text = translate.message("typeOfPay")
        
        if  config.typeCard_id != 0 {
            
            
            //Paypal
            if config.typeCard_id == 6 {
                IBNumberLabel.isHidden = true
                IBNumber.isHidden = true
                IBDate.isHidden = true
                IBDateLabel.isHidden = true
                IBDatePicker.isHidden = true
            }
            else {
                IBNumberLabel.isHidden = false
                IBNumber.isHidden = false
                IBDate.isHidden = false
                IBDateLabel.isHidden = false
                IBDatePicker.isHidden = false
            }
            
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
                    IBImageCardLabel.textColor = UIColor.init(hexString: config.colorAppLabel)
                    IBImageCardLabel.text = typeC.typeCard_Wording
                    
                }
                
            }
      
        }
        
        
        IBNumber.attributedPlaceholder = NSAttributedString.init(string: translate.message("CBNumber"), attributes: [NSForegroundColorAttributeName : UIColor.init(hexString: config.colorAppPlHd)])

        
        IBNumberLabel.textColor = UIColor.init(hexString: config.colorAppLabel)
        IBNumberLabel.text = translate.message("CBNumber")
        IBNumber.layer.addSublayer(MyTools.sharedInstance.createLine(frame: IBNumber.frame))

        
        IBDateLabel.textColor = UIColor.init(hexString: config.colorAppLabel)
        IBDateLabel.text = translate.message("expiryDate")
        IBDate.layer.addSublayer(MyTools.sharedInstance.createLine(frame: IBDate.frame))
        
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
            
            MyTools.sharedInstance.checkBadge(completionHdlerBadge: { (success, result) in
                
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
    
    
    
    @IBAction func actionDone(_ sender: AnyObject) {
        
        IBActivity.startAnimating()
        IBActivity.isHidden = false
        
        
        //Paypal
        if aCard.typeCard_id == 6 {
            
           callPayPal()
        }
        else {
            
            //type card
            guard aCard.typeCard_id != 0 else {
                self.displayAlert(self.translate.message("error"), mess: self.translate.message("errorCardType"))
                return
            }
            
            //number card
            guard IBNumber.text != "" else {
                self.displayAlert(self.translate.message("error"), mess: self.translate.message("errorCardNumber"))
                return
            }
            
            
            let numberStr = IBNumber.text!
            let range = numberStr.index(numberStr.endIndex, offsetBy: -4)..<numberStr.endIndex
            aCard.card_lastNumber = numberStr.substring(with: range)
            
            //date
            guard IBDate.text != "" else {
                self.displayAlert(self.translate.message("error"), mess: self.translate.message("errorExpiryDate"))
                return
            }
            
            let month = Calendar.current.component(.month, from: IBDatePicker.date)
            let year = Calendar.current.component(.year, from: IBDatePicker.date)
            
            if config.clientTokenBraintree == "" {
                
                MDBPressOperation.sharedInstance.getBraintreeToken(config.user_id, completionHandlerbtToken: { (success, clientToken, errorString) in
                    
                    if success == true {
                        
                        self.config.clientTokenBraintree = clientToken
                        
                        let braintreeClient = BTAPIClient.init(authorization: clientToken!)!
                        let cardClient = BTCardClient(apiClient: braintreeClient)
                        
                        let card = BTCard(number: self.IBNumber.text!, expirationMonth: String(month), expirationYear: String(year), cvv: nil)
                        
                        cardClient.tokenizeCard(card) { (tokenCard, error) in
                            // Communicate the tokenizedCard.nonce to your server, or handle error
                            if error == nil {
                                
                                self.aCard.tokenizedCard = tokenCard!.nonce
                                
                                //user_id
                                self.aCard.user_id = self.config.user_id
                                if Cards.sharedInstance.cardsArray.count == 0 || Cards.sharedInstance.cardsArray == nil {
                                    self.aCard.main_card = true
                                }
                                
                                MDBCard.sharedInstance.setAddCard(self.aCard, completionHandlerCard: { (success, errorString) in
                                    
                                    if success {
                                        Cards.sharedInstance.cardsArray = nil
                                        MyTools.sharedInstance.performUIUpdatesOnMain {
                                            self.dismiss(animated: true, completion: nil)
                                        }
                                    }
                                    else {
                                        MyTools.sharedInstance.performUIUpdatesOnMain {
                                            self.IBActivity.isHidden = true
                                            self.IBActivity.stopAnimating()
                                            self.displayAlert(self.translate.message("error"), mess: errorString!)
                                        }
                                    }
                                    
                                    
                                })
                                
                            }
                            else {
                                
                                MyTools.sharedInstance.performUIUpdatesOnMain {
                                    self.IBActivity.isHidden = true
                                    self.IBActivity.stopAnimating()
                                    self.displayAlert(self.translate.message("error"), mess: error!.localizedDescription)
                                }
                            }
                        }
                        
                    }
                    else {
                        
                        MyTools.sharedInstance.performUIUpdatesOnMain {
                            self.IBActivity.isHidden = true
                            self.IBActivity.stopAnimating()
                            self.displayAlert(self.translate.message("error"), mess: errorString!)
                        }
                    }
                    
                })
            }
            else {
                
                let braintreeClient = BTAPIClient.init(authorization: config.clientTokenBraintree!)!
                let cardClient = BTCardClient(apiClient: braintreeClient)
                
                let card = BTCard(number: self.IBNumber.text!, expirationMonth: String(month), expirationYear: String(year), cvv: nil)
                
                cardClient.tokenizeCard(card) { (tokenCard, error) in
                    // Communicate the tokenizedCard.nonce to your server, or handle error
                    if error == nil {
                        self.aCard.tokenizedCard = tokenCard!.nonce
                        
                        //user_id
                        self.aCard.user_id = self.config.user_id
                        
                        if Cards.sharedInstance.cardsArray.count == 0 || Cards.sharedInstance.cardsArray == nil {
                            self.aCard.main_card = true
                        }
                        
                        MDBCard.sharedInstance.setAddCard(self.aCard, completionHandlerCard: { (success, errorString) in
                            
                            if success {
                                Cards.sharedInstance.cardsArray = nil
                                MyTools.sharedInstance.performUIUpdatesOnMain {
                                    self.dismiss(animated: true, completion: nil)
                                }
                            }
                            else {
                                MyTools.sharedInstance.performUIUpdatesOnMain {
                                    self.IBActivity.isHidden = true
                                    self.IBActivity.stopAnimating()
                                    self.displayAlert(self.translate.message("error"), mess: errorString!)
                                }
                            }
                            
                            
                        })
                        
                    }
                    else {
                        MyTools.sharedInstance.performUIUpdatesOnMain {
                            self.IBActivity.isHidden = true
                            self.IBActivity.stopAnimating()
                            self.displayAlert(self.translate.message("error"), mess: error!.localizedDescription)
                        }
                    }
                    
                    
                }
                
            }
            
        }
        
    
    
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

        textField.endEditing(true)
        return true
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        
    }
    
    @IBAction func actionHelp(_ sender: Any) {
        
        //action info
        MyTools.sharedInstance.showHelp("CardTableViewController", self)
        
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
    
    
    private func callPayPal() {
        
        if config.clientTokenBraintree == "" {
            
            MDBPressOperation.sharedInstance.getBraintreeToken(config.user_id, completionHandlerbtToken: { (success, clientToken, errorString) in
                
                if success == true {
                    self.config.clientTokenBraintree = clientToken
                    let braintreeClient = BTAPIClient.init(authorization: self.config.clientTokenBraintree!)!
                    let payPalDriver = BTPayPalDriver(apiClient: braintreeClient)
                    payPalDriver.viewControllerPresentingDelegate = self
                    payPalDriver.appSwitchDelegate = self
                    
                    let request = BTPayPalRequest()
                    request.billingAgreementDescription = "Your agremeent description" //Displayed in customer's PayPal account
                    payPalDriver.requestBillingAgreement(request) { (tokenizedPayPalAccount, error) -> Void in
                        
                        if tokenizedPayPalAccount != nil  {
                            
                            self.aCard.tokenizedCard = tokenizedPayPalAccount!.nonce
                            
                            //user_id
                            self.aCard.user_id = self.config.user_id
                            if Cards.sharedInstance.cardsArray.count == 0 || Cards.sharedInstance.cardsArray == nil {
                                self.aCard.main_card = true
                            }
                            
                            MDBCard.sharedInstance.setAddCard(self.aCard, completionHandlerCard: { (success, errorString) in
                                
                                if success {
                                    Cards.sharedInstance.cardsArray = nil
                                    MyTools.sharedInstance.performUIUpdatesOnMain {
                                        self.dismiss(animated: true, completion: nil)
                                    }
                                }
                                else {
                                    MyTools.sharedInstance.performUIUpdatesOnMain {
                                        self.IBActivity.isHidden = true
                                        self.IBActivity.stopAnimating()
                                        self.displayAlert(self.translate.message("error"), mess: errorString!)
                                    }
                                }
                                
                                
                            })
                            
                            
                            
                        } else if error != nil {
                            
                            // Handle error here...
                            MyTools.sharedInstance.performUIUpdatesOnMain {
                                self.IBActivity.isHidden = true
                                self.IBActivity.stopAnimating()
                                self.displayAlert(self.translate.message("error"), mess: error!.localizedDescription)
                            }
                            
                        } else {
                            print("Buyer canceled payment approval")
                        }
                        
                    }
                    
                    
                }
                else {
                    
                    MyTools.sharedInstance.performUIUpdatesOnMain {
                        self.IBActivity.isHidden = true
                        self.IBActivity.stopAnimating()
                        self.displayAlert(self.translate.message("error"), mess: errorString!)
                    }
                }
                
            })
            
        }
        else {
            
            let braintreeClient = BTAPIClient.init(authorization: config.clientTokenBraintree!)!
            let payPalDriver = BTPayPalDriver(apiClient: braintreeClient)
            payPalDriver.viewControllerPresentingDelegate = self
            payPalDriver.appSwitchDelegate = self
            
            let request = BTPayPalRequest()
            request.billingAgreementDescription = "Your agremeent description" //Displayed in customer's PayPal account
            payPalDriver.requestBillingAgreement(request) { (tokenizedPayPalAccount, error) -> Void in
                
                if tokenizedPayPalAccount != nil  {
                    
                    self.aCard.tokenizedCard = tokenizedPayPalAccount!.nonce
                    
                    //user_id
                    self.aCard.user_id = self.config.user_id
                    if Cards.sharedInstance.cardsArray.count == 0 || Cards.sharedInstance.cardsArray == nil {
                        self.aCard.main_card = true
                    }
                    
                    MDBCard.sharedInstance.setAddCard(self.aCard, completionHandlerCard: { (success, errorString) in
                        
                        if success {
                            Cards.sharedInstance.cardsArray = nil
                            MyTools.sharedInstance.performUIUpdatesOnMain {
                                self.dismiss(animated: true, completion: nil)
                            }
                        }
                        else {
                            MyTools.sharedInstance.performUIUpdatesOnMain {
                                self.IBActivity.isHidden = true
                                self.IBActivity.stopAnimating()
                                self.displayAlert(self.translate.message("error"), mess: errorString!)
                            }
                        }
                        
                        
                    })
                    
                    
                } else if error != nil {
                    
                    // Handle error here...
                    MyTools.sharedInstance.performUIUpdatesOnMain {
                        self.IBActivity.isHidden = true
                        self.IBActivity.stopAnimating()
                        self.displayAlert(self.translate.message("error"), mess: error!.localizedDescription)
                    }
                    
                } else {
                    print("Buyer canceled payment approval")
                }
                
            }
            
            
        }
        
        
        
    }
    
    
    // MARK: - BTViewControllerPresentingDelegate
    
    func paymentDriver(_ driver: Any, requestsDismissalOf viewController: UIViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func paymentDriver(_ driver: Any, requestsPresentationOf viewController: UIViewController) {
        present(viewController, animated: true, completion: nil)
    }
    
    // MARK: - BTAppSwitchDelegate
    
    func appSwitcherWillPerformAppSwitch(_ appSwitcher: Any) {
        
    }
    
    func appSwitcher(_ appSwitcher: Any, didPerformSwitchTo target: BTAppSwitchTarget) {
        
    }
    
    func appSwitcherWillProcessPaymentInfo(_ appSwitcher: Any) {
        
    }
   
    
    
}
