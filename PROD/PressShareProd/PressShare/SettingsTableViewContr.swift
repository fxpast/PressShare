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
    
    
    @IBOutlet weak var IBCompteur: UILabel!
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
    
    var timerBadge : Timer!
    
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
        
        
        IBNomLabel.textColor = UIColor.init(hexString: config.colorAppLabel)
        IBNomLabel.text = "\(config.user_nom!) \(config.user_prenom!) (\(config.user_note!) \(self.translate.message("star")))"

        
        IBEmailLabel.textColor = UIColor.init(hexString: config.colorAppLabel)
        IBEmailLabel.text = config.user_email

        
        IBCompteur.textColor = UIColor.init(hexString: config.colorAppLabel)
        IBCompteur.text = "\(translate.message("CancelCounter")) \(config.failure_count!)"
        
        tableView.scrollToRow(at: IndexPath(item: 1, section: 0), at: .none, animated: false)
        
        IBProfilLabel.textColor = UIColor.init(hexString: config.colorAppLabel)
        IBProfilLabel.text = translate.message("editProfil")
        tableView.scrollToRow(at: IndexPath(item: 2, section: 0), at: .none, animated: false)
        chargeData(2, labelText: translate.message("runTransac"), badgeValue: config.trans_badge!)
        tableView.scrollToRow(at: IndexPath(item: 3, section: 0), at: .none, animated: false)
        
        IBConnectionLabel.textColor = UIColor.init(hexString: config.colorAppLabel)
        IBConnectionLabel.text = translate.message("connectInfo")
        tableView.scrollToRow(at: IndexPath(item: 4, section: 0), at: .none, animated: false)
        
        IBSubscripLabel.textColor = UIColor.init(hexString: config.colorAppLabel)
        IBSubscripLabel.text = translate.message("mySubscrit")
        tableView.scrollToRow(at: IndexPath(item: 5, section: 0), at: .none, animated: false)
        
        IBTermsLabel.textColor = UIColor.init(hexString: config.colorAppLabel)
        IBTermsLabel.text = translate.message("termsOfUse")
        tableView.scrollToRow(at: IndexPath(item: 6, section: 0), at: .none, animated: false)
        
        IBMyCBLabel.textColor = UIColor.init(hexString: config.colorAppLabel)
        IBMyCBLabel.text = translate.message("myCB")
        tableView.scrollToRow(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
        
        
        for i in 0...6 {
            tableView.scrollToRow(at: IndexPath(item: i, section: 0), at: .none, animated: false)
            tableView(tableView, cellForRowAt: IndexPath(item: i, section: 0)).backgroundColor  = UIColor.init(hexString: config.colorApp)
            tableView(tableView, cellForRowAt: IndexPath(item: i, section: 0)).backgroundView?.backgroundColor  = UIColor.init(hexString: config.colorApp)
        }
        tableView.scrollToRow(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
        
        tableView.backgroundColor = UIColor.init(hexString: config.colorApp)
        tableView.backgroundView?.backgroundColor = UIColor.init(hexString: config.colorApp)
        tableView.sectionIndexColor = UIColor.init(hexString: config.colorApp)
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        timerBadge = Timer.scheduledTimer(timeInterval: config.dureeTimer, target: self, selector: #selector(routineTimer), userInfo: nil, repeats: true)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    
        config.isTimer = false
        timerBadge.invalidate()
        timerBadge = nil
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "fromsettings" {
            
            let nav = segue.destination as! UINavigationController
            let controller = nav.topViewController as! ProductTableViewContr
            
            controller.aProduct = aProduct
            
        }

    }
    
    
    @objc private func routineTimer() {
        
        if config.isTimer == false {
            BlackBox.sharedInstance.checkBadge(menuBar: tabBarController!)
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
        
        
        let maxSize : CGFloat = 1024.0
        let width : CGFloat = (IBPhotoUser.image?.size.width)!
        let height : CGFloat = (IBPhotoUser.image?.size.height)!
        var newWidth : CGFloat = width
        var newHeight : CGFloat = height
        
        // If any side exceeds the maximun size, reduce the greater side to 1200px and proportionately the other one
        if (width > maxSize || height > maxSize) {
            if (width > height) {
                newWidth = maxSize;
                newHeight = (height*maxSize)/width;
            } else {
                newHeight = maxSize;
                newWidth = (width*maxSize)/height;
            }
        }
        
        // Resize the image
        let newSize = CGSize.init(width: newWidth, height: newHeight)
        UIGraphicsBeginImageContext(newSize)
        IBPhotoUser.image?.draw(in: CGRect.init(origin: CGPoint.init(x: 0, y: 0), size: newSize))
        IBPhotoUser.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Set maximun compression in order to decrease file size and enable faster uploads & downloads
        let imageData = UIImageJPEGRepresentation(IBPhotoUser.image!, 0.0)!
        IBPhotoUser.image = UIImage(data: imageData)
        
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
        
        
        IBTransactLabel.textColor = UIColor.init(hexString: config.colorAppLabel)
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



