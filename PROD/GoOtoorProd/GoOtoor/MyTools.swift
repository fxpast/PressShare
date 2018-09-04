//
//  MyTools.swift
//  GoOtoor
//
//  Created by MacbookPRV on 03/05/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//


import Foundation
import UIKit
import SystemConfiguration

//Globale function

class MyTools  {
    
    let translate = TranslateMessage.sharedInstance
    let config = Config.sharedInstance
    
    func showHelp(_ titre:String, _ sender: AnyObject) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "help") as! HelpViewController
        controller.helpTitre = titre
        sender.present(controller, animated: true, completion: nil)
        
    }
    
     func createLine(frame: CGRect) -> CAShapeLayer {
        
        var x1 = CGFloat()
        var y1 = CGFloat()
        var x2 = CGFloat()
        var y2 = CGFloat()
        
        let bezierObjet = UIBezierPath()
        let shapeLayer1 = CAShapeLayer()
        
        x1 = frame.origin.x
        y1 = frame.size.height
        x2 = frame.size.width
        y2 = frame.size.height
        
        
        bezierObjet.move(to: CGPoint.init(x: x1, y: y1))
        shapeLayer1.strokeColor = UIColor.blue.cgColor
        shapeLayer1.fillColor = UIColor.blue.cgColor
        
        bezierObjet.addLine(to: CGPoint.init(x: x2, y: y2))
        shapeLayer1.path = bezierObjet.cgPath
        shapeLayer1.lineWidth = 1.0
        
        return shapeLayer1
        
    }
    
    
    
    func checkBadge(completionHdlerBadge: @escaping (_ succes: Bool, _ result:String?) -> Void) {
        
        config.isTimer = true
        
        MDBMessage.sharedInstance.getAllMessages(config.user_id) {(success, messageArray, errorString) in
            
            if success {
                
                Messages.sharedInstance.MessagesArray = messageArray
                
                MyTools.sharedInstance.performUIUpdatesOnMain {
                    
                    var i = 0
                    
                    for mess in Messages.sharedInstance.MessagesArray {
                        
                        let message = Message(dico: mess)
                        
                        if message.destinataire == self.config.user_id && message.deja_lu == false {
                            i+=1
                        }
                        
                    }
                    if i > self.config.mess_badge {
                        
                        self.config.mess_badge = i
                        completionHdlerBadge(true, "mess_badge")
                    }
                    else {
                        
                         completionHdlerBadge(false, nil)
                    }
                    
                }
                
            }
            else {
                
                MyTools.sharedInstance.performUIUpdatesOnMain {
                    print(errorString ?? "error message")
                }
            }
            
        }
        
        

        MDBTransact.sharedInstance.getAllTransactions(self.config.user_id) { (success, transactionArray, errorString) in
                    
            if success {
                        
                        Transactions.sharedInstance.transactionArray = transactionArray
                        MyTools.sharedInstance.performUIUpdatesOnMain {
                            
                            var i = 0
                            for tran in Transactions.sharedInstance.transactionArray  {
                                
                                let tran1 = Transaction(dico: tran)
                                
                                if (tran1.trans_valid != 1 && tran1.trans_valid != 2 )  {
                                    i+=1
                                }
                                
                            }
                            
                            if i > self.config.trans_badge {
                                
                                self.config.trans_badge = i
                                completionHdlerBadge(true, "trans_badge")
                            }
                            else {
                                
                                completionHdlerBadge(false, nil)
                            }
                            
                        }
                        
                        self.config.isTimer = false
                    }
                    else {
                        
                        MyTools.sharedInstance.performUIUpdatesOnMain {
                            print(errorString ?? "error message")
                        }
            }
                    
        }
              
        
    }
    
    
    func checkBadge(menuBar:UITabBarController?) {
        
        config.isTimer = true
        
        MDBMessage.sharedInstance.getAllMessages(config.user_id) {(success, messageArray, errorString) in
            
            if success {
                
                Messages.sharedInstance.MessagesArray = messageArray
                
                MyTools.sharedInstance.performUIUpdatesOnMain {
                    
                    var i = 0
                    
                    for mess in Messages.sharedInstance.MessagesArray {
                        
                        let message = Message(dico: mess)
                        
                        if message.destinataire == self.config.user_id && message.deja_lu == false {
                            i+=1
                        }
                        
                    }
                    if i > 0 {
                        self.config.mess_badge = i
                        
                        menuBar?.tabBar.items![1].badgeValue = "\(i)"
                        
                        UIApplication.shared.applicationIconBadgeNumber = i
                    }
                    else {
                        
                        menuBar?.tabBar.items![1].badgeValue = nil
                        
                        UIApplication.shared.applicationIconBadgeNumber = 0
                    }
                    
                }
                
             
            }
            else {
                
                MyTools.sharedInstance.performUIUpdatesOnMain {
                   print(errorString ?? "error message")
                }
            }
            
        }
        
        
   
        MDBTransact.sharedInstance.getAllTransactions(self.config.user_id) { (success, transactionArray, errorString) in
                    
            if success {
                        
                        Transactions.sharedInstance.transactionArray = transactionArray
                        MyTools.sharedInstance.performUIUpdatesOnMain {
                            
                            var i = 0
                            for tran in Transactions.sharedInstance.transactionArray  {
                                
                                let tran1 = Transaction(dico: tran)
                                
                                if (tran1.trans_valid != 1 && tran1.trans_valid != 2 )  {
                                    i+=1
                                }
                                
                            }
                            if i > 0 {
                                self.config.trans_badge = i
                                
                                if menuBar?.tabBar.items![2] != nil {
                                    menuBar?.tabBar.items![2].badgeValue = "\(i)"
                                }
                                
                            }
                            else {
                                
                                menuBar?.tabBar.items![2].badgeValue = nil
                                
                            }
                            
                        }
                        
                        self.config.isTimer = false
                }
                else {
                        
                        MyTools.sharedInstance.performUIUpdatesOnMain {
                           print(errorString ?? "error message")
                        }
                }
                    
        }
                
                        
        
    }
    
    
    func pushProduct(menuBar:UITabBarController?, completionHdlerPushProduct: @escaping (_ success: Bool, _ product: Product?, _ errorStr: String?) -> Void) {
        
        let manager = FileManager.default
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first! as NSURL
        let filePath  = url.appendingPathComponent("aps_dico")!.path
        
        if let aps = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as? [String:AnyObject]  {
            
            do {
                try FileManager.default.removeItem(atPath: filePath)
            } catch  {
                print("error ", filePath)
            }
            
            
            MDBMessage.sharedInstance.getAllMessages(Config.sharedInstance.user_id) { (success, messageArray, errorString) in
                
                if success {
                    
                    Messages.sharedInstance.MessagesArray = messageArray
                }
                
            }
            
            let productId = Int(aps["product_id"] as! String)!
            let badge =  Int(aps["badge"] as! String)!
            UIApplication.shared.applicationIconBadgeNumber = badge
            
            menuBar?.tabBar.items![1].badgeValue = "\(badge)"
            Config.sharedInstance.mess_badge = badge
            
            MDBProduct.sharedInstance.getProduct(productId, completionHandlerProduct: { (success, productArray, errorString) in
                
                if success {
                    
                    for prod in productArray! {
                        
                        let produ = Product(dico: prod)
                        completionHdlerPushProduct(true, produ, nil)
                    }
                }
                else {
                     completionHdlerPushProduct(false, nil, errorString)
                }
                
            })
            
        }
        else {
            completionHdlerPushProduct(false, nil, "")
        }
        
    }
    
    
     func saveImageArchive(prod_imageUrl:String) -> String {
        
        let manager = FileManager.default
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first! as NSURL
        let filePath  = url.appendingPathComponent(prod_imageUrl)!.path
        let fileListPath = url.appendingPathComponent("listProdImage")!.path
        
        var prodImage = ""
        
        if (NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as? Data) != nil {
            prodImage = prod_imageUrl
        }
        else {
            
            let imageURL = URL(string: "\(CommunRequest.sharedInstance.urlServer)/images/\(prod_imageUrl).jpg")
            
            do {
                NSKeyedArchiver.archiveRootObject(try Data(contentsOf: imageURL!), toFile: filePath)
                prodImage = prod_imageUrl
                
                if (NSKeyedUnarchiver.unarchiveObject(withFile: fileListPath) as? [String]) != nil {
                    var arrayImage =  NSKeyedUnarchiver.unarchiveObject(withFile: fileListPath) as! [String]
                    
                    var dateText = arrayImage[0]
                    dateText.removeLast(6)
                    let aDate = Date().dateFromString(dateText)
                    let futureDate = Calendar.current.date(byAdding: .day, value: 7, to: aDate)
                    let resultCompare = Date().compare(futureDate!)
                    
                    if resultCompare == ComparisonResult.orderedDescending {
                        
                        for index in 1...arrayImage.count-1 {
                            do {
                                try FileManager.default.removeItem(atPath: arrayImage[index])
                            } catch  {
                                print("error ", arrayImage[index])
                            }
                        }
                        
                        do {
                            try FileManager.default.removeItem(atPath: fileListPath)
                        } catch  {
                            print("error ", fileListPath)
                        }
                        
                        var arrayImage = [String]()
                        arrayImage.append("\(Date())")
                        arrayImage.append(filePath)
                        NSKeyedArchiver.archiveRootObject(arrayImage, toFile: fileListPath)
                    }
                    else {
                        arrayImage.append(filePath)
                        NSKeyedArchiver.archiveRootObject(arrayImage, toFile: fileListPath)
                    }
                    
                }
                else {
                    var arrayImage = [String]()
                    arrayImage.append("\(Date())")
                    arrayImage.append(filePath)
                    NSKeyedArchiver.archiveRootObject(arrayImage, toFile: fileListPath)
                }
                
                
            }
            catch {
                prodImage = ""
                
            }
            
        }
        
        return prodImage
        
    }
    
    
    func restoreImageArchive(prod_imageUrl:String) -> UIImage {
        
        let manager = FileManager.default
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first! as NSURL
        let filePath  = url.appendingPathComponent(prod_imageUrl)!.path
        
        if let imagData = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as? Data {
            return UIImage(data:imagData)!
        }
        else {
            
            return #imageLiteral(resourceName: "noimage")
            
        }
        
    }
    
    
    
    func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        
        // Working for Cellular and WIFI
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)
        
        return ret
        
    }
    
    
    
    //Main queue
    func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
        DispatchQueue.main.async {
            updates()
        }
    }
    
    
    //formated double to string like 99999.99
    func formatedAmount(_ amount:Double) -> String {
        
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale.current
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        numberFormatter.usesGroupingSeparator = false
        if translate.message("lang") == "fr" {
            
            return "\(numberFormatter.string(from: NSNumber.init(value: amount))!) \(translate.message("devise"))"
        }
        else if translate.message("lang") == "us" {
            
            return "\(numberFormatter.string(from: NSNumber.init(value: amount))!) \(translate.message("devise"))"
            
        }
        
        return ""
    }
    
    //formated string to double like 99,999.99
    func formatedAmount(_ amount:String) -> Double? {
        
        var amountClear = amount.replacingOccurrences(of: translate.message("devise"), with: "")
        amountClear = amountClear.replacingOccurrences(of: " ", with: "")
        if translate.message("lang") == "fr" {
            amountClear = amountClear.replacingOccurrences(of: ".", with: "")
            amountClear = amountClear.replacingOccurrences(of: ",", with: ".")
        }
        else if translate.message("lang") == "us" {
            amountClear = amountClear.replacingOccurrences(of: ",", with: "")
        }
        
        if amountClear == "" {
            amountClear = "0"
        }
        
        return Double(amountClear)
        
    }
    
    
    //status code http
    func statusCode (_ code:Int) -> String {
        
        var text:String
        
        switch (code) {
        case 100: text = "Continue"
        case 101: text = "Switching Protocols"
        case 200: text = "OK"
        case 201: text = "Created"
        case 202: text = "Accepted"
        case 203: text = "Non-Authoritative Information"
        case 204: text = "No Content"
        case 205: text = "Reset Content"
        case 206: text = "Partial Content"
        case 300: text = "Multiple Choices"
        case 301: text = "Moved Permanently"
        case 302: text = "Moved Temporarily"
        case 303: text = "See Other"
        case 304: text = "Not Modified"
        case 305: text = "Use Proxy"
        case 400: text = "Bad Request"
        case 401: text = "Unauthorized"
        case 402: text = "Payment Required"
        case 403: text = "Forbidden"
        case 404: text = "Not Found"
        case 405: text = "Method Not Allowed"
        case 406: text = "Not Acceptable"
        case 407: text = "Proxy Authentication Required"
        case 408: text = "Request Time-out"
        case 409: text = "Conflict"
        case 410: text = "Gone"
        case 411: text = "Length Required"
        case 412: text = "Precondition Failed"
        case 413: text = "Request Entity Too Large"
        case 414: text = "Request-URI Too Large"
        case 415: text = "Unsupported Media Type"
        case 500: text = "Internal Server Error"
        case 501: text = "Not Implemented"
        case 502: text = "Bad Gateway"
        case 503: text = "Service Unavailable"
        case 504: text = "Gateway Time-out"
        case 505: text = "HTTP Version not supported"
        default:
            text = "Unknown http status code "
            
        }
        
        return "\(code) : \(text)"
        
    }
    
    static let sharedInstance = MyTools()
    
    
}





extension UIViewController {
    
    
    //display alert from view controller
    func displayModalAlert(_ title:String!, mess : String!) {
        
        let alertController = UIAlertController(title: title, message: mess, preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        
        
        self.present(alertController, animated: true, completion: nil)
        
        
        
    }
    
    //display alert like android Toast
    func displayAlert(_ title:String!, mess : String!) {
        
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let label = UILabel(frame: CGRect.zero)
        label.textAlignment = NSTextAlignment.center
        label.text = "\(title!): \(mess!)"
        label.font = UIFont(name: "", size: 15)
        label.adjustsFontSizeToFitWidth = true
        
       
        label.backgroundColor =  UIColor.black //UIColor.whiteColor()
        label.textColor = UIColor.white //TEXT COLOR
        
        label.sizeToFit()
        label.numberOfLines = 4
        label.layer.shadowColor = UIColor.gray.cgColor
        label.layer.shadowOffset = CGSize(width: 4, height: 3)
        label.layer.shadowOpacity = 0.3
        label.frame = CGRect(x: appDelegate.window!.frame.size.width, y: 64, width: appDelegate.window!.frame.size.width, height: 44)
        
        label.alpha = 1
        label.layer.cornerRadius = 10;
        label.clipsToBounds  =  true
        
        
        appDelegate.window!.addSubview(label)
        
        var basketTopFrame: CGRect = label.frame;
        basketTopFrame.origin.x = 0;
        
        UIView.animate(withDuration
            :4.0, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.1, options: UIViewAnimationOptions.curveEaseOut, animations: { () -> Void in
                label.frame = basketTopFrame
        },  completion: {
            (value: Bool) in
            UIView.animate(withDuration:4.0, delay: 2.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.1, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
                label.alpha = 0
            },  completion: {
                (value: Bool) in
                label.removeFromSuperview()
            })
        })
        
        
    }
    
    
    
}

extension UINavigationController {
    
    
    override open var shouldAutorotate: Bool {
        get {
            if let visibleVC = visibleViewController {
                return visibleVC.shouldAutorotate
            }
            return super.shouldAutorotate
        }
    }
    
    override open var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation{
        get {
            if let visibleVC = visibleViewController {
                return visibleVC.preferredInterfaceOrientationForPresentation
            }
            return super.preferredInterfaceOrientationForPresentation
        }
    }
    
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        get {
            if let visibleVC = visibleViewController {
                return visibleVC.supportedInterfaceOrientations
            }
            return super.supportedInterfaceOrientations
        }
    }}


extension UITabBarController {
    
    override open var shouldAutorotate: Bool {
        get {
            if let selectedVC = selectedViewController{
                return selectedVC.shouldAutorotate
            }
            return super.shouldAutorotate
        }
    }
    
    override open var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation{
        get {
            if let selectedVC = selectedViewController{
                return selectedVC.preferredInterfaceOrientationForPresentation
            }
            return super.preferredInterfaceOrientationForPresentation
        }
    }
    
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        get {
            if let selectedVC = selectedViewController{
                return selectedVC.supportedInterfaceOrientations
            }
            return super.supportedInterfaceOrientations
        }
    }}




extension UIAlertController {
    
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    override open var shouldAutorotate: Bool {
        return false
    }
}



extension Date {
    
    //date format : 2016/12/14 12:00:00
    func dateFromString(_ dateString: String) -> Date {
    
        let sdf = DateFormatter()
        sdf.locale = Locale.current
        sdf.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return sdf.date(from: dateString)!
    }
    
   
    func stringFromDate(_ dt: Date) -> String  {
        
        let sdf = DateFormatter()
        sdf.locale = Locale.current
        sdf.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return sdf.string(from: dt)
        
    }
    
    func dateFromServer(_ dateString: String) -> Date {
        

        let sdf = DateFormatter()
        sdf.locale = Locale.current
        sdf.timeZone = TimeZone.current
        sdf.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        
        let calendar = Calendar.current
    
        var timeZoneVal = "\(calendar.timeZone.abbreviation()!)"
        timeZoneVal.removeFirst()
        timeZoneVal.removeFirst()
        timeZoneVal.removeFirst()
        let signeZone = timeZoneVal.prefix(1)
        timeZoneVal.removeFirst()
        let hourZone = timeZoneVal
        
        var resultDate = sdf.date(from: dateString)!
        
       
        
        if signeZone == "+" {
            
            resultDate = calendar.date(byAdding: Calendar.Component.hour, value: +2*Int(hourZone)!, to: resultDate)!
            
            
        } else if signeZone == "-" {
            
            resultDate = calendar.date(byAdding: Calendar.Component.hour, value: -2*Int(hourZone)!, to: resultDate)!
            
        }
        
        return resultDate
        
    }
    
    
    func dateToServer(_ dt: Date) -> Date {
        
        let sdf = DateFormatter()
        sdf.locale = Locale.current
        sdf.timeZone = TimeZone.current
        sdf.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let dateStr = sdf.string(from: dt)
        let resultDate = sdf.date(from: dateStr)!
        
        return resultDate
        
    }
 
 
    
  /*
   

     func dateToServer(_ date: Date) -> Date {
     
     
     let RFC3339DateFormatter = DateFormatter()
     RFC3339DateFormatter.locale = Locale.current //Locale(identifier: "en_US_POSIX")
     RFC3339DateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ssZZZZZ"
     RFC3339DateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
     
     return RFC3339DateFormatter.date(from:  "\(date)")!
     
     }
 
     */
    
}


extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.characters.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue:      CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

