
//
//  MWCadArc.swift
//  DrawingSpace_CustomTransforms_V0.0.3
//
//  Created by Mark Walker on 2/2/16.
//  Copyright © 2016 Mark Walker. All rights reserved.
//

import Cocoa

class MWCadArc: NSObject, MWCadEntity {
    
    var modelArc = MWArc()
    var ct = MWCadTransforms()
    var handle:Int = -1
    
    var isClockwise:Bool = true
    
    var selectionPtSpacing:CGFloat = 35
    
    var modelBounds:MWLine{
        get{
            let line = MWLine()
            var minX = modelArc.PILine.startPt.x
            var maxX = modelArc.PILine.endPt.x
            if modelArc.PILine.endPt.x < minX{
                minX = modelArc.PILine.endPt.x
                maxX = modelArc.PILine.startPt.x
            }
            
            var minY = modelArc.PILine.startPt.y
            var maxY = modelArc.PILine.endPt.y
            if modelArc.PILine.endPt.y < minY{
                minY = modelArc.PILine.endPt.y
                maxY = modelArc.PILine.startPt.y
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


    var viewArc:MWArc{
        get{
            
            let newViewArc = MWArc()
            
            let mA = modelArc
            
            var tempCenterPt = NSPoint()
            tempCenterPt.x = mA.centerPt.x * ct.zoomScale - ct.scaledTrans.x
            tempCenterPt.y = mA.centerPt.y * ct.zoomScale - ct.scaledTrans.y
            
            let newRadius = mA.radius * ct.zoomScale
            
            var tempStartPt = NSPoint()
            tempStartPt.x = mA.startPt.x * ct.zoomScale - ct.scaledTrans.x
            tempStartPt.y = mA.startPt.y * ct.zoomScale - ct.scaledTrans.y
            
            var tempEndPt = NSPoint()
            tempEndPt.x = mA.endPt.x * ct.zoomScale - ct.scaledTrans.x
            tempEndPt.y = mA.endPt.y * ct.zoomScale - ct.scaledTrans.y
            
            
            newViewArc.startPt = tempStartPt
            newViewArc.endPt = tempEndPt
            newViewArc.radius = newRadius
            
            return newViewArc
        }
    }

let kind = "arc"



    var listArray:[String]{
        get{
            var theArray = [String]()
            let line1 = "CHORD LENGTH \(modelArc.chordLine.length)"
            let line2 = "CHORD ANGLE \(modelArc.chordLine.angleInXYPlaneDeg)"
            let line3 = "ARC LENGTH: \(modelArc.arcLength)"
            let line4 = "RADIUS: \(modelArc.radius)"
            let line5 = "CENTER: x_\(modelArc.centerPt.x), y_\(modelArc.centerPt.y)"
            let line6 = "Object Handle: \(self.handle)"
            let line7 = "Object Type: ARC"
            let line8 = "LIST OBJECT DATA"
            theArray.append(line1)
            theArray.append(line2)
            theArray.append(line3)
            theArray.append(line4)
            theArray.append(line5)
            theArray.append(line6)
            theArray.append(line7)
            theArray.append(line8)
            return theArray
        }
    }








    var bezierPath:NSBezierPath{
        get{
           
            
            let centerPt = viewArc.centerPt
            let radius = viewArc.radius
            let startAngle = modelArc.startRadiusLine.angleInXYPlaneDeg
            let endAngle = modelArc.endRadiusLine.angleInXYPlaneDeg
        
            let tempPath:NSBezierPath = NSBezierPath()
            Swift.print("ViewArcCenterPt = \(centerPt.x), \(centerPt.y)")
            Swift.print("viewStartPt = \(viewArc.startPt.x), \(viewArc.startPt.y)")
            Swift.print("sA = \(startAngle), eA = \(endAngle)")
            tempPath.appendArc(withCenter: centerPt, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: isClockwise)
            Swift.print("path clockwise: \(isClockwise)")
            return tempPath
        }
    }
    
    
    required override init() {
        super.init()
    }
    
    init(theModelArc:MWArc, cadTransform:MWCadTransforms){
        super.init()
        self.modelArc = theModelArc
        self.ct = cadTransform
    }
    
    init(theModelArc:MWArc){
        super.init()
        self.modelArc = theModelArc
    }
    
    var selectionPts:[NSPoint]{
        get{
            var returnArray = [NSPoint]()
            let angle:CGFloat = modelArc.startRadiusLine.angleInXYPlaneDeg
            var angleSoFar:CGFloat = 0
            var computedAngle:CGFloat = 0
                repeat{
                    if isClockwise == true{
                        computedAngle = angle - angleSoFar
                    }else{
                        computedAngle = angle + angleSoFar
                    }
                    if computedAngle < 0 {
                        computedAngle = computedAngle + 360
                    }
                    
                    var tempPt = NSPoint()
                    tempPt.x = modelArc.centerPt.x + modelArc.radius * cos(computedAngle.degToRad())
                    tempPt.y = modelArc.centerPt.y + modelArc.radius * sin(computedAngle.degToRad())
                    
                    returnArray.append(tempPt)
                    angleSoFar = angleSoFar + selectionPtSpacing
                }while angleSoFar <= modelArc.IAngleDegrees
            
            
            return returnArray
            
        }
    }
    
    var selectionPtsView:[NSPoint]{
        get{
            var returnArray = [NSPoint]()
            let angle:CGFloat = viewArc.startRadiusLine.angleInXYPlaneDeg
            var angleSoFar:CGFloat = 0
            var computedAngle:CGFloat = 0
            repeat{
                if isClockwise == true{
                    computedAngle = angle - angleSoFar
                }else{
                    computedAngle = angle + angleSoFar
                }
                if computedAngle < 0 {
                    computedAngle = computedAngle + 360
                }
                
                var tempPt = NSPoint()
                tempPt.x = viewArc.centerPt.x + viewArc.radius * cos(computedAngle.degToRad())
                tempPt.y = viewArc.centerPt.y + viewArc.radius * sin(computedAngle.degToRad())
                
                returnArray.append(tempPt)
                angleSoFar = angleSoFar + selectionPtSpacing * ct.zoomScale
            }while angleSoFar <= viewArc.IAngleDegrees
            
            //add the startpoint and endpoint
            returnArray.append(viewArc.startPt)
            returnArray.append(viewArc.endPt)
            
            
            return returnArray
            
        }
    }
    
}
