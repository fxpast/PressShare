//
//  Data.swift
//  PressShare
//
//  Created by MacbookPRV on 11/05/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//


//Todo :Sauvegarder les photos en memoire cache pour gagner en temps de chargement

//Todo :Les commentaires doivent être en anglais
//Todo :Les classes doivent avoir en entete l'auteur , la date de création, de modification, la definitions, leurs paramètres
//Todo :Les methodes doivent avoir en entete leur definition, leurs paramètre et leur @return


import Foundation

struct Product {
    
    //MARK: Properties
    
    
    var prod_id:Int
    var prod_imageData:Data
    var prod_image:String
    var prod_nom:String
    var prod_date:Date
    var prod_prix:Double
    var prod_by_user:Int
    var prod_by_cat:Int
    var prod_latitude:Double
    var prod_longitude:Double
    var prod_mapString:String
    var prod_comment:String
    var prod_tempsDispo:String
    var prod_etat:Int
    
    //MARK: Initialisation
    
    init(dico : [String : AnyObject]) {
        
        if dico.count > 1 {
            
            prod_id = Int(dico["prod_id"] as! String)!
            
            prod_image = dico["prod_image"] as! String
            let imageURL = URL(string: "http://pressshare.fxpast.com/images/\(prod_image).jpg")
            do {
                prod_imageData = try Data(contentsOf: imageURL!)
            }
            catch {
                prod_imageData = Data()
            }
            
            prod_nom = dico["prod_nom"] as! String
            
            prod_date = Date().dateFromString(dico["prod_date"] as! String, format: "yyyy-MM-dd HH:mm:ss")
            prod_prix = Double(dico["prod_prix"] as! String)!
            
            
            prod_by_user = Int(dico["prod_by_user"] as! String)!
            prod_by_cat = Int(dico["prod_by_cat"] as! String)!
            prod_latitude = Double(dico["prod_latitude"] as! String)!
            prod_longitude = Double(dico["prod_longitude"] as! String)!
            prod_mapString = dico["prod_mapString"] as! String
            prod_comment = dico["prod_comment"] as! String
            prod_tempsDispo = dico["prod_tempsDispo"] as! String
            prod_etat = Int(dico["prod_etat"] as! String)!
            
        }
        else {
            prod_id = 0
            prod_imageData = Data()
            prod_image = ""
            prod_nom = ""
            
            prod_date = Date()
            prod_prix = 0
            prod_by_user = 0
            prod_by_cat = 0
            prod_latitude = 0
            prod_longitude = 0
            prod_mapString = ""
            prod_comment = ""
            prod_tempsDispo = ""
            prod_etat = 0
            
        }
        
    }
    
}


//MARK: Products Array
class Products {
    
    var productsArray :[[String:AnyObject]]!
    static let sharedInstance = Products()
    
}


class MDBProduct {
    
    func getAllProducts(_ userId:Int, completionHandlerProducts: @escaping (_ success: Bool, _ productArray: [[String:AnyObject]]?, _ errorString: String?) -> Void) {
        
        // Create Data from request
        var request = NSMutableURLRequest(url: URL(string: "http://pressshare.fxpast.com/api_getAllProducts.php")!)
        let body: String = "user_id=\(userId)"
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
    
    
    func setDeleteProduct(_ product: Product, completionHandlerDelProduct: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        // Create your request string with parameter name as defined in PHP file
        let body: String = "prod_id=\(product.prod_id)&prod_image=\(product.prod_image)"
        // Create Data from request
        var request = NSMutableURLRequest(url: URL(string: "http://pressshare.fxpast.com/api_delProduct.php")!)
        
        request = CommunRequest.sharedInstance.buildRequest(body, request)
        
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            
            CommunRequest.sharedInstance.responseRequest(data, response!, error, completionHdler: { (suces, result, errorStr) in
                
                if suces {
                    
                    let res = result as! [String:String]
                    
                    if (res["success"] == "1") {
                        completionHandlerDelProduct(true, nil)
                    }
                    else {
                        completionHandlerDelProduct(false, "impossible to delete the product")
                        
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
        
        
        //add parameters
        
        let param = [
            "prod_by_user" : product.prod_by_user,
            "prod_date" : product.prod_date,
            "prod_nom" : product.prod_nom,
            "prod_prix" : product.prod_prix,
            "prod_by_cat" : product.prod_by_cat,
            "prod_latitude" : product.prod_latitude,
            "prod_longitude" : product.prod_longitude,
            "prod_mapString" : product.prod_mapString,
            "prod_comment" : product.prod_comment,
            "prod_tempsDispo" : product.prod_tempsDispo,
            "prod_etat" : product.prod_etat,
            "prod_image" : product.prod_image
            ] as [String : Any]
        
   
        // Create Data from request
        var request = NSMutableURLRequest(url: URL(string: "http://pressshare.fxpast.com/api_addProduct.php")!)
        let body = createBodyWithParameters(parameters: param, filePathKey: "file", imageDataKey: product.prod_imageData, boundary: product.prod_image)
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
    
    
    func createBodyWithParameters(parameters: [String: Any]?, filePathKey: String?, imageDataKey: Data, boundary: String) -> Data {
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
