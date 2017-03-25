//
//  SettingsTableViewContr.swift
//  PressShare
//
//  Description : List of setting functions
//
//  Created by MacbookPRV on 22/05/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//


import UIKit
import Foundation
import MobileCoreServices


class SettingsTableViewContr : UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var IBLogout: UIBarButtonItem!
    @IBOutlet weak var IBProfilLabel: UILabel!
    @IBOutlet weak var IBTermsLabel: UILabel!
    @IBOutlet weak var IBConnectionLabel: UILabel!
    @IBOutlet weak var IBSubscripLabel: UILabel!
    @IBOutlet weak var IBMyCBLabel: UILabel!
    @IBOutlet weak var IBTransactLabel: UILabel!
    @IBOutlet weak var IBTutoLabel: UILabel!
    @IBOutlet weak var IBNomLabel: UILabel!
    @IBOutlet weak var IBEmailLabel: UILabel!
    @IBOutlet weak var IBPhotoUser: UIImageView!
    @IBOutlet weak var IBInfo: UIImageView!
    
    let config = Config.sharedInstance
    let translate = TranslateMessage.sharedInstance
    
    var aProduct:Product!
    
    let refreshControl1 = UIRefreshControl()
    
    
    //MARK: View Controller Delegate
    override func viewDidLoad() {
        super.viewDidLoad()
        
        config.previousView = "SettingsTableViewContr"
      
        refreshControl1.addTarget(self, action: #selector(actionRefresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl1)
        
        tableView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(handleTap)))
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        config.isReturnToTab = false
        
        self.navigationItem.title = "\(config.user_pseudo!) (\(config.user_id!))"
        
        navigationController?.tabBarItem.title = translate.message("settings")
        
        IBPhotoUser.image = restoreImageArchive()
        IBNomLabel.text = "\(config.user_nom!) \(config.user_prenom!)"
        IBEmailLabel.text = config.user_email
        
        tableView.scrollToRow(at: IndexPath(item: 1, section: 0), at: .none, animated: false)
        IBProfilLabel.text = translate.message("editProfil")
        tableView.scrollToRow(at: IndexPath(item: 2, section: 0), at: .none, animated: false)
        chargeData(2, labelText: translate.message("runTransac"), badgeValue: config.trans_badge!)
        tableView.scrollToRow(at: IndexPath(item: 3, section: 0), at: .none, animated: false)
        IBConnectionLabel.text = translate.message("connectInfo")
        tableView.scrollToRow(at: IndexPath(item: 4, section: 0), at: .none, animated: false)
        IBSubscripLabel.text = translate.message("mySubscrit")
        tableView.scrollToRow(at: IndexPath(item: 5, section: 0), at: .none, animated: false)
        IBTermsLabel.text = translate.message("termsOfUse")
        tableView.scrollToRow(at: IndexPath(item: 6, section: 0), at: .none, animated: false)
        IBMyCBLabel.text = translate.message("myCB")
        tableView.scrollToRow(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "fromsettings" {
            
            let nav = segue.destination as! UINavigationController
            let controller = nav.topViewController as! ProductTableViewContr
            
            controller.aProduct = aProduct
            //controller.aProduct?.prod_imageData = UIImageJPEGRepresentation(BlackBox.sharedInstance.restoreImageArchive(prod_imageUrl: (controller.aProduct!.prod_imageUrl)), 1)!
            
        }

    }
    
    
    func handleTap(sender: UITapGestureRecognizer) {
        
        if sender.state == .ended {
            
            let location = sender.location(in: tableView)
            let indexPath = tableView.indexPathForRow(at:location)
            
            let zx = location.x
            let cell = tableView.cellForRow(at: indexPath!)
            let zy = location.y - (cell?.frame.origin.y)!
            
            if indexPath?.row == 0 && indexPath?.section == 0 {
                
                var xw1 = IBPhotoUser.frame.origin.x + IBPhotoUser.frame.size.width
                var yh1 = IBPhotoUser.frame.origin.y + IBPhotoUser.frame.size.height
                if zx <= xw1 && zx >= IBPhotoUser.frame.origin.x && zy  <= yh1 && zy >= IBPhotoUser.frame.origin.y {
                    
                    actionPhotoProfil()
                }
                else {
                    
                    xw1 = IBInfo.frame.origin.x + IBInfo.frame.size.width
                    yh1 = IBInfo.frame.origin.y + IBInfo.frame.size.height
                    
                    if zx <= xw1 && zx >= IBInfo.frame.origin.x && zy  <= yh1 && zy >= IBInfo.frame.origin.y {
                        
                        //action info
                        BlackBox.sharedInstance.showHelp("SettingsTableViewContr", self)
                        
                    }
                    
                }
                
            }
            
        }
        
        sender.cancelsTouchesInView = false
    }
    
    
    private func actionPhotoProfil() {
        
        
        guard UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) == true else {
            
            imageFromCamera(camera: false, type: nil)
            return
        }
        
        let alertController = UIAlertController(title: translate.message("takePicture"), message: translate.message("makeChoice"), preferredStyle: .alert)
        
        let actionBiblio = UIAlertAction(title: translate.message("library"), style: .destructive, handler: { (action) in
            BlackBox.sharedInstance.performUIUpdatesOnMain {
                
                self.imageFromCamera(camera: false, type: nil)
                
            }
            
        })
        
        let actionCameraFront = UIAlertAction(title: translate.message("cameraFront"), style: .destructive, handler: { (action) in
            
            BlackBox.sharedInstance.performUIUpdatesOnMain {
                
                self.imageFromCamera(camera: true, type: UIImagePickerControllerCameraDevice.front)
                
            }
        })
        
        let actionCameraRear = UIAlertAction(title: translate.message("cameraRear"), style: .destructive, handler: { (action) in
            
            BlackBox.sharedInstance.performUIUpdatesOnMain {
                
                self.imageFromCamera(camera: true, type: UIImagePickerControllerCameraDevice.rear)
                
            }
        })
        
        let actionAnnuler = UIAlertAction(title: translate.message("cancel"), style: .destructive, handler: { (action) in
            
            
            //no action
            
        })
        
        alertController.addAction(actionBiblio)
        alertController.addAction(actionCameraFront)
        alertController.addAction(actionCameraRear)
        alertController.addAction(actionAnnuler)
        
     
        self.present(alertController, animated: true) {
            
        }
        
        
        
    }
    
    
    private func imageFromCamera(camera:Bool, type:UIImagePickerControllerCameraDevice?) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.modalPresentationStyle = UIModalPresentationStyle.currentContext;
        imagePicker.mediaTypes = [kUTTypeImage as String]
        
        if camera {
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.cameraDevice = type!
        }
        else {
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        }
        
        show(imagePicker, sender: self)
        
        
    }

    
    //MARK: Image Picker Delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
       
        IBPhotoUser.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        IBPhotoUser.contentMode = .scaleAspectFit
        
        saveImageArchive(photo: IBPhotoUser.image!)
        
        dismiss(animated: true, completion: nil)
    }
    
    
    //MARK: coreData function
    
    
    private func saveImageArchive(photo:UIImage) {
        
        let manager = FileManager.default
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first! as NSURL
        let filePath  = url.appendingPathComponent("userPhoto")!.path
        
        NSKeyedArchiver.archiveRootObject(photo, toFile: filePath)
        
    }
    
    
   private func restoreImageArchive() -> UIImage {
        
        let manager = FileManager.default
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first! as NSURL
        let filePath  = url.appendingPathComponent("userPhoto")!.path
        
        if let imageSave = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as? UIImage {
            return imageSave
        }
        else {
            return #imageLiteral(resourceName: "user")
        }
        
    }
    
    
    @IBAction func actionRefresh(_ sender: AnyObject) {
        
        refreshData()
        
    }
    
    @IBAction func actionLogout(_ sender: AnyObject) {
        
        //logout
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! as NSURL
        let filePath  = url.appendingPathComponent("userDico")!.path
        
        do {
            try FileManager.default.removeItem(atPath: filePath)
        } catch  {
            print("error ", filePath)
        }
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    
    private func refreshData()  {
        
        
        refreshControl1.beginRefreshing()
        
        MDBTransact.sharedInstance.getAllTransactions(config.user_id) { (success, transactionArray, errorString) in
            
            if success {
                
                Transactions.sharedInstance.transactionArray = transactionArray
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    
                    var i = 0
                    for tran in Transactions.sharedInstance.transactionArray  {
                        
                        let tran1 = Transaction(dico: tran)
                        
                        if (tran1.trans_valid != 1 && tran1.trans_valid != 2 )  {
                            i+=1
                        }
                        
                    }
                    if i > 0 {
                        self.config.trans_badge = i
                        
                    }
                    
                    BlackBox.sharedInstance.performUIUpdatesOnMain {
                        
                        self.chargeData(2, labelText: self.translate.message("runTransac"), badgeValue: self.config.trans_badge!)
                        
                        self.refreshControl1.endRefreshing()
                        
                    }
                    
                    
                }
            }
            else {
                
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    self.refreshControl1.endRefreshing()
                    self.displayAlert(self.translate.message("error"), mess: errorString!)
                }
            }
            
        }
        
        
    }
    
    private func chargeData(_ item:Int, labelText:String, badgeValue:Int)  {
        
        var cell:UITableViewCell
        
        cell = tableView.cellForRow(at: IndexPath(item: item, section: 0))!
        
        IBTransactLabel.text = labelText
        
        if cell.contentView.subviews.count > 1 {
            
            cell.contentView.subviews[1].removeFromSuperview()
            IBTransactLabel.frame = CGRect(origin: CGPoint.init(x: IBTransactLabel.frame.origin.x - 10, y: 0) , size: IBTransactLabel.frame.size)
            tabBarController?.tabBar.items![2].badgeValue  = nil
        }
        
        if badgeValue > 0 {
            let badge = BadgeLabel(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0))
            badge.setup()
            
            badge.badgeValue = "\(badgeValue)"
            
            cell.contentView.addSubview(badge)
            IBTransactLabel.frame = CGRect(origin: CGPoint.init(x: IBTransactLabel.frame.origin.x + 10.0, y: 0) , size: IBTransactLabel.frame.size)
            
            tabBarController?.tabBar.items![2].badgeValue = "\(badgeValue)"
            
        }
        else {
            tabBarController?.tabBar.items![2].badgeValue  = nil
            
        }
        
        
    }
    
    
    //MARK: Table View Controller Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch (indexPath as NSIndexPath).row {
        case 1:
            
      
            
            if config.level > -1 {
                performSegue(withIdentifier: "profil", sender: self)
            }
        case 2:
            
            if config.level > -1 {
                performSegue(withIdentifier: "transaction", sender: self)
            }
            
            
        case 3:
            
            if config.level > -1 {
                performSegue(withIdentifier: "abonner", sender: self)
            }
            
        case 4:
            
            
            if config.level > -1 {
                performSegue(withIdentifier: "infoconnexion", sender: self)
            }
            
        case 5:
            
            
            
            if config.level > -1 {
                performSegue(withIdentifier: "carte", sender: self)
            }
            
        case 6:
            
            BlackBox.sharedInstance.showHelp("Conditions_PressShare", self)
            
            
        default:
            break
        }
        
    }
    
    
}



