//
//  CustomCell.swift
//  PressShare
//
//  Created by MacbookPRV on 21/01/2017.
//  Copyright © 2017 Pastouret Roger. All rights reserved.
//

import Foundation

class CustomCell: UITableViewCell {
    
    
    var label:UILabel!
    var photo:UIImageView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        photo = UIImageView(frame: CGRect(x: 5, y: 10, width: 20.0, height: 20.0))
        photo.tag = 88
        
        label = UILabel(frame: CGRect(x: 30, y: 2, width: 250, height: 40))
        label.tag = 99
        label.font = UIFont.systemFont(ofSize: 16.0)
        
        contentView.addSubview(label)
        contentView.addSubview(photo)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
