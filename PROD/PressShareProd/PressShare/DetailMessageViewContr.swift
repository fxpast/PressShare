//
//  DetailMessageViewContr.swift
//  PressShare
//
//  Created by MacbookPRV on 16/01/2017.
//  Copyright © 2017 Pastouret Roger. All rights reserved.
//


//Todo : Aide inadapté pour détaille message

import Foundation
import UIKit

class DetailMessageViewContr: UIViewController, UITextViewDelegate  {
    
    @IBOutlet weak var IBActivity: UIActivityIndicatorView!
    @IBOutlet weak var IBTextMess: UITextView!
    @IBOutlet weak var IBSend: UIButton!
    @IBOutlet weak var IBScrollView: UIScrollView!
    @IBOutlet weak var IBCancel: UIBarButtonItem!
    
    var timerBadge : Timer!

    var aProduct:Product?
    var customOpeation = BlockOperation()
    let myQueue = OperationQueue()
    var fieldName = ""
    var keybordY:CGFloat! = 0
    let config = Config.sharedInstance
    let translate = TranslateMessage.sharedInstance
    var dateStrBefore = ""
    var dateStrAfter = ""
    let distance:CGFloat = 10.0
    var initFrame = CGRect()
    var readOnly = false
    
    //MARK: Locked portrait
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
        
        self.view.addGestureRecognizer(setUpTapGesture())
        IBScrollView.addGestureRecognizer(setUpTapGesture())
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        view.backgroundColor =  UIColor.init(hexString: config.colorApp)
        IBScrollView.backgroundColor = UIColor.init(hexString: config.colorApp)
        
        IBTextMess.textColor = UIColor.init(hexString: config.colorAppText)
        
        self.navigationItem.title = translate.message("myNotif")
        subscibeToKeyboardNotifications()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        timerBadge = Timer.scheduledTimer(timeInterval: config.dureeTimer, target: self, selector: #selector(routineTimer), userInfo: nil, repeats: true)
        
        for trans in Transactions.sharedInstance.transactionArray {
            
            let tran = Transaction(dico: trans)
            
            //Cancel transaction = 1 | Confirmed transaction = 2
            if tran.prod_id == aProduct?.prod_id && (tran.trans_valid == 1 || tran.trans_valid == 2) {
                IBSend.isEnabled = false
                IBTextMess.isEditable = false
                readOnly = true
                break
            }
        }
        
        
        
        initFrame = IBScrollView.frame
        IBActivity.isHidden = false
        IBActivity.startAnimating()
        IBScrollView.isHidden = true
        
        if let _ = Messages.sharedInstance.MessagesArray {
            
            myQueue.addOperation {
                
                self.customOpeation = BlockOperation()
                self.customOpeation.addExecutionBlock {
                    if !self.customOpeation.isCancelled
                    {
                        BlackBox.sharedInstance.performUIUpdatesOnMain {
                            self.chargeData()
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
        
    }
    
    
    @IBAction func actionHelp(_ sender: Any) {
        
        
        initScrollView()
        
        //action info
        BlackBox.sharedInstance.showHelp("transactions", self)
        
    }
    
    
    @IBAction func actionSend(_ sender: Any) {
        
     
        guard IBTextMess.text != "" else {
            return
        }
        
        IBTextMess.endEditing(true)
        
        IBSend.isEnabled = false
      
        var message = Message(dico: [String : AnyObject]())
        message.date_ajout = Date()
        message.expediteur = config.user_id
        message.message_id = 0
   
        
        if aProduct?.prod_by_user == message.expediteur {
            message.destinataire = aProduct!.prod_oth_user
            
        }
        else if aProduct?.prod_oth_user == message.expediteur {
            message.destinataire = aProduct!.prod_by_user
            
        }
        message.proprietaire = config.user_id
        message.client_id = aProduct!.prod_oth_user
        message.vendeur_id = aProduct!.prod_by_user
        message.product_id = aProduct!.prod_id
        message.contenu = "\(translate.message("emailSender")) \(config.user_nom!) \(config.user_prenom!) \n \(IBTextMess.text!)"
        
        let frame = self.createLabelMess(message)
        
        var y = IBScrollView.contentSize.height - IBScrollView.frame.size.height
        IBScrollView.contentOffset = CGPoint(x: 0.0, y: y)
        
        
        IBActivity.startAnimating()
        IBActivity.isHidden = false
        
        MDBMessage.sharedInstance.setAddMessage(message, completionHandlerMessages: { (success, errorString) in
            
            if success {
                
                
                MDBMessage.sharedInstance.setPushNotification(message, completionHandlerPush: { (success, errorString) in
                    
                    if success {
                        
                        //ok
                    }
                    else {
                        
                        BlackBox.sharedInstance.performUIUpdatesOnMain {
                            self.displayAlert(self.translate.message("error"), mess: errorString!)
                        }
                    }
                })
                
                
                MDBMessage.sharedInstance.getAllMessages(self.config.user_id) { (success, messageArray, errorString) in
                    
                    if success {
                        
                        Messages.sharedInstance.MessagesArray = messageArray
                    }
                    else {
                        
                        BlackBox.sharedInstance.performUIUpdatesOnMain {
                            self.displayAlert(self.translate.message("error"), mess: errorString!)
                        }
                    }
                    
                }
                
                
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    
                    self.createLabelTime(message.date_ajout, frame: frame)
                    
                    y = self.IBScrollView.contentSize.height - self.IBScrollView.frame.size.height
                    self.IBScrollView.contentOffset = CGPoint(x: 0.0, y: y)
                    
                    self.IBTextMess.text = ""
                    self.IBSend.isEnabled = true
                    self.IBActivity.stopAnimating()
                }
            }
            else {
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    self.IBSend.isEnabled = true
                    self.IBActivity.stopAnimating()
                    self.displayAlert(self.translate.message("error"), mess: errorString!)
                }
            }
            
            
        })
        
    }
    
    @objc private func routineTimer() {
        
        if config.isTimer == false {
            
            BlackBox.sharedInstance.checkBadge(completionHdlerBadge: { (success, result) in
                
                if success == true {
                    
                    self.actionRefresh(self)
                    
                }
                else {
                    
                }
                
            })
        }
        
    }
    
    
    @IBAction func actionRefresh(_ sender: Any) {
        
  
        initScrollView()
        refreshData()
    }
    
    @IBAction func actionCancel(_ sender: Any) {
        
        var flgMAJ = false
        
        config.isTimer = false
        timerBadge.invalidate()
        timerBadge = nil
        
        IBScrollView.isHidden = true
        IBCancel.isEnabled = false
        IBActivity.isHidden = false
        IBActivity.startAnimating()
        
       
            for index in 0...Messages.sharedInstance.MessagesArray.count-1 {
                
                var message = Message(dico: Messages.sharedInstance.MessagesArray[index])
                
                if message.product_id == aProduct?.prod_id && message.deja_lu == false {
                    
                    if message.deja_lu == false {
                        config.mess_badge = config.mess_badge - 1
                        UIApplication.shared.applicationIconBadgeNumber = config.mess_badge
                        
                    }
                    
                    message.deja_lu = true
                   
                    flgMAJ = true
                    MDBMessage.sharedInstance.setUpdateMessage(message, completionHandlerUpdate: { (success, errorString) in
                        
                        if success {
                            
                            
                            MDBMessage.sharedInstance.getAllMessages(self.config.user_id) { (success, messageArray, errorString) in
                                
                                if success {
                                    
                                    Messages.sharedInstance.MessagesArray = messageArray
                                }
                                else {
                                    
                                    BlackBox.sharedInstance.performUIUpdatesOnMain {
                                        self.displayAlert(self.translate.message("error"), mess: errorString!)
                                    }
                                }
                                
                            }
                            
                            
                            BlackBox.sharedInstance.performUIUpdatesOnMain {
                                self.IBActivity.stopAnimating()
                                self.dismiss(animated: true, completion: nil)
                            }
                        }
                        else {
                            
                            BlackBox.sharedInstance.performUIUpdatesOnMain {
                                if self.readOnly == false {
                                    self.IBSend.isEnabled = true
                                }
                                self.IBCancel.isEnabled = true
                                self.IBScrollView.isHidden = false
                                self.IBActivity.stopAnimating()
                                self.displayAlert(self.translate.message("error"), mess: errorString!)
                            }
                        }
                        
                    })
                    
                }
                
            }
            
        
        
        if flgMAJ == false {
            dismiss(animated: true, completion: nil)
            
        }
        
    }
    
    //MARK: Data Message
    
    private func initScrollView() {
     
        for view in IBScrollView.subviews {
            view.removeFromSuperview()
        }
        
        for layer in IBScrollView.layer.sublayers! {
            layer.removeFromSuperlayer()
        }
        
        IBScrollView.frame = initFrame
        IBScrollView.contentOffset = initFrame.origin
        IBScrollView.contentSize = initFrame.size
        
        dateStrAfter = ""
        dateStrBefore = ""
        
    }
    
    private func DrawLineTime(_ date: Date) {
        
        var offSet = IBScrollView.contentSize.height + 10.0
        var middleX = view.frame.size.width * 1/2
        
        let width = IBScrollView.frame.size.width
        offSet = offSet - 1
        let labelLine = UILabel(frame: CGRect(x: middleX, y: offSet, width: width, height: 0))
        
        let day = Calendar.current.component(.day, from: date)
        let month = Calendar.current.component(.month, from: date)
        let year = Calendar.current.component(.year, from: date)
        
        dateStrAfter =  "\(year)\(month)\(day)"
        
        if dateStrAfter != dateStrBefore {
            dateStrBefore = dateStrAfter
       
         
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = .none
            dateFormatter.dateStyle = .medium
            dateFormatter.locale = Locale.current
            dateFormatter.doesRelativeDateFormatting = true
            let dateString = dateFormatter.string(from: date)
            
            labelLine.text = dateString
            
            labelLine.font = UIFont.systemFont(ofSize: 8.0)
            labelLine.sizeToFit()
            var frame = labelLine.frame
            frame.origin.x = frame.origin.x - frame.size.width/2
            labelLine.frame = frame
            middleX = frame.origin.x
            IBScrollView.addSubview(labelLine)
            
            let line1 = UIBezierPath()
            offSet = offSet + 5
            line1.move(to: CGPoint.init(x: 0.0, y: offSet))
            middleX = labelLine.frame.origin.x
            line1.addLine(to: CGPoint.init(x: middleX, y: offSet))
            let shapeLayer1 = CAShapeLayer()
            shapeLayer1.path = line1.cgPath
            shapeLayer1.strokeColor = UIColor.lightGray.cgColor
            shapeLayer1.lineWidth = 1.0
            
            IBScrollView.layer.addSublayer(shapeLayer1)
            
            let line2 = UIBezierPath()
            middleX = middleX + labelLine.frame.size.width
            line2.move(to: CGPoint.init(x: middleX, y: offSet))
            middleX = IBScrollView.frame.size.width
            line2.addLine(to: CGPoint.init(x: middleX, y: offSet))
            let shapeLayer2 = CAShapeLayer()
            shapeLayer2.path = line2.cgPath
            shapeLayer2.strokeColor = UIColor.lightGray.cgColor
            shapeLayer2.lineWidth = 1.0
            
            IBScrollView.layer.addSublayer(shapeLayer2)
            
            offSet = offSet + 20.0
            
            IBScrollView.alwaysBounceHorizontal = false
            IBScrollView.showsHorizontalScrollIndicator = false
            IBScrollView.contentSize = CGSize.init(width: width, height: offSet)
            IBScrollView.sizeToFit()
            
        }
        
    }
    
    private func createLabelMess(_ messa:Message) -> CGRect {
        
        
        self.DrawLineTime(messa.date_ajout)
        
        var offSet:CGFloat = self.IBScrollView.contentSize.height
        let width = self.IBScrollView.frame.size.width
        
        let labelMessage = UITextView(frame: CGRect(x: 0.0, y: offSet, width: width, height: 0))
        
        labelMessage.text = messa.contenu
        labelMessage.tag = messa.message_id
        
        labelMessage.sizeToFit()
        
    
        labelMessage.addGestureRecognizer(setUpTapGesture())
        if messa.expediteur == config.user_id {
            var frame = labelMessage.frame
            frame.origin.x = IBScrollView.frame.size.width - frame.size.width
            labelMessage.frame = frame
            
            labelMessage.textColor = UIColor.white
            labelMessage.backgroundColor = UIColor.blue
            createArrow(labelMessage.frame, sens: "E")
            
        }
        if messa.destinataire == config.user_id {
            labelMessage.textColor = UIColor.black
            labelMessage.backgroundColor = UIColor.lightGray
            createArrow(labelMessage.frame, sens: "D")
        }
        
        labelMessage.isEditable = false
        IBScrollView.addSubview(labelMessage)
        IBScrollView.sizeToFit()
        
        offSet = offSet + labelMessage.frame.size.height
        
        IBScrollView.contentSize = CGSize.init(width: width, height: offSet)
        
        return labelMessage.frame
        
    }
    
    private func createArrow(_ frame:CGRect, sens:String) {
    
        var x1 = CGFloat()
        var y1 = CGFloat()
        var x2 = CGFloat()
        var y2 = CGFloat()
        
        let bezierObjet = UIBezierPath()
        let shapeLayer1 = CAShapeLayer()
        
        y1 = frame.origin.y + frame.size.height
        if sens == "E" {
            x1 = frame.origin.x + frame.size.width - distance
            bezierObjet.move(to: CGPoint.init(x: x1, y: y1))
            x1 = x1 + distance
            shapeLayer1.strokeColor = UIColor.blue.cgColor
            shapeLayer1.fillColor = UIColor.blue.cgColor
        }
        else if sens == "D" {
            x1 = frame.origin.x + distance
            bezierObjet.move(to: CGPoint.init(x: x1, y: y1))
            x1 = x1 - distance
            shapeLayer1.strokeColor = UIColor.lightGray.cgColor
            shapeLayer1.fillColor = UIColor.lightGray.cgColor
        }
        
        x2 = x1
        y2 = y1 + distance * 3/2
       
        bezierObjet.addCurve(to: CGPoint.init(x: x1, y: y1), controlPoint1: CGPoint.init(x: x2, y: y2), controlPoint2: CGPoint.init(x: x2, y: y2))
        shapeLayer1.path = bezierObjet.cgPath
        shapeLayer1.lineWidth = 1.0
        IBScrollView.layer.addSublayer(shapeLayer1)
        
    }
    
    private func createLabelTime(_ date:Date, frame:CGRect) {
        
        var offSet = IBScrollView.contentSize.height
        
        let labelTime = UILabel(frame: CGRect(x: frame.origin.x, y: offSet, width: 0.0, height: 0.0))
        let hour = Calendar.current.component(.hour, from: date)
        let minute = Calendar.current.component(.minute, from: date)
        labelTime.text = "\(hour):\(minute) ✓"
        labelTime.font = UIFont.systemFont(ofSize: 8.0)
        labelTime.addGestureRecognizer(setUpTapGesture())
        labelTime.sizeToFit()
        var frame = labelTime.frame
        frame.origin.x = frame.origin.x + distance
        labelTime.frame = frame
        
        offSet = offSet + labelTime.frame.size.height + 10.0
        
        IBScrollView.addSubview(labelTime)
        IBScrollView.sizeToFit()
        
        IBScrollView.contentSize = CGSize.init(width: IBScrollView.frame.size.width, height: offSet)
        
    }
    
    private func chargeData() {
        
        var flgMessExist = false
        
        for index in 0...Messages.sharedInstance.MessagesArray.count-1 {
            
            guard !self.customOpeation.isCancelled else {
                return
            }
            
            let messa = Message(dico: Messages.sharedInstance.MessagesArray[index])
            
            if messa.product_id == self.aProduct?.prod_id {
                
                flgMessExist = true
                
                let frame = self.createLabelMess(messa)
                
                createLabelTime(messa.date_ajout, frame: frame)
                
                let y = IBScrollView.contentSize.height - IBScrollView.frame.size.height
                IBScrollView.contentOffset = CGPoint(x: 0.0, y: y)
                
            }
            
        }
        
        if flgMessExist == true && readOnly == false {
            self.IBSend.isEnabled = true
        }
        else {
            self.IBSend.isEnabled = false
        }
        
        IBScrollView.isHidden = false
        
        
    }
    
    
    private func refreshData()  {
        
        
        myQueue.cancelAllOperations()
        guard myQueue.operationCount == 0 else {
            
            return
        }
        
        
        IBActivity.isHidden = false
        IBActivity.startAnimating()
        IBScrollView.isHidden = true
        
        MDBMessage.sharedInstance.getAllMessages(config.user_id) { (success, messageArray, errorString) in
            
            if success {
                
                Messages.sharedInstance.MessagesArray = messageArray
                
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    self.chargeData()
                    self.IBActivity.stopAnimating()
                    
                }
            }
            else {
                
                BlackBox.sharedInstance.performUIUpdatesOnMain {
                    self.IBActivity.stopAnimating()
                    self.displayAlert(self.translate.message("error"), mess: errorString!)
                }
            }
            
        }
        
        
    }
    
    
    //MARK: textView Delegate
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        
        textView.endEditing(true)
        return true
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView.isEqual(IBTextMess) {
            fieldName = "IBTextMess"
        }
        return true
    }
    
    //MARK: keyboard function
    
    private func setUpTapGesture() -> UITapGestureRecognizer {
        
        let tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action:#selector(tapActionGesture(_:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        tapGestureRecognizer.delaysTouchesBegan = true
        
        return tapGestureRecognizer
    }
    
    @objc private func tapActionGesture(_ gesture:UITapGestureRecognizer) {
        
        if gesture.state == UIGestureRecognizerState.ended {
            
            guard fieldName != "" && keybordY > 0 else {
                return
            }
            
            var textView = UITextView()
            
            if fieldName == "IBTextMess" {
                textView = IBTextMess
            }
            
            textView.endEditing(true)
        }
        
    }
    
    
    func  subscibeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        
    }
    
    
    func keyboardWillShow(notification:NSNotification) {
        
        
        var textView = UITextView()
        
        
        if fieldName == "IBTextMess" {
            textView = IBTextMess
        }
        
        if textView.isFirstResponder {
            keybordY = view.frame.size.height - getkeyboardHeight(notification: notification)
            if keybordY < (textView.frame.origin.y + textView.frame.size.height/2)  {
                view.frame.origin.y = keybordY - textView.frame.origin.y - textView.frame.size.height
            }
            
            
        }
        
        
    }
    
    
    func keyboardWillHide(notification:NSNotification) {
        
        var textView = UITextView()
        
        
        if fieldName == "IBTextMess" {
            textView = IBTextMess
        }
        
        if textView.isFirstResponder {
            view.frame.origin.y = 0
        }
        
        fieldName = ""
        keybordY = 0
        
        
    }
    
    func getkeyboardHeight(notification:NSNotification)->CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
        
    }
    
    
}
