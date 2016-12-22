//
//  BlackBox.swift
//  PressShare
//
//  Created by MacbookPRV on 03/05/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//


import Foundation
import UIKit

//Globale function

class BlackBox  {
    
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
        numberFormatter.usesGroupingSeparator = true
        return numberFormatter.string(from: NSNumber.init(value: amount))!
        
    }
    
    //formated string to double like 99,999.99
    func formatedAmount(_ amount:String) -> Double? {
        
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale.current
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        numberFormatter.usesGroupingSeparator = true
        
        let amountClear = amount.replacingOccurrences(of: " ", with: "")
        
        return (numberFormatter.number(from: amountClear)?.doubleValue)!
        
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
    
    static let sharedInstance = BlackBox()
    
    
}




extension UIViewController {
    
    
    //display alert from view controller
    func displayAlert(_ title:String!, mess : String!) {
        
        let alertController = UIAlertController(title: title, message: mess, preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        
        
        self.present(alertController, animated: true, completion: nil)
        
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




extension Date {
    
    //date format : 2016/12/14 12:00:00
    func dateFromString(_ date: String, format: String) -> Date {
        let formatter = DateFormatter()
        let locale = Locale(identifier: "en_US_POSIX")
        
        formatter.locale = locale
        formatter.dateFormat = format
        
        return formatter.date(from: date)!
    }
}




