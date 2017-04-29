//
//  MWSnapsController.swift
//  DrawingSpaceControl_UsingCustomTransforms
//
//  Created by Mark Walker on 12/22/15.
//  Copyright © 2015 Mark Walker. All rights reserved.
//

import Cocoa

class MWSnapsController: NSObject {
    
    var snapRadius:CGFloat = 50
    var endPointActive = false
    var centerPointActive = false
    
    //these must be updated prior to gettin the snap point
    var mouseCoords = CGPoint()
    var entityDB = [MWCadEntity]()
    
  
    
    //if no snap is active, we must return nil so the calling functions ignores the snap point.
    //if an endpoint is active and not close enough to be effective we still need to return nil so that the calling function ignores the snap point
    var snapPoint:NSPoint?{
        get{
            
            var returnPoint = NSPoint()
            if endPointActive == true{
                if  getEndPtSnap() != nil{
                    returnPoint = getEndPtSnap()!
                    return returnPoint
                }
                
            }else if centerPointActive == true{
                if getCenterPtSnap() != nil{
                    returnPoint = getCenterPtSnap()!
                    return returnPoint
                }
            }
            return nil
        }
        
    }
    
    override init(){
        super.init()
    }
    
    
    fileprivate func buildRefinedEndPtEntityList(_ entityDB:[MWCadEntity], withMCoords:CGPoint) -> [MWCadEntity] {
        var returnEntityList = [MWCadEntity]()
        
        // function builds an array of entities but only adds the entity if the startPt or EndPt of the entity is withing the snap radius
        for i:Int in 0 ... entityDB.count-1{
            if  entityDB[i].kind == "line"{
                let cadLine = entityDB[i] as? MWCadLine
                if distFromCoords(withMCoords, coord2: cadLine!.viewLine.startPt) <= snapRadius{
                    returnEntityList.append(cadLine!)
                }else if distFromCoords(withMCoords, coord2: cadLine!.viewLine.endPt) <= snapRadius{
                    returnEntityList.append(cadLine!)
                }
            }else if entityDB[i].kind == "arc"{
                let cadArc = entityDB[i] as? MWCadArc
                if distFromCoords(withMCoords, coord2: cadArc!.viewArc.chordLine.startPt) <= snapRadius{
                    returnEntityList.append(cadArc!)
                }else if distFromCoords(withMCoords, coord2: cadArc!.viewArc.chordLine.endPt) <= snapRadius{
                    returnEntityList.append(cadArc!)
                }
            }
        }
        
        return returnEntityList
        }

    fileprivate func buildRefinedCenterPtEntityList(_ entityDB:[MWCadEntity], withMCoords:CGPoint) -> [MWCadEntity]{
        var returnEntityList = [MWCadEntity]()
        
        //function builds a list of entities, but only adds the entity is it is the correct type, i.e., circle,arc ect. and only is one of the selection points is within the snapradius to the mouseCoord.
        
        for i:Int in 0 ... entityDB.count-1{
            var shouldAdd = false
            if entityDB[i].kind == "arc"{
                let arc = entityDB[i] as! MWCadArc
                let selectionPtCount = arc.selectionPtsView.count
                var counter:Int = 0
                
                repeat{
                    if distFromCoords(withMCoords, coord2: arc.selectionPtsView[counter]) <= snapRadius{
                        shouldAdd = true
                    }
                
                    counter += 1
                }while(counter < selectionPtCount)
                
            }else if entityDB[i].kind == "circle"{
                let circle = entityDB[i] as! MWCadCircle
                let selectionPtCount = circle.selectionPtsView.count
                var counter:Int = 0
                
                repeat{
                    if distFromCoords(withMCoords, coord2: circle.selectionPtsView[counter]) <= snapRadius{
                        shouldAdd = true
                    }
                    
                    counter += 1
                }while(counter < selectionPtCount)
            }
            
            if shouldAdd == true{
                returnEntityList.append(entityDB[i])
            }
        }//end main for
        
        
        return returnEntityList
    }
    
  
    
    
    fileprivate func getEndPtSnap()->NSPoint?{
        var refinedEntityList = [MWCadEntity]()
        
        
        refinedEntityList = buildRefinedEndPtEntityList(entityDB, withMCoords: mouseCoords)
        
        if refinedEntityList.count > 0 {
            var dist:CGFloat = snapRadius
            var entityIndex:Int = 0
            var isStartCoord:Bool = true
            
            
            //run through the start points
            var testDistStart:CGFloat = 0
            for i:Int in 0 ... refinedEntityList.count-1{
                if refinedEntityList[i].kind == "line"{
                    let line = refinedEntityList[i] as! MWCadLine
                    testDistStart = distFromCoords(line.viewLine.startPt, coord2:mouseCoords)
                }else if refinedEntityList[i].kind == "arc"{
                    let arc = refinedEntityList[i] as! MWCadArc
                    testDistStart = distFromCoords(arc.viewArc.chordLine.startPt, coord2:mouseCoords)
                }
                
                if  testDistStart < dist{
                    dist = testDistStart
                    entityIndex = i
                }
                
            }
            
            //run through the end points
            var testDistEnd:CGFloat = 0
            for j:Int in 0 ... refinedEntityList.count-1{
                if refinedEntityList[j].kind == "line"{
                    let line = refinedEntityList[j] as! MWCadLine
                    testDistEnd = distFromCoords(line.viewLine.endPt, coord2: mouseCoords)
                }else if refinedEntityList[j].kind == "arc"{
                    let arc = refinedEntityList[j] as! MWCadArc
                    testDistEnd = distFromCoords(arc.viewArc.chordLine.endPt, coord2: mouseCoords)
                }
                
                if testDistEnd < dist{
                    dist = testDistEnd
                    entityIndex = j
                    isStartCoord = false
                }
            }
            
            //at the end of the 2 for's we should have the index for the closest endpoint to the mouse coords
            
            var returnPoint = CGPoint()
            
            if refinedEntityList[entityIndex].kind == "line"{
                let line = refinedEntityList[entityIndex] as! MWCadLine
                if isStartCoord == true{
                    returnPoint = line.viewLine.startPt
                }else{
                    returnPoint = line.viewLine.endPt
                }
            }else if refinedEntityList[entityIndex].kind == "arc"{
                let arc = refinedEntityList[entityIndex] as! MWCadArc
                if isStartCoord == true{
                    returnPoint = arc.viewArc.chordLine.startPt
                }else{
                    returnPoint = arc.viewArc.chordLine.endPt
                }
            }
            
            Swift.print("returnPt is endPtActive: \(endPointActive)")
            return returnPoint
            
            
        }else{
            Swift.print("returnNil is endPtActive: \(endPointActive)")
            return nil
            
        }
        
    }
    
    
    fileprivate func distFromCoords(_ coord1:NSPoint, coord2:NSPoint) -> CGFloat{
        let deltaX = coord1.x - coord2.x
        let deltaY = coord1.y - coord2.y
        let dist:CGFloat  = sqrt(pow(deltaX,2) + pow(deltaY,2))
        
        return dist
    }
    
    
    
    
    fileprivate func getCenterPtSnap()->NSPoint?{
        var returnPoint = NSPoint()
        var refinedEntityList = [MWCadEntity]()
        
        //list of circles or arcs that have a selection pt within the snap radius distance
        refinedEntityList = buildRefinedCenterPtEntityList(entityDB, withMCoords:mouseCoords)
        
        
        //we need to determin the closest selection pt so that we can return that entities center
        if refinedEntityList.count > 0 {
            var entityIndexCircle:Int = 0
            var entityIndexArc:Int = 0
            
            var testDistCircle:CGFloat = 0
            var testDistArc:CGFloat = 0
            
            for i:Int in 0 ... refinedEntityList.count-1{
                if refinedEntityList[i].kind == "circle"{
                    
                    let circle = refinedEntityList[i] as! MWCadCircle
                    for j:Int in 0 ... circle.selectionPtsView.count-1{
                        let currentDist = distFromCoords(circle.selectionPtsView[j], coord2:mouseCoords)
                        if currentDist < testDistCircle || testDistCircle == 0{
                            testDistCircle = currentDist
                            entityIndexCircle = i
                        }
                    }//for
                    
                }else if refinedEntityList[i].kind == "arc"{
                    let arc = refinedEntityList[i] as! MWCadArc
                    for j:Int in 0 ... arc.selectionPtsView.count-1{
                        let currentDist = distFromCoords(arc.selectionPtsView[j], coord2:mouseCoords)
                        if currentDist < testDistArc || testDistArc == 0{
                            testDistArc = currentDist
                            entityIndexArc = i
                        }
                        
                    }//for
                    
                }//if
                
            }//for
            
            
            //TODO:causeing problems fix this not encompassing all cases correctly
            if testDistCircle > 0 && testDistArc == 0{
                let returnCircle = refinedEntityList[entityIndexCircle] as! MWCadCircle
                returnPoint = returnCircle.viewCircle.centerPt
                return returnPoint
                
            }else if testDistArc > 0 && testDistCircle == 0{
                let returnArc = refinedEntityList[entityIndexArc] as! MWCadArc
                returnPoint = returnArc.viewArc.centerPt
                Swift.print("rpoint x = \(returnPoint.x), y = \(returnPoint.y)")
                return returnPoint
                
            }else if testDistCircle <= testDistArc{
                let returnCircle = refinedEntityList[entityIndexCircle] as! MWCadCircle
                returnPoint = returnCircle.viewCircle.centerPt
                return returnPoint
                
            }else if testDistArc < testDistCircle{
                let returnArc = refinedEntityList[entityIndexArc] as! MWCadArc
                returnPoint = returnArc.viewArc.centerPt
                Swift.print("rpoint x = \(returnPoint.x), y = \(returnPoint.y)")
                return returnPoint
            }
        }//if
        
        Swift.print("returning nil from getCenterSnapPoint")
        return nil
    
    }//function
    

}//class
