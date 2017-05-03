//
//  SplitViewController_Main.swift
//  DrawingSpaceControl_UsingCustomTransforms
//
//  Created by Mark Walker on 12/28/15.
//  Copyright © 2015 Mark Walker. All rights reserved.
//

import Cocoa

class SplitViewController_Main: NSSplitViewController{
    
    
    var vc_DwgControl = myViewController()
    var vc_InputPanel = ViewController_textInputPanel()
    var vc_TabView = NSTabViewController()
    var vc_legalText = ViewController_LegalTextView()
    
    var lineSequence = MWLineCommandSequence()
    var idSequence = MWIDCommandSequence()
    var distSequence = MWDistCommandSequence()
    var listSequence = MWListCommandSequence()
    var zoomExtentsSequence = MWZoomExtentsCommandSequence()
    var delSequence = MWDeleteCommandSequence()
    var moveSequence = MWMoveCommmadSequence()
    var circleSequence = MWCircleCommandSequence()
    var mlineSequence = MWMlineCommandSequence()
    var copySequence = MWCopyCommandSequence()
    var arcSequence = MWArcCommandSequence()
    
    
    var cadCommandList = MWCadCommandList()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        //get a reference to both controllers
        
        vc_DwgControl = self.childViewControllers[0] as! myViewController
        vc_InputPanel = self.childViewControllers[1] as! ViewController_textInputPanel
        vc_TabView = self.childViewControllers[2] as! NSTabViewController
        
        vc_legalText = vc_TabView.tabViewItems[0].viewController as! ViewController_LegalTextView
        
        vc_DwgControl.drawingControl.inputPanelDelegate = vc_InputPanel.commandControl
        vc_InputPanel.commandControl.drawingController = vc_DwgControl.drawingControl
        vc_legalText.drawingController = vc_DwgControl.drawingControl
        
        lineSequence.inputPanelDelegate = vc_InputPanel.commandControl
        lineSequence.drawingSpaceDelegate = vc_DwgControl.drawingControl
        
        
        idSequence.inputPanelDelegate = vc_InputPanel.commandControl
        idSequence.drawingSpaceDelegate = vc_DwgControl.drawingControl
        
        distSequence.inputPanelDelegate = vc_InputPanel.commandControl
        distSequence.drawingSpaceDelegate = vc_DwgControl.drawingControl
        
        listSequence.inputPanelDelegate = vc_InputPanel.commandControl
        listSequence.drawingSpaceDelegate = vc_DwgControl.drawingControl
        
        zoomExtentsSequence.inputPanelDelegate = vc_InputPanel.commandControl
        zoomExtentsSequence.drawingSpaceDelegate = vc_DwgControl.drawingControl
        
        delSequence.inputPanelDelegate = vc_InputPanel.commandControl
        delSequence.drawingSpaceDelegate = vc_DwgControl.drawingControl
        
        moveSequence.inputPanelDelegate = vc_InputPanel.commandControl
        moveSequence.drawingSpaceDelegate = vc_DwgControl.drawingControl
        
        circleSequence.inputPanelDelegate = vc_InputPanel.commandControl
        circleSequence.drawingSpaceDelegate = vc_DwgControl.drawingControl
        
        mlineSequence.inputPanelDelegate = vc_InputPanel.commandControl
        mlineSequence.drawingSpaceDelegate = vc_DwgControl.drawingControl
        
        
        copySequence.inputPanelDelegate = vc_InputPanel.commandControl
        copySequence.drawingSpaceDelegate = vc_DwgControl.drawingControl
        
        arcSequence.inputPanelDelegate = vc_InputPanel.commandControl
        arcSequence.drawingSpaceDelegate = vc_DwgControl.drawingControl
      //add the commands to the command list
        
        
        let noCommand = MWCadCommand(name: "noCommand", acceptsPtInput: false, acceptsAngleDistInput: false)
        noCommand.commandStatus = .noCommand
        
        cadCommandList.commands[noCommand.name] = noCommand
        
        
        let circleCommand = MWCadCommand(name: "circle", acceptsPtInput: false, acceptsAngleDistInput: false)
        circleCommand.commandSequence = circleSequence
        circleCommand.commandStatus = .mainCommand
        
        let circleACommand = MWCadCommand(name: "circleA", acceptsPtInput: true, acceptsAngleDistInput: false)
        circleACommand.commandSequence = circleSequence
        
        let circleBCommand = MWCadCommand(name: "circleB", acceptsPtInput: true, acceptsAngleDistInput: true)
        circleBCommand.commandSequence = circleSequence
        
        cadCommandList.commands[circleCommand.name] = circleCommand
        cadCommandList.commands[circleACommand.name] = circleACommand
        cadCommandList.commands[circleBCommand.name] = circleBCommand
        
        let lineCommand = MWCadCommand(name: "line", acceptsPtInput: false, acceptsAngleDistInput: false)
        lineCommand.commandSequence = lineSequence
        lineCommand.commandStatus = .mainCommand
        
        let lineACommand = MWCadCommand(name: "lineA", acceptsPtInput: true, acceptsAngleDistInput: false)
        lineACommand.commandSequence = lineSequence
        
        let lineABCommand = MWCadCommand(name: "lineAB", acceptsPtInput: true, acceptsAngleDistInput: true)
        lineABCommand.commandSequence = lineSequence
        
        cadCommandList.commands[lineCommand.name] = lineCommand
        cadCommandList.commands[lineACommand.name] = lineACommand
        cadCommandList.commands[lineABCommand.name] = lineABCommand
        
        
        let idCommand = MWCadCommand(name: "id", acceptsPtInput: false, acceptsAngleDistInput: false)
        idCommand.commandSequence = idSequence
        idCommand.commandStatus = .mainCommand
        
        let idACommand = MWCadCommand(name: "idA", acceptsPtInput: true, acceptsAngleDistInput: false)
        idACommand.commandSequence = idSequence
        
        cadCommandList.commands[idCommand.name] = idCommand
        cadCommandList.commands[idACommand.name] = idACommand
        
        
        
        let distCommand = MWCadCommand(name: "dist", acceptsPtInput: false, acceptsAngleDistInput: false)
        distCommand.commandSequence = distSequence
        distCommand.commandStatus = .mainCommand
        
        let distACommand = MWCadCommand(name: "distA", acceptsPtInput: true, acceptsAngleDistInput: false)
        distACommand.commandSequence = distSequence
        
        let distABCommand = MWCadCommand(name: "distAB", acceptsPtInput: true, acceptsAngleDistInput: false)
        distABCommand.commandSequence = distSequence
        
        cadCommandList.commands[distCommand.name] = distCommand
        cadCommandList.commands[distACommand.name] = distACommand
        cadCommandList.commands[distABCommand.name] = distABCommand
        
        let listCommand = MWCadCommand(name: "list", acceptsPtInput: false, acceptsAngleDistInput: false)
        listCommand.commandSequence = listSequence
        listCommand.commandStatus = .mainCommand
        
        let listACommand = MWCadCommand(name: "listA", acceptsPtInput: false, acceptsAngleDistInput: false)
        listACommand.commandSequence = listSequence
        listACommand.acceptsObjectSelection = true
       

        cadCommandList.commands[listCommand.name] = listCommand
        cadCommandList.commands[listACommand.name] = listACommand
        
        
        let zoomExtentsCommand = MWCadCommand(name: "ze", acceptsPtInput: false, acceptsAngleDistInput: false)
        zoomExtentsCommand.commandStatus = .mainCommand
        zoomExtentsCommand.commandSequence = zoomExtentsSequence
        
        cadCommandList.commands[zoomExtentsCommand.name] = zoomExtentsCommand
        
        let delCommand = MWCadCommand(name: "del", acceptsPtInput: false, acceptsAngleDistInput: false)
        delCommand.commandSequence = delSequence
        delCommand.commandStatus = .mainCommand
        
        let delACommand = MWCadCommand(name: "delA", acceptsPtInput: false, acceptsAngleDistInput: false)
        delACommand.acceptsObjectSelection = true
        delACommand.commandSequence = delSequence
        delACommand.endSelectionOnReturn = true
        
        let delBCommand = MWCadCommand(name: "delB", acceptsPtInput: false, acceptsAngleDistInput: false)
        delBCommand.commandSequence = delSequence
        
        cadCommandList.commands[delCommand.name] = delCommand
        cadCommandList.commands[delACommand.name] = delACommand
        cadCommandList.commands[delBCommand.name] = delBCommand
        
        
        let moveCommand = MWCadCommand(name: "move", acceptsPtInput: false, acceptsAngleDistInput: false)
        moveCommand.commandSequence = moveSequence
        moveCommand.commandStatus = .mainCommand
        
        let moveACommand = MWCadCommand(name: "moveA", acceptsPtInput: false, acceptsAngleDistInput: false)
        moveACommand.acceptsObjectSelection = true
        moveACommand.commandSequence = moveSequence
        moveACommand.endSelectionOnReturn = true
        
        
        let moveBCommand = MWCadCommand(name: "moveB", acceptsPtInput: false, acceptsAngleDistInput: false)
        moveBCommand.commandSequence = moveSequence
        
        let moveCCommand = MWCadCommand(name: "moveC", acceptsPtInput: true, acceptsAngleDistInput: true)
        moveCCommand.commandSequence = moveSequence
        
        let moveDCommand = MWCadCommand(name: "moveD", acceptsPtInput: true, acceptsAngleDistInput: true)
        moveDCommand.commandSequence = moveSequence
        
        
        cadCommandList.commands[moveCommand.name] = moveCommand
        cadCommandList.commands[moveACommand.name] = moveACommand
        cadCommandList.commands[moveBCommand.name] = moveBCommand
        cadCommandList.commands[moveCCommand.name] = moveCCommand
        cadCommandList.commands[moveDCommand.name] = moveDCommand
        
        
        let copyCommand = MWCadCommand(name: "copy", acceptsPtInput: false, acceptsAngleDistInput: false)
        copyCommand.commandSequence = copySequence
        copyCommand.commandStatus = .mainCommand
        
        let copyACommand = MWCadCommand(name: "copyA", acceptsPtInput: false, acceptsAngleDistInput: false)
        copyACommand.acceptsObjectSelection = true
        copyACommand.commandSequence = copySequence
        copyACommand.endSelectionOnReturn = true
        
        let copyBCommand = MWCadCommand(name: "copyB", acceptsPtInput: false, acceptsAngleDistInput: false)
        copyBCommand.commandSequence = copySequence
        
        let copyCCommand = MWCadCommand(name: "copyC", acceptsPtInput: true, acceptsAngleDistInput: true)
        copyCCommand.commandSequence = copySequence
       
        
        let copyDCommand = MWCadCommand(name: "copyD", acceptsPtInput: true, acceptsAngleDistInput: true)
        copyDCommand.commandSequence = copySequence
         copyDCommand.endCommandOnReturn = true
        
        //let copyECommand = MWCadCommand(name: "copyE", acceptsPtInput: false, acceptsAngleDistInput: false)
        //copyECommand.commandSequence = copySequence
        
        
        cadCommandList.commands[copyCommand.name] = copyCommand
        cadCommandList.commands[copyACommand.name] = copyACommand
        cadCommandList.commands[copyBCommand.name] = copyBCommand
        cadCommandList.commands[copyCCommand.name] = copyCCommand
        cadCommandList.commands[copyDCommand.name] = copyDCommand
        //cadCommandList.commands[copyECommand.name] = copyECommand
        
        let mlineCommand = MWCadCommand(name: "mline", acceptsPtInput: false, acceptsAngleDistInput: false)
        mlineCommand.commandSequence = mlineSequence
        mlineCommand.commandStatus = .mainCommand
        
        let mlineACommand = MWCadCommand(name: "mlineA", acceptsPtInput: true, acceptsAngleDistInput: false)
        mlineACommand.commandSequence = mlineSequence
        
        
        let mlineBCommand = MWCadCommand(name: "mlineB", acceptsPtInput: true, acceptsAngleDistInput: true)
        mlineBCommand.commandSequence = mlineSequence
        mlineBCommand.endCommandOnReturn = true
        
        let mlineCCommand = MWCadCommand (name: "mlineC", acceptsPtInput: true, acceptsAngleDistInput: true)
        mlineCCommand.commandSequence = mlineSequence
        
        cadCommandList.commands[mlineCommand.name] = mlineCommand
        cadCommandList.commands[mlineACommand.name] = mlineACommand
        cadCommandList.commands[mlineBCommand.name] = mlineBCommand
        cadCommandList.commands[mlineCCommand.name] = mlineCCommand
        
        let arcCommand = MWCadCommand(name: "arc", acceptsPtInput: false, acceptsAngleDistInput: false)
        arcCommand.commandSequence = arcSequence
        arcCommand.commandStatus = .mainCommand
        
        let arcACommand = MWCadCommand(name: "arcA", acceptsPtInput: true, acceptsAngleDistInput: false)
        arcACommand.commandSequence = arcSequence
        
        let arcBCommand = MWCadCommand(name: "arcB", acceptsPtInput: true, acceptsAngleDistInput: true)
        arcBCommand.commandSequence = arcSequence
        
        let arcCCommand = MWCadCommand(name: "arcC", acceptsPtInput: true, acceptsAngleDistInput: true)
        arcCCommand.commandSequence = arcSequence
        
        cadCommandList.commands[arcCommand.name] = arcCommand
        cadCommandList.commands[arcACommand.name] = arcACommand
        cadCommandList.commands[arcBCommand.name] = arcBCommand
        cadCommandList.commands[arcCCommand.name] = arcCCommand
        
        //complete - add the commands to the command list
        
        
        
        vc_InputPanel.commandControl.cadCommandList = self.cadCommandList
        vc_DwgControl.drawingControl.cadCommandList = self.cadCommandList
        
        lineSequence.cadCommandList = self.cadCommandList
        idSequence.cadCommandList = self.cadCommandList
        distSequence.cadCommandList = self.cadCommandList
        listSequence.cadCommandList = self.cadCommandList
        zoomExtentsSequence.cadCommandList = self.cadCommandList
        delSequence.cadCommandList = self.cadCommandList
        moveSequence.cadCommandList = self.cadCommandList
        circleSequence.cadCommandList = self.cadCommandList
        mlineSequence.cadCommandList = self.cadCommandList
        copySequence.cadCommandList = self.cadCommandList
        arcSequence.cadCommandList = self.cadCommandList
        
        vc_InputPanel.commandControl.makeCurrentCommand(noCommand)
        vc_InputPanel.commandControl.makeLastMainCommand(noCommand)
        vc_DwgControl.drawingControl.makeCurrentCommand(noCommand)
    }
    
    
   
    
    @IBAction func toggleRight(_ sender: AnyObject) {
        if self.splitViewItem(for: vc_TabView)?.isCollapsed == false{
            self.splitViewItem(for: vc_TabView)?.isCollapsed = true
        }else{
            self.splitViewItem(for: vc_TabView)?.isCollapsed = false
        }
        print("Clicked Right")
    }
    
    
    @IBAction func toggleEndSnap(_ sender: AnyObject){
    
        let button = sender as! NSToolbarItem
        button.image = NSImage(named: "righton.png")
        
        
        vc_DwgControl.drawingControl.toggleEndSnap()
        vc_InputPanel.commandControl.outputText("")
        vc_InputPanel.commandControl.outputText("end snap toggle")
        vc_InputPanel.commandControl.outputText("")
        button.image = NSImage(named: "lefton.png")
        vc_DwgControl.drawingControl.setFocus()
        
       
     
    }
    
    @IBAction func toggleCenterSnap(_ sender: AnyObject){
        vc_DwgControl.drawingControl.toggleCenterSnap()
        vc_InputPanel.commandControl.outputText("")
        vc_InputPanel.commandControl.outputText("center snap toggle")
        vc_InputPanel.commandControl.outputText("")
        vc_DwgControl.drawingControl.setFocus()
    }
    
    
   
    
    
}
