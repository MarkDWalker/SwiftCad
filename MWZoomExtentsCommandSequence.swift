//
//  MWZoomExtentsCommandSequence.swift
//  DrawingSpace_CustomTransforms_V0.0.2
//
//  Created by Mark Walker on 1/6/16.
//  Copyright © 2016 Mark Walker. All rights reserved.
//

import Cocoa

class MWZoomExtentsCommandSequence: NSObject, MWCommandSequence {
    
    var inputPanelDelegate:MWInputController?
    var drawingSpaceDelegate:MWDrawingController?

    var cadCommandList = MWCadCommandList()
    var pickedPt = NSPoint()
    var pickedPtIsDelta = false
    
    func runCommandSequence(_ command:MWCadCommand){
        let commandString = command.name
        if commandString == "ze"{
            guard let ipd = inputPanelDelegate else{
                return
            }
            guard let dsd = drawingSpaceDelegate else{
                return
            }
            
            ipd.prepareNewLine()
            ipd.outputText("<zooom extent>")
            ipd.prepareNewLine()
            dsd.setFocus()
            dsd.zoomExtents()
            dsd.makeCurrentCommand(cadCommandList.commands["noCommand"]!)
            ipd.makeCurrentCommand(cadCommandList.commands["noCommand"]!)
            ipd.setCommandStatus(MWCommandStatusEnum.noCommand)

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
