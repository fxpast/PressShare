//
//  ListAlerteTableViewController.swift
//  PressShare
//
//  Description : List of Alerte, with inbox and send
//
//  Created by MacbookPRV on 23/11/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//


//Todo :In the view "Send", add the recipient in the top of the line, e.g "A:Roger pastouret".


import Foundation


class ListAlerteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var IBActivity: UIActivityIndicatorView!
    @IBOutlet weak var IBTableView: UITableView!
    @IBOutlet weak var IBEdit: UIBarButtonItem!
    @IBOutlet weak var IBCancel: UIBarButtonItem!
    @IBOutlet weak var IBNav: UINavigationItem!
    @IBOutlet weak var IBInbox: UIBarButtonItem!
    @IBOutlet weak var IBSend: UIBarButtonItem!
    
    var messages = [Message]()
    var customOpeation = BlockOperation()
    let myqueue = OperationQueue()
    var config = Config.sharedInstance
    var aindex:Int!
    var aWindow = 1
    let translate = TranslateMessage.sharedInstance
    
    //MARK: View Controller Delegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        IBInbox.title = translate.inBox
        IBSend.title = translate.sendBox
        
        IBCancel.title = translate.cancel
        IBEdit.title = translate.delete
        
        
        IBActivity.startAnimating()
        setUIEnabled(false)
        IBTableView.isHidden = true
        if let _ = Messages.sharedInstance.MessagesArray {
            IBNav.title = translate.inBox
            myqueue.addOperation {
                
                self.customOpeation = BlockOperation()
                self.customOpeation.addExecutionBlock {
                    if !self.customOpeation.isCancelled
                    {
                        
                        self.chargeDataInbox()
                        
                        BlackBox.sharedInstance.performUIUpdatesOnMain {
                            
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
            refreshData()
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
            
            MDBMessage.sharedInstance.getAllMessages(config.user_id, completionHandlerMessages: {(success, messageArray, errorString) in
                
                
                if success {
                    
                    Messages.sharedInstance.MessagesArray = messageArray
                    
                    BlackBox.sharedInstance.performUIUpdatesOnMain {
                        
                        if self.aWindow == 1 {
                            self.IBNav.title = self.translate.inBox
                            self.chargeDataInbox()
                        }
                        
                        if self.aWindow == 2 {
                            self.IBNav.title = self.translate.sendBox
                            self.chargeDataSend()
                        }
                        self.IBActivity.stopAnimating()
                        self.IBTableView.isHidden = false
                        self.IBTableView.reloadData()
                        self.setUIEnabled(true)
                    }
                }
                else {
                    
                    BlackBox.sharedInstance.performUIUpdatesOnMain {
                        self.IBActivity.stopAnimating()
                        self.IBTableView.isHidden = false
                        self.displayAlert(self.translate.error, mess: errorString!)
                    }
                }
                
            })
            
            
            
        }
        
        
    }
    
    private func setUIEnabled(_ enabled: Bool) {
        
        IBEdit.isEnabled = enabled
        IBInbox.isEnabled = enabled
        IBSend.isEnabled = enabled
        
    }
    
    @IBAction func actionSend(_ sender: Any) {
        
        aWindow = 2
        IBActivity.startAnimating()
        setUIEnabled(false)
        IBTableView.isHidden = true
        IBNav.title = translate.sendBox
        
        messages.removeAll()
        IBTableView.reloadData()
        myqueue.cancelAllOperations()
        
        myqueue.addOperation {
            
            self.customOpeation = BlockOperation()
            self.customOpeation.addExecutionBlock {
                if !self.customOpeation.isCancelled
                {
                    if let _ = Messages.sharedInstance.MessagesArray {
                        self.chargeDataSend()
                    }
                    
                    BlackBox.sharedInstance.performUIUpdatesOnMain {
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
    
    
    @IBAction func actionInBox(_ sender: Any) {
        
        aWindow = 1
        refreshData()
        
    }
    
    @IBAction func actionEdit(_ sender: Any) {
        
        
        if IBEdit.title == translate.delete {
            IBTableView.isEditing=true
            IBEdit.title = translate.done
        }
        else {
            IBTableView.isEditing=false
            IBEdit.title = translate.delete
        }
        
    }
    
    
    @IBAction func actionCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if segue.identifier == "fromalerte" {
            
            
            let nav = segue.destination as! UINavigationController
            let controller = nav.topViewController as! DetailAlertViewController
            
            controller.aMessage = messages[aindex]
            controller.aWindow = aWindow
            
        }
        
    }
    
    
    
    //MARK: Data Message
    
    private func chargeDataInbox() {
        
        
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
    
    
    private func chargeDataSend() {
        
        
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
    
    
    
    private func refreshData()  {
        
        
        IBActivity.startAnimating()
        setUIEnabled(false)
        IBTableView.isHidden = true
        IBNav.title = translate.inBox
        
        messages.removeAll()
        IBTableView.reloadData()
        
        MDBMessage.sharedInstance.getAllMessages(config.user_id, completionHandlerMessages: {(success, messageArray, errorString) in
            
            
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
                
                
                self.chargeDataInbox()
                
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    self.IBActivity.stopAnimating()
                    self.IBTableView.isHidden = false
                    self.IBTableView.reloadData()
                    self.setUIEnabled(true)
                }
            }
            else {
                
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    self.IBActivity.stopAnimating()
                    self.IBTableView.isHidden = false
                    self.setUIEnabled(true)
                    self.displayAlert(self.translate.error, mess: errorString!)
                }
            }
            
        })
        
        
        
    }
    
    
    //MARK: Table View Controller data source
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        //delete row
        let message =  messages[indexPath.row]
        MDBMessage.sharedInstance.setDeleteMessage(message, completionHandlerDelMessage: { (success, errorString) in
            
            
            if success {
                
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    
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
                        self.IBEdit.title = self.translate.delete
                        self.IBEdit.isEnabled=false
                        self.IBTableView.isEditing = false
                    }
                    
                    tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.left)
                    self.IBTableView.reloadData()
                }
            }
            else {
                
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    self.displayAlert(self.translate.error, mess: errorString!)
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
        
        if (aWindow == 1 && message.deja_lu_dest == false) || (aWindow == 2 && message.deja_lu_exp == false)  {
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
