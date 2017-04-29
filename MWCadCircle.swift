//
//  MWCadCircle.swift
//  DrawingSpace_CustomTransforms_V0.0.2
//
//  Created by Mark Walker on 1/18/16.
//  Copyright © 2016 Mark Walker. All rights reserved.
//


protocol MWCadEntity{
    var handle : Int {get set}
    var kind : String {get}
    var bezierPath : NSBezierPath {get}
    var selectionPts:[NSPoint] {get}
    var selectionPtSpacing:CGFloat {get set}
    var listArray:[String] {get}
    var ct:MWCadTransforms {get set}
    var modelBounds:MWLine {get}
    var viewBounds:MWLine {get}
    init()
}

import Cocoa

class MWCadCircle: NSObject, MWCadEntity {
    
    var modelCircle = MWCircle()
    var ct = MWCadTransforms()
    var handle:Int = -1
    
    var selectionPtSpacing:CGFloat = 5
    
    
    var modelBounds:MWLine{
        get{
            let line = MWLine()
            
            line.startPt.x = modelCircle.centerPt.x - modelCircle.radius
            line.startPt.y = modelCircle.centerPt.y - modelCircle.radius
            line.endPt.x = modelCircle.centerPt.x + modelCircle.radius
            line.endPt.y = modelCircle.centerPt.y + modelCircle.radius
            
            return line
        }
    }
    
    var viewBounds:MWLine{
        get{
            let line = MWLine()
            
            line.startPt.x = modelBounds.startPt.x * ct.zoomScale - ct.scaledTrans.x
            line.startPt.y = modelBounds.startPt.y * ct.zoomScale - ct.scaledTrans.y
            line.endPt.x = modelBounds.endPt.x * ct.zoomScale - ct.scaledTrans.x
            line.endPt.y = modelBounds.endPt.y * ct.zoomScale - ct.scaledTrans.y
            
            return line
        }
    }
    
    
    var viewCircle:MWCircle{
        get{
            
            let newViewCircle = MWCircle()
            var tempCenterPt = modelCircle.centerPt
            let tempRadius = modelCircle.radius
            
            let mC = modelCircle
            
            let newCenterX = mC.centerPt.x * ct.zoomScale
            let newCenterY = mC.centerPt.y * ct.zoomScale
            
            let newRadius = tempRadius * ct.zoomScale
            
            tempCenterPt.x = newCenterX - ct.scaledTrans.x
            tempCenterPt.y = newCenterY - ct.scaledTrans.y
            
            newViewCircle.centerPt = tempCenterPt
            newViewCircle.radius = newRadius
            
            return newViewCircle
        }
    }
    
    let kind = "circle"
    
   
    
    var listArray:[String]{
        get{
            var theArray = [String]()
            let line1 = "CIRCUMFERENCE: \(modelCircle.circumference)"
            let line2 = "RADIUS: \(modelCircle.radius)"
            let line3 = "CENTER: x_\(modelCircle.centerPt.x), y_\(modelCircle.centerPt.y)"
            let line4 = "Object Handle: \(self.handle)"
            let line5 = "Object Type: CIRCLE"
            let line6 = "LIST OBJECT DATA"
            theArray.append(line1)
            theArray.append(line2)
            theArray.append(line3)
            theArray.append(line4)
            theArray.append(line5)
            theArray.append(line6)
            return theArray
        }
    }
    
    var bezierPath:NSBezierPath{
        get{
            let rectOriginX = viewCircle.centerPt.x - viewCircle.radius
            let rectOriginY = viewCircle.centerPt.y - viewCircle.radius
            let rectForCircle = NSMakeRect(rectOriginX, rectOriginY, 2 * viewCircle.radius, 2 * viewCircle.radius)
            let tempPath:NSBezierPath = NSBezierPath(ovalIn: rectForCircle)
            return tempPath
        }
    }
    
   required override init() {
        super.init()
    }
    
    init(theModelCircle:MWCircle){
        super.init()
        self.modelCircle = theModelCircle
        
        
    }
    
    init(theModelCircle:MWCircle, cadTransform:MWCadTransforms){
        super.init()
        self.modelCircle = theModelCircle
        self.ct = cadTransform
    }
    
    var selectionPts:[NSPoint]{
        get{
            var returnArray = [NSPoint]()
            var angle:CGFloat = 0
            
            repeat{
                
                var tempPt = NSPoint()
                tempPt.x = modelCircle.centerPt.x + modelCircle.radius * cos(angle.degToRad())
                tempPt.y = modelCircle.centerPt.y + modelCircle.radius * sin(angle.degToRad())
                
                returnArray.append(tempPt)
                angle = angle + selectionPtSpacing
                
            }while angle <= 360
            
            return returnArray
            
        }
    }
    
    var selectionPtsView:[NSPoint]{
        get{
            var returnArray = [NSPoint]()
            var angle:CGFloat = 0
            
            repeat{
                
                var tempPt = NSPoint()
                tempPt.x = viewCircle.centerPt.x + viewCircle.radius * cos(angle.degToRad())
                tempPt.y = viewCircle.centerPt.y + viewCircle.radius * sin(angle.degToRad())
                
                returnArray.append(tempPt)
                angle = angle + selectionPtSpacing * ct.zoomScale
                
            }while angle <= 360
            
            return returnArray
            
        }
    }
    
    

}
