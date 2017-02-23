//
//  CommunRequest.swift
//  PressShare
//
//  Description : This class contains the main JSON request for others class 
//
//  Created by MacbookPRV on 18/12/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//

import Foundation

class CommunRequest {
    
    let translate = TranslateMessage.sharedInstance
    let urlServer = "http://pressshare.fxpast.com"
    
    func responseRequest(_ data:Data?, _ response:URLResponse, _ error:Error?, completionHdler:(_ success:Bool, _ result:Any?, _ errorString:String?) -> Void) {
        
        
        /* GUARD: Was there an error? */
        guard (error == nil) else {
            completionHdler(false, nil, "\(translate.message("errorRequest")) \(error?.localizedDescription)")
            return
            
        }
        
        /* GUARD: Did we get a successful 2XX response? */
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode , statusCode >= 200 && statusCode <= 299 else {
            completionHdler(false, nil, "\(translate.message("errorRequestReturn")) \(BlackBox.sharedInstance.statusCode(((response as? HTTPURLResponse)?.statusCode)!))")
            return
            
        }
        
        /* GUARD: Was there any data returned? */
        guard let data = data else {
            completionHdler(false, nil, translate.message("errorNoDataRequest"))
            return
            
        }
        
        
        /* Parse the data */
        let parsedResult: Any!
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        } catch {
            completionHdler(false, nil, "\(translate.message("errorParseJSON")) '\(data)'")
            return
            
        }
        
        completionHdler(true, parsedResult, nil)
        
        
    }
    
    
    func buildRequest(_ body: Data, _ product:Product, _ request:NSMutableURLRequest) -> NSMutableURLRequest {
        
        // Set Request Body
        
        request.setValue("multipart/form-data; boundary=\(product.prod_imageUrl)", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        let req = buildRequest("", request)
        return req
        
    }
    
    
    func buildRequest(_ body: String, _ request:NSMutableURLRequest) -> NSMutableURLRequest {
        
        // set Request Type
        request.httpMethod = "POST"
        // Set content-type
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        // Set Request Body
        if body != "" {
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
            request.httpBody = body.data(using: String.Encoding.utf8)
        }
        
        return request
        
    }
    
    static let sharedInstance = CommunRequest()
    
}
