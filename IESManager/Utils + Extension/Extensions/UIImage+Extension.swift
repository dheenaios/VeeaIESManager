//
//  UIImage+Extension.swift
//  VeeaHub Manager
//
//  Created by Niranjan Ravichandran on 4/10/19.
//  Copyright © 2019 Veea. All rights reserved.
//

import UIKit


extension UIImage {
    func tintWithColor(_ color:UIColor)->UIImage {
        
        UIGraphicsBeginImageContext(self.size)
        let context = UIGraphicsGetCurrentContext()
        
        // flip the image
        context!.scaleBy(x: 1.0, y: -1.0)
        context!.translateBy(x: 0.0, y: -self.size.height)
        
        // multiply blend mode
        context!.setBlendMode(CGBlendMode.multiply)
        
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        context!.clip(to: rect, mask: self.cgImage!)
        color.setFill()
        context!.fill(rect)
        
        // create uiimage
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
        
    }
}
