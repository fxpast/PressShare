//
//  PendingOperations.swift
//  PressShare
//
//  Created by MacbookPRV on 24/03/2017.
//  Copyright © 2017 Pastouret Roger. All rights reserved.
//

//https://www.raywenderlich.com/76341/use-nsoperation-nsoperationqueue-swift


import Foundation
import UIKit



class PendingOperations {
    
    lazy var downloadsInProgress = [IndexPath:Operation]()
    
    lazy var downloadQueue:OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Download queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    lazy var filtrationsInProgress = [IndexPath:Operation]()
    
    lazy var filtrationQueue:OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Image Filtration queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
}
