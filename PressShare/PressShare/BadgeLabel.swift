//
//  BadgeLabel.swift
//  BadgeLabel
//
//Description : Create red flag with a count.

//  Created by Roger Pastouret on 25/11/2016.
//  Copyright © 2016 RP. All rights reserved.
//



import Foundation
import UIKit

class BadgeLabel: UILabel {
    
    // Badge value to be display
    
    var badgeValue : String = "" {
        didSet {
            if (badgeValue == "0" && shouldHideBadgeAtZero == true) || badgeValue.isEmpty {
                removeBadge()
            } else {
                isHidden = false
                updateBadgeValueAnimated(animated: true)
            }
        }
    }
    
    // Badge background color
    var badgeBGColor = UIColor.red
    
    // Badge text color
    var badgeTextColor = UIColor.white
    
    // Badge font
    var badgeFont = UIFont()
    
    // Padding value for the badge
    var badgePadding = CGFloat()
    
    // Minimum size badge to small
    var badgeMinSize = CGFloat()
    
    //Values for offseting the badge over the BarButtonItem you picked
    var badgeOriginX : CGFloat = 0 {
        didSet {
            updateBadgeFrame()
        }
    }
    var badgeOriginY : CGFloat = 0 {
        didSet {
            updateBadgeFrame()
        }
    }
    
    
    // In case of numbers, remove the badge when reaching zero
    var shouldHideBadgeAtZero = true
    
    // Badge has a bounce animation when value changes
    var shouldAnimateBadge = true
    
    // The badge displayed over the BarButtonItem
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    
    //MARK: -
    func setup() {
        
        badgeBGColor = UIColor.red
        badgeTextColor = UIColor.white
        badgeFont = UIFont.systemFont(ofSize: 14.0)
        badgePadding = 4.0
        badgeMinSize = 10.0
        badgeOriginY = 0
        badgeOriginX = 0
        shouldHideBadgeAtZero = true
        shouldAnimateBadge = true
        clipsToBounds = false
        
        frame = CGRect(x: badgeOriginX, y: badgeOriginY, width: 20.0, height: 20.0)
        textColor = badgeTextColor
        backgroundColor = badgeBGColor
        font = badgeFont
        textAlignment = NSTextAlignment.center
        text = ""
        
        updateBadgeValueAnimated(animated: true)
    }
    
    
    func updateBadgeFrame() {
        let lbl_Frame = duplicateLabel(lblCopy: self)
        lbl_Frame.sizeToFit()
        
        let expectedLabelSize = lbl_Frame.frame.size
        
        var minHeight = expectedLabelSize.height
        minHeight = (minHeight < badgeMinSize) ? badgeMinSize : expectedLabelSize.height
        
        var minWidth = expectedLabelSize.width
        minWidth = (minWidth < minHeight) ? minHeight : expectedLabelSize.width
        
        let padding = badgePadding
        frame = CGRect(x: badgeOriginX, y: badgeOriginY, width: minWidth + padding, height: minHeight + padding)
        layer.cornerRadius = frame.width / 2
        layer.masksToBounds = true
    }
    
    func duplicateLabel(lblCopy: UILabel) -> UILabel {
        let lbl_duplicate = UILabel(frame: lblCopy.frame)
        lbl_duplicate.text = lblCopy.text
        lbl_duplicate.font = lblCopy.font
        
        return lbl_duplicate
    }
    
    func updateBadgeValueAnimated(animated : Bool) {
        if(animated == true && shouldAnimateBadge && text != badgeValue) {
            let animation = CABasicAnimation .init(keyPath: "transform.scale")
            animation.fromValue = 1.5
            animation.toValue = 1
            animation.duration = 0.2
            animation.timingFunction = CAMediaTimingFunction .init(controlPoints: 0.4, 1.3, 1, 1)
            layer.add(animation, forKey: "bounceAnimation")
        }
        text = badgeValue
        updateBadgeFrame()
    }
    
    func removeBadge() {
        UIView.animate(withDuration: 0.3) {
            self.isHidden = true
        }
    }
}
