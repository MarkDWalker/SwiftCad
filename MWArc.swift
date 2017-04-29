//
//  MWArc.swift
//  DrawingSpace_CustomTransforms_V0.0.3
//
//  Created by Mark Walker on 2/2/16.
//  Copyright © 2016 Mark Walker. All rights reserved.
//

import Cocoa

class MWArc: NSObject, MWEntity {
    var ptDefArray = [CGPoint]()
    
    var kind = "arc"
    
    var isAcute = true
    
    var centerPt:CGPoint{
        get{
            var tempPt = startPt
            let IAngleD = self.IAngleDegrees
            let angleFromTanget = (180 - IAngleD) / 2
            var startRadiusAngleInXYPlane = (chordLine.angleInXYPlaneDeg - angleFromTanget)
            if startRadiusAngleInXYPlane < 0{
                startRadiusAngleInXYPlane += 360
            }
            let delta = calcDeltasFromAngleDist(startRadiusAngleInXYPlane, dist: radius)
            
            
            //Swift.print("centerPointCalcAngle = \(startRadiusAngleInXYPlane), radius = \(radius)")
            tempPt.x = startPt.x + delta.x
            tempPt.y = startPt.y + delta.y
            
            if tempPt.x.isNaN || tempPt.y.isNaN{
                Swift.print("This is where there error resides: \(IAngleDegrees)")
                
            }
            
            return tempPt
            
        }
    }
    
    var startPt:CGPoint{
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
    
    
    var endPt:CGPoint{
        get{
            let noPoint = NSPoint.init(x: 0, y: 0)
            guard ptDefArray.count > 1 else{
                return noPoint
            }
            return ptDefArray[1]
        }
        set(newPt){
            
            if ptDefArray.count > 1 {
                ptDefArray[1] = newPt
            }else {
                ptDefArray.append(newPt)
            }
            
        }
    }
    
    
    var lengthDef = CGFloat()
    
    
    var radius:CGFloat{
        get{
            return lengthDef
        }
        
        set(theRadius){
            lengthDef = theRadius
        }
    }
    
    var arcLength:CGFloat{
        get{
            //TODO: fix this
            return 0
        }
    }
    
    required init(thePointDefArray:[CGPoint], theLengthDef:CGFloat){
        super.init()
    
        startPt = thePointDefArray[0]
        endPt = thePointDefArray[1]
        radius = theLengthDef
    }
    
    override init(){
        super.init()
    }
    
    var chordLine:MWLine{
        get{
            let cLine = MWLine()
            cLine.startPt = startPt
            cLine.endPt = endPt
            return cLine
        }
    }
    
    var IAngleRadians:CGFloat{
        get{
            let lc = chordLine.length
            let r  = self.radius
            
            let angle = (2 * asin(lc / (2 * r)))
            return angle
        }
    }
    
    var IAngleDegrees:CGFloat{
        get{
            return IAngleRadians * (180.00 / CGFloat(M_PI))
        }
    }
    
    var IAcuteDeg:CGFloat{
        get{
            var returnAngle:CGFloat = IAngleDegrees
            if returnAngle > 180{
                returnAngle = 360 - returnAngle
            }
            return returnAngle
        }
    }
    
    var IObtuseDeg:CGFloat{
        get{
            var returnAngle:CGFloat = IAngleDegrees
            if returnAngle < 180{
                returnAngle = 360 - returnAngle
            }
            return returnAngle
        }
    }
    
    
    
    var tLength:CGFloat{
        return radius * tan(IAngleRadians / 2)
    }
    
    var externalDistanceE:CGFloat{
        get{
            return tLength * tan (IAngleRadians / 4)
        }
    }
    
    var middleOrdinateM:CGFloat{
        get{
            return externalDistanceE * cos(IAngleRadians / 2)
        }
    }
    
    
    var startRadiusLine:MWLine{
        get{
            let tempLine = MWLine()
            tempLine.startPt = self.centerPt
            tempLine.endPt = self.startPt
            
            return tempLine
        }
    }
    
    var endRadiusLine:MWLine{
        get{
            let tempLine = MWLine()
            tempLine.startPt = self.centerPt
            tempLine.endPt = self.endPt
            return tempLine
        }
    }
    
    var PILine:MWLine{
        let tempLine = MWLine()
        tempLine.startPt = centerPt
        
        let tempLineLength = radius + middleOrdinateM + externalDistanceE
        
        var tempLineAngle:CGFloat = 0
        
        if startRadiusLine.angleInXYPlaneDeg > endRadiusLine.angleInXYPlaneDeg{
            tempLineAngle = endRadiusLine.angleInXYPlaneDeg + IAngleDegrees / 2
        }else{
            tempLineAngle = startRadiusLine.angleInXYPlaneDeg + IAngleDegrees / 2
        }
        
        let delta = calcDeltasFromAngleDist(tempLineAngle, dist: tempLineLength)
        tempLine.endPt.x = tempLine.startPt.x + delta.x
        tempLine.endPt.y = tempLine.startPt.y + delta.y
        return tempLine
    }
    
    fileprivate func calcDeltasFromAngleDist(_ angleDeg:CGFloat, dist:CGFloat) -> NSPoint{
        var pt = NSPoint()
        if angleDeg >= 0 && angleDeg <= 90{
            pt.x = cos(degToRad(angleDeg)) * dist
            pt.y = sin(degToRad(angleDeg)) * dist
            
        }else if angleDeg > 90 && angleDeg <= 180{
            pt.x = -sin(degToRad(angleDeg - 90)) * dist
            pt.y = cos(degToRad(angleDeg - 90)) * dist
            
        }else if angleDeg > 180 && angleDeg <= 270{
            pt.x = -cos(degToRad(angleDeg - 180)) * dist
            pt.y = -sin(degToRad(angleDeg - 180)) * dist
            
        }else if angleDeg > 270 && angleDeg <= 360{
            pt.x = sin(degToRad(angleDeg - 270)) * dist
            pt.y = -cos(degToRad(angleDeg - 270)) * dist
        }
        
        
        return pt
    }
    
    fileprivate func degToRad(_ deg:CGFloat) -> CGFloat{
        return deg * CGFloat(M_PI) / 180.00
    }
    
    fileprivate func radToDeg(_ radians:CGFloat) -> CGFloat{
        return radians * 180.00 / CGFloat(M_PI)
    }
    
    

}
