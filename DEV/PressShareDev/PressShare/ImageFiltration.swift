//
//  PhotoOperations.swift
//  PressShare
//
//  Created by MacbookPRV on 23/03/2017.
//  Copyright © 2017 Pastouret Roger. All rights reserved.
//

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
        
        if let filteredImage = self.applySepiaFilter(self.product.prod_image) {
            self.product.prod_image = filteredImage
            self.product.state = .Filtered
        }
    }
    
    private func applySepiaFilter(_ image: UIImage) -> UIImage? {
    
        let inputImage = CIImage.init(data: UIImagePNGRepresentation(image)!)
        
        if self.isCancelled {
            return nil
        }
        
        let context = CIContext.init(options: nil)
        let filter = CIFilter.init(name: "CISepiaTone")
        filter?.setValue(inputImage, forKey: kCIInputImageKey)
        filter?.setValue(0.8, forKey: "inputIntensity")
        let outputImage = filter?.outputImage
        
        if self.isCancelled {
            return nil
        }
        
        let outImage = context.createCGImage(outputImage!, from: outputImage!.extent)
        let returnImage = UIImage.init(cgImage: outImage!)
        
        return returnImage
        
        
    }
    
}








