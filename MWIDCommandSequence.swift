//
//  MWIDCommandSequence.swift
//  DrawingSpace_CustomTransforms_V0.0.2
//
//  Created by Mark Walker on 1/3/16.
//  Copyright © 2016 Mark Walker. All rights reserved.
//

import Cocoa

class MWIDCommandSequence: NSObject, MWCommandSequence{
    
    var inputPanelDelegate:MWInputController?
    var drawingSpaceDelegate:MWDrawingController?
    
     var cadCommandList = MWCadCommandList()
    
    var pickedPt = NSPoint()
    var pickedPtIsDelta = false
    
    func runCommandSequence(_ command:MWCadCommand){
        let commandString = command.name
        if commandString == "id"{
            guard let ipd = inputPanelDelegate else{
                return
            }
            guard let dsd = drawingSpaceDelegate else{
                return
            }
            
            ipd.prepareNewLine()
            ipd.outputText("ID_select screen point")
            dsd.setFocus()
            dsd.makeCurrentCommand(cadCommandList.commands["idA"]!)
            ipd.makeCurrentCommand(cadCommandList.commands["idA"]!)
        }else if commandString == "idA"{
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
            ipd.outputText("ID Point")
            ipd.prepareNewLine()
            dsd.makeCurrentCommand(cadCommandList.commands["noCommand"]!)
            ipd.makeCurrentCommand(cadCommandList.commands["noCommand"]!)
            ipd.setCommandStatus(MWCommandStatusEnum.noCommand)
            dsd.remoteEnableCursorRects()
        }
    }
    
    func makePickedPoint(_ pt:NSPoint, isDelta:Bool){
        pickedPt = pt
    }
    
    func cancelMidCommand() {
        return
    }
    
    func endMidCommand(){
        
    }
    
}

