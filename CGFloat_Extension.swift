//
//  CGFloat_Extension.swift
//  DrawingSpaceControl_UsingCustomTransforms
//
//  Created by Mark Walker on 12/29/15.
//  Copyright © 2015 Mark Walker. All rights reserved.
//

import Foundation

extension CGFloat{
    func fm(_ f: Int) -> String {
        return NSString(format: "%.\(f)f" as NSString, self) as String
    }
    
    func degToRad() -> CGFloat{
        return self * CGFloat(Double.pi) / 180.00
    }
    
    func radToDeg() -> CGFloat{
        return self * 180.00 / CGFloat(Double.pi)
    }
}
