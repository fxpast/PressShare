//
//  ListTransactTablViewContr.swift
//  PressShare
//
//  Created by MacbookPRV on 05/12/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//


import Foundation
import UIKit

class ListTransactTablViewContr: UITableViewController {
    
    
    @IBOutlet weak var IBCancel: UIBarButtonItem!
    
    var transactions = [Transaction]()
    var aindex:Int!
    var flgOpen=false
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
        self.navigationItem.title = translate.message("runTransac")
        
      
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if config.transaction_maj == true {
            config.transaction_maj = false
            refreshData()
        }
        
        if flgOpen == false {
            
            flgOpen = true
            refreshControl1.beginRefreshing()
            
            
            if let _ = Transactions.sharedInstance.transactionArray {
                
                myQueue.addOperation {
                    
                    self.customOpeation = BlockOperation()
                    self.customOpeation.addExecutionBlock {
                        if !self.customOpeation.isCancelled
                        {
                            
                            self.chargeData()
                            
                            BlackBox.sharedInstance.performUIUpdatesOnMain {                                
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
                
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                   self.refreshControl1.endRefreshing()
                }
            }
            else {
                
                BlackBox.sharedInstance.performUIUpdatesOnMain {
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
            
            BlackBox.sharedInstance.performUIUpdatesOnMain {
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
        aamount.text = BlackBox.sharedInstance.formatedAmount(transaction.trans_amount)
        
        
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
