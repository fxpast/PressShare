//
//  ImageDownloader.swift
//  PressShare
//
//  Created by MacbookPRV on 24/03/2017.
//  Copyright © 2017 Pastouret Roger. All rights reserved.
//

//https://www.raywenderlich.com/76341/use-nsoperation-nsoperationqueue-swift

import Foundation
import UIKit


// This enum contains all the possible states a photo record can be in
enum PhotoRecordState {
    case New, Downloaded, Filtered, Failed
}


class ImageDownloader : Operation {
    
    var product : Product
    let config = Config.sharedInstance
    
    init(product: Product) {
        self.product = product
    }
    
    override func main() {
        
        if self.isCancelled{
            return
        }
        
        product.prod_imageUrl = BlackBox.sharedInstance.saveImageArchive(prod_imageUrl: product.prod_imageUrl)
        
        if self.isCancelled{
            return
        }
        
        product.prod_image = BlackBox.sharedInstance.restoreImageArchive(prod_imageUrl: product.prod_imageUrl)
        
        if self.isCancelled{
            return
        }
        
        if  product.prod_image == #imageLiteral(resourceName: "noimage") {
            product.state = .Failed
        }
        else {
            product.state = .Downloaded
        }
        
        
        if self.isCancelled{
            return
        }

        //Resize the image
        let newSize = CGSize.init(width: config.widthImage, height: config.heightImage)
        UIGraphicsBeginImageContext(newSize)
        product.prod_image.draw(in: CGRect.init(origin: CGPoint.init(x: 0, y: 0), size: newSize))
        product.prod_image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        
    }
    
}
