//
//  MWCadEntityCollection.swift
//  DrawingSpace_CustomTransforms_V0.0.2
//
//  Created by Mark Walker on 1/19/16.
//  Copyright © 2016 Mark Walker. All rights reserved.
//

import Cocoa

class MWCadEntityCollection: NSObject {
    
    var entities = [Int: MWCadEntity]()
    
    var selectObjPts = [MWNSPointWithHandle]()
    
    fileprivate var selectionRadius:CGFloat = 10
    
    
    override init(){
        super.init()
    }
    
    init(theEntities:[Int:MWCadEntity], theSelectionObjpts:[MWNSPointWithHandle]){
        super.init()
        entities = theEntities
        selectObjPts = theSelectionObjpts
    }
    
    var entityArray:[MWCadEntity]{
        get{
            var eArray = [MWCadEntity]()
            for (_, entity) in entities{
                eArray.append(entity)
            }
            return eArray
        }
    }
    
    var handlesAsArray:[Int]{
        get{
            var handleArray = [Int]()
            for (handle, _) in entities{
                handleArray.append(handle)
            }
            return handleArray
        }
    }
    
    fileprivate func generateHandle()->Int{
        //this function will find the next available int to use as a handle for the entity
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
    
    func appendEntity(_ newEntity:MWCadEntity){
        var newEntity = newEntity
        
        let tempHandle = generateHandle()
        newEntity.handle = tempHandle
        entities[newEntity.handle] = newEntity
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
        
        let totalEntityCount = entities.count
        var counter = 0
        for (handle, entity) in entities {
            
            Swift.print("entities complete: \(counter / totalEntityCount)%")
            
            var wholeLineWithin = true
            var alreadyAdded = false
            let entitySelectionPts = entity.selectionPts.count
            for i:Int in 0 ... entitySelectionPts-1{
                
                if touchMode == true{
                    //find all of the handles that fall within the window
                    let testPt = entity.selectionPts[i]
                    if ptIsInRect(startPt, rectEnd: endPt, thePoint: testPt){
                        if alreadyAdded == false{
                            handles.append(handle)
                            alreadyAdded = true
                        }
                    }
                    
                    
                }else if touchMode == false{
                    if ptIsInRect(startPt, rectEnd: endPt, thePoint: entity.selectionPts[i]) == false{
                        wholeLineWithin = false
                    }
                    
                }// end if touch mode
                
            }//end for selectionpts
            
            if touchMode == false && wholeLineWithin == true{
                handles.append(handle)
            }
            counter += 1
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
    
    func getHandleFromPtPick(_ modelPickPt:NSPoint)->Int{
        //this function must go throught he array of selectObjPts and find the closest match that is within the selection radius. when a suitable point is found it returns the handle of the point.
        
        var dist:CGFloat = -1
        var bestHandle = -1
        var counter = 0
        let totalEntityCount = entities.count
        
        for (handle, entity) in entities {
            
            
            
            for i:Int in 0 ... entity.selectionPts.count-1{
                
                let tempDist = calculateDist(modelPickPt, EndPt:entity.selectionPts[i])
                //Swift.print("tempDist: \(tempDist)")
                
                if dist == -1 && tempDist <= selectionRadius{
                    dist = tempDist
                    bestHandle = handle
                }else if tempDist < selectionRadius && tempDist < dist{
                    dist = tempDist
                    bestHandle = handle
                }
                
                
            }
            
            counter += 1
            Swift.print("\((CGFloat(counter) / CGFloat(totalEntityCount)) * 100)% complete")
        }//end Dictionary For
        Swift.print ("final Counter: \(counter)")
        return bestHandle
    }
    
    fileprivate func calculateDist(_ StartPt:NSPoint, EndPt:NSPoint)-> CGFloat{
        let deltaX = EndPt.x - StartPt.x
        let deltaY = EndPt.y - StartPt.y
        
        let dist = CGFloat(sqrt(pow(deltaX,2) + pow(deltaY, 2)))
        return dist
    }
    
    func moveArrayOfHandles(_ handles:[Int], delta:NSPoint){
        if handles.count>0{
            
            for i:Int in 0 ... handles.count-1{
                
                guard let currentEntity = entities[handles[i]] else{
                    return
                }
                
                if currentEntity.kind == "line"{
                    let currentLine = entities[handles[i]] as! MWCadLine
                    currentLine.modelLine.startPt.x += delta.x
                    currentLine.modelLine.startPt.y += delta.y
                    
                    currentLine.modelLine.endPt.x += delta.x
                    currentLine.modelLine.endPt.y += delta.y
                    
                    
                    
                    
                }else if currentEntity.kind == "circle"{
                    let currentCircle = entities[handles[i]] as! MWCadCircle
                    currentCircle.modelCircle.centerPt.x += delta.x
                    currentCircle.modelCircle.centerPt.y += delta.y
                }
                
                self.entities[handles[i]] = currentEntity
                
            }
        }
    }
    
    func copyArrayOfHandles(_ handles:[Int], delta:NSPoint){
        for i:Int in 0 ... handles.count-1{
            
            guard let currentEntity = entities[handles[i]] else{
                return
            }
            
            
            if currentEntity.kind == "line"{
                let oldLine = currentEntity as! MWCadLine
                let newLine = MWCadLine()
                newLine.modelLine.startPt.x = oldLine.modelLine.startPt.x
                newLine.modelLine.startPt.y = oldLine.modelLine.startPt.y
                newLine.modelLine.endPt.x = oldLine.modelLine.endPt.x
                newLine.modelLine.endPt.y = oldLine.modelLine.endPt.y
                newLine.handle = self.generateHandle()
                newLine.ct = oldLine.ct
                
                //let currentLine = entities[handles[i]] as! MWCadLine
                newLine.modelLine.startPt.x += delta.x
                newLine.modelLine.startPt.y += delta.y
                
                newLine.modelLine.endPt.x += delta.x
                newLine.modelLine.endPt.y += delta.y
                
                self.appendEntity(newLine)
                
                
            }else if currentEntity.kind == "circle"{
                let oldCircle = currentEntity as! MWCadCircle
                let newCircle = MWCadCircle()
                
                newCircle.modelCircle.centerPt.x  = oldCircle.modelCircle.centerPt.x + delta.x
                newCircle.modelCircle.centerPt.y = oldCircle.modelCircle.centerPt.y + delta.y
                
                newCircle.modelCircle.radius = oldCircle.modelCircle.radius
                newCircle.ct = oldCircle.ct
                newCircle.handle = self.generateHandle()
                
               self.appendEntity(newCircle)
            }
            
            
            
        }
    }
    
    
    func deleteArrayOfHandles(_ handles:[Int]){
        for i:Int in 0 ... handles.count-1{
            guard let _ = entities[handles[i]] else{
                return
            }
            
            entities[handles[i]] = nil
        }
    }
    
    

}
