//
//  ImageDownloader.swift
//  PressShare
//
//  Created by MacbookPRV on 24/03/2017.
//  Copyright © 2017 Pastouret Roger. All rights reserved.
//

import Foundation
import UIKit




class ImageDownloader : Operation {
    
    var product : Product
    
    init(product: Product) {
        self.product = product
    }
    
    
    override func main() {
        
        
        if self.isCancelled {
            return
        }
        
        product.prod_imageUrl = BlackBox.sharedInstance.saveImageArchive(prod_imageUrl: product.prod_imageUrl)
        
        if self.isCancelled {
            return
        }
        
        product.prod_image = BlackBox.sharedInstance.restoreImageArchive(prod_imageUrl: product.prod_imageUrl)
        
        if  product.prod_image == #imageLiteral(resourceName: "noimage") {
            product.state = .Failed
        }
        else {
            product.state = .Downloaded
        }
        
    }
    
}
