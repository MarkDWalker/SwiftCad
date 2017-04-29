//
//  MWDeleteCommandSequence.swift
//  DrawingSpace_CustomTransforms_V0.0.2
//
//  Created by Mark Walker on 1/12/16.
//  Copyright © 2016 Mark Walker. All rights reserved.
//

import Cocoa

class MWDeleteCommandSequence: NSObject, MWCommandSequence {

    var inputPanelDelegate:MWInputController?//allows calling of functions in the inputpanel
    var drawingSpaceDelegate:MWDrawingController? //allows calling of functions in the drawingspace
    
    var pickedPt = NSPoint()
    var pickedPtIsDelta = false
    
    var cadCommandList = MWCadCommandList()
    
    var commandAfterSelection = "delB"
    
    func runCommandSequence(_ command: MWCadCommand) {
        let commandString = command.name
        if commandString == "del"{
            guard let ipd = inputPanelDelegate else{
                return
            }
            guard let dsd = drawingSpaceDelegate else{
                return
            }
            
            ipd.prepareNewLine()
            ipd.outputText("Select Objects to Delete>")
            
            //set focus to drawings space Control
            dsd.setFocus()
            dsd.makeCurrentCommand(cadCommandList.commands["delA"]!)
            ipd.makeCurrentCommand(cadCommandList.commands["delA"]!)
            
        }else if commandString == "delA"{
            guard let ipd = inputPanelDelegate else{
                return
            }
            guard let dsd = drawingSpaceDelegate else{
                return
            }
            
            let selectedHandle = dsd.masterEntityTable.getHandleFromPtPick(pickedPt)
            
            if selectedHandle == -1 && dsd.selectionBoxActive == false{
                dsd.mySetSelectionBoxActive(true)
                dsd.mySetSelectionBoxOrigin(pickedPt)
            }else if selectedHandle == -1 && dsd.selectionBoxActive == true{
                 dsd.mySetSelectionBoxActive(false)
                let startBound = dsd.selectionBoxOriginModelPt
                let endBound = pickedPt
                
                let selectedHandles = dsd.masterEntityTable.getHandlesFromSelectionWindow(startBound, endPt: endBound)
                
                for handle in selectedHandles{
                    dsd.adjustTablesOnEntitySelection(handle)
                    
                }
                
            }else if selectedHandle != -1 && dsd.selectionBoxActive == false{
                dsd.adjustTablesOnEntitySelection(selectedHandle)
                
            }
            
            dsd.remoteDisplay()
            dsd.mySetRenderPickBox(false)
            
            dsd.setFocus()
            dsd.makeCurrentCommand(cadCommandList.commands["delA"]!)
            ipd.makeCurrentCommand(cadCommandList.commands["delA"]!)
            ipd.prepareNewLine()
            ipd.outputText("Continue Selecting, or enter to finish>")
            ipd.prepareNewLine()
            
        }else if commandString == "delB"{
            guard let ipd = inputPanelDelegate else{
                return
            }
            guard let dsd = drawingSpaceDelegate else{
                return
            }
            
            ipd.prepareNewLine()
            ipd.prepareNewLine()
            
            dsd.deleteEntitiesInSelection()//deletes selected lines from the master table
            dsd.adjustTablesOnSelectionClear()
            dsd.remoteDisplay()
            //end the command
            
            dsd.makeCurrentCommand(cadCommandList.commands["noCommand"]!)
            ipd.makeCurrentCommand(cadCommandList.commands["noCommand"]!)
            ipd.setCommandStatus(MWCommandStatusEnum.noCommand)
            dsd.remoteEnableCursorRects()
        
        }
        
        
    }
    
    func makePickedPoint(_ pt: NSPoint, isDelta: Bool) {
        pickedPt = pt
        pickedPtIsDelta = isDelta
    }
    
    func cancelMidCommand() {
        guard let dsd = drawingSpaceDelegate else{
            return
        }
        dsd.adjustTablesOnSelectionClear()
        dsd.remoteDisplay()
    }
    
    func endMidCommand(){
        
    }
}
