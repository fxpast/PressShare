//
//  ListCardViewController.swift
//  PressShare
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
    @IBOutlet weak var IBDelete: UIBarButtonItem!
    
    var IBAddCard: UIButton!
    
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
        
        
        if config.level <= 0 {
            IBDelete.isEnabled = false
        }
        
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
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
                        
                        BlackBox.sharedInstance.performUIUpdatesOnMain {
                            
                            if self.cards.count == 1 {
                                self.IBDelete.isEnabled=false
                            }
                            else {
                                self.IBDelete.isEnabled=true
                            }
                            
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
    
    @IBAction func actionAddCB(_ sender: AnyObject) {
        
        performSegue(withIdentifier: "CB", sender: self)
    }
    
    
    @IBAction func actionHelp(_ sender: Any) {
        
        //action info
        BlackBox.sharedInstance.showHelp("ListCardViewController", self)
        
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
                        
                        BlackBox.sharedInstance.performUIUpdatesOnMain {
                            
                            if self.cards.count == 1 {
                                self.IBDelete.isEnabled=false
                            }
                            else {
                                self.IBDelete.isEnabled=true
                            }
                            
                            self.IBActivity.stopAnimating()
                            self.IBActivity.isHidden = true
                        }
                    }
                    else {
                        
                        BlackBox.sharedInstance.performUIUpdatesOnMain {
                            self.IBActivity.stopAnimating()
                            self.IBActivity.isHidden = true
                            self.displayAlert(self.translate.message("error"), mess: errorString!)
                        }
                    }
                    
                })
                
            }
            else {
                
                BlackBox.sharedInstance.performUIUpdatesOnMain {
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
                    
                    BlackBox.sharedInstance.performUIUpdatesOnMain {
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
                
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    
                    if self.cards.count == 1 {
                        self.IBDelete.isEnabled=false
                    }
                    else {
                        self.IBDelete.isEnabled=true
                    }
                    
                    self.IBTableView.isEditing = false
                    self.IBTableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.left)
                    self.IBTableView.reloadData()
                }
                
                
            }
            else {
                BlackBox.sharedInstance.performUIUpdatesOnMain {
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
                    BlackBox.sharedInstance.performUIUpdatesOnMain {
                        self.IBTableView.reloadData()
                    }
                    
                }
                else {
                    
                    BlackBox.sharedInstance.performUIUpdatesOnMain {
                        self.displayAlert(self.translate.message("error"), mess: errorString!)
                    }
                }
                
            })
            
        }
        
    }
    
  
    
}
