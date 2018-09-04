//
//  CreneauTableViewController.swift
//  GoOtoor
//
// Description : Add slots for product
//
//  Created by MacbookPRV on 30/03/2018.
//  Copyright © 2018 Pastouret Roger. All rights reserved.
//


import Foundation
import UIKit

class CreneauTableViewController: UITableViewController {
    
    @IBOutlet weak var IBAdd: UIBarButtonItem!
    var client:Bool?
    var aProduct:Product?
    var creneaux = [Creneau]()
    var config = Config.sharedInstance
    let translate = TranslateMessage.sharedInstance
    var timerBadge : Timer!

    let refreshControl1 = UIRefreshControl()
    
    
    //MARK: View Controller Delegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl1.addTarget(self, action: #selector(actionRefresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl1)
        
    
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        title = translate.message("timeslot")
        tableView.backgroundColor = UIColor.init(hexString: config.colorApp)
        tableView.backgroundView?.backgroundColor = UIColor.init(hexString: config.colorApp)
        tableView.sectionIndexColor = UIColor.init(hexString: config.colorApp)
        if client == true {
            IBAdd.isEnabled = false
        }
        
      
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        timerBadge = Timer.scheduledTimer(timeInterval: config.dureeTimer, target: self, selector: #selector(routineTimer), userInfo: nil, repeats: true)
        
        refreshControl1.beginRefreshing()
        
        refreshData()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        config.isTimer = false
        timerBadge.invalidate()
        timerBadge = nil
        
        
    }
    
    @IBAction func actionCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionHelp(_ sender: Any) {
        
        //action info
        MyTools.sharedInstance.showHelp("creneaux", self)
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
      if segue.identifier == "addcreneau" {
            
            let nav = segue.destination as! UINavigationController
            let controller = nav.topViewController as! AddCreneauTableViewController
            controller.aProduct = aProduct
            
        }
        
    }
    
    
    @IBAction func actionRefresh(_ sender: AnyObject) {
        
        refreshData()
        
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
    
    
    
    //MARK: coreData function
    
    private func refreshData()  {
        
        
        

        refreshControl1.beginRefreshing()
        
        creneaux.removeAll()
        tableView.reloadData()
        
        
        MDBCreneau.sharedInstance.getCreneauxProd(aProduct!.prod_id, completionHandlerCreneaux: {(success, creneauArray, errorString) in
            
            if success {
    
                Creneaux.sharedInstance.creneauxArray = creneauArray
                
                for crene in  Creneaux.sharedInstance.creneauxArray  {

                    let cren = Creneau(dico: crene)
                    self.creneaux.append(cren)
                    
                    MyTools.sharedInstance.performUIUpdatesOnMain {
                        self.tableView.reloadData()
                    }
                }
                
                
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
    

    
    
    //MARK: Table View Controller data source
    
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let entete = view as! UITableViewHeaderFooterView
        entete.textLabel?.font = UIFont(descriptor: (entete.textLabel?.font.fontDescriptor)!, size: 14)
        
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        
        return "\(translate.message("dateDebut"))       \(translate.message("dateFin"))     \(translate.message("location"))     \(translate.message("repeat"))"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let CellReuseId = "cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: CellReuseId) as UITableViewCell?
        
        cell?.backgroundColor  = UIColor.init(hexString: config.colorApp)
        cell?.backgroundView?.backgroundColor  = UIColor.init(hexString: config.colorApp)
        
        let creneau =  creneaux[indexPath.row]
        
        let adateDebut = cell?.contentView.viewWithTag(10) as! UILabel
        adateDebut.text =  "\(creneau.cre_dateDebut)"
        adateDebut.text?.removeLast(6)
       
        
        let adateFin = cell?.contentView.viewWithTag(20) as! UILabel
        adateFin.text =  "\(creneau.cre_dateFin)"
        adateFin.text?.removeLast(6)
        
        let amapString = cell?.contentView.viewWithTag(30) as! UILabel
        amapString.text =  "\(creneau.cre_mapString)"
        
        let arepeat = cell?.contentView.viewWithTag(40) as! UILabel
        if creneau.cre_repeat == 0 {
            arepeat.text =  ""
        } else if creneau.cre_repeat == 1 {
            arepeat.text =  translate.message("daily")
        } else if creneau.cre_repeat == 2 {
            arepeat.text =  translate.message("weekly")
        }
        
        return cell!
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return creneaux.count
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if client == true {
            tableView.setEditing(false, animated: false)
            return
        }
        
        //delete row
        let creneau = creneaux[indexPath.row]
        
        MDBCreneau.sharedInstance.setDeleteCreneau(creneau) { (success, errorString) in
            
            if success {
                
                self.creneaux.remove(at: indexPath.row)
                
                MyTools.sharedInstance.performUIUpdatesOnMain {
                    
                    self.tableView.isEditing = false
                    self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.left)
                    self.tableView.reloadData()
                }
                
                
            }
            else {
                MyTools.sharedInstance.performUIUpdatesOnMain {
                    self.displayAlert(self.translate.message("error"), mess: errorString!)
                }
            }
            
        }
        
        
    }
    
    
}
