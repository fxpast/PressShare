//
//  Products.swift
//  GoOtoor
//
//  Created by MacbookPRV on 22/08/2017.
//  Copyright © 2017 Pastouret Roger. All rights reserved.
//

import Foundation


//MARK: Products Array
class Products {
    
    var productsArray :[[String:AnyObject]]! //list of products from map
    var productsUserArray :[[String:AnyObject]]! //list of new products from user
    var productsTraderArray :[[String:AnyObject]]! //list of products from traders
    static let sharedInstance = Products()
    
}
