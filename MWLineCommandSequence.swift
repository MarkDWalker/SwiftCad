//
//  MWLineCommandSequence.swift
//  DrawingSpaceControl_UsingCustomTransforms
//
//  Created by Mark Walker on 12/31/15.
//  Copyright © 2015 Mark Walker. All rights reserved.
//

import Cocoa

class MWLineCommandSequence:NSObject, MWCommandSequence{
    
    var inputPanelDelegate:MWInputController?//allows calling of functions in the inputpanel
    var drawingSpaceDelegate:MWDrawingController? //allows calling of functions in the drawingspace
    
    var pickedPt = NSPoint()
    var pickedPtIsDelta = false
    //var pointPicked = pointPickedStatusEnum.notPicked
    
    
    var cadCommandList = MWCadCommandList()
    
    func runCommandSequence(_ command:MWCadCommand){
        let commandString = command.name
        if commandString == "line"{
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
            dsd.makeCurrentCommand(cadCommandList.commands["lineA"]!)
            ipd.makeCurrentCommand(cadCommandList.commands["lineA"]!)
            
        }else if commandString == "lineA"{
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
            dsd.makeCurrentCommand(cadCommandList.commands["lineAB"]!)
            ipd.makeCurrentCommand(cadCommandList.commands["lineAB"]!)
            ipd.prepareNewLine()
            ipd.outputText("Select P2>")
            ipd.prepareNewLine()
            dsd.setFocus()
            
        }else if commandString == "lineAB"{
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
            dsd.appendLineListWithTemp()
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
        guard let ipd = inputPanelDelegate else{
            return
        }
        
        dsd.mySetDrawTempLine(false)
        dsd.adjustTablesOnSelectionClear()
        dsd.remoteDisplay()
        
        dsd.makeCurrentCommand(cadCommandList.commands["noCommand"]!)
        ipd.makeCurrentCommand(cadCommandList.commands["noCommand"]!)
        
    }
    
    func endMidCommand(){
        
    }
}
