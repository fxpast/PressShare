//
//  PhotoOperations.swift
//  PressShare
//
//  Created by MacbookPRV on 23/03/2017.
//  Copyright © 2017 Pastouret Roger. All rights reserved.
//

//https://www.raywenderlich.com/76341/use-nsoperation-nsoperationqueue-swift

import Foundation
import UIKit

class ImageFiltration: Operation {
    
    
    var product : Product
    
    init(product: Product) {
        
        self.product = product
        
    }
    
    override func main() {
        
        if self.isCancelled {
            return
        }
        
        if self.product.state != .Downloaded {
            return
        }
        
        self.product.state = .Filtered
        
       
    }
    

}

