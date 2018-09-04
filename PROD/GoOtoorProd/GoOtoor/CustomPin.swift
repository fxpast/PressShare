//
//  PinView.swift
//  GoOtoor
//
//Description : Create a extend Pin with prod_id property
//
//  Created by MacbookPRV on 20/02/2017.
//  Copyright © 2017 Pastouret Roger. All rights reserved.
//

import Foundation
import MapKit

class CustomPin: MKPointAnnotation {
    
    
    var prod_id:Int!
    
    override init() {
        
        super.init()
        prod_id = 0
        
    }
    
    
    
}
