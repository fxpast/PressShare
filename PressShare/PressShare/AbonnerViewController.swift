//
//  AbonnerViewController.swift
//  PressShare
//
//  Created by MacbookPRV on 28/11/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//


import Foundation

class AbonnerViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate  {
    
    
    @IBOutlet weak var IBActivity: UIActivityIndicatorView!
    @IBOutlet weak var IBTableView: UITableView!
    @IBOutlet weak var IBSolde: UITextField!
    @IBOutlet weak var IBRetrait: UITextField!
    @IBOutlet weak var IBVersement: UITextField!
    
    var fieldName = ""
    var keybordY:CGFloat! = 0
    var config = Config.sharedInstance
    let traduction = InternationalIHM.sharedInstance
    
    var operations = [Operation]()
    
    var customOpeation = BlockOperation()
    let myqueue = OperationQueue()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        IBSolde.text = "\(FormaterMontant(config.solde!)) \(traduction.devise!)"
        IBSolde.isEnabled = false
        
       
        IBActivity.isHidden = false
        IBActivity.startAnimating()
        IBTableView.isHidden = true
        if let _ = Operations.sharedInstance.operationArray {
            
            myqueue.addOperation {
                
                self.customOpeation = BlockOperation()
                self.customOpeation.addExecutionBlock {
                    if !self.customOpeation.isCancelled
                    {
                        
                        self.chargerData()
                        
                        performUIUpdatesOnMain {
                            
                            self.IBTableView.reloadData()
                            self.IBActivity.stopAnimating()
                            self.IBActivity.isHidden = true
                            self.IBTableView.isHidden = false
                            
                        }
                        
                    }
                }
                
                self.customOpeation.start()
                
            }
            
        }
        else {
            RefreshData()
        }
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        subscibeToKeyboardNotifications()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
        
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if fieldName == "IBRetrait" {
            IBRetrait.endEditing(true)
        }
        else if fieldName == "IBVersement" {
            IBVersement.endEditing(true)
        }
        
        
    }
    
    
    
    //MARK: textfield Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        
        if textField.isEqual(IBRetrait) {
            
            
            guard let _ = NumberFormatter().number(from: IBRetrait.text!) else {
                
                displayAlert("Error", mess: "valeur incorrecte")
                return false
                
            }
            
        }
        
        textField.endEditing(true)
        return true
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        
        if textField.isEqual(IBRetrait) {
            fieldName = "IBRetrait"
        }
        else if textField.isEqual(IBVersement) {
            fieldName = "IBVersement"
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
        
        
        if fieldName == "IBRetrait" {
            textField = IBRetrait
        }
        else if fieldName == "IBVersement" {
            textField = IBVersement
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
        
        
        if fieldName == "IBRetrait" {
            textField = IBRetrait
        }
        else if fieldName == "IBVersement" {
            textField = IBVersement
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
    
    
    @IBAction func ActionCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func ActionRetrait(_ sender: Any) {
        
        let alertController = UIAlertController(title: "Retrait", message: "Confirmer votre retrait", preferredStyle: .alert)
        
        let actionValider = UIAlertAction(title: "Valider", style: .destructive, handler: { (action) in
            
            guard let montant = FormaterMontant(self.IBRetrait.text!) else {
                
                performUIUpdatesOnMain {
                    self.displayAlert("Error", mess: "montant retrait incorrect!")
                }
                
                return
            }
            
            var valeurfinal = self.IBSolde.text! as String
            valeurfinal = valeurfinal.replacingOccurrences(of: self.traduction.devise!, with: "")
            valeurfinal = valeurfinal.replacingOccurrences(of: " ", with: "")
            
            guard let solde = FormaterMontant(valeurfinal) else {
                performUIUpdatesOnMain {
                    self.displayAlert("Error", mess: "solde incorrect!")
                    
                }
                return
            }

            
            guard solde >= montant else {
                
                performUIUpdatesOnMain {
                    self.displayAlert("Error", mess: "solde insuffisant!")
                    
                }
                
                return
            }
            
            
            self.config.solde = solde - montant
            var capital = Capital(dico: [String : AnyObject]())
            capital.solde = self.config.solde
            capital.user_id = self.config.user_id
            
            var operation = Operation(dico: [String : AnyObject]())
            operation.user_id = self.config.user_id
            operation.op_type = 2
            operation.op_montant = montant
            operation.op_libelle = "retrait ponctuel"
            
            setUpdateCapital(capital, completionHandlerUpdate: { (success, errorString) in
                
                if success {
                    
                    setAddOperation(operation, completionHandlerAddOp: {(success, errorString) in
                        
                        if success {
                            
                            performUIUpdatesOnMain {
                                
                                self.IBSolde.text = "\(FormaterMontant(self.config.solde!)) \(self.traduction.devise!)"
                                self.IBRetrait.text = ""
                                self.IBRetrait.endEditing(true)
                                self.RefreshData()
                                self.displayAlert("info", mess: "votre retrait a été effectué")
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
    
    
    
    @IBAction func ActionVersement(_ sender: Any) {
        
        
        let alertController = UIAlertController(title: "Versement", message: "Confirmer votre versement", preferredStyle: .alert)
        
        let actionValider = UIAlertAction(title: "Valider", style: .destructive, handler: { (action) in
            
            guard let montant = FormaterMontant(self.IBVersement.text!) else {
                
                performUIUpdatesOnMain {
                    
                    self.displayAlert("Error", mess: "montant versement incorrect!")
                }
                
                return
            }
            
            
            var valeurfinal = self.IBSolde.text! as String
            valeurfinal = valeurfinal.replacingOccurrences(of: self.traduction.devise!, with: "")
            valeurfinal = valeurfinal.replacingOccurrences(of: " ", with: "")
            
            guard let solde = FormaterMontant(valeurfinal) else {
                performUIUpdatesOnMain {
                    self.displayAlert("Error", mess: "solde incorrect!")
                    
                }
                return
            }
            
            self.config.solde = solde + montant
            var capital = Capital(dico: [String : AnyObject]())
            capital.solde = self.config.solde
            capital.user_id = self.config.user_id
            
            var operation = Operation(dico: [String : AnyObject]())
            operation.user_id = self.config.user_id
            operation.op_type = 1
            operation.op_montant = montant
            operation.op_libelle = "depôt ponctuel"
            
            setUpdateCapital(capital, completionHandlerUpdate: { (success, errorString) in
                
                if success {
                    
                    setAddOperation(operation, completionHandlerAddOp: {(success, errorString) in
                        
                        if success {
                            
                            performUIUpdatesOnMain {
                                
                                self.IBSolde.text = "\(FormaterMontant(self.config.solde!)) \(self.traduction.devise!)"
                                self.IBVersement.text = ""
                                self.IBVersement.endEditing(true)
                                self.RefreshData()
                                self.displayAlert("info", mess: "votre versement a été effectué")
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
    
    
    @IBAction func ActionResilier(_ sender: Any) {
        
        
        let alertController = UIAlertController(title: "Resilier abonnement", message: "Confirmer la resilisation", preferredStyle: .alert)
        
        let actionValider = UIAlertAction(title: "Valider", style: .destructive, handler: { (action) in
            
            
            var valeurfinal = self.IBSolde.text! as String
            valeurfinal = valeurfinal.replacingOccurrences(of: self.traduction.devise!, with: "")
            valeurfinal = valeurfinal.replacingOccurrences(of: " ", with: "")
            
            guard let solde = NumberFormatter().number(from: valeurfinal) else {
                performUIUpdatesOnMain {
                    self.displayAlert("Error", mess: "solde incorrect!")
                    
                }
                return
            }
            
            performUIUpdatesOnMain {
                
                if solde.doubleValue > 0 {
                    self.displayAlert("Error", mess: "Vous devez solder votre compte avant la resiliation.")
                }
                else {
                    self.displayAlert("info", mess: "votre abonnement a été résilié")
                    
                }
                
                
                
            }
            
            
        })
        
        let actionCancel = UIAlertAction(title: "Annuler", style: .destructive, handler: { (action) in
            
            
            
        })
        
        alertController.addAction(actionCancel)
        alertController.addAction(actionValider)
        
        
        present(alertController, animated: true) {
            
        }
        
        
    }
    
    
    private func RefreshData()  {
        
        
        IBActivity.isHidden = false
        IBActivity.startAnimating()
        IBTableView.isHidden = true
        
        operations.removeAll()
        IBTableView.reloadData()
        
        getAllOperations(config.user_id, completionHandlerOperations: {(success, operationArray, errorString) in
            
            
            if success {
                
                Operations.sharedInstance.operationArray = operationArray
                self.chargerData()
                
                performUIUpdatesOnMain {
                    self.IBActivity.stopAnimating()
                    self.IBActivity.isHidden = true
                    self.IBTableView.isHidden = false
                    self.IBTableView.reloadData()
                }
            }
            else {
                
                performUIUpdatesOnMain {
                    self.IBActivity.stopAnimating()
                    self.IBActivity.isHidden = true
                    self.IBTableView.isHidden = false
                    self.displayAlert("Error", mess: errorString!)
                }
            }
            
        })
        
        
        
    }
    
    
    private func chargerData() {
        
        
        for ope in Operations.sharedInstance.operationArray {
            
            if customOpeation.isCancelled {
                break
            }
            
            let opera = Operation(dico: ope)
            operations.append(opera)
            
        }
        
        
    }
    
    
    
    //MARK: Table View Controller data source
    
   
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let entete = view as! UITableViewHeaderFooterView
        entete.textLabel?.font = UIFont(descriptor: (entete.textLabel?.font.fontDescriptor)!, size: 14)
    
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return "Date        Type    Montant  Libelle"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let CellReuseId = "cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: CellReuseId) as UITableViewCell!
        let operation =  operations[(indexPath as NSIndexPath).row]
        
        
        let adate = cell?.contentView.viewWithTag(10) as! UILabel
        
        adate.text =  "\(operation.op_date)"
        let index = adate.text?.index((adate.text?.startIndex)!, offsetBy: 10)
        adate.text = adate.text?.substring(to: index!)
        
        
        let atype =  cell?.contentView.viewWithTag(20) as! UILabel
        if operation.op_type == 2 {
            atype.text =  "retrait"
        }
        else if operation.op_type == 1 {
            atype.text =  "Depôt"
        }
        
        let amontant = cell?.contentView.viewWithTag(30) as! UILabel
        amontant.text = FormaterMontant(operation.op_montant)
        
        
        let alibelle = cell?.contentView.viewWithTag(40) as! UILabel
        alibelle.text = operation.op_libelle
        
        
        return cell!
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return operations.count
    }
    
    
    
}
