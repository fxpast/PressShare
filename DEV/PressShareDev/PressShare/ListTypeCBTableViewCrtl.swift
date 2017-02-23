//
//  ListCBTableViewController.swift
//  PressShare
//
//  Created by MacbookPRV on 10/02/2017.
//  Copyright © 2017 Pastouret Roger. All rights reserved.
//

import Foundation
import UIKit


class ListTypeCBTableViewCrtl: UITableViewController {
    
    @IBOutlet weak var IBActivity: UIActivityIndicatorView!
    
    var typeCards = [TypeCard]()
    let config = Config.sharedInstance
    let translate = TranslateMessage.sharedInstance
    
    var customOpeation = BlockOperation()
    let myQueue = OperationQueue()
    

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
        IBActivity.isHidden = false
        IBActivity.startAnimating()
        
        if let _ = TypeCards.sharedInstance.typeCardsArray {
            
            myQueue.addOperation {
                
                self.customOpeation = BlockOperation()
                self.customOpeation.addExecutionBlock {
                    if !self.customOpeation.isCancelled
                    {
                        
                        self.chargeData()
                        
                        BlackBox.sharedInstance.performUIUpdatesOnMain {
                            
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

    
    
    //MARK: coreData function
    
    private func refreshData()  {
        
        
        myQueue.cancelAllOperations()
        guard myQueue.operationCount == 0 else {
            
            return
        }
        
        IBActivity.isHidden = false
        IBActivity.startAnimating()
        
        
        typeCards.removeAll()
        tableView.reloadData()
        
    
        MDBTypeCard.sharedInstance.getAllTypeCards(completionHandlerTypeCards: {(success, typeCardsArray, errorString) in
            
            
            if success {
                
                TypeCards.sharedInstance.typeCardsArray = typeCardsArray
                self.chargeData()
                
                BlackBox.sharedInstance.performUIUpdatesOnMain {
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
    
    private func chargeData() {
        
        for typeCd in TypeCards.sharedInstance.typeCardsArray  {
            
            if customOpeation.isCancelled {
                break
            }
            
            let typeC = TypeCard(dico: typeCd)
            if typeC.typeCard_id != 6 {
                typeCards.append(typeC)
            }
            
            BlackBox.sharedInstance.performUIUpdatesOnMain {
                self.tableView.reloadData()
            }
        }
        
    }
    
    
    
    //MARK: Table View Controller data source
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let CellReuseId = "cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: CellReuseId) as UITableViewCell!
        let typeCard =  typeCards[indexPath.row]
        
        
        let photo = cell?.contentView.viewWithTag(10) as! UIImageView
        
        do {
            let url = URL(string: "\(CommunRequest.sharedInstance.urlServer)/images_cb/\(typeCard.typeCard_ImageUrl)")!
            let data = try Data(contentsOf: url)
            photo.image = UIImage(data: data)
        } catch  {
            print("error url : ", typeCard.typeCard_ImageUrl)
        }
        
        let wording = cell?.contentView.viewWithTag(20) as! UILabel
        wording.text = typeCard.typeCard_Wording
        
        return cell!
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return typeCards.count
    }
    
   override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    let typeCard =  typeCards[indexPath.row]
    config.typeCard_id = typeCard.typeCard_id
    
        
    }
    
    
    
    
}
