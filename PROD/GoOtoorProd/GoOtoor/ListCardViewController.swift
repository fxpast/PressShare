//
//  ListCardViewController.swift
//  GoOtoor
//
//  Created by MacbookPRV on 10/02/2017.
//  Copyright © 2017 Pastouret Roger. All rights reserved.
//

//Todo bug: traduire le libellé : carte bancaire et vos données bancaires sont cryptés


//Todo: aide ListCardViewController ne fonctionne pas


import Foundation
import UIKit


class ListCardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var IBActivity: UIActivityIndicatorView!
    @IBOutlet weak var IBTableView: UITableView!
    @IBOutlet weak var IBCBLabel: UILabel!
    @IBOutlet weak var IBInfoLabel: UILabel!
    
    var IBAddCard: UIButton!
    
    var timerBadge : Timer!

    var cards = [Card]()
    let config = Config.sharedInstance
    let translate = TranslateMessage.sharedInstance
    
    var customOpeation = BlockOperation()
    let myQueue = OperationQueue()
    

    //MARK: View Controller Delegate
    override func viewDidLoad() {
        super.viewDidLoad()
        
        IBAddCard = UIButton()
        IBAddCard.setImage(#imageLiteral(resourceName: "addButton"), for: UIControlState())
        IBAddCard.addTarget(self, action: #selector(actionAddCB(_:)), for: UIControlEvents.touchUpInside)
        IBAddCard.tag = 999
        IBAddCard.sizeToFit()
        view.addSubview(IBAddCard)
        
        IBAddCard.frame = CGRect(origin: CGPoint.init(x: view.frame.size.width - IBAddCard.frame.size.width*2, y: view.frame.size.height - IBAddCard.frame.height*2), size: IBAddCard.frame.size)
  
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        view.backgroundColor =  UIColor.init(hexString: config.colorApp)
        
        IBTableView.backgroundColor = UIColor.init(hexString: config.colorApp)
        IBTableView.backgroundView?.backgroundColor = UIColor.init(hexString: config.colorApp)
        IBTableView.sectionIndexColor = UIColor.init(hexString: config.colorApp)
        
        IBCBLabel.textColor = UIColor.init(hexString: config.colorAppLabel)
        IBCBLabel.text = translate.message("myCB")
        
        IBInfoLabel.textColor = UIColor.init(hexString: config.colorAppLabel)
        IBInfoLabel.text = translate.message("infoCB")
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        timerBadge = Timer.scheduledTimer(timeInterval: config.dureeTimer, target: self, selector: #selector(routineTimer), userInfo: nil, repeats: true)
        
        IBActivity.isHidden = false
        IBActivity.startAnimating()
        
        if let _ = Cards.sharedInstance.cardsArray {
            
            cards.removeAll()
            myQueue.addOperation {
                
                self.customOpeation = BlockOperation()
                self.customOpeation.addExecutionBlock {
                    if !self.customOpeation.isCancelled
                    {
                        
                        self.chargeData()
                        
                        MyTools.sharedInstance.performUIUpdatesOnMain {
                      
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
    
    
    
    @IBAction func actionAddCB(_ sender: AnyObject) {
        
        performSegue(withIdentifier: "CB", sender: self)
    }
    
    
    @IBAction func actionHelp(_ sender: Any) {
        
        //action info
        MyTools.sharedInstance.showHelp("ListCardViewController", self)
        
    }
    
    
    
    @IBAction func actionDelete(_ sender: AnyObject)  {
        
        IBTableView.isEditing = !IBTableView.isEditing
        
    }
    
    
    @IBAction func actionCancel(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
        
    }
    
    
    //MARK: coreData function
    
    private func refreshData()  {
        
        
        myQueue.cancelAllOperations()
        guard myQueue.operationCount == 0 else {
            
            return
        }
        
        IBActivity.isHidden = false
        IBActivity.startAnimating()
        
        cards.removeAll()
        IBTableView.reloadData()
        
        
        MDBTypeCard.sharedInstance.getAllTypeCards(completionHandlerTypeCards: {(success, typeCardsArray, errorString) in
            
            if success {
                
                TypeCards.sharedInstance.typeCardsArray = typeCardsArray
                
                MDBCard.sharedInstance.getAllCards(user_id: self.config.user_id, completionHandlerCards: {(success, cardsArray, errorString) in
                    
                    if success {
                        
                        Cards.sharedInstance.cardsArray = cardsArray
                        
                        self.chargeData()
                        
                        MyTools.sharedInstance.performUIUpdatesOnMain {
                            
                            self.IBActivity.stopAnimating()
                            self.IBActivity.isHidden = true
                        }
                    }
                    else {
                        
                        MyTools.sharedInstance.performUIUpdatesOnMain {
                            self.IBActivity.stopAnimating()
                            self.IBActivity.isHidden = true
                            self.displayAlert(self.translate.message("error"), mess: errorString!)
                        }
                    }
                    
                })
                
            }
            else {
                
                MyTools.sharedInstance.performUIUpdatesOnMain {
                    self.IBActivity.stopAnimating()
                    self.IBActivity.isHidden = true
                    self.displayAlert(self.translate.message("error"), mess: errorString!)
                }
            }
            
        })
        
        
    }
    
    private func chargeData() {
        
        for card in Cards.sharedInstance.cardsArray  {
            
            if customOpeation.isCancelled {
                break
            }
            
            var cd = Card(dico: card)
            
            for typeCd in TypeCards.sharedInstance.typeCardsArray  {
                
                if customOpeation.isCancelled {
                    break
                }
                
                let typeC = TypeCard(dico: typeCd)
                if typeC.typeCard_id == cd.typeCard_id {
                    cd.typeCard_ImageUrl = typeC.typeCard_ImageUrl
                    cards.append(cd)
                    
                    MyTools.sharedInstance.performUIUpdatesOnMain {
                        self.IBTableView.reloadData()
                    }
                    
                }
               
            }
            
        }
        
    }
    
    //MARK: Table View Controller data source
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let CellReuseId = "cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: CellReuseId) as UITableViewCell!
        
        cell?.backgroundColor  = UIColor.init(hexString: config.colorApp)
        cell?.backgroundView?.backgroundColor  = UIColor.init(hexString: config.colorApp)
        
        let card =  cards[indexPath.row]
        
        
        let photo = cell?.contentView.viewWithTag(10) as! UIImageView
        
        do {
            let url = URL(string: "\(CommunRequest.sharedInstance.urlServer)/images_cb/\(card.typeCard_ImageUrl)")!
            let data = try Data(contentsOf: url)
            photo.image = UIImage(data: data)
        } catch  {
            print("error url : ", card.typeCard_ImageUrl)
        }
        
        let lastNumber = cell?.contentView.viewWithTag(20) as! UILabel
        lastNumber.textColor = UIColor.init(hexString: config.colorAppLabel)
        if card.typeCard_id == 6 {
            
            lastNumber.text = "Paypal"
            
        }
        else {
            
            lastNumber.text = "(\(card.card_lastNumber))"
            
        }
        
        if card.main_card == true {
          cell?.accessoryType = .checkmark
        }
        else {
            cell?.accessoryType = .none
        }
        
        return cell!
    }
    
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return cards.count
    }
    
  
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        //delete row
        let card =  cards[indexPath.row]
        
        MDBCard.sharedInstance.setDeleteCard(card) { (success, errorString) in
            
            if success {
                
                let card1 =  self.cards[indexPath.row]
                
                var i = 0
                
                for cd in Cards.sharedInstance.cardsArray {
                    i+=1
                    let card2 = Card(dico: cd)
                    if (card2.card_id == card1.card_id) {
                        self.cards.remove(at: indexPath.row)
                        Cards.sharedInstance.cardsArray.remove(at: i-1)
                        break
                    }
                }
                
                MyTools.sharedInstance.performUIUpdatesOnMain {
       
                    self.IBTableView.isEditing = false
                    self.IBTableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.left)
                    self.IBTableView.reloadData()
                }
                
                
            }
            else {
                MyTools.sharedInstance.performUIUpdatesOnMain {
                    self.displayAlert(self.translate.message("error"), mess: errorString!)
                }
            }
            
        }
        
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        for index in 0...cards.count-1 {
            
            if index == indexPath.row {
                cards[index].main_card = true
            }
            else {
                cards[index].main_card = false
            }
            
     
            MDBCard.sharedInstance.setUpdateCard(cards[index], completionHandlerUpdCard: { (success, errorString) in
                
                if success {
                    
                    Cards.sharedInstance.cardsArray = nil
                    MyTools.sharedInstance.performUIUpdatesOnMain {
                        self.IBTableView.reloadData()
                    }
                    
                }
                else {
                    
                    MyTools.sharedInstance.performUIUpdatesOnMain {
                        self.displayAlert(self.translate.message("error"), mess: errorString!)
                    }
                }
                
            })
            
        }
        
    }
    
  
    
}
