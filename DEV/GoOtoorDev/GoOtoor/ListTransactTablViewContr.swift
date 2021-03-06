//
//  ListTransactTablViewContr.swift
//  GoOtoor
//
//  Created by MacbookPRV on 05/12/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//



//Todo: L'aide de la liste de transaction n'est pas conforme


import Foundation
import UIKit

class ListTransactTablViewContr: UITableViewController {
    
    
    @IBOutlet weak var IBCancel: UIBarButtonItem!
    
    var timerBadge : Timer!

    var transactions = [Transaction]()
    var aindex:Int!
    var isOpen=false
    var config = Config.sharedInstance
    let translate = TranslateMessage.sharedInstance
    var customOpeation = BlockOperation()
    let myQueue = OperationQueue()
    
    let refreshControl1 = UIRefreshControl()
    
    
    //MARK: View Controller Delegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl1.addTarget(self, action: #selector(actionRefresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl1)
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        title = translate.message("runTransac")
        
        tableView.backgroundColor = UIColor.init(hexString: config.colorApp)
        tableView.backgroundView?.backgroundColor = UIColor.init(hexString: config.colorApp)
        tableView.sectionIndexColor = UIColor.init(hexString: config.colorApp)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        
        timerBadge = Timer.scheduledTimer(timeInterval: config.dureeTimer, target: self, selector: #selector(routineTimer), userInfo: nil, repeats: true)
  
        
        if config.transaction_maj == true {
            config.transaction_maj = false
            refreshData()
        }
        
        if isOpen == false {
            
            isOpen = true
            refreshControl1.beginRefreshing()
            
            
            if let _ = Transactions.sharedInstance.transactionArray {
                
                myQueue.addOperation {
                    
                    self.customOpeation = BlockOperation()
                    self.customOpeation.addExecutionBlock {
                        if !self.customOpeation.isCancelled
                        {
                            
                            self.chargeData()
                            
                            MyTools.sharedInstance.performUIUpdatesOnMain {                                
                                self.refreshControl1.endRefreshing()
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
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "detailtransaction" {
            
            let nav = segue.destination as! UINavigationController
            let controller = nav.topViewController as! DetailTransViewController
            
            controller.aTransaction = transactions[aindex]
            
        }
        
    }
    
    
    @IBAction func actionRefresh(_ sender: AnyObject) {
        
        refreshData()
        
    }
    
    @IBAction func actionCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionHelp(_ sender: Any) {
        
        //action info
        MyTools.sharedInstance.showHelp("transactions", self)
        
    }
    
    
    //MARK: coreData function
    
    private func refreshData()  {
        
        
       
        myQueue.cancelAllOperations()
        guard myQueue.operationCount == 0 else {
            
            return
        }
        
        refreshControl1.beginRefreshing()
        
        transactions.removeAll()
        tableView.reloadData()
        
        
        MDBTransact.sharedInstance.getAllTransactions(config.user_id, completionHandlerTransactions: {(success, transactionArray, errorString) in
            
            
            if success {
                
                Transactions.sharedInstance.transactionArray = transactionArray
                self.chargeData()
                
                MyTools.sharedInstance.performUIUpdatesOnMain {
                   self.refreshControl1.endRefreshing()
                }
            }
            else {
                
                MyTools.sharedInstance.performUIUpdatesOnMain {
                    self.refreshControl1.endRefreshing()
                    self.displayAlert(self.translate.message("error"), mess: errorString!)
                }
            }
            
        })
        
        
    }
    
    private func chargeData() {
        
        for trans in Transactions.sharedInstance.transactionArray {
            
            if customOpeation.isCancelled {
                break
            }
            
            let tran = Transaction(dico: trans)
            transactions.append(tran)
            
            MyTools.sharedInstance.performUIUpdatesOnMain {
                self.tableView.reloadData()
            }
        }        
        
    }
    
    
    
    //MARK: Table View Controller data source
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let entete = view as! UITableViewHeaderFooterView
        entete.textLabel?.font = UIFont(descriptor: (entete.textLabel?.font.fontDescriptor)!, size: 14)
        
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return "\(translate.message("date"))        \(translate.message("type"))    \(translate.message("amount"))  \(translate.message("wording"))"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let CellReuseId = "cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: CellReuseId) as UITableViewCell!
        
        cell?.backgroundColor  = UIColor.init(hexString: config.colorApp)
        cell?.backgroundView?.backgroundColor  = UIColor.init(hexString: config.colorApp)
        
        let transaction =  transactions[indexPath.row]
        
        
        let adate = cell?.contentView.viewWithTag(10) as! UILabel
        
        adate.text =  "\(transaction.trans_date)"
        let index = adate.text?.index((adate.text?.startIndex)!, offsetBy: 10)
        adate.text = adate.text?.substring(to: index!)
        
        
        let atype =  cell?.contentView.viewWithTag(20) as! UILabel
        if transaction.trans_type == 1 {
            atype.text =  translate.message("buy")
        }
        else if transaction.trans_type == 2 {
            atype.text =  translate.message("exchange")
        }
        else {
            atype.text =  ""
        }
        
        
        let aamount = cell?.contentView.viewWithTag(30) as! UILabel
        aamount.text = MyTools.sharedInstance.formatedAmount(transaction.trans_amount)
        
        
        let awording = cell?.contentView.viewWithTag(40) as! UILabel
        awording.text = transaction.trans_wording
        
        if (transaction.trans_valid == 1 || transaction.trans_valid == 2)  {
            aamount.textColor = UIColor.black
            atype.textColor = UIColor.black
            adate.textColor = UIColor.black
            awording.textColor = UIColor.black
        }
        else {
            aamount.textColor = UIColor.blue
            atype.textColor = UIColor.blue
            adate.textColor = UIColor.blue
            awording.textColor = UIColor.blue
        }
        
        return cell!
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions.count
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        aindex = (indexPath as NSIndexPath).row
        performSegue(withIdentifier: "detailtransaction", sender: self)
        
        
    }
    
    
}
