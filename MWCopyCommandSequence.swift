//
//  MWCopySequence.swift
//  DrawingSpace_CustomTransforms_V0.0.3
//
//  Created by Mark Walker on 1/23/16.
//  Copyright © 2016 Mark Walker. All rights reserved.
//

import Cocoa

class MWCopyCommandSequence: NSObject, MWCommandSequence {
    
    var inputPanelDelegate:MWInputController?//allows calling of functions in the inputpanel
    var drawingSpaceDelegate:MWDrawingController? //allows calling of functions in the drawingspace
    
    var pickedPt = NSPoint()
    var pickedPtIsDelta = false
    //var pointPicked = pointPickedStatusEnum.notPicked
    
    
    var cadCommandList = MWCadCommandList()
    
    var commandAfterSelection = "copyB"
    
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
        
        if commandString == "copy"{
            
            //starts the command
            //instructs the user to select object to copy
            //moves the current command to "copA"
            //sets the focus to the drawing space control
            commandAfterSelection = "copyB"    
            ipd.prepareNewLine()
            ipd.outputText("Select Objects to Copy>")
            
            //set focus to drawings space Control
            dsd.setFocus()
            dsd.makeCurrentCommand(cadCommandList.commands["copyA"]!)
            ipd.makeCurrentCommand(cadCommandList.commands["copyA"]!)
            
        }else if commandString == "copyA"{
            //this is only hit after every after "copy give the dsd focus and
            //the mouse click event is triggered
            //The command will not be advanced to "copyB" until the
            //dsd enter event is triggered
            
            
            
            //This section adds the entities to the selected entities table
            //redisplays the dsd to show the selected entities
            //prompts the user in the ipd to select more or click enter to finish
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
            dsd.makeCurrentCommand(cadCommandList.commands["copyA"]!)
            ipd.makeCurrentCommand(cadCommandList.commands["copyA"]!)
            ipd.prepareNewLine()
            ipd.outputText("Continue Selecting, or enter to finish>")
            ipd.prepareNewLine()
            
        }else if commandString == "copyB"{
            
            
            //after selecting items in "copyA" the user must press enter
            //which advances the command to "copyC" in the dsd enter key event
            
            //this section prompts the user to select a base point
            //advances the command to "copyC" and sets focus to dsd
            
            ipd.prepareNewLine()
            ipd.outputText("Select Base Point.")
            ipd.prepareNewLine()
            ipd.prepareNewLine()
            
            dsd.setFocus()
            dsd.makeCurrentCommand(cadCommandList.commands["copyC"]!)
            ipd.makeCurrentCommand(cadCommandList.commands["copyC"]!)
            
            
            
        }else if commandString == "copyC"{
            //after "copyB" dsd will detect a base point selection
            // and  run "copyC"
            
            
            //This section promps the user to select the second point for 
            //location change but since the change can also be a command line 
            //text entry (ex: @5<90) then we have to set the commandAfterSelection
            //which will handle the return event
            
            self.commandAfterSelection = "copyD"
            
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
            dsd.makeCurrentCommand(cadCommandList.commands["copyD"]!)
            ipd.makeCurrentCommand(cadCommandList.commands["copyD"]!)
            
        }else if commandString == "copyD"{
            
            ipd.prepareNewLine()
            ipd.prepareNewLine()
            
            
            
            var delta = NSPoint()
            if pickedPtIsDelta == true{
                delta.x = pickedPt.x
                delta.y = pickedPt.y
            }else if pickedPtIsDelta == false{
                modelSecondPt.x = pickedPt.x
                modelSecondPt.y = pickedPt.y
                
                delta.x = modelSecondPt.x - modelBasePt.x
                delta.y = modelSecondPt.y - modelBasePt.y
            }
            
            dsd.copyEntitiesInSelection(delta)//copies selected lines from the master table
            //dsd.adjustTablesOnSelectionClear()
            dsd.remoteDisplay()
            
            
        }//else if commandString == "copyE"{
            //end the command
            
//            dsd.mySetDrawTempLine(false)
//            dsd.mySetDrawTempMoveEntities(false)
//            dsd.adjustTablesOnSelectionClear()
//        
//            dsd.makeCurrentCommand(cadCommandList.commands["noCommand"]!)
//            ipd.makeCurrentCommand(cadCommandList.commands["noCommand"]!)
//            ipd.setCommandStatus(MWCommandStatusEnum.noCommand)
//            dsd.remoteEnableCursorRects()
//        
//        }
        
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
        dsd.mySetDrawTempMoveEntities(false)
        dsd.adjustTablesOnSelectionClear()
        dsd.remoteDisplay()
        
    }
    
    func endMidCommand(){
        guard let dsd = drawingSpaceDelegate else{
            return
        }
        
        dsd.mySetDrawTempLine(false)
        dsd.mySetDrawTempMoveEntities(false)
        dsd.adjustTablesOnSelectionClear()
        dsd.remoteDisplay()
    }

    
    
}
