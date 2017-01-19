//
//  ListAlerteTableViewController.swift
//  PressShare
//
//  Description : List of Alerte, with inbox and send
//
//  Created by MacbookPRV on 23/11/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//



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
    let myQueue = OperationQueue()
    var config = Config.sharedInstance
    var aindex:Int!
    var aWindow = 1
    let translate = TranslateMessage.sharedInstance
    var flgOpen=false
    
    //MARK: View Controller Delegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        IBInbox.title = translate.inBox
        IBSend.title = translate.sendBox
        
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        

        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if config.message_maj == true {
            config.mess_badge = config.mess_badge - 1
            config.message_maj = false
            
            setUIEnabled(false)
            IBActivity.startAnimating()
            
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
                        self.setUIEnabled(true)
                    }
                }
                else {
                    
                    BlackBox.sharedInstance.performUIUpdatesOnMain {
                        self.IBActivity.stopAnimating()
                        self.displayAlert(self.translate.error, mess: errorString!)
                    }
                }
                
            })
            
        }
        
        if flgOpen == false {
            flgOpen = true
            IBActivity.startAnimating()
            setUIEnabled(false)
            if let _ = Messages.sharedInstance.MessagesArray {
                IBNav.title = translate.inBox
                myQueue.addOperation {
                    
                    self.customOpeation = BlockOperation()
                    self.customOpeation.addExecutionBlock {
                        if !self.customOpeation.isCancelled
                        {
                            
                            self.chargeDataInbox()
                            
                            BlackBox.sharedInstance.performUIUpdatesOnMain {
                                
                                self.IBActivity.stopAnimating()
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
        IBNav.title = translate.sendBox
        
        messages.removeAll()
        IBTableView.reloadData()
        myQueue.cancelAllOperations()
        
        myQueue.addOperation {
            
            self.customOpeation = BlockOperation()
            self.customOpeation.addExecutionBlock {
                if !self.customOpeation.isCancelled
                {
                    if let _ = Messages.sharedInstance.MessagesArray {
                        self.chargeDataSend()
                    }
                    
                    BlackBox.sharedInstance.performUIUpdatesOnMain {
                        self.IBActivity.stopAnimating()
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
        
        IBTableView.isEditing = !IBTableView.isEditing
        
    }
    
    
    @IBAction func actionCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if segue.identifier == "fromalerte" {
            
           
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
        
        BlackBox.sharedInstance.performUIUpdatesOnMain {
            self.IBTableView.reloadData()
            
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
        
        BlackBox.sharedInstance.performUIUpdatesOnMain {
            self.IBTableView.reloadData()
            
        }
        
        
    }
    
    
    
    private func refreshData()  {
        
        
        
        myQueue.cancelAllOperations()
        guard myQueue.operationCount == 0 else {
            
            return
        }
        
        IBActivity.startAnimating()
        setUIEnabled(false)
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
                    self.setUIEnabled(true)
                }
            }
            else {
                
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    self.IBActivity.stopAnimating()
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
