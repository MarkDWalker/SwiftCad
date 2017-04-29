//
//  MWCircleCommandSequence.swift
//  DrawingSpace_CustomTransforms_V0.0.3
//
//  Created by Mark Walker on 1/21/16.
//  Copyright © 2016 Mark Walker. All rights reserved.
//

import Cocoa

class MWCircleCommandSequence: NSObject, MWCommandSequence {

    var inputPanelDelegate:MWInputController?//allows calling of functions in the inputpanel
    var drawingSpaceDelegate:MWDrawingController? //allows calling of functions in the drawingspace
    
    var pickedPt = NSPoint()
    var pickedPtIsDelta = false
    
    var cadCommandList = MWCadCommandList()
    
    
    func runCommandSequence(_ command:MWCadCommand){
        let commandString = command.name
        if commandString == "circle"{
            guard let ipd = inputPanelDelegate else{
                return
            }
            guard let dsd = drawingSpaceDelegate else{
                return
            }
            
            ipd.prepareNewLine()
            ipd.outputText("Select Center Pt>")
            
            //set focus to drawings space Control
            dsd.setFocus()
            dsd.makeCurrentCommand(cadCommandList.commands["circleA"]!)
            ipd.makeCurrentCommand(cadCommandList.commands["circleA"]!)
            
        }else if commandString == "circleA"{
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
            ipd.outputText("Center Pt Picked:....")
            ipd.prepareNewLine()
            
            let ptArray = [pickedPt]
            
            
            let newBaseCircle = MWCircle(thePointDefArray: ptArray, theLengthDef: 1)
            let newCadCircle = MWCadCircle(theModelCircle: newBaseCircle
            )
            
            dsd.mySetTempCircle(newCadCircle)
            dsd.mySetDrawTempCircle(true)
            
            //send additional instructions to the user
            //pick the second point
            dsd.makeCurrentCommand(cadCommandList.commands["circleB"]!)
            ipd.makeCurrentCommand(cadCommandList.commands["circleB"]!)
            ipd.prepareNewLine()
            ipd.outputText("Select (or enter) radius")
            ipd.prepareNewLine()
            dsd.setFocus()
            
        }else if commandString == "circleB"{
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
            ipd.outputText("Radius Set Pt:....")
            dsd.mySetDrawTempCircle(false)
            dsd.modifyTempCircleRadiusPt(pickedPt, isDelta: pickedPtIsDelta)
            dsd.appendCircleListWithTemp()
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
        
        dsd.mySetDrawTempLine(false)
        dsd.adjustTablesOnSelectionClear()
        dsd.remoteDisplay()
        
    }
    
    func endMidCommand(){
        
    }
    

}
