//
//  MWCadLine.swift
//  DrawSpaceControl
//
//  Created by Mark Walker on 9/27/15.
//  Copyright © 2015 Mark Walker. All rights reserved.
//


import Cocoa

class MWCadLine: NSObject, MWCadEntity {
    
    var modelLine = MWLine()
    
    var ct = MWCadTransforms()
    var handle:Int = -1
    let kind = "line"
    
    var selectionPtSpacing:CGFloat = 10
    
    
    var modelBounds:MWLine{
        get{
            let line = MWLine()
            
            var minX = modelLine.startPt.x
            var maxX = modelLine.endPt.x
            if modelLine.endPt.x < minX{
                minX = modelLine.endPt.x
                maxX = modelLine.startPt.x
            }
            
            var minY = modelLine.startPt.y
            var maxY = modelLine.endPt.y
            if modelLine.endPt.y < minY{
                minY = modelLine.endPt.y
                maxY = modelLine.startPt.y
            }
            
            line.startPt.x = minX
            line.startPt.y = minY
            line.endPt.x = maxX
            line.endPt.y = maxY
            
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
    
    var viewLine:MWLine{
        get{
            
            let newViewLine = MWLine()
            var tempStartPt = modelLine.startPt
            var tempEndPt = modelLine.endPt
            let mL = modelLine
            
            let scaledStartx = mL.startPt.x * ct.zoomScale
            let scaledStarty = mL.startPt.y * ct.zoomScale
            let scaledEndx = mL.endPt.x * ct.zoomScale
            let scaledEndy = mL.endPt.y * ct.zoomScale
            
            tempStartPt.x = scaledStartx - ct.scaledTrans.x
            tempStartPt.y = scaledStarty - ct.scaledTrans.y
            tempEndPt.x = scaledEndx - ct.scaledTrans.x
            tempEndPt.y = scaledEndy - ct.scaledTrans.y
            
            newViewLine.startPt = tempStartPt
            newViewLine.endPt = tempEndPt
            return newViewLine
        }
    }
    
    
    
   
    
    var listArray:[String]{
        get{
            var theArray = [String]()
            let line1 = "length: \(self.modelLine.length.fm(3)), angle \(modelLine.angleInXYPlaneDeg.fm(3)) deg"
            let line2 = "End: x_\(modelLine.endPt.x), y_\(modelLine.endPt.y)"
            let line3 = "Start: x_\(modelLine.startPt.x), y_\(modelLine.startPt.y)"
            let line4 = "Object Handle: \(self.handle)"
            let line5 = "Object Type: LINE"
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
    
    
    
    var selectionPts:[NSPoint]{
        get{
            setSelectionPtSpacing()
            
            var returnArray = [NSPoint]()
            var distFromStart:CGFloat = 0
            let angle = modelLine.angleInXYPlaneDeg
            
            repeat{
                
                var tempPt = NSPoint()
                tempPt.x = modelLine.startPt.x + distFromStart * cos(angle.degToRad())
                tempPt.y = modelLine.startPt.y + distFromStart * sin(angle.degToRad())
                
            returnArray.append(tempPt)
            distFromStart = distFromStart + selectionPtSpacing
                
            }while distFromStart < modelLine.length
            
            returnArray.append(modelLine.endPt)
            
            return returnArray
            
        }
    }


    var bezierPath:NSBezierPath{
        get{
            let tempPath:NSBezierPath = NSBezierPath()
            tempPath.move(to: viewLine.startPt)
            tempPath.line(to: viewLine.endPt)
            return tempPath
        }
    }
    
    
    
    init(theModelLine:MWLine){
        super.init()
        self.modelLine = theModelLine
       
        
    }
    
    
    
   required override init(){
        super.init()
            }
    
    init(theModelLine:MWLine, cadTransform:MWCadTransforms){
        super.init()
        self.modelLine = theModelLine
        self.ct = cadTransform
       
    }
    
    fileprivate func setSelectionPtSpacing(){
        selectionPtSpacing = modelLine.length / b
    }
    
    
    

}
