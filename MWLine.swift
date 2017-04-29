//
//  MWLine.swift
//  DrawSpaceControlUsing_stockTransforms
//
//  Created by Mark Walker on 10/13/15.
//  Copyright © 2015 Mark Walker. All rights reserved.
//

import Cocoa

class MWLine: NSObject, MWEntity{
    
    var ptDefArray = [NSPoint]()
    
    var kind = "line"
    
    var startPt:NSPoint{
        get{
            let noPoint = NSPoint.init(x: 0, y: 0)
            guard ptDefArray.count >= 1 else{
                return noPoint
            }
            return ptDefArray[0]
        }
        
        set(newPt){
            if ptDefArray.count > 0 {
                ptDefArray[0] = newPt
            }else{
                ptDefArray.append(newPt)
            }

        }
        
    }
    
    var endPt:NSPoint{
        get{
            let noPoint = NSPoint.init(x: 0, y: 0)
            guard ptDefArray.count >= 2 else{
                return noPoint
            }
            return ptDefArray[1]
        }
        set(newPt){
            if ptDefArray.count > 1{
                ptDefArray[1] = newPt
            }else if ptDefArray.count == 1{
                ptDefArray.append(newPt)
            }else if ptDefArray.count == 0{
                ptDefArray.append(newPt)
                ptDefArray.append(newPt)
            }
        }
    }
    
    var lengthDef = CGFloat()
    
    var length:CGFloat{
        get{
            return calculateLength()
        }
    }
    
    var angleInXYPlaneDeg:CGFloat{
        get{
            let deltaX = endPt.x - startPt.x
            let deltaY = endPt.y - startPt.y
            
            
            let tempAngleDeg = radToDeg(atan(abs(deltaY / deltaX)))
            var returnAngle = tempAngleDeg
            if deltaX >= 0 && deltaY >= 0{
                //returnAngle = tempAngle
            }else if deltaX < 0 && deltaY >= 0{
                returnAngle = 180 - tempAngleDeg
            }else if deltaX < 0 && deltaY < 0{
                returnAngle = 180 + tempAngleDeg
            }else if deltaX >= 0 && deltaY < 0{
                returnAngle = 360 - tempAngleDeg
            }
            return returnAngle
        }
    }
    
   required init(thePointDefArray : [NSPoint], theLengthDef:CGFloat){
        super.init()
    
        startPt = thePointDefArray[0]
        endPt = thePointDefArray[1]
    }
    
    override init(){
        super.init()
    }
    
    init(call:MWSurveyCall, origin:NSPoint){
        super.init()
        
        var ptArray = [NSPoint]()
        
        ptArray.append(origin)
        
        let bearingAngle = call.degrees + call.minutes/60 + call.seconds / 3600
        let length = call.distance
        
        var azimuth:Double = 0
        if call.startDirection == .North && call.endDirection == .East{
            azimuth = 90 - bearingAngle
        }else if call.startDirection == .North && call.endDirection == .West{
            azimuth = 90 + bearingAngle
        }else if call.startDirection == .South && call.endDirection == .West{
            azimuth = 270 - bearingAngle
        }else if call.startDirection == .South && call.endDirection == .East{
            azimuth = 270 + bearingAngle
        }
        
        let delta = calcDeltasFromAngleDist(CGFloat(azimuth), dist: CGFloat(length))
        
        let endPoint:NSPoint = NSMakePoint(origin.x + delta.x, origin.y + delta.y)
        
        ptArray.append(endPoint)
        
        startPt = ptArray[0]
        endPt = ptArray[1]
        
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
        return deg * CGFloat(Double.pi) / 180.00
    }
    
    fileprivate func radToDeg(_ radians:CGFloat) -> CGFloat{
        return radians * 180.00 / CGFloat(Double.pi)
    }
    
    fileprivate func calculateLength()-> CGFloat{
        let deltaX = endPt.x - startPt.x
        let deltaY = endPt.y - startPt.y
        
        let length = CGFloat(sqrt(pow(deltaX,2) + pow(deltaY, 2)))
        return length
    }
    
   

}
