//
//  MWListCommandSequence.swift
//  DrawingSpace_CustomTransforms_V0.0.2
//
//  Created by Mark Walker on 1/6/16.
//  Copyright © 2016 Mark Walker. All rights reserved.
//

import Cocoa

class MWListCommandSequence: NSObject, MWCommandSequence {
    var inputPanelDelegate:MWInputController?
    var drawingSpaceDelegate:MWDrawingController?
    
    var pickedPt = NSPoint()
    var pickedPtIsDelta = false
    
    var cadCommandList = MWCadCommandList()
    
  
    func runCommandSequence(_ command: MWCadCommand) {
        let commandString = command.name
        if commandString == "list"{
            guard let ipd = inputPanelDelegate else{
                return
            }
            guard let dsd = drawingSpaceDelegate else{
                return
            }
            
            ipd.prepareNewLine()
            ipd.outputText("select object>")
            
            //set focus to drawings space Control
            dsd.makeCurrentCommand(cadCommandList.commands["listA"]!)
            ipd.makeCurrentCommand(cadCommandList.commands["listA"]!)
            dsd.setFocus()
        }else if commandString == "listA"{
            guard let ipd = inputPanelDelegate else{
                return
            }
            guard let dsd = drawingSpaceDelegate else{
                return
            }
            
            let selectedHandle = dsd.masterEntityTable.getHandleFromPtPick(pickedPt)
            
            if selectedHandle == -1 {
                //do nothing the user missed
                
            }else if selectedHandle > -1{
                dsd.mySetRenderPickBox(false)
                dsd.adjustTablesOnEntitySelection(selectedHandle)
                dsd.remoteDisplay()
                
                let selectedEntityTable:MWCadEntityCollection = dsd.getselectedEntityTable()
                
                guard selectedEntityTable.entities.count > 0 else{
                    return
                }
                let entity = selectedEntityTable.entityArray[0]
                
                
                for i:Int in 0 ... entity.listArray.count-1{
                    ipd.prepareNewLine()
                    ipd.outputText(entity.listArray[i])
                }
                
                ipd.prepareNewLine()
                ipd.prepareNewLine()
                
                dsd.adjustTablesOnSelectionClear()
                dsd.remoteDisplay()
                dsd.makeCurrentCommand(cadCommandList.commands["noCommand"]!)
                ipd.makeCurrentCommand(cadCommandList.commands["noCommand"]!)
                ipd.setCommandStatus(MWCommandStatusEnum.noCommand)
                dsd.remoteEnableCursorRects()
            }
            
        }
        
    }
    
    func makePickedPoint(_ pt: NSPoint, isDelta:Bool) {
        pickedPt = pt
        pickedPtIsDelta = isDelta
    }
    
    func cancelMidCommand() {
        
    }
    
    func endMidCommand(){
        
    }
    
    

}
