//
//  DetailTransViewController.swift
//  PressShare
//
//  Description : List of transaction
//
//  Created by MacbookPRV on 06/12/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//



//Todo :Translate IHM
//Todo :Ajouter une pastille à la transaction.
//Todo :Gerer la saisie de zone de texte autre
//Todo :Afficher le wording transaction
//Todo :Refaire la disposition des zone IHM
//Todo :Ajouter un control de validation des deux parties avant de créer des operations et de mettre à jour le capital



import Foundation
import UIKit

class DetailTransViewController: UIViewController {
    
    
    @IBOutlet weak var IBActivity: UIActivityIndicatorView!
    @IBOutlet weak var IBInfoContact: UILabel!
    @IBOutlet weak var IBClient: UILabel!
    @IBOutlet weak var IBWording: UILabel!
    @IBOutlet weak var IBAmount: UILabel!
    
    @IBOutlet weak var IBLabelConfirm: UILabel!
    @IBOutlet weak var IBLabelCancel: UILabel!
    
    @IBOutlet weak var IBLabelType: UILabel!
    
    @IBOutlet weak var IBButtonCancelr: UIBarButtonItem!
    @IBOutlet weak var IBEnded: UIBarButtonItem!
    
    @IBOutlet weak var IBConfirm: UISwitch!
    @IBOutlet weak var IBCancel: UISwitch!
    
    @IBOutlet weak var IBOtherText: UITextField!
    @IBOutlet weak var IBOther: UISwitch!
    
    @IBOutlet weak var IBMyAbsent: UISwitch!
    @IBOutlet weak var IBLabelMyAbsent: UILabel!
    @IBOutlet weak var IBCompliant: UISwitch!
    @IBOutlet weak var IBCompliantLabel: UILabel!
    @IBOutlet weak var IBInterlo: UISwitch!
    @IBOutlet weak var IBLabelInterlo: UILabel!
    
    
    
    let config = Config.sharedInstance
    let translate = InternationalIHM.sharedInstance
    var aTransaction:Transaction?
    
    
    //MARK: Locked landscapee
    open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation{
        get {
            return .portrait
        }
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        get {
            return .portrait
        }
    }
    
    open override var shouldAutorotate: Bool {
        get {
            return false
        }
    }
    
    //MARK: View Controller Delegate
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUIHidden(true)
        
        
        IBWording.text = "\(translate.wording!) \(aTransaction!.trans_wording)"
        IBAmount.text = "\(translate.amount!) \(BlackBox.sharedInstance.formatedAmount(aTransaction!.trans_amount)) \(translate.devise!)"
        
        
        IBConfirm.isOn = false
        IBCancel.isOn = false
        
        if aTransaction?.trans_type == 1 {
            IBLabelType.text = "\(IBLabelType.text!) \(translate.trade!)"
        }
        else if aTransaction?.trans_type == 2 {
            IBLabelType.text = "\(IBLabelType.text!) \(translate.exchange!)"
            
        }
        
        
        
        
        IBActivity.isHidden = false
        IBActivity.startAnimating()
        let paramId = (aTransaction?.client_id == aTransaction?.proprietaire) ? aTransaction?.vendeur_id : aTransaction?.client_id
        
        
        MDBUser.sharedInstance.getUser(paramId!, completionHandlerUser: {(success, usersArray, errorString) in
            
            if success {
                
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    
                    if (usersArray?.count)! > 0 {
                        for userDico in usersArray! {
                            self.IBClient.text = (self.aTransaction?.client_id == self.aTransaction?.proprietaire) ? "Vendeur :" : "Client :"
                            self.IBClient.text = "\(self.IBClient.text!) \(userDico["user_nom"]!) \(userDico["user_prenom"]!) (\(paramId!))"
                            self.IBInfoContact.text = "\(self.IBInfoContact.text!) \(userDico["user_ville"]!), \(userDico["user_pays"]!))"
                            
                            break
                            
                        }
                    }
                    
                    self.IBActivity.stopAnimating()
                    self.IBActivity.isHidden = true
                    
                }
            }
            else {
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    self.IBActivity.stopAnimating()
                    self.IBActivity.isHidden = true
                    self.displayAlert("Error", mess: errorString!)
                }
            }
            
            
        })
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IBButtonCancelr.title = translate.cancel
        IBEnded.title = translate.done
        IBLabelConfirm.text = translate.confirm
        IBLabelCancel.text = translate.cancel
        IBCompliantLabel.text = translate.compliant
        IBLabelMyAbsent.text = translate.myAbsence
        IBOtherText.placeholder = translate.other
    }
    
    @IBAction func actionButtonCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    //MARK: Data Transaction
    
    @IBAction func actionEnded(_ sender: Any) {
        
        guard IBConfirm.isOn || IBCancel.isOn else {
            displayAlert("Error", mess: "Vous n'avez pas accepté ou rejeté la transaction")
            return
        }
        
        
        let alertController = UIAlertController(title: "Transaction", message: "Attention vous allez terminer la transaction.", preferredStyle: .alert)
        
        let actionValider = UIAlertAction(title: "Valider", style: .destructive, handler: { (action) in
            
            if self.IBOther.isOn {
                self.aTransaction?.trans_avis = self.IBOtherText.text!
                
            }
            else if self.IBInterlo.isOn {
                self.aTransaction?.trans_avis = "interlocuteur" //l'interlocuteur était absent
                
            }
            else if self.IBCompliant.isOn {
                self.aTransaction?.trans_avis = "conformite" //le produit vendu ou echangé n'était pas conforme à l'annonce
                
            }
            else if self.IBMyAbsent.isOn {
                self.aTransaction?.trans_avis = "absence" //Je n'ai pu etre au rendez-vous
                
            }
            
            
            if self.IBCancel.isOn {
                
                self.aTransaction?.trans_valide = 1 //La transaction a été annulée
                
            }
            else if self.IBConfirm.isOn {
                
                self.aTransaction?.trans_valide = 2 //La transaction est confirmée
                
            }
            
            MDBTransact.sharedInstance.setUpdateTransaction(self.aTransaction!, completionHandlerUpdTrans: { (success, errorString) in
                
                if success {
                    
                    //Cas où le client confirme la transaction. alors son compte est debité
                    if self.aTransaction?.trans_type == 2 && self.aTransaction?.client_id == self.aTransaction?.proprietaire {
                        
                        self.config.balance = self.config.balance - Double(self.aTransaction!.trans_amount)
                        
                        var capital = Capital(dico: [String : AnyObject]())
                        var operation = Operation(dico: [String : AnyObject]())
                        
                        //Acheteur
                        
                        capital.balance = self.config.balance
                        capital.user_id = self.aTransaction!.proprietaire
                        
                        MDBCapital.sharedInstance.setUpdateCapital(capital, completionHandlerUpdate: { (success, errorString) in
                            
                            if success {
                                
                                operation.user_id = self.aTransaction!.proprietaire
                                operation.op_type = 3 //c'est une operation d'achat de produit
                                operation.op_amount = Double(self.aTransaction!.trans_amount)
                                operation.op_wording = "achat produit"
                                
                                //Création d'un operation d'achat pour le client
                                MDBOperation.sharedInstance.setAddOperation(operation, completionHandlerAddOp: {(success, errorString) in
                                    
                                    if success {
                                        
                                        Operations.sharedInstance.operationArray = nil
                                        
                                        
                                        //Le compte du vendeur est consulté
                                        MDBCapital.sharedInstance.getCapital(self.aTransaction!.vendeur_id, completionHandlerCapital: {(success, capitalArray, errorString) in
                                            
                                            if success {
                                                
                                                
                                                for dictionary in capitalArray!{
                                                    let cap = Capital(dico: dictionary)
                                                    capital.balance = cap.balance + Double(self.aTransaction!.trans_amount)
                                                    capital.user_id = cap.user_id
                                                }
                                                
                                                //Le compte du vendeur est crédité
                                                MDBCapital.sharedInstance.setUpdateCapital(capital, completionHandlerUpdate: { (success, errorString) in
                                                    
                                                    if success {
                                                        
                                                        
                                                        operation.user_id = self.aTransaction!.vendeur_id
                                                        operation.op_type = 4 //C'est une opération de vente de produit
                                                        operation.op_amount = Double(self.aTransaction!.trans_amount)
                                                        operation.op_wording = "vente produit"
                                                        
                                                        //Création d'un operation de vente pour le vendeur
                                                        MDBOperation.sharedInstance.setAddOperation(operation, completionHandlerAddOp: {(success, errorString) in
                                                            
                                                            if success {
                                                                
                                                                BlackBox.sharedInstance.performUIUpdatesOnMain {
                                                                    self.IBActivity.stopAnimating()
                                                                    self.dismiss(animated: true, completion: nil)
                                                                }
                                                                
                                                            }
                                                            else {
                                                                BlackBox.sharedInstance.performUIUpdatesOnMain {
                                                                    
                                                                    self.displayAlert("Error", mess: errorString!)
                                                                }
                                                            }
                                                            
                                                            
                                                        })
                                                        
                                                        
                                                        
                                                    }
                                                    else {
                                                        BlackBox.sharedInstance.performUIUpdatesOnMain {
                                                            
                                                            self.displayAlert("Error", mess: errorString!)
                                                        }
                                                    }
                                                    
                                                    
                                                })
                                                
                                                
                                                
                                            }
                                            else {
                                                
                                                BlackBox.sharedInstance.performUIUpdatesOnMain {
                                                    self.IBActivity.stopAnimating()
                                                    self.displayAlert("Error", mess: errorString!)
                                                }
                                            }
                                            
                                            
                                        })
                                        
                                        
                                    }
                                    else {
                                        BlackBox.sharedInstance.performUIUpdatesOnMain {
                                            
                                            self.displayAlert("Error", mess: errorString!)
                                        }
                                    }
                                    
                                    
                                })
                                
                                
                                
                            }
                            else {
                                BlackBox.sharedInstance.performUIUpdatesOnMain {
                                    
                                    self.displayAlert("Error", mess: errorString!)
                                }
                            }
                            
                            
                        })
                        
                        
                    }
                    else {
                        //Cas où le client annule la transaction ou bien le vendeur confirme la transaction.
                        BlackBox.sharedInstance.performUIUpdatesOnMain {
                            self.IBActivity.stopAnimating()
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                    
                    
                    
                }
                else {
                    
                    BlackBox.sharedInstance.performUIUpdatesOnMain {
                        
                        self.IBActivity.stopAnimating()
                        self.displayAlert("Error", mess: errorString!)
                    }
                }
                
            })
            
            
            
            
        })
        
        let actionCancel = UIAlertAction(title: "Annuler", style: .destructive, handler: { (action) in
            
        })
        
        alertController.addAction(actionCancel)
        alertController.addAction(actionValider)
        
        
        present(alertController, animated: true) {
            
        }
        
        
    }
    
    
    //MARK: Bouton Switch
    
    @IBAction func actionConfirm(_ sender: Any) {
        //confirmer la transaction
        IBCancel.isOn = (IBConfirm.isOn == true) ? false : true
        setUIHidden(!IBCancel.isOn)
    }
    
    @IBAction func actionCancel(_ sender: Any) {
        //annuler la transaction
        IBConfirm.isOn = (IBCancel.isOn == true) ? false : true
        setUIHidden(!IBCancel.isOn)
        
    }
    
    @IBAction func actionOther(_ sender: Any) {
        //Autre cause d'annulation de la transaction
        IBInterlo.isOn = (IBOther.isOn == true) ? false : true
        IBMyAbsent.isOn = (IBOther.isOn == true) ? false : true
        IBCompliant.isOn = (IBOther.isOn == true) ? false : true
        
        IBOtherText.isEnabled = IBOther.isOn
        
    }
    
    @IBAction func actionCompliant(_ sender: Any) {
        //Cause d'annulation : produit non conforme
        IBInterlo.isOn = (IBCompliant.isOn == true) ? false : true
        IBMyAbsent.isOn = (IBCompliant.isOn == true) ? false : true
        IBOther.isOn = (IBCompliant.isOn == true) ? false : true
        
        IBOtherText.isEnabled = IBOther.isOn
        
    }
    
    @IBAction func actionMyAbsent(_ sender: Any) {
        //Cause d'annulation : je suis absent
        IBInterlo.isOn = (IBMyAbsent.isOn == true) ? false : true
        IBCompliant.isOn = (IBMyAbsent.isOn == true) ? false : true
        IBOther.isOn = (IBMyAbsent.isOn == true) ? false : true
        
        IBOtherText.isEnabled = IBOther.isOn
        
    }
    
    @IBAction func actionInterlo(_ sender: Any) {
        //Cause d'annulation : mon interlocuteur est absent
        IBMyAbsent.isOn = (IBInterlo.isOn == true) ? false : true
        IBCompliant.isOn = (IBInterlo.isOn == true) ? false : true
        IBOther.isOn = (IBInterlo.isOn == true) ? false : true
        
        IBOtherText.isEnabled = IBOther.isOn
        
        
    }
    
    private func setUIHidden(_ hidden: Bool) {
        
        IBOther.isHidden = hidden
        IBInterlo.isHidden = hidden
        IBCompliant.isHidden = hidden
        IBMyAbsent.isHidden = hidden
        
        IBOtherText.isHidden = hidden
        IBOtherText.isEnabled = !hidden
        
        IBLabelInterlo.isHidden = hidden
        IBCompliantLabel.isHidden = hidden
        IBLabelMyAbsent.isHidden = hidden
        
        
        
    }
    
}
