//
//  MWArcCommandSequence.swift
//  DrawingSpace_CustomTransforms_V0.0.3
//
//  Created by Mark Walker on 2/12/16.
//  Copyright © 2016 Mark Walker. All rights reserved.
//

import Cocoa

class MWArcCommandSequence: NSObject, MWCommandSequence {

    var inputPanelDelegate:MWInputController?//allows calling of functions in the inputpanel
    var drawingSpaceDelegate:MWDrawingController? //allows calling of functions in the drawingspace
    
    var pickedPt = NSPoint()
    var pickedPtIsDelta = false
    
    var cadCommandList = MWCadCommandList()
    
    var pickedStartPoint = NSPoint()
    var pickedEndPoint = NSPoint()
    var isClockwise = true
    
    func runCommandSequence(_ command:MWCadCommand){
        let commandString = command.name
       
        if commandString == "arc"{
            guard let ipd = inputPanelDelegate else{
                return
            }
            guard let dsd = drawingSpaceDelegate else{
                return
            }
            
            ipd.prepareNewLine()
            ipd.outputText("Select Start Pt>")
            
            //set focus to drawings space Control
            dsd.setFocus()
            dsd.makeCurrentCommand(cadCommandList.commands["arcA"]!)
            ipd.makeCurrentCommand(cadCommandList.commands["arcA"]!)
            
        }else if commandString == "arcA"{
            guard let ipd = inputPanelDelegate else{
                return
            }
            guard let dsd = drawingSpaceDelegate else{
                return
            }
            ipd.prepareNewLine()
            ipd.outputText("y:\(pickedPt.y.fm(3))")
            ipd.prepareNewLine()
            ipd.outputText("x:\(pickedPt.x.fm(3))")
            ipd.prepareNewLine()
            ipd.outputText("Start Pt Picked:....")
            ipd.prepareNewLine()
            
            let tempSecondPt = NSMakePoint(pickedPt.x + 50, pickedPt.y + 50)
            let ptArray = [pickedPt, tempSecondPt]
            
            
            pickedStartPoint = pickedPt
            
            let newBaseArc = MWArc(thePointDefArray: ptArray, theLengthDef: 50)
            let newCadArc = MWCadArc(theModelArc: newBaseArc)
            
            dsd.mySetTempArc(newCadArc)
            dsd.mySetDrawTempArc(true, endSet: false)
            
            //send additional instructions to the user
            //pick the second point
            dsd.makeCurrentCommand(cadCommandList.commands["arcB"]!)
            ipd.makeCurrentCommand(cadCommandList.commands["arcB"]!)
            ipd.prepareNewLine()
            ipd.outputText("Select End Pt>")
            ipd.prepareNewLine()
            dsd.setFocus()
            
        }else if commandString == "arcB"{
            guard let ipd = inputPanelDelegate else{
                return
            }
            guard let dsd = drawingSpaceDelegate else{
                return
            }
            ipd.prepareNewLine()
            ipd.outputText("y:\(pickedPt.y.fm(3))")
            ipd.prepareNewLine()
            ipd.outputText("x:\(pickedPt.x.fm(3))")
            ipd.prepareNewLine()
            ipd.outputText("End Pt Picked:....")
            ipd.prepareNewLine()
            
            
            //if it was entered at the command line as 
            //an angle and distance @100<50 then the
            //pickedPt will be a dx and dy.
            if pickedPtIsDelta == true{
                pickedPt.x += pickedStartPoint.x
                pickedPt.y += pickedStartPoint.y
            }
            
            let ptArray = [pickedStartPoint, pickedPt]
            pickedEndPoint = pickedPt
            
            let minRad = distFromCoords(pickedPt,coord2: pickedStartPoint) / 1.99
            
            let newBaseArc = MWArc(thePointDefArray: ptArray, theLengthDef: minRad)
            let newCadArc = MWCadArc(theModelArc: newBaseArc)
            
            dsd.mySetTempArc(newCadArc)
            dsd.mySetDrawTempArc(true, endSet: true)
            
            //send additional instructions to the user
            //pick the second point
            dsd.makeCurrentCommand(cadCommandList.commands["arcC"]!)
            ipd.makeCurrentCommand(cadCommandList.commands["arcC"]!)
            ipd.prepareNewLine()
            ipd.outputText("Enter or pick Radius")
            ipd.prepareNewLine()
            dsd.setFocus()
            
        }else if commandString == "arcC"{
            guard let ipd = inputPanelDelegate else{
                return
            }
            guard let dsd = drawingSpaceDelegate else{
                return
            }
            
            
            //determine clockwise or counterClockwise
            if pickedEndPoint.y > pickedPt.y{
                isClockwise = false
            }else{
                isClockwise = true
            }
            
            //get the min rad
            let minRad = distFromCoords(pickedEndPoint,coord2: pickedStartPoint) / 1.99
            let maxRad = distFromCoords(pickedEndPoint,coord2: pickedStartPoint) / 0.002
            
            var calculatedRadius:CGFloat = 0
            if pickedPtIsDelta == false{
                calculatedRadius = distFromCoords(pickedPt, coord2: pickedEndPoint)
            }else{
                calculatedRadius = sqrt(pow(pickedPt.x,2)+pow(pickedPt.y,2))
            }
            
            ipd.prepareNewLine()
            ipd.outputText("min rad = \(minRad)")
            ipd.prepareNewLine()
            
            if calculatedRadius > minRad && calculatedRadius < maxRad {
                dsd.modifyTempArcRadius(calculatedRadius, isClockwise: isClockwise)
                ipd.outputText("arc radius from selection = \(calculatedRadius)")
            }else if calculatedRadius < minRad{
                dsd.modifyTempArcRadius(minRad, isClockwise: isClockwise)
                ipd.outputText("arc radius is min = \(minRad)")
            }else if calculatedRadius > maxRad{
                dsd.modifyTempArcRadius(maxRad, isClockwise: isClockwise)
                ipd.outputText("arc radius is max = \(maxRad)")
            }
            
            dsd.mySetDrawTempArc(false, endSet: false)
            dsd.appendArcListWithTemp()
            dsd.remoteDisplay()
            ipd.prepareNewLine()
            dsd.makeCurrentCommand(cadCommandList.commands["noCommand"]!)
            ipd.makeCurrentCommand(cadCommandList.commands["noCommand"]!)
            ipd.setCommandStatus(MWCommandStatusEnum.noCommand)
            dsd.remoteEnableCursorRects()
        }
        
    }
    
    func makePickedPoint(_ pt: NSPoint, isDelta:Bool) {
        pickedPt = pt
        pickedPtIsDelta = isDelta
    }
    
    
    func cancelMidCommand(){
        guard let dsd = drawingSpaceDelegate else{
            return
        }
        
        dsd.mySetDrawTempArc(false, endSet: false)
        dsd.adjustTablesOnSelectionClear()
        dsd.remoteDisplay()
        
    }
    
    func endMidCommand(){
        
    }
    
    fileprivate func distFromCoords(_ coord1:NSPoint, coord2:NSPoint) -> CGFloat{
        let deltaX = coord1.x - coord2.x
        let deltaY = coord1.y - coord2.y
        let dist:CGFloat  = sqrt(pow(deltaX,2) + pow(deltaY,2))
        
        return dist
    }
    
}
