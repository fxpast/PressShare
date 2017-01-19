//
//  AbonnerViewController.swift
//  PressShare
//
//  Description : This class contains account balance, withdrawal, deposit, operation history
//
//  Created by MacbookPRV on 28/11/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//

//Todo: add on the operation line detail product


import CoreData
import Foundation

class SubscriptViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate  {
    
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
    
    var users = [User]()
    
    var fieldName = ""
    var keybordY:CGFloat! = 0
    var config = Config.sharedInstance
    let translate = TranslateMessage.sharedInstance
    var flgOpen=false
    var operations = [Operation]()
    
    var customOpeation = BlockOperation()
    let myQueue = OperationQueue()
    
    let subscriptAmount = 10.0
    
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
    
    var sharedContext: NSManagedObjectContext {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.managedObjectContext
    }
    
    
    //MARK: View Controller Delegate
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        users = fetchAllUser()
        
        IBBalance.text = BlackBox.sharedInstance.formatedAmount(config.balance!)
        
        IBBalance.isEnabled = false
        
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        IBLabelBalance.text = translate.balance
        IBLabelWithdraw.text = translate.withdrawal
        IBLabelDeposit.text = translate.deposit
        IBButtonWithdr.setTitle(translate.done, for: UIControlState.normal)
        IBButtonDeposit.setTitle(translate.done, for: UIControlState.normal)
        
        if config.level <= 0 {
            IBButtonSubUnsub.setTitle(translate.subscribe, for: UIControlState.normal)
            IBButtonDeposit.isEnabled = false
            IBButtonWithdr.isEnabled = false
        }
        else  if config.level > 0 {
            IBButtonSubUnsub.setTitle(translate.unsubscribe, for: UIControlState.normal)
            IBButtonDeposit.isEnabled = true
            IBButtonWithdr.isEnabled = true
        }
        
        subscibeToKeyboardNotifications()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if flgOpen == false {
            flgOpen = true
            IBActivity.isHidden = false
            IBActivity.startAnimating()
            if let _ = Operations.sharedInstance.operationArray {
                
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
                
                displayAlert(translate.error, mess: translate.ErrorPrice)
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
    
    
    @IBAction func actionWithdrawal(_ sender: Any) {
        
        let alertController = UIAlertController(title: translate.withdrawal, message: translate.confirmWithdrawal, preferredStyle: .alert)
        
        let actionValider = UIAlertAction(title: translate.done, style: .destructive, handler: { (action) in
            
            guard self.IBWithdrawal.text != "" else {
                
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    
                    self.displayAlert(self.translate.error, mess: "\(self.translate.withdrawal!) : \(self.translate.ErrorPrice!)")
                }
                
                return
            }
            
            guard let amount = BlackBox.sharedInstance.formatedAmount(self.IBWithdrawal.text!) else {
                
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    self.displayAlert(self.translate.error, mess: "\(self.translate.withdrawal!) : \(self.translate.ErrorPrice!)")
                }
                
                return
            }
            
            var finalValue = self.IBBalance.text! as String
            finalValue = finalValue.replacingOccurrences(of: self.translate.devise!, with: "")
            finalValue = finalValue.replacingOccurrences(of: " ", with: "")
            
            guard let balance = BlackBox.sharedInstance.formatedAmount(finalValue) else {
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    self.displayAlert(self.translate.error, mess: "\(self.translate.balance!) : \(self.translate.ErrorPrice!)")
                    
                }
                return
            }
            
            
            guard balance >= amount else {
                
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    self.displayAlert(self.translate.error, mess: self.translate.errorBalanceTrans)
                    
                }
                
                return
            }
            
            
            self.config.balance = balance - amount
            var capital = Capital(dico: [String : AnyObject]())
            capital.balance = self.config.balance
            capital.user_id = self.config.user_id
            capital.failure_count = self.config.failure_count
            
            var operation = Operation(dico: [String : AnyObject]())
            operation.user_id = self.config.user_id
            operation.op_type = 2
            operation.op_amount = -1 * amount
            operation.op_wording = self.translate.OneTimeWithd
            
            MDBCapital.sharedInstance.setUpdateCapital(capital, completionHandlerUpdate: { (success, errorString) in
                
                if success {
                    
                    MDBOperation.sharedInstance.setAddOperation(operation, completionHandlerAddOp: {(success, errorString) in
                        
                        if success {
                            
                            BlackBox.sharedInstance.performUIUpdatesOnMain {
                                
                                
                                if self.translate.lang == "fr" {
                                    
                                    self.IBBalance.text = BlackBox.sharedInstance.formatedAmount(self.config.balance!)
                                }
                                else if self.translate.lang == "us" {
                                    
                                    self.IBBalance.text = BlackBox.sharedInstance.formatedAmount(self.config.balance!)
                                    
                                    
                                }
                                
                                
                                self.IBWithdrawal.text = ""
                                self.IBWithdrawal.endEditing(true)
                                self.refreshData()
                                self.displayAlert("info", mess: self.translate.withdrawalMade)
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
        
        let actionCancel = UIAlertAction(title: translate.cancel, style: .destructive, handler: { (action) in
            
            
            
        })
        
        alertController.addAction(actionCancel)
        alertController.addAction(actionValider)
        
        
        present(alertController, animated: true) {
            
        }
    }
    
    
    
    @IBAction func actionDeposit(_ sender: Any) {
        
        
        let alertController = UIAlertController(title: translate.deposit, message: translate.confirmPayment, preferredStyle: .alert)
        
        let actionValider = UIAlertAction(title: translate.done, style: .destructive, handler: { (action) in
            
            guard self.IBDeposit.text != "" else {
                
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    
                    self.displayAlert(self.translate.error, mess: "\(self.translate.deposit!) : \(self.translate.ErrorPrice!)")
                }
                
                return
            }
            
            guard let amount = BlackBox.sharedInstance.formatedAmount(self.IBDeposit.text!) else {
                
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    
                    self.displayAlert(self.translate.error, mess: "\(self.translate.deposit!) : \(self.translate.ErrorPrice!)")
                }
                
                return
            }
            
            self.addDeposit(amount)
            
        })
        
        let actionCancel = UIAlertAction(title: translate.cancel, style: .destructive, handler: { (action) in
            
            
        })
        
        alertController.addAction(actionCancel)
        alertController.addAction(actionValider)
        
        
        present(alertController, animated: true) {
            
        }
        
        
    }
    
    
    private func addDeposit(_ amount: Double) {
        
        config.balance = config.balance + amount
        var capital = Capital(dico: [String : AnyObject]())
        capital.balance = config.balance
        capital.user_id = config.user_id
        capital.failure_count = config.failure_count
        
        var operation = Operation(dico: [String : AnyObject]())
        operation.user_id = config.user_id
        operation.op_type = 1
        operation.op_amount = amount
        operation.op_wording = translate.OneTimeDepo
        
        MDBCapital.sharedInstance.setUpdateCapital(capital, completionHandlerUpdate: { (success, errorString) in
            
            if success {
                
                MDBOperation.sharedInstance.setAddOperation(operation, completionHandlerAddOp: {(success, errorString) in
                    
                    if success {
                        
                        BlackBox.sharedInstance.performUIUpdatesOnMain {
                            
                            
                            if self.translate.lang == "fr" {
                                
                                self.IBBalance.text = BlackBox.sharedInstance.formatedAmount(self.config.balance!)
                                
                            }
                            else if self.translate.lang == "us" {
                                
                                self.IBBalance.text = BlackBox.sharedInstance.formatedAmount(self.config.balance!)
                                
                                
                            }
                            
                            
                            self.IBDeposit.text = ""
                            self.IBDeposit.endEditing(true)
                            self.refreshData()
                            self.displayAlert("info", mess: self.translate.paymentMade)
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
        
        
    }
    
    @IBAction func actionSubUnsub(_ sender: Any) {
        
        var mess = ""
        if self.config.level <= 0 && self.config.balance == 0 {
            
            mess = translate.confirmSubsWithDepot
        }
        else if self.config.level <= 0 && self.config.balance > 0 {
            
            mess = translate.confirmSubs
        }
        else if self.config.level > 0 {
            
            mess = translate.confirmTermin
        }
        
        
        let alertController = UIAlertController(title: (self.config.level <= 0) ? translate.subscribeSubs : translate.cancelSubs, message: mess, preferredStyle: .alert)
        
        let actionValider = UIAlertAction(title: translate.done, style: .destructive, handler: { (action) in
            
            if self.config.level <= 0 && self.config.balance == 0 {
                
                self.addDeposit(self.subscriptAmount)
            }
            
            
            self.config.level = (self.config.level <= 0) ? 1 : 0
            
            MDBUser.sharedInstance.setUpdateUser(self.config) { (success, errorString) in
                
                if success {
                    BlackBox.sharedInstance.performUIUpdatesOnMain {
                        
                        if self.users.count > 0 {
                            self.assignUser(self.users[0])
                        }
                        
                        if self.config.level <= 0 {
                            self.IBButtonSubUnsub.setTitle(self.translate.subscribe, for: UIControlState.normal)
                            self.IBButtonDeposit.isEnabled = false
                            self.IBButtonWithdr.isEnabled = false
                        }
                        else  if self.config.level > 0 {
                            self.IBButtonSubUnsub.setTitle(self.translate.unsubscribe, for: UIControlState.normal)
                            self.IBButtonDeposit.isEnabled = true
                            self.IBButtonWithdr.isEnabled = true
                        }
                        
                        self.displayAlert("info", mess: "\(self.translate.subscriptionHas!) \((self.config.level <= 0) ?  self.translate.canceled!: self.translate.confirmed!)")
                        
                    }
                }
                else {
                    BlackBox.sharedInstance.performUIUpdatesOnMain {
                        self.displayAlert(self.translate.error, mess: errorString!)
                        
                    }
                }
                
            }
            
            
            
            
        })
        
        let actionCancel = UIAlertAction(title: translate.cancel, style: .destructive, handler: { (action) in
            
            
            
        })
        
        alertController.addAction(actionCancel)
        alertController.addAction(actionValider)
        
        
        present(alertController, animated: true) {
            
        }
        
        
    }
    
    
    
    private func assignUser(_ aUser:User) {
        
        aUser.user_pseudo = config.user_pseudo
        aUser.user_email = config.user_email
        aUser.user_nom = config.user_nom
        aUser.user_prenom = config.user_prenom
        aUser.user_pays = config.user_pays
        aUser.user_ville = config.user_ville
        aUser.user_adresse = config.user_adresse
        aUser.user_codepostal = config.user_codepostal
        aUser.user_pass = config.user_pass
        aUser.user_level = config.level as NSNumber?
        
        // Save the context.
        do {
            try sharedContext.save()
        } catch _ {}
        
        
        users = fetchAllUser()
        
        
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
                    self.displayAlert(self.translate.error, mess: errorString!)
                }
            }
            
            
        })
        
        
        MDBOperation.sharedInstance.getAllOperations(config.user_id, completionHandlerOperations: {(success, operationArray, errorString) in
            
            if success {
                
                Operations.sharedInstance.operationArray = operationArray
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
                    self.displayAlert(self.translate.error, mess: errorString!)
                }
            }
            
        })
        
    }
    
    
    private func chargeData() {
        
        
        for ope in Operations.sharedInstance.operationArray {
            
            if customOpeation.isCancelled {
                break
            }
            
            let opera = Operation(dico: ope)
            operations.append(opera)
            
            BlackBox.sharedInstance.performUIUpdatesOnMain {
                
                self.IBTableView.reloadData()
                
            }
            
        }
        
        
    }
    
    
    //MARK: coreData function
    
    private func fetchAllUser() -> [User] {
        
        
        users.removeAll()
        
        // Create the Fetch Request
        
        
        let request : NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "User")
        
        // Execute the Fetch Request
        do {
            return try sharedContext.fetch(request) as! [User]
        } catch _ {
            return [User]()
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
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return  "\(translate.date!)        \(translate.type!)    \(translate.amount!)  \(translate.wording!)"
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let CellReuseId = "cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: CellReuseId) as UITableViewCell!
        let operation =  operations[(indexPath as NSIndexPath).row]
        
        let adate = cell?.contentView.viewWithTag(10) as! UILabel
        
        adate.text =  "\(operation.op_date)"
        let index = adate.text?.index((adate.text?.startIndex)!, offsetBy: 10)
        adate.text = adate.text?.substring(to: index!)
        
        //1: deposit, 2: withdrawal, 3: buy, 4: sell, 5:Commission
        
        let atype =  cell?.contentView.viewWithTag(20) as! UILabel
        if operation.op_type == 1 {
            atype.text =  translate.deposit
        }
        else if operation.op_type == 2 {
            atype.text =  translate.withdrawal
        }
        else if operation.op_type == 3 {
            atype.text =  translate.buy
        }
        else if operation.op_type == 4 {
            atype.text =  translate.sell
        }
        else if operation.op_type == 5 {
            atype.text =  translate.commission
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
