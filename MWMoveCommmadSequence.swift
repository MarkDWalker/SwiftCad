//
//  MWMoveCommmadSequence.swift
//  DrawingSpace_CustomTransforms_V0.0.2
//
//  Created by Mark Walker on 1/14/16.
//  Copyright © 2016 Mark Walker. All rights reserved.
//

import Cocoa

class MWMoveCommmadSequence: NSObject, MWCommandSequence{
    
    var inputPanelDelegate:MWInputController?//allows calling of functions in the inputpanel
    var drawingSpaceDelegate:MWDrawingController? //allows calling of functions in the drawingspace
    
    var pickedPt = NSPoint()
    var pickedPtIsDelta = false
    //var pointPicked = pointPickedStatusEnum.notPicked
    
    
    var cadCommandList = MWCadCommandList()
    
    var commandAfterSelection = "moveB"
    
    var modelBasePt = NSPoint()
    var modelSecondPt = NSPoint()
    
    func runCommandSequence(_ command:MWCadCommand){
        let commandString = command.name
        
        guard let ipd = inputPanelDelegate else{
            return
        }
        guard let dsd = drawingSpaceDelegate else{
            return
        }
        
        if commandString == "move"{
            //this is necessary to reset the commandAfterSelection
            //as later in the command it is moved to "moveD"
            commandAfterSelection = "moveB"
            ipd.prepareNewLine()
            ipd.outputText("Select Objects to Move>")
            
            //set focus to drawings space Control
            dsd.setFocus()
            dsd.makeCurrentCommand(cadCommandList.commands["moveA"]!)
            ipd.makeCurrentCommand(cadCommandList.commands["moveA"]!)
            
        }else if commandString == "moveA"{
            guard let ipd = inputPanelDelegate else{
                return
            }
            guard let dsd = drawingSpaceDelegate else{
                return
            }
            
            let selectedHandle = dsd.masterEntityTable.getHandleFromPtPick(pickedPt)
            
            if selectedHandle == -1 && dsd.selectionBoxActive == false { //nothing picked start selection window
                
                dsd.mySetSelectionBoxActive(true)
                dsd.mySetSelectionBoxOrigin(pickedPt)
                
            }else if selectedHandle == -1 && dsd.selectionBoxActive == true{ // we are finishing a window pick
                    dsd.mySetSelectionBoxActive(false)
                    
                    let startBound = dsd.selectionBoxOriginModelPt
                    let endBound = pickedPt
                    
                    let selectedHandles = dsd.masterEntityTable.getHandlesFromSelectionWindow(startBound, endPt: endBound)
                    
                    for handle in selectedHandles{
                        dsd.adjustTablesOnEntitySelection(handle)
                        dsd.adjustTempMoveTableOnSelection(handle)
                    }
            
                dsd.mySetRenderPickBox(false)
            }else if selectedHandle != -1 && dsd.selectionBoxActive == false{ // item picked
                
                dsd.adjustTablesOnEntitySelection(selectedHandle)
                dsd.adjustTempMoveTableOnSelection(selectedHandle)
            }
            
            dsd.remoteDisplay()
            
            dsd.setFocus()
            dsd.makeCurrentCommand(cadCommandList.commands["moveA"]!)
            ipd.makeCurrentCommand(cadCommandList.commands["moveA"]!)
            ipd.prepareNewLine()
            ipd.outputText("Continue Selecting, or enter to finish>")
            ipd.prepareNewLine()
            
        }else if commandString == "moveB"{
         
            
            ipd.prepareNewLine()
            ipd.outputText("Select Base Point.")
            ipd.prepareNewLine()
            ipd.prepareNewLine()
            
            dsd.setFocus()
            dsd.makeCurrentCommand(cadCommandList.commands["moveC"]!)
            ipd.makeCurrentCommand(cadCommandList.commands["moveC"]!)
            
            
            
            
        }else if commandString == "moveC"{
            //this is here so the user can hit return after entering
            //the exact move at the command line -- EX: @50<20
            self.commandAfterSelection = "moveD"
            
            ipd.prepareNewLine()
            ipd.outputText("Select Second Point.")
            ipd.prepareNewLine()
            ipd.prepareNewLine()
            
            let ptArray = [pickedPt, pickedPt]
            let newBaseLine = MWLine(thePointDefArray: ptArray, theLengthDef: 0)
            let newCadLine = MWCadLine(theModelLine:newBaseLine)
            dsd.mySetTempLine(newCadLine)
            dsd.mySetDrawTempLine(true)
            dsd.mySetDrawTempMoveEntities(true)
            
            modelBasePt.x = pickedPt.x
            modelBasePt.y = pickedPt.y
            
            dsd.setFocus()
            dsd.makeCurrentCommand(cadCommandList.commands["moveD"]!)
            ipd.makeCurrentCommand(cadCommandList.commands["moveD"]!)
        
        }else if commandString == "moveD"{
            
            ipd.prepareNewLine()
            ipd.prepareNewLine()
            
            dsd.mySetDrawTempLine(false)
            dsd.mySetDrawTempMoveEntities(false)
            
            var delta = NSPoint()
            
            //a mousedown make this false
            //while a return makes it true
            if pickedPtIsDelta == true{
                delta.x = pickedPt.x
                delta.y = pickedPt.y
            }else if pickedPtIsDelta == false{
                modelSecondPt.x = pickedPt.x
                modelSecondPt.y = pickedPt.y
        
                delta.x = modelSecondPt.x - modelBasePt.x
                delta.y = modelSecondPt.y - modelBasePt.y
            }
            
            dsd.moveEntitiesInSelection(delta)//moves selected lines from the master table
            dsd.adjustTablesOnSelectionClear()
            dsd.remoteDisplay()
            
            //end the command
            
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
