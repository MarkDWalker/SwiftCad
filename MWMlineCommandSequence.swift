//
//  MWMlineCommandSequence.swift
//  DrawingSpace_CustomTransforms_V0.0.3
//
//  Created by Mark Walker on 1/23/16.
//  Copyright © 2016 Mark Walker. All rights reserved.
//

import Cocoa

class MWMlineCommandSequence: NSObject, MWCommandSequence {
    
    var inputPanelDelegate:MWInputController?//allows calling of functions in the inputpanel
    var drawingSpaceDelegate:MWDrawingController? //allows calling of functions in the drawingspace
    
    var pickedPt = NSPoint()
    var pickedPtIsDelta = false
    
    var cadCommandList = MWCadCommandList()
    
    var commandAfterSelection = "mlineC"
    
    var lastPickedRealPt = NSPoint()
    
    func runCommandSequence(_ command:MWCadCommand){
        let commandString = command.name
        if commandString == "mline"{
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
            dsd.makeCurrentCommand(cadCommandList.commands["mlineA"]!)
            ipd.makeCurrentCommand(cadCommandList.commands["mlineA"]!)
            
        }else if commandString == "mlineA"{
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
            ipd.outputText("Pt Picked:....")
            ipd.prepareNewLine()
            
            let ptArray = [pickedPt, pickedPt]
            let newBaseLine = MWLine(thePointDefArray: ptArray, theLengthDef: 0)
            let newCadLine = MWCadLine(theModelLine:newBaseLine)
            dsd.mySetTempLine(newCadLine)
            dsd.mySetDrawTempLine(true)
            
            //send additional instructions to the user
            //pick the second point
            dsd.makeCurrentCommand(cadCommandList.commands["mlineB"]!)
            ipd.makeCurrentCommand(cadCommandList.commands["mlineB"]!)
            ipd.prepareNewLine()
            ipd.outputText("Select Next Point>")
            ipd.prepareNewLine()
            dsd.setFocus()
            
        }else if commandString == "mlineB"{
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
            ipd.outputText("picked Pt:....")
            dsd.mySetDrawTempLine(false)
            lastPickedRealPt = dsd.modifyTempEndPt(pickedPt, isDelta: pickedPtIsDelta)
            dsd.appendLineListWithTemp()
            dsd.remoteDisplay()
            ipd.prepareNewLine()
            
            
            //this is a repeat of mlineA
            let ptArray = [lastPickedRealPt, lastPickedRealPt]
            let newBaseLine = MWLine(thePointDefArray: ptArray, theLengthDef: 0)
            let newCadLine = MWCadLine(theModelLine:newBaseLine)
            
            
            dsd.mySetTempLine(newCadLine)
            dsd.mySetDrawTempLine(true)
            
            dsd.makeCurrentCommand(cadCommandList.commands["mlineB"]!)
            ipd.makeCurrentCommand(cadCommandList.commands["mlineB"]!)
            ipd.prepareNewLine()
            ipd.outputText("Select Next Point>")
            ipd.prepareNewLine()
            dsd.setFocus()
 
        }else if commandString == "mlineC"{
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
            ipd.outputText("last Pt:....")
            dsd.mySetDrawTempLine(false)
            dsd.modifyTempEndPt(pickedPt, isDelta: pickedPtIsDelta)
            dsd.appendLineListWithTemp()
            dsd.remoteDisplay()
            ipd.prepareNewLine()
            dsd.makeCurrentCommand(cadCommandList.commands["mlineA"]!)
            ipd.makeCurrentCommand(cadCommandList.commands["mlineA"]!)
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
        
        dsd.makeCurrentCommand(cadCommandList.commands["noCommand"]!)
        ipd.makeCurrentCommand(cadCommandList.commands["noCommand"]!)
        dsd.remoteDisplay()
    }
    
    func endMidCommand(){
        guard let dsd = drawingSpaceDelegate else{
            return
        }
        guard let ipd = inputPanelDelegate else{
            return
        }
        
        dsd.mySetDrawTempLine(false)
        dsd.adjustTablesOnSelectionClear()
        
        dsd.makeCurrentCommand(cadCommandList.commands["noCommand"]!)
        ipd.makeCurrentCommand(cadCommandList.commands["noCommand"]!)
        dsd.remoteDisplay()
    }

}
