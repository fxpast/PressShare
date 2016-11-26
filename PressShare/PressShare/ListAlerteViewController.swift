//
//  AlerteTableViewController.swift
//  PressShare
//
//  Created by MacbookPRV on 23/11/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//

import Foundation

    
class ListAlerteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
        
    @IBOutlet weak var IBActivity: UIActivityIndicatorView!
    @IBOutlet weak var IBTableView: UITableView!
    @IBOutlet weak var IBEdit: UIBarButtonItem!
    @IBOutlet weak var IBNav: UINavigationItem!
    @IBOutlet weak var IBReception: UIBarButtonItem!
    @IBOutlet weak var IBEnvoi: UIBarButtonItem!
    
    let reception = "Boite de Reception"
    let envoi = "Boite d'Envoi"
    var messages = [Message]()
    var customOpeation = BlockOperation()
    let myqueue = OperationQueue()
    var config = Config.sharedInstance
    var aindex:Int!
     var fenetre = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        IBActivity.startAnimating()
        setUIEnabled(false)
        IBTableView.isHidden = true
        if let _ = Messages.sharedInstance.MessagesArray {
            IBNav.title = reception
            myqueue.addOperation {
                
                self.customOpeation = BlockOperation()
                self.customOpeation.addExecutionBlock {
                    if !self.customOpeation.isCancelled
                    {
                        
                        self.chargerDataInbox()
                        
                        performUIUpdatesOnMain {
                            
                            self.IBTableView.reloadData()
                            self.IBActivity.stopAnimating()
                            self.IBTableView.isHidden = false
                            self.setUIEnabled(true)
                            
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
        
        if config.message_maj == true {
            config.mess_badge = config.mess_badge - 1
            config.message_maj = false
         
            setUIEnabled(false)
            IBActivity.startAnimating()
            IBTableView.isHidden = true
            
            messages.removeAll()
            IBTableView.reloadData()
            
            getAllMessages(config.user_id, completionHandlerMessages: {(success, messageArray, errorString) in
                
                
                if success {
                    
                    Messages.sharedInstance.MessagesArray = messageArray
            
                    performUIUpdatesOnMain {
                        
                        if self.fenetre == 1 {
                            self.IBNav.title = self.reception
                            self.chargerDataInbox()
                        }
                        
                        if self.fenetre == 2 {
                            self.IBNav.title = self.envoi
                            self.chargerDataSend()
                        }
                        self.IBActivity.stopAnimating()
                        self.IBTableView.isHidden = false
                        self.IBTableView.reloadData()
                        self.setUIEnabled(true)
                    }
                }
                else {
                    
                    performUIUpdatesOnMain {
                        self.IBActivity.stopAnimating()
                        self.IBTableView.isHidden = false
                        self.displayAlert("Error", mess: errorString!)
                    }
                }
                
            })
            
            
            
        }
        
        
    }
    
    private func setUIEnabled(_ enabled: Bool) {
        
        IBEdit.isEnabled = enabled
        IBReception.isEnabled = enabled
        IBEnvoi.isEnabled = enabled
        
    }
    
    
    
    @IBAction func ActionEnvoi(_ sender: Any) {
        
        fenetre = 2
        IBActivity.startAnimating()
        setUIEnabled(false)
        IBTableView.isHidden = true
        IBNav.title = envoi
        
        messages.removeAll()
        IBTableView.reloadData()
        myqueue.cancelAllOperations()
        
        myqueue.addOperation {
            
            self.customOpeation = BlockOperation()
            self.customOpeation.addExecutionBlock {
                if !self.customOpeation.isCancelled
                {
                    if let _ = Messages.sharedInstance.MessagesArray {
                        self.chargerDataSend()
                    }
                    
                    performUIUpdatesOnMain {
                        self.IBTableView.reloadData()
                        self.IBActivity.stopAnimating()
                        self.IBTableView.isHidden = false
                        self.setUIEnabled(true)
                    }
                    
                }
            }
            
            self.customOpeation.start()
            
        }
        
        
    }
    
   
    @IBAction func ActionReception(_ sender: Any) {
        
         fenetre = 1
         RefreshData()
        
    }
   
    @IBAction func ActionEdit(_ sender: Any) {
        
        
        if IBEdit.title == "Edit" {
            IBTableView.isEditing=true
            IBEdit.title="Done"
        }
        else {
            IBTableView.isEditing=false
            IBEdit.title="Edit"
        }
        
    }
    
    
    @IBAction func ActionCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    private func chargerDataInbox() {
  
      
        for mess in Messages.sharedInstance.MessagesArray {
            
            if customOpeation.isCancelled {
                break
            }
            
            let messa = Message(dico: mess)
            if messa.destinataire == config.user_id {
                messages.append(messa)
            }
            
        }
        
        
    }
    
    
    private func chargerDataSend() {
        
        
        for mess in Messages.sharedInstance.MessagesArray {
            
            if customOpeation.isCancelled {
                break
            }
            
            let messa = Message(dico: mess)
            if messa.expediteur == config.user_id {
                messages.append(messa)
            }
            
        }
        
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if segue.identifier == "fromalerte" {
            
          
                let nav = segue.destination as! UINavigationController
                let controller = nav.topViewController as! DetailAlertViewController
                
                controller.aMessage = messages[aindex]
                controller.fenetre = fenetre
            
        }
        
    }

    

    private func RefreshData()  {
        
        
        IBActivity.startAnimating()
        setUIEnabled(false)
        IBTableView.isHidden = true
        IBNav.title = reception
        
        messages.removeAll()
        IBTableView.reloadData()
        
        getAllMessages(config.user_id, completionHandlerMessages: {(success, messageArray, errorString) in
        
            
            if success {
                
                Messages.sharedInstance.MessagesArray = messageArray
                
                var i = 0
                for mess in Messages.sharedInstance.MessagesArray {
                    
                    let mess1 = Message(dico: mess)
                    
                    if mess1.destinataire == self.config.user_id && mess1.deja_lu_dest == false {
                        i+=1
                    }
                    
                }
                if i > 0 {
                    self.config.mess_badge = i
                   
                }
                
                
                self.chargerDataInbox()
                
                performUIUpdatesOnMain {
                    self.IBActivity.stopAnimating()
                    self.IBTableView.isHidden = false
                    self.IBTableView.reloadData()
                    self.setUIEnabled(true)
                }
            }
            else {
                
                performUIUpdatesOnMain {
                    self.IBActivity.stopAnimating()
                    self.IBTableView.isHidden = false
                    self.setUIEnabled(true)
                    self.displayAlert("Error", mess: errorString!)
                }
            }
            
        })
        
        
        
    }
    
    
    //MARK: Table View Controller data source
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        //delete row
        let message =  messages[indexPath.row]
        setDeleteMessage(message, completionHandlerDelMessage: { (success, errorString) in
        
            
            if success {
                
                performUIUpdatesOnMain {
                    
                    let mess1 =  self.messages[indexPath.row]
                    var i = 0
                    for mess in Messages.sharedInstance.MessagesArray {
                       i+=1
                       let mess2 = Message(dico: mess)
                        if (mess2.message_id == mess1.message_id) {
                            if mess1.destinataire == self.config.user_id && mess1.deja_lu_dest == false {
                                self.config.mess_badge = self.config.mess_badge - 1
                            }
                            self.messages.remove(at: indexPath.row)
                            Messages.sharedInstance.MessagesArray.remove(at: i-1)
                          
                            
                            break
                        }
                    }
                    
                    if self.messages.count == 0 {
                        self.IBEdit.title="Edit"
                        self.IBEdit.isEnabled=false
                        self.IBTableView.isEditing = false
                    }
                    
                    tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.left)
                    self.IBTableView.reloadData()
                }
            }
            else {
                
                performUIUpdatesOnMain {
                    self.displayAlert("Error", mess: errorString!)
                }
            }
            
        
        })
        
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let CellReuseId = "Cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: CellReuseId) as UITableViewCell!
        let message =  messages[(indexPath as NSIndexPath).row]
        
        var adate = UILabel()
        var acontenu = UILabel()
        
        for view in (cell?.contentView.subviews)! {
            
            if view.tag == 10 {
                adate = view as! UILabel
                adate.text =  "\(message.date_ajout)"
                adate.text = adate.text?.replacingOccurrences(of: "+0000", with: "")
            }
            else if view.tag == 20 {
                acontenu = view as! UILabel
                acontenu.text =  message.contenu
            }
            
        }
        
        if (fenetre == 1 && message.deja_lu_dest == false) || (fenetre == 2 && message.deja_lu_exp == false)  {
            adate.textColor = UIColor.blue
            acontenu.textColor = UIColor.blue
        }
        else {
            adate.textColor = UIColor.black
            acontenu.textColor = UIColor.black
        }
        
        return cell!
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        aindex = (indexPath as NSIndexPath).row
        performSegue(withIdentifier: "fromalerte", sender: self)
        
        
    }

    
}
