//
//  MWCadLineCollection.swift
//  DrawingSpace_CustomTransforms_V0.0.2
//
//  Created by Mark Walker on 1/7/16.
//  Copyright © 2016 Mark Walker. All rights reserved.
//

import Cocoa

class MWNSPointWithHandle:NSObject{
    //a object designed to store the available selection points along with the handle that the point originated from.
    var pt:NSPoint = NSPoint()
    var handle : Int = -1
    
}

class MWCadLineCollection: NSObject{
    var lines = [Int: MWCadLine]()
    
    var selectObjPts = [MWNSPointWithHandle]()
    
    fileprivate var selectionRadius:CGFloat = 40
    fileprivate var lineSelectionSegmentLength:CGFloat = 10
    
    override init(){
        super.init()
    }
    
    init(theLines: [Int: MWCadLine], theSelectObjPts: [MWNSPointWithHandle]){
        super.init()
        lines = theLines
        selectObjPts = theSelectObjPts
    }
    
    var linesAsArray:[MWCadLine]{
        get{
            var linesArray = [MWCadLine]()
            for (_, line) in lines{
                linesArray.append(line)
                
            }
            return linesArray
        }
    }
    
    var handlesAsArray:[Int]{
        get{
            var handleArray = [Int]()
            for (handle, _) in lines{
                handleArray.append(handle)
            }
            return handleArray
        }
    }
    
    func appendLine(_ line:MWCadLine){
        line.handle = generateHandle()
        lines[line.handle] = line
    }
    
    func getHandlesFromSelectionWindow(_ startPt:NSPoint, endPt:NSPoint)-> [Int]{
        //startPt and EndPt have to be modelPts
        
        var handles = [Int]()
        
        var touchMode = false

        if startPt.x <= endPt.x {
            touchMode = false
        }else{
            touchMode = true
        }
        
        for (handle, line) in lines {
            
            var wholeLineWithin = true
            var alreadyAdded = false
            let entitySelectionPts = line.selectionPts.count
            for i:Int in 0 ... entitySelectionPts - 1 {
                
                if touchMode == true{
                    //find all of the handles that fall within the window
                    let testPt = line.selectionPts[i]
                    if ptIsInRect(startPt, rectEnd: endPt, thePoint: testPt){
                        if alreadyAdded == false{
                            handles.append(handle)
                            alreadyAdded = true
                        }
                    }
                   
                    
                }else if touchMode == false{
                    if ptIsInRect(startPt, rectEnd: endPt, thePoint: line.selectionPts[i]) == false{
                        wholeLineWithin = false
                    }
                    
                }// end if touch mode
                
            }//end for selectionpts
            
            if touchMode == false && wholeLineWithin == true{
                handles.append(handle)
            }
        }
    
        
        return handles
        
    }
    
    func ptIsInRect(_ rectStart:NSPoint, rectEnd:NSPoint, thePoint:NSPoint)->Bool{
        var returnBool = false
        
        var lowerX = rectStart.x
        var upperX = rectEnd.x
        
        if rectEnd.x < lowerX{
            lowerX = rectEnd.x
            upperX = rectStart.x
        }
        
        var lowerY = rectStart.y
        var upperY = rectEnd.y
        
        if rectEnd.y < lowerY{
            lowerY = rectEnd.y
            upperY = rectStart.y
        }
        
        if thePoint.x >= lowerX && thePoint.x <= upperX && thePoint.y >= lowerY && thePoint.y <= upperY {
            returnBool = true
        }
        
        return returnBool
    }
    
    
    
    
    func getLineHandleFromPtPick(_ modelPickPt:NSPoint)->Int{
        //this function must go throught he array of selectObjPts and find the closest match that is within the selection radius. when a suitable point is found it returns the handle of the point.
        
        var dist:CGFloat = -1
        var bestHandle = -1
        
        for (handle, line) in lines {
            
            for i:Int in 0 ... line.selectionPts.count-1{
                
                let tempDist = calculateDist(modelPickPt, EndPt:line.selectionPts[i])
                //Swift.print("tempDist: \(tempDist)")
               
                if dist == -1 && tempDist <= selectionRadius{
                    dist = tempDist
                    bestHandle = handle
                }else if tempDist < selectionRadius && tempDist < dist{
                    dist = tempDist
                    bestHandle = handle
                }
            }
        }//end Dictionary For
        return bestHandle
    }
    
    
    fileprivate func calculateDist(_ StartPt:NSPoint, EndPt:NSPoint)-> CGFloat{
        let deltaX = EndPt.x - StartPt.x
        let deltaY = EndPt.y - StartPt.y
        
        let dist = CGFloat(sqrt(pow(deltaX,2) + pow(deltaY, 2)))
        return dist
    }
    
    fileprivate func generateHandle()->Int{
        //this function will find the next available int to use as a handle for the line
        var newHandle:Int = -1
        var handleArray = self.handlesAsArray
        
        guard handleArray.count > 0 else{
            newHandle = 0
            Swift.print("Handle Assigned: \(newHandle)")
            return newHandle
        }
        
    
        handleArray.sort()
        
        if handleArray[0] > 0{
            newHandle = 0
            Swift.print("Handle Assigned: \(newHandle)")
            return newHandle
        }
        
        var j:Int = 0
        while j == handleArray[j] && j < handleArray.count - 1{
            j += 1
        }
        
        if j == handleArray.count - 1{
          newHandle = j + 1
        }else{
            newHandle = j
                
        }
        Swift.print("Handle Assigned: \(newHandle)")
        return newHandle
    }
    
    
    func deleteArrayOfHandles(_ handles:[Int]){
        for i:Int in 0 ... handles.count-1{
            guard let _ = lines[handles[i]] else{
                return
            }
            
            lines[handles[i]] = nil
        }
    }
    
    func moveArrayOfHandles(_ handles:[Int], delta:NSPoint){
        for i:Int in 0 ... handles.count-1{
            
            guard let currentLine = lines[handles[i]] else{
                return
            }
            
            currentLine.modelLine.startPt.x += delta.x
            currentLine.modelLine.startPt.y += delta.y
            
            currentLine.modelLine.endPt.x += delta.x
            currentLine.modelLine.endPt.y += delta.y
            
            Swift.print("moved Line, sX: \(currentLine.modelLine.startPt.x), sY: \(currentLine.modelLine.startPt.y), eX: \(currentLine.modelLine.endPt.x), eY: \(currentLine.modelLine.endPt.y)")
            
            self.lines[handles[i]] = currentLine
            
            Swift.print("moved Line, sX: \(lines[handles[i]]!.modelLine.startPt.x), sY: \(lines[handles[i]]!.modelLine.startPt.y), eX: \(lines[handles[i]]!.modelLine.endPt.x), eY: \(lines[handles[i]]!.modelLine.endPt.y)")
        }
    }
    
   
    
}
