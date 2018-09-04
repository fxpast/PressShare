//
//  MDBProduct.swift
//  GoOtoor
//
//  Created by MacbookPRV on 22/08/2017.
//  Copyright © 2017 Pastouret Roger. All rights reserved.
//

import Foundation
import UIKit


//MARK: Product methods
class MDBProduct {
    
    let translate = TranslateMessage.sharedInstance
    
    func getProduct(_ prod_id:Int, completionHandlerProduct: @escaping (_ success: Bool, _ productArray: [[String:AnyObject]]?, _ errorString: String?) -> Void) {
        
        guard  MyTools.sharedInstance.isConnectedToNetwork() == true else {
            completionHandlerProduct(false, nil, translate.message("errorConnection"))
            return
        }
        
        // Create Data from request
        var request = NSMutableURLRequest(url: URL(string: "\(CommunRequest.sharedInstance.urlServer)/api_getProduct.php")!)
        let body: String = "prod_id=\(prod_id)&lang=\(translate.message("lang"))"
        request = CommunRequest.sharedInstance.buildRequest(body, request)
        
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            CommunRequest.sharedInstance.responseRequest(data, response!, error, completionHdler: { (suces, result, errorStr) in
                
                if suces {
                    
                    let resultDico = result as! [String:AnyObject]
                    let resultArray = resultDico["aproduct"] as! [[String:AnyObject]]
                    
                    
                    if resultDico["success"] as! String == "1" {
                        completionHandlerProduct(true, resultArray, nil)
                    }
                    else {
                        completionHandlerProduct(false, nil, resultDico["error"] as? String)
                        
                    }
                    
                }
                else {
                    completionHandlerProduct(false, nil, errorStr)
                }
                
            })
            
            
        })
        
        
        task.resume()
        
    }
    
    
    func getProductsByTrader(_ userId:Int, completHandleProdByTrader: @escaping (_ success: Bool, _ productArray: [[String:AnyObject]]?, _ errorString: String?) -> Void) {
        
        guard  MyTools.sharedInstance.isConnectedToNetwork() == true else {
            completHandleProdByTrader(false, nil, translate.message("errorConnection"))
            return
        }
        
        // Create Data from request
        var request = NSMutableURLRequest(url: URL(string: "\(CommunRequest.sharedInstance.urlServer)/api_getProductsByTrader.php")!)
        let body: String = "user_id=\(userId)&lang=\(translate.message("lang"))"
        request = CommunRequest.sharedInstance.buildRequest(body, request)
        
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            CommunRequest.sharedInstance.responseRequest(data, response!, error, completionHdler: { (suces, result, errorStr) in
                
                if suces {
                    
                    let resultDico = result as! [String:AnyObject]
                    let resultArray = resultDico["allproducts"] as! [[String:AnyObject]]
                    
                    
                    if resultDico["success"] as! String == "1" {
                        completHandleProdByTrader(true, resultArray, nil)
                    }
                    else {
                        completHandleProdByTrader(false, nil, resultDico["error"] as? String)
                        
                    }
                    
                }
                else {
                    completHandleProdByTrader(false, nil, errorStr)
                }
                
            })
            
            
        })
        
        
        task.resume()
        
    }
    
    
    func getProductsByUser(_ userId:Int, completHandleProdByUser: @escaping (_ success: Bool, _ productArray: [[String:AnyObject]]?, _ errorString: String?) -> Void) {
        
        guard  MyTools.sharedInstance.isConnectedToNetwork() == true else {
            completHandleProdByUser(false, nil, translate.message("errorConnection"))
            return
        }
        
        // Create Data from request
        var request = NSMutableURLRequest(url: URL(string: "\(CommunRequest.sharedInstance.urlServer)/api_getProductsByUser.php")!)
        let body: String = "user_id=\(userId)&lang=\(translate.message("lang"))"
        request = CommunRequest.sharedInstance.buildRequest(body, request)
        
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            CommunRequest.sharedInstance.responseRequest(data, response!, error, completionHdler: { (suces, result, errorStr) in
                
                if suces {
                    
                    let resultDico = result as! [String:AnyObject]
                    let resultArray = resultDico["allproducts"] as! [[String:AnyObject]]
                    
                    
                    if resultDico["success"] as! String == "1" {
                        completHandleProdByUser(true, resultArray, nil)
                    }
                    else {
                        completHandleProdByUser(false, nil, resultDico["error"] as? String)
                        
                    }
                    
                }
                else {
                    completHandleProdByUser(false, nil, errorStr)
                }
                
            })
            
            
        })
        
        
        task.resume()
        
    }
    
    
    func getProductsByCoord(_ userId:Int,  minLon:Double, maxLon:Double, minLat:Double, maxLat:Double, completionHandlerProducts: @escaping (_ success: Bool, _ productArray: [[String:AnyObject]]?, _ errorString: String?) -> Void) {
        
        guard  MyTools.sharedInstance.isConnectedToNetwork() == true else {
            completionHandlerProducts(false, nil, translate.message("errorConnection"))
            return
        }
        
        // Create Data from request
        var request = NSMutableURLRequest(url: URL(string: "\(CommunRequest.sharedInstance.urlServer)/api_getProductsByCoord.php")!)
        let body: String = "user_id=\(userId)&minLon=\(minLon)&maxLon=\(maxLon)&minLat=\(minLat)&maxLat=\(maxLat)&lang=\(translate.message("lang"))"
        request = CommunRequest.sharedInstance.buildRequest(body, request)
        
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            CommunRequest.sharedInstance.responseRequest(data, response!, error, completionHdler: { (suces, result, errorStr) in
                
                if suces {
                    
                    let resultDico = result as! [String:AnyObject]
                    let resultArray = resultDico["allproducts"] as! [[String:AnyObject]]
                    
                    
                    if resultDico["success"] as! String == "1" {
                        completionHandlerProducts(true, resultArray, nil)
                    }
                    else {
                        completionHandlerProducts(false, nil, resultDico["error"] as? String)
                        
                    }
                    
                }
                else {
                    completionHandlerProducts(false, nil, errorStr)
                }
                
            })
            
            
        })
        
        
        task.resume()
        
    }
    
    
    func setUpdateProduct(_ typeUpdate:String, _ product: Product, completionHandlerUpdProduct: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        guard  MyTools.sharedInstance.isConnectedToNetwork() == true else {
            completionHandlerUpdProduct(false, translate.message("errorConnection"))
            return
        }
        
        // Create Data from request
        var request = NSMutableURLRequest(url: URL(string: "\(CommunRequest.sharedInstance.urlServer)/api_update\(typeUpdate).php")!)
        
        // Create your request string with parameter name as defined in PHP file
        var body: String = ""
        if typeUpdate == "ProductTrans" {
            
            body = "prod_id=\(product.prod_id)&prod_oth_user=\(product.prod_oth_user)&prod_hidden=\(product.prod_hidden)&prod_closed=\(product.prod_closed)&lang=\(translate.message("lang"))"
            request = CommunRequest.sharedInstance.buildRequest(body, request)
            
        }
        else if typeUpdate == "Product" {
            
            if product.prodImageOld == "" {
                
                body = "prod_id=\(product.prod_id)&prod_nom=\(product.prod_nom)&prod_date=\(product.prod_date)&prod_prix=\(product.prod_prix)&prod_by_user=\(product.prod_by_user)&prod_by_cat=\(product.prod_by_cat)&prod_comment=\(product.prod_comment)&prod_etat=\(product.prod_etat)&prod_hidden=\(product.prod_hidden)&prod_echange=\(product.prod_echange)&prod_closed=\(product.prod_closed)&prod_imageUrl=\(product.prod_imageUrl)&prodImageOld=\(product.prodImageOld)&lang=\(translate.message("lang"))"
                request = CommunRequest.sharedInstance.buildRequest(body, request)
            }
            else {
                //add parameters
                
                let param = [
                    "prod_by_user" : product.prod_by_user,
                    "prod_date" : product.prod_date,
                    "prod_nom" : product.prod_nom,
                    "prod_prix" : product.prod_prix,
                    "prod_by_cat" : product.prod_by_cat,
                    "prod_comment" : product.prod_comment,
                    "prod_etat" : product.prod_etat,
                    "prod_imageUrl" : product.prod_imageUrl,
                    "prodImageOld" : product.prodImageOld,
                    "prod_hidden" : product.prod_hidden,
                    "prod_echange" : product.prod_echange,
                    "prod_id" : product.prod_id,
                    "prod_closed" : product.prod_closed,
                    "lang" : translate.message("lang")
                    ] as [String : Any]
                
                let bodyData = createBodyWithParameters(parameters: param, filePathKey: "file", imageDataKey: UIImageJPEGRepresentation(product.prod_image, 1)!, boundary: product.prod_imageUrl)
                request = CommunRequest.sharedInstance.buildRequest(bodyData, product, request)
                
                
            }
            
        }
        
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            CommunRequest.sharedInstance.responseRequest(data, response!, error, completionHdler: { (suces, result, errorStr) in
                
                if suces {
                    
                    let res = result as! [String:String]
                    
                    if (res["success"] == "1") {
                        completionHandlerUpdProduct(true, nil)
                    }
                    else {
                        completionHandlerUpdProduct(false, self.translate.message("impossibleUpdPr"))
                        
                    }
                    
                }
                else {
                    completionHandlerUpdProduct(false, errorStr)
                }
                
            })
            
        })
        
        
        task.resume()
        
    }
    
    func setDeleteProduct(_ product: Product, completionHandlerDelProduct: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        guard  MyTools.sharedInstance.isConnectedToNetwork() == true else {
            completionHandlerDelProduct(false, translate.message("errorConnection"))
            return
        }
        
        // Create your request string with parameter name as defined in PHP file
        let body: String = "prod_id=\(product.prod_id)&prod_imageUrl=\(product.prod_imageUrl)&lang=\(translate.message("lang"))"
        // Create Data from request
        var request = NSMutableURLRequest(url: URL(string: "\(CommunRequest.sharedInstance.urlServer)/api_delProduct.php")!)
        
        request = CommunRequest.sharedInstance.buildRequest(body, request)
        
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            
            CommunRequest.sharedInstance.responseRequest(data, response!, error, completionHdler: { (suces, result, errorStr) in
                
                if suces {
                    
                    let res = result as! [String:String]
                    
                    if (res["success"] == "1") {
                        completionHandlerDelProduct(true, nil)
                    }
                    else {
                        completionHandlerDelProduct(false, self.translate.message("impossibleDeldPr"))
                        
                    }
                    
                }
                else {
                    completionHandlerDelProduct(false, errorStr)
                }
                
            })
            
        })
        
        
        task.resume()
        
    }
    
    
    func setAddProduct(_ product: Product, completionHandlerProduct: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        guard  MyTools.sharedInstance.isConnectedToNetwork() == true else {
            completionHandlerProduct(false, translate.message("errorConnection"))
            return
        }
        
        //add parameters
        
        let param = [
            "prod_by_user" : product.prod_by_user,
            "prod_date" : product.prod_date,
            "prod_nom" : product.prod_nom,
            "prod_prix" : product.prod_prix,
            "prod_by_cat" : product.prod_by_cat,
            "prod_comment" : product.prod_comment,
            "prod_etat" : product.prod_etat,
            "prod_echange" : product.prod_echange,
            "prod_imageUrl" : product.prod_imageUrl,
            "prod_closed" : product.prod_closed,
            "lang" : translate.message("lang")
            ] as [String : Any]
        
        
        // Create Data from request
        var request = NSMutableURLRequest(url: URL(string: "\(CommunRequest.sharedInstance.urlServer)/api_addProduct.php")!)
        let body = createBodyWithParameters(parameters: param, filePathKey: "file", imageDataKey: UIImageJPEGRepresentation(product.prod_image, 1)!, boundary: product.prod_imageUrl)
        request = CommunRequest.sharedInstance.buildRequest(body, product, request)
        
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            
            
            CommunRequest.sharedInstance.responseRequest(data, response!, error, completionHdler: { (suces, result, errorStr) in
                
                if suces {
                    
                    let res = result as! [String:String]
                    
                    if (res["success"] == "1") {
                        completionHandlerProduct(true, nil)
                    }
                    else {
                        completionHandlerProduct(false, res["error"])
                        
                    }
                    
                }
                else {
                    completionHandlerProduct(false, errorStr)
                }
                
            })
            
            
        })
        
        
        task.resume()
        
    }
    
    
    private func createBodyWithParameters(parameters: [String: Any]?, filePathKey: String?, imageDataKey: Data, boundary: String) -> Data {
        var body = Data()
        
        var chaine:String
        
        if parameters != nil {
            for (key, value) in parameters! {
                chaine = "--\(boundary)\r\n"
                body.append(chaine.data(using: String.Encoding.utf8, allowLossyConversion: true)!)
                chaine = "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n"
                body.append(chaine.data(using: String.Encoding.utf8, allowLossyConversion: true)!)
                chaine = "\(value)\r\n"
                body.append(chaine.data(using: String.Encoding.utf8, allowLossyConversion: true)!)
                
            }
        }
        
        
        let filename = "\(boundary).jpg"
        let mimetype = "image/jpg"
        
        chaine = "--\(boundary)\r\n"
        body.append(chaine.data(using: String.Encoding.utf8, allowLossyConversion: true)!)
        
        chaine = "Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n"
        body.append(chaine.data(using: String.Encoding.utf8, allowLossyConversion: true)!)
        
        chaine = "Content-Type: \(mimetype)\r\n\r\n"
        body.append(chaine.data(using: String.Encoding.utf8, allowLossyConversion: true)!)
        
        body.append(imageDataKey)
        
        chaine = "\r\n"
        body.append(chaine.data(using: String.Encoding.utf8, allowLossyConversion: true)!)
        
        chaine = "--\(boundary)--\r\n"
        body.append(chaine.data(using: String.Encoding.utf8, allowLossyConversion: true)!)
        
        return body
    }
    
    static let sharedInstance = MDBProduct()
    
    
}

