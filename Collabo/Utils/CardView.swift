//
//  CardView.swift
//  RushMeStuff
//
//  Created by Zeeshan Ashraf on 07/12/2019.
//  Copyright © 2019 maclogix. All rights reserved.
//

import Foundation
import UIKit
@IBDesignable
class CardView: UIView{
    
    @IBInspectable var cornerRadius: CGFloat = 8
    @IBInspectable var shadowOffsetWidth: Int = 0
    @IBInspectable var shadowOffsetHeight: Int = 2
    //    @IBInspectable var shadowColor: UIColor? = UIColor.black
    @IBInspectable var shadowOpacity: Float = 0.3
    
    override func layoutSubviews() {
        layer.cornerRadius = cornerRadius
        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        layer.masksToBounds = false
//                layer.shadowColor = shadowColor?.cgColor
        layer.shadowOffset = CGSize(width: shadowOffsetWidth, height: shadowOffsetHeight);
        layer.shadowOpacity = shadowOpacity
        layer.shadowPath = shadowPath.cgPath
    }
}

class TextFieldCardView: UIView{
    
    @IBInspectable var cornerRadius: CGFloat = 26
    @IBInspectable var shadowOffsetWidth: Int = 0
    @IBInspectable var shadowOffsetHeight: Int = 2
    //    @IBInspectable var shadowColor: UIColor? = UIColor.black
    @IBInspectable var shadowOpacity: Float = 0.3
    
    override func layoutSubviews() {
        layer.cornerRadius = cornerRadius
        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        
        layer.masksToBounds = false
        layer.shadowRadius = 6 //border width
        layer.shadowOpacity = 0.5    //brightness
        layer.shadowColor = UIColor.lightGray.cgColor  //color
        layer.shadowOffset = CGSize(width: 0, height: 1)   //shadow size
    }
    
}

class ThumbnailView: UIView{
    
    @IBInspectable var cornerRadius: CGFloat = 4
    @IBInspectable var shadowOffsetWidth: Int = 2
    @IBInspectable var shadowOffsetHeight: Int = 2
    @IBInspectable var shadowColor: UIColor? = UIColor.black
    @IBInspectable var shadowOpacity: Float = 0.6
    
    override func layoutSubviews() {
        layer.cornerRadius = cornerRadius
        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        
        layer.masksToBounds = false
        layer.shadowRadius = 6 //border width
        layer.shadowOpacity = shadowOpacity    //brightness
        layer.shadowColor = shadowColor?.cgColor  //color
        layer.shadowOffset = CGSize(width: shadowOffsetWidth, height: shadowOffsetHeight)   //shadow size
    }
    
}

extension UIView {
    
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
       
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    
    func round(){
        self.layer.masksToBounds = true
        self.layer.cornerRadius = self.frame.height/2
    }
    
    func roundWithBorderColorAndWidth(){
        self.layer.cornerRadius = self.frame.height/2
        self.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        self.layer.borderWidth = 2
    }
    
}
