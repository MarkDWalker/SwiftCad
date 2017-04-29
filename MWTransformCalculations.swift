//
//  MWTransformCalculations.swift
//  DrawSpaceControlUsing_stockTransforms
//
//  Created by Mark Walker on 12/17/15.
//  Copyright © 2015 Mark Walker. All rights reserved.
//

import Cocoa

class MWTransformCalculations: NSObject {
    
    func calculateScrollZoomData(_ mouseCoords:NSPoint, scaleChange:CGFloat, exZoomScale:CGFloat, exTrans:NSPoint, testLine:MWCadEntity) -> (zoomScale:CGFloat, trans:NSPoint){
        
        //This function starts with the existing zoom and trans and changes them based upon the new zoom factor and the zoom origin.
        
        var zoomOrigin = NSPoint(); zoomOrigin.x = mouseCoords.x; zoomOrigin.y = mouseCoords.y
        
        let newZoomScale:CGFloat = exZoomScale + scaleChange
        let scalePercentChange:CGFloat = newZoomScale / exZoomScale
        
        let exDistx:CGFloat = testLine.viewBounds.endPt.x - zoomOrigin.x
        let exDisty:CGFloat = testLine.viewBounds.endPt.y - zoomOrigin.y
        
        let newDistx:CGFloat = exDistx * scalePercentChange
        let newDisty:CGFloat = exDisty * scalePercentChange
        
        let newCoordx:CGFloat = zoomOrigin.x + newDistx
        let newCoordy:CGFloat = zoomOrigin.y + newDisty
        
        let newTransx:CGFloat = testLine.modelBounds.endPt.x * newZoomScale - newCoordx
        let newTransy:CGFloat = testLine.modelBounds.endPt.y * newZoomScale - newCoordy
        
        let newTrans = NSPoint(x:newTransx, y:newTransy)

        //print("zWheel -> scale:\(newZoomScale) | transx:\(newTrans.x) | transy:\(newTrans.y)")
        
        return (newZoomScale, newTrans)
    }
    
    func calculateZExtentData(_ entities:[MWCadEntity], viewBounds:NSRect) -> (zoomScale:CGFloat, trans:NSPoint) {
        var minX:CGFloat = 0; var maxX:CGFloat = 0; var minY:CGFloat = 0; var maxY:CGFloat = 0
        
        //set the transforms back to scale = 1 and translates x and y = 0
        var zoomScale:CGFloat = 1
        var trans = NSMakePoint(0, 0)
        
        if entities.count > 0{
            
                minX = entities[0].modelBounds.startPt.x
                maxX = entities[0].modelBounds.endPt.x
    
                minY = entities[0].modelBounds.startPt.y
                maxY = entities[0].modelBounds.endPt.y
          
            
            guard entities.count > 0 else{
                return (zoomScale, trans)
            }
            
            for i:Int in 0 ... entities.count-1{
                //minX
                if entities[i].modelBounds.startPt.x < minX{
                    minX = entities[i].modelBounds.startPt.x
                }
                
                //minY
                if entities[i].modelBounds.startPt.y < minY{
                    minY = entities[i].modelBounds.startPt.y
                }
                
                //maxX
                if entities[i].modelBounds.endPt.x > maxX{
                    maxX = entities[i].modelBounds.endPt.x
                }
                
                //maxY
                
                if entities[i].modelBounds.endPt.y > maxY{
                    maxY = entities[i].modelBounds.endPt.y
                }
            }//end for
        }//end if
        
        
        
        //set the new values of the transforms
        let tempXScale = viewBounds.width / (maxX - minX)
        let tempYScale = viewBounds.height / (maxY - minY)
        
        if tempXScale <= tempYScale{
            zoomScale = tempXScale
            trans.x =  (minX * zoomScale)
            trans.y =  (minY * zoomScale)
        }else{
            zoomScale = tempYScale
            trans.x = (minX * zoomScale)
            trans.y = (minY * zoomScale)
        }
        
        print("zExtents -> scale:\(zoomScale) | transx:\(trans.x) | transy:\(trans.y)")
        return (zoomScale, trans)
    }

}
