//
//  AbonnerViewController.swift
//  PressShare
//
//  Description : This class contains account balance, withdrawal, deposit, operation history
//
//  Created by MacbookPRV on 28/11/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//


/* Info Sandbox Braintree (Paypal) :
 
 ------------------------------------------------------------------------------------------------------------------
 https://sandbox.braintreegateway.com
 user : fxpast@gmail.com
 password: fxpastsandbox1
 
 Merchant ID: ngygpwcrrdbqybjm
 Public Key: fxwvx5twt9ft8gyy
 Private Key: 6d9a2c5d55a9fab4700aa33e10281274
 
 dev ios : https://github.com/braintree/braintree_ios
 
 ------------------------------------------------------------------------------------------------------------------
 */

//Todo: aide SubscriptViewController ne fonctionne pas


import Foundation
import BraintreeCore
import BraintreeCard

class SubscriptViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource  {
    
    @IBOutlet weak var IBBarCancel: UIBarButtonItem!
    @IBOutlet weak var IBActivity: UIActivityIndicatorView!
    @IBOutlet weak var IBTableView: UITableView!
    @IBOutlet weak var IBBalance: UITextField!
    @IBOutlet weak var IBWithdrawal: UITextField!
    @IBOutlet weak var IBDeposit: UITextField!
    @IBOutlet weak var IBLabelBalance: UILabel!
    @IBOutlet weak var IBButtonWithdr: UIButton!
    @IBOutlet weak var IBLabelDeposit: UILabel!
    @IBOutlet weak var IBButtonDeposit: UIButton!
    @IBOutlet weak var IBButtonSubUnsub: UIButton!
    @IBOutlet weak var IBLabelWithdraw: UILabel!
    @IBOutlet weak var IBEntete: UILabel!
    
    var fieldName = ""
    var keybordY:CGFloat! = 0
    var config = Config.sharedInstance
    let translate = TranslateMessage.sharedInstance
    var isOpen = false
    var operations = [PressOperation]()
    
    var customOpeation = BlockOperation()
    let myQueue = OperationQueue()
    

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
        
        self.title = translate.message("mySubscrit")
        IBBalance.text = BlackBox.sharedInstance.formatedAmount(config.balance!)
        IBBalance.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        IBEntete.text = "\(translate.message("date"))        \(translate.message("type"))    \(translate.message("amount"))  \(translate.message("wording"))"
        
        if Cards.sharedInstance.cardsArray == nil {
            
            MDBTypeCard.sharedInstance.getAllTypeCards(completionHandlerTypeCards: {(success, typeCardsArray, errorString) in
                
                if success {
                    TypeCards.sharedInstance.typeCardsArray = typeCardsArray
                }
                else {
                    
                    BlackBox.sharedInstance.performUIUpdatesOnMain {
                        self.displayAlert(self.translate.message("error"), mess: errorString!)
                    }
                }
                
            })
            
            
            MDBCard.sharedInstance.getAllCards(user_id: config.user_id, completionHandlerCards: {(success, cardsArray, errorString) in
                if success {
                    Cards.sharedInstance.cardsArray = cardsArray
                    
                    for card in Cards.sharedInstance.cardsArray {
                        self.aCard = Card(dico: card)
                        if self.aCard.main_card == true {
                            break
                        }
                        else {
                            self.aCard = nil
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
            
            for card in Cards.sharedInstance.cardsArray {
                aCard = Card(dico: card)
                if aCard.main_card == true {
                    break
                }
                else {
                    aCard = nil
                }
            }
            
        }
        
        
        IBLabelBalance.text = translate.message("balance")
        IBLabelWithdraw.text = translate.message("withdrawal")
        IBLabelDeposit.text = translate.message("deposit")
        IBButtonWithdr.setTitle(translate.message("done"), for: UIControlState.normal)
        IBButtonDeposit.setTitle(translate.message("done"), for: UIControlState.normal)
        
        if config.level <= 0 {
            IBButtonSubUnsub.setTitle(translate.message("subscribe"), for: UIControlState.normal)
            IBButtonDeposit.isEnabled = false
            IBButtonWithdr.isEnabled = false
        }
        else  if config.level > 0 {
            IBButtonSubUnsub.setTitle(translate.message("unsubscribe"), for: UIControlState.normal)
            IBButtonDeposit.isEnabled = true
            IBButtonWithdr.isEnabled = true
        }
        
        subscibeToKeyboardNotifications()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if isOpen == false {
            isOpen = true
            IBActivity.isHidden = false
            IBActivity.startAnimating()
            if let _ = PressOperations.sharedInstance.operationArray {
                
                myQueue.addOperation {
                    
                    self.customOpeation = BlockOperation()
                    self.customOpeation.addExecutionBlock {
                        if !self.customOpeation.isCancelled
                        {
                            
                            self.chargeData()
                            
                            BlackBox.sharedInstance.performUIUpdatesOnMain {
                                
                                self.IBActivity.stopAnimating()
                                self.IBActivity.isHidden = true
                                
                            }
                            
                        }
                    }
                    
                    self.customOpeation.start()
                    
                }
                
            }
            else {
                refreshData()
            }
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
        
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if fieldName == "IBWithdrawal" {
            IBWithdrawal.endEditing(true)
        }
        else if fieldName == "IBDeposit" {
            IBDeposit.endEditing(true)
        }
        
    }
    
    @IBAction func actionHelp(_ sender: Any) {
        
        //action info
        BlackBox.sharedInstance.showHelp("SubscriptViewController", self)
        
    }
    
    
    @IBAction func actionCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func actionRefresh(_ sender: Any) {
        
        refreshData()
        
    }
    
    
    //MARK: textfield Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        
        if textField.isEqual(IBWithdrawal) {
            
            
            guard let _ = NumberFormatter().number(from: IBWithdrawal.text!) else {
                
                displayAlert(translate.message("error"), mess: translate.message("ErrorPrice"))
                return false
                
            }
            
        }
        
        textField.endEditing(true)
        return true
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        
        if textField.isEqual(IBWithdrawal) {
            fieldName = "IBWithdrawal"
        }
        else if textField.isEqual(IBDeposit) {
            fieldName = "IBDeposit"
        }
        
    }
    
    
    //MARK: Data operation , capital
    
    private func withdrawal(_ amount: Double, _ typeOp: Int) {
        
        self.config.balance = config.balance - amount
        var capital = Capital(dico: [String : AnyObject]())
        capital.balance = self.config.balance
        capital.user_id = self.config.user_id
        capital.failure_count = self.config.failure_count
        
        var operation = PressOperation(dico: [String : AnyObject]())
        operation.user_id = self.config.user_id
        operation.op_type = typeOp
        operation.op_amount = -1 * amount
        if typeOp == 2 {
            //withdrawal
            operation.op_wording = self.translate.message("OneTimeWithd")
        }
        else if typeOp == 6 {
            //refund
            operation.op_wording = self.translate.message("OneTimeRefund")
        }
        
        
        MDBCapital.sharedInstance.setUpdateCapital(capital, completionHandlerUpdate: { (success, errorString) in
            
            if success {
                
                MDBPressOperation.sharedInstance.setAddOperation(operation, completionHandlerAddOp: {(success, errorString) in
                    
                    if success {
                        
                        MDBPressOperation.sharedInstance.getAllOperations(self.config.user_id, completionHandlerOperations: {(success, operationArray, errorString) in
                            
                            if success {
                                
                                PressOperations.sharedInstance.operationArray = operationArray
                                BlackBox.sharedInstance.performUIUpdatesOnMain {
                                    self.IBActivity.isHidden = true
                                    self.IBActivity.stopAnimating()
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
                        
                        BlackBox.sharedInstance.performUIUpdatesOnMain {
                            
                            self.IBBalance.text = BlackBox.sharedInstance.formatedAmount(self.config.balance!)
                            
                            self.IBWithdrawal.text = ""
                            self.IBWithdrawal.endEditing(true)
                            self.refreshData()
                            self.displayAlert("info", mess: self.translate.message("withdrawalMade"))
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
            else {
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    
                    self.displayAlert(self.translate.message("error"), mess: errorString!)
                    self.IBActivity.isHidden = true
                    self.IBActivity.stopAnimating()
                }
            }
            
            
        })
        
    }
    
    @IBAction func actionWithdrawal(_ sender: Any) {
        
        let alertController = UIAlertController(title: translate.message("withdrawal"), message: translate.message("confirmWithdrawal"), preferredStyle: .alert)
        
        let actionValider = UIAlertAction(title: translate.message("done"), style: .destructive, handler: { (action) in
            
            guard self.IBWithdrawal.text != "" else {
                
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    
                    self.displayAlert(self.translate.message("error"), mess: "\(self.translate.message("withdrawal")) : \(self.translate.message("ErrorPrice"))")
                }
                
                return
            }
            
            guard let amount = BlackBox.sharedInstance.formatedAmount(self.IBWithdrawal.text!) else {
                
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    self.displayAlert(self.translate.message("error"), mess: "\(self.translate.message("withdrawal")) : \(self.translate.message("ErrorPrice"))")
                }
                
                return
            }
            
            let finalValue = self.IBBalance.text! as String
            guard let balance = BlackBox.sharedInstance.formatedAmount(finalValue) else {
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    self.displayAlert(self.translate.message("error"), mess: "\(self.translate.message("balance")) : \(self.translate.message("ErrorPrice"))")
                    
                }
                return
            }
            
            guard balance >= (amount + self.config.minimumAmount!) else {
                
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    self.displayAlert(self.translate.message("error"), mess: "\(self.translate.message("errorBalanceTrans")) \n \(self.translate.message("errorMinimumBal")) \(self.config.minimumAmount!)")
                    
                }
                
                return
            }
            
            self.IBActivity.isHidden = false
            self.IBActivity.startAnimating()
            self.braintreeOperation(amount, "withdrawal")
            
        })
        
        let actionCancel = UIAlertAction(title: translate.message("cancel"), style: .destructive, handler: { (action) in
            
        })
        
        alertController.addAction(actionCancel)
        alertController.addAction(actionValider)
        
        present(alertController, animated: true) {
            
        }
    }
    
    
    
    @IBAction func actionDeposit(_ sender: Any) {
        
        var alertController = UIAlertController()
        
        if aCard == nil {
            
            
            alertController = UIAlertController(title: "Carte de credit", message: "Ajouter une carte de credit", preferredStyle: .alert)
            
            let actionValider = UIAlertAction(title: translate.message("done"), style: .destructive, handler: { (action) in
                
                self.performSegue(withIdentifier: "CB", sender: self)
                
            })
            
            let actionCancel = UIAlertAction(title: translate.message("cancel"), style: .destructive, handler: { (action) in
                
            })
            
            alertController.addAction(actionCancel)
            alertController.addAction(actionValider)
            
         
            
        }
        else {
            
            alertController = UIAlertController(title: translate.message("deposit"), message: translate.message("confirmPayment"), preferredStyle: .alert)
            
            let actionValider = UIAlertAction(title: translate.message("done"), style: .destructive, handler: { (action) in
                
                guard self.IBDeposit.text != "" else {
                    
                    BlackBox.sharedInstance.performUIUpdatesOnMain {
                        
                        self.displayAlert(self.translate.message("error"), mess: "\(self.translate.message("deposit")) : \(self.translate.message("ErrorPrice"))")
                    }
                    
                    return
                }
                
                guard let amount = BlackBox.sharedInstance.formatedAmount(self.IBDeposit.text!) else {
                    
                    BlackBox.sharedInstance.performUIUpdatesOnMain {
                        
                        self.displayAlert(self.translate.message("error"), mess: "\(self.translate.message("deposit")) : \(self.translate.message("ErrorPrice"))")
                    }
                    
                    return
                }
                
                self.IBActivity.isHidden = false
                self.IBActivity.startAnimating()
                self.braintreeOperation(amount, "deposit")
                
            })
            
            let actionCancel = UIAlertAction(title: translate.message("cancel"), style: .destructive, handler: { (action) in
                
                
            })
            
            alertController.addAction(actionCancel)
            alertController.addAction(actionValider)
            
        }
        
        
        present(alertController, animated: true) {
            
        }
        
    }
    
    
    private func braintreeOperation(_ amount: Double, _ type: String) {
        
        MDBPressOperation.sharedInstance.operationBraintree(type, self.config.user_id, amount, completionHandlerNonce: { (success, restAmount, errorString) in
            
            if success == true {
                if type == "deposit" {
                    self.deposit(amount)
                }
                else if type == "withdrawal" {
                    let rest = Double(restAmount!)!
                    if rest > 0 {
                        
                        if amount > rest {
                            //refund
                            self.withdrawal(amount - rest, 6)
                        }
                    
                        //withdrawal
                        self.withdrawal(rest, 2)
                        
                    }
                    else {
                        //refund
                        self.withdrawal(amount - rest, 6)
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
    
    
    private func deposit(_ amount: Double) {
        
        config.balance = config.balance + amount
        var capital = Capital(dico: [String : AnyObject]())
        capital.balance = config.balance
        capital.user_id = config.user_id
        capital.failure_count = config.failure_count
        
        var operation = PressOperation(dico: [String : AnyObject]())
        operation.user_id = config.user_id
        operation.op_type = 1
        operation.op_amount = amount
        operation.op_wording = translate.message("OneTimeDepo")
        
        MDBCapital.sharedInstance.setUpdateCapital(capital, completionHandlerUpdate: { (success, errorString) in
            
            if success {
                
                MDBPressOperation.sharedInstance.setAddOperation(operation, completionHandlerAddOp: {(success, errorString) in
                    
                    if success {
                        
                        MDBPressOperation.sharedInstance.getAllOperations(self.config.user_id, completionHandlerOperations: {(success, operationArray, errorString) in
                            
                            if success {
                                
                                PressOperations.sharedInstance.operationArray = operationArray
                                
                                BlackBox.sharedInstance.performUIUpdatesOnMain {
                                    self.IBActivity.isHidden = true
                                    self.IBActivity.stopAnimating()
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
                        
                        BlackBox.sharedInstance.performUIUpdatesOnMain {
                            
                            self.IBBalance.text = BlackBox.sharedInstance.formatedAmount(self.config.balance!)
                            
                            self.IBDeposit.text = ""
                            self.IBDeposit.endEditing(true)
                            self.refreshData()
                            self.displayAlert("info", mess: self.translate.message("paymentMade"))
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
            else {
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    
                    self.displayAlert(self.translate.message("error"), mess: errorString!)
                    self.IBActivity.isHidden = true
                    self.IBActivity.stopAnimating()
                }
            }
            
            
        })
        
        
    }
    
    @IBAction func actionSubUnsub(_ sender: Any) {
        
        var mess = ""
        if self.config.level <= 0 && self.config.balance == 0 {
            
            mess = translate.message("confirmSubsWithDepot")
        }
        else if self.config.level <= 0 && self.config.balance > 0 {
            
            mess = translate.message("confirmSubs")
        }
        else if self.config.level > 0 {
            
            mess = translate.message("confirmTermin")
        }
        
        
        let alertController = UIAlertController(title: (self.config.level <= 0) ? translate.message("subscribeSubs") : translate.message("cancelSubs"), message: mess, preferredStyle: .alert)
        
        let actionValider = UIAlertAction(title: translate.message("done"), style: .destructive, handler: { (action) in
            
            self.IBActivity.isHidden = false
            self.IBActivity.startAnimating()
            
            if self.config.level <= 0 && self.config.balance == 0 {
               
                self.braintreeOperation(self.config.subscriptAmount!, "deposit")
            }
            else if self.config.level > 0 && self.config.balance > 0 {
                
                self.braintreeOperation(self.config.balance!, "withdrawal")
                
            }
            
            
            self.config.level = (self.config.level <= 0) ? 1 : 0
            
            MDBUser.sharedInstance.setUpdateUser(self.config) { (success, errorString) in
                
                if success {
                    BlackBox.sharedInstance.performUIUpdatesOnMain {
                        
                        if self.config.level <= 0 {
                            self.IBButtonSubUnsub.setTitle(self.translate.message("subscribe"), for: UIControlState.normal)
                            self.IBButtonDeposit.isEnabled = false
                            self.IBButtonWithdr.isEnabled = false
                        }
                        else  if self.config.level > 0 {
                            self.IBButtonSubUnsub.setTitle(self.translate.message("unsubscribe"), for: UIControlState.normal)
                            self.IBButtonDeposit.isEnabled = true
                            self.IBButtonWithdr.isEnabled = true
                        }
                        
                        self.displayAlert("info", mess: "\(self.translate.message("subscriptionHas")) \((self.config.level <= 0) ?  self.translate.message("canceled"): self.translate.message("confirmed"))")
                        
                    }
                }
                else {
                    BlackBox.sharedInstance.performUIUpdatesOnMain {
                        self.displayAlert(self.translate.message("error"), mess: errorString!)
                        
                    }
                }
                
            }
            
            
            
            
        })
        
        let actionCancel = UIAlertAction(title: translate.message("cancel"), style: .destructive, handler: { (action) in
            
            
            
        })
        
        alertController.addAction(actionCancel)
        alertController.addAction(actionValider)
        
        
        present(alertController, animated: true) {
            
        }
        
        
    }
    
    
    private func refreshData()  {
        
        myQueue.cancelAllOperations()
        guard myQueue.operationCount == 0 else {
            
            return
        }
        
        IBActivity.isHidden = false
        IBActivity.startAnimating()
        
        operations.removeAll()
        IBTableView.reloadData()
        
        MDBCapital.sharedInstance.getCapital(config.user_id, completionHandlerCapital: {(success, capitalArray, errorString) in
            
            if success {
                
                Capitals.sharedInstance.capitalsArray = capitalArray
                for dictionary in Capitals.sharedInstance.capitalsArray {
                    let capital = Capital(dico: dictionary)
                    self.config.balance = capital.balance
                    self.config.failure_count = capital.failure_count
                }
                
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    self.IBBalance.text = BlackBox.sharedInstance.formatedAmount(self.config.balance!)
                    
                }
            }
            else {
                
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    self.displayAlert(self.translate.message("error"), mess: errorString!)
                }
            }
            
            
        })
        
        
        MDBPressOperation.sharedInstance.getAllOperations(config.user_id, completionHandlerOperations: {(success, operationArray, errorString) in
            
            if success {
                
                PressOperations.sharedInstance.operationArray = operationArray
                self.chargeData()
                
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    self.IBActivity.stopAnimating()
                    self.IBActivity.isHidden = true
                }
            }
            else {
                
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    self.IBActivity.stopAnimating()
                    self.IBActivity.isHidden = true
                    self.displayAlert(self.translate.message("error"), mess: errorString!)
                }
            }
            
        })
        
    }
    
    
    private func chargeData() {
        
        
        for ope in PressOperations.sharedInstance.operationArray {
            
            if customOpeation.isCancelled {
                break
            }
            
            let opera = PressOperation(dico: ope)
            operations.append(opera)
            
            BlackBox.sharedInstance.performUIUpdatesOnMain {
                
                self.IBTableView.reloadData()
                
            }
            
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
        
        
        if fieldName == "IBWithdrawal" {
            textField = IBWithdrawal
        }
        else if fieldName == "IBDeposit" {
            textField = IBDeposit
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
        
        
        if fieldName == "IBWithdrawal" {
            textField = IBWithdrawal
        }
        else if fieldName == "IBDeposit" {
            textField = IBDeposit
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
    
    //MARK: Table View Controller data source
    
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(descriptor: (header.textLabel?.font.fontDescriptor)!, size: 14)
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let CellReuseId = "cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: CellReuseId) as UITableViewCell!
        let operation =  operations[(indexPath as NSIndexPath).row]
        
        let adate = cell?.contentView.viewWithTag(10) as! UILabel
        
        adate.text =  "\(operation.op_date)"
        let index = adate.text?.index((adate.text?.startIndex)!, offsetBy: 10)
        adate.text = adate.text?.substring(to: index!)
        
        //1: deposit, 2: withdrawal, 3: buy, 4: sell, 5:Commission, 6:refund
        
        let atype =  cell?.contentView.viewWithTag(20) as! UILabel
        if operation.op_type == 1 {
            atype.text =  translate.message("deposit")
        }
        else if operation.op_type == 2 {
            atype.text =  translate.message("withdrawal")
        }
        else if operation.op_type == 3 {
            atype.text =  translate.message("buy")
        }
        else if operation.op_type == 4 {
            atype.text =  translate.message("sell")
        }
        else if operation.op_type == 5 {
            atype.text =  translate.message("commission")
        }
        else if operation.op_type == 6 {
            atype.text =  translate.message("refund")
        }
        let aAmount = cell?.contentView.viewWithTag(30) as! UILabel
        aAmount.text = BlackBox.sharedInstance.formatedAmount(operation.op_amount)
        
        let aLabel = cell?.contentView.viewWithTag(40) as! UILabel
        aLabel.text = operation.op_wording
        
        return cell!
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return operations.count
    }
    
    
    
}
