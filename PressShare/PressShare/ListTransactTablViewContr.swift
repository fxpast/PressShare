//
//  ListTransactTablViewContr.swift
//  PressShare
//
//  Created by MacbookPRV on 05/12/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//


//Todo :Ajouter une pastille à la transaction.


import Foundation
import UIKit

class ListTransactTablViewContr: UITableViewController {
    
    
    @IBOutlet weak var IBActivity: UIActivityIndicatorView!
    @IBOutlet weak var IBCancel: UIBarButtonItem!
    
    var transactions = [Transaction]()
    var aindex:Int!
    
    var config = Config.sharedInstance
    let translate = TranslateMessage.sharedInstance
    
    var customOpeation = BlockOperation()
    let myqueue = OperationQueue()
    
    //MARK: View Controller Delegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        IBActivity.isHidden = false
        IBActivity.startAnimating()
        
        if let _ = Transactions.sharedInstance.transactionArray {
            
            myqueue.addOperation {
                
                self.customOpeation = BlockOperation()
                self.customOpeation.addExecutionBlock {
                    if !self.customOpeation.isCancelled
                    {
                        
                        self.chargeData()
                        
                        BlackBox.sharedInstance.performUIUpdatesOnMain {
                            
                            self.tableView.reloadData()
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
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        IBCancel.title = translate.cancel
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
        
        
        IBActivity.isHidden = false
        IBActivity.startAnimating()
        
        transactions.removeAll()
        tableView.reloadData()
        
        
        MDBTransact.sharedInstance.getAllTransactions(config.user_id, completionHandlerTransactions: {(success, transactionArray, errorString) in
            
            
            if success {
                
                Transactions.sharedInstance.transactionArray = transactionArray
                self.chargeData()
                
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    self.IBActivity.stopAnimating()
                    self.IBActivity.isHidden = true
                    self.tableView.reloadData()
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
        
        
        for trans in Transactions.sharedInstance.transactionArray {
            
            if customOpeation.isCancelled {
                break
            }
            
            let tran = Transaction(dico: trans)
            transactions.append(tran)
            
        }
        
        
    }
    
    
    
    //MARK: Table View Controller data source
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let entete = view as! UITableViewHeaderFooterView
        entete.textLabel?.font = UIFont(descriptor: (entete.textLabel?.font.fontDescriptor)!, size: 14)
        
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return "\(translate.date!)        \(translate.type!)    \(translate.amount!)  \(translate.wording!)"
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
            atype.text =  translate.trade
        }
        else if transaction.trans_type == 2 {
            atype.text =  translate.exchange
        }
        else {
            atype.text =  ""
        }
        
        
        let aamount = cell?.contentView.viewWithTag(30) as! UILabel
        aamount.text = BlackBox.sharedInstance.formatedAmount(transaction.trans_amount)
        
        
        let awording = cell?.contentView.viewWithTag(40) as! UILabel
        awording.text = transaction.trans_wording
        
        if (transaction.trans_valide == 1 || transaction.trans_valide == 2)  {
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
