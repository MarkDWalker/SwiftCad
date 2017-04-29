//
//  MWDistCommandSequence.swift
//  DrawingSpace_CustomTransforms_V0.0.2
//
//  Created by Mark Walker on 1/5/16.
//  Copyright © 2016 Mark Walker. All rights reserved.
//

import Cocoa

class MWDistCommandSequence: NSObject, MWCommandSequence {
    
    var inputPanelDelegate:MWInputController?
    var drawingSpaceDelegate:MWDrawingController?
    
    var pickedPt = NSPoint()
    var pickedPtIsDelta = false
    
    var cadCommandList = MWCadCommandList()
    
    func runCommandSequence(_ command: MWCadCommand) {
        let commandString = command.name
        if commandString == "dist"{
            guard let ipd = inputPanelDelegate else{
                return
            }
            guard let dsd = drawingSpaceDelegate else{
                return
            }
            
            ipd.prepareNewLine()
            ipd.outputText("Select P1>")
            
            //set focus to drawings space Control
            dsd.setFocus()
            dsd.makeCurrentCommand(cadCommandList.commands["distA"]!)
            ipd.makeCurrentCommand(cadCommandList.commands["distA"]!)
        }else if commandString == "distA"{
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
            ipd.outputText("P1 Picked:....")
            ipd.prepareNewLine()
            
            let ptArray = [pickedPt, pickedPt]
            let newBaseLine = MWLine(thePointDefArray: ptArray, theLengthDef: 0)
            let newCadLine = MWCadLine(theModelLine:newBaseLine)
            dsd.mySetTempLine(newCadLine)
            dsd.mySetDrawTempLine(true)
            
            //send additional instructions to the user
            //pick the second point
            dsd.makeCurrentCommand(cadCommandList.commands["distAB"]!)
            ipd.makeCurrentCommand(cadCommandList.commands["distAB"]!)
            ipd.prepareNewLine()
            ipd.outputText("Select P2>")
            ipd.prepareNewLine()
            dsd.setFocus()
        }else if commandString == "distAB"{
            guard let ipd = inputPanelDelegate else{
                return
            }
            guard let dsd = drawingSpaceDelegate else{
                return
            }
            
            //finish and add line to db and turn temp off
            ipd.prepareNewLine()
            ipd.outputText("y:\(pickedPt.y.fm(3))")
            ipd.prepareNewLine()
            ipd.outputText("x:\(pickedPt.x.fm(3))")
            ipd.prepareNewLine()
            ipd.outputText("P2 Picked:....")
            dsd.mySetDrawTempLine(false)
            dsd.modifyTempEndPt(pickedPt, isDelta: pickedPtIsDelta)
            let tempStartPt = dsd.getTempLineStartPt()
            let dist = calculateDist(tempStartPt, EndPt: pickedPt)
            ipd.prepareNewLine()
            ipd.outputText("Distance = \(dist.fm(3))")
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
    
    fileprivate func calculateDist(_ StartPt:NSPoint, EndPt:NSPoint)-> CGFloat{
        let deltaX = EndPt.x - StartPt.x
        let deltaY = EndPt.y - StartPt.y
        
        let dist = CGFloat(sqrt(pow(deltaX,2) + pow(deltaY, 2)))
        return dist
    }
    
    func cancelMidCommand() {
        guard let dsd = drawingSpaceDelegate else{
            return
        }
        
        dsd.mySetDrawTempLine(false)
        dsd.adjustTablesOnSelectionClear()
        dsd.remoteDisplay()
    }
    
    func endMidCommand(){
        
    }
}
