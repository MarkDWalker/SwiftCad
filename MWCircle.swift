//
//  MWCircle.swift
//  DrawingSpace_CustomTransforms_V0.0.2
//
//  Created by Mark Walker on 1/18/16.
//  Copyright © 2016 Mark Walker. All rights reserved.
//

protocol MWEntity{
    var ptDefArray : [CGPoint] {get set}
    var lengthDef : CGFloat {get set}
    var kind : String {get}
    init(thePointDefArray : [NSPoint], theLengthDef:CGFloat)
    
}

import Cocoa

class MWCircle: NSObject, MWEntity {
    var ptDefArray = [CGPoint]()
    
    var kind = "circle"
    
    var centerPt:CGPoint{
        get{
            let noPoint = NSPoint.init(x: 0, y: 0)
            guard ptDefArray.count > 0 else{
                return noPoint
            }
            return ptDefArray[0]
        }
        set(newPt){
            
            if ptDefArray.count > 0 {
                ptDefArray[0] = newPt
            }else {
                ptDefArray.append(newPt)
            }
            
        }
    }
    var lengthDef = CGFloat()
    
    
    
    var circumference:CGFloat{
        get{
            let returnVal:CGFloat = 2 * CGFloat(M_PI) * radius
            return returnVal        }
    }
    
    var radius:CGFloat{
        get{
        return lengthDef
        }
        
        set(theRadius){
        lengthDef = theRadius
        }
    }
    
   required init(thePointDefArray:[CGPoint], theLengthDef:CGFloat){
        super.init()
        centerPt = thePointDefArray[0]
        radius = theLengthDef
    }
    
    override init(){
        super.init()
    }
    
 

    
    

}
