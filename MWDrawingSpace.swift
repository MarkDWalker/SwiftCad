//
//  MWDrawingSpace.swift
//  DrawSpaceControlUsing_stockTransforms
//
//  Created by Mark Walker on 9/26/15.
//  Copyright © 2015 Mark Walker. All rights reserved.
//

import Cocoa

protocol MWDrawingController{
    var masterEntityTable:MWCadEntityCollection{get set}
    var selectedEntityTable:MWCadEntityCollection{get set}
    var unselectedEntityTable:MWCadEntityCollection{get set}
    var selectionBoxOrigin:NSPoint{get set}
    var selectionBoxOriginModelPt:NSPoint{get}
    var selectionBoxActive:Bool{get set}
    
    func mySetDrawTempLine(_ theBool:Bool)
    func mySetDrawTempCircle(_ theBool:Bool)
    func mySetDrawTempArc(_ theBool:Bool, endSet:Bool)
    
    func mySetTempLine(_ line:MWCadLine)
    func mySetTempCircle(_ circle:MWCadCircle)
    func mySetTempArc(_ arc:MWCadArc)
    
    
    func setFocus()
    func makeCurrentCommand(_ command:MWCadCommand)
    func modifyTempEndPt(_ newEndPoint:NSPoint, isDelta:Bool)->NSPoint
    func modifyTempCircleRadiusPt(_ newRadiusPt:NSPoint, isDelta: Bool)
    func modifyTempArcRadius(_ newViewRadius:CGFloat, isClockwise:Bool)
    
    func appendLineListWithTemp()
    func appendCircleListWithTemp()
    func appendArcListWithTemp()
    
    func remoteDisplay()
    func remoteEnableCursorRects()
    func getTempLineStartPt()->NSPoint
    func toggleEndSnap()
    func zoomExtents()
    func adjustTablesOnEntitySelection(_ handle:Int)
    func adjustTablesOnSelectionClear()
    func getselectedEntityTable()-> MWCadEntityCollection
    func cancelCommand()
    
    func deleteEntitiesInSelection()
    
    func moveEntitiesInSelection(_ delta:NSPoint)
    
    func copyEntitiesInSelection(_ delta: NSPoint)
    
    func adjustTempMoveTableOnSelection(_ handle:Int)
    func mySetDrawTempMoveEntities(_ theBool:Bool)
    func testAndAdjustForSelectionBox(_ handle:Int)
    func mySetSelectionBoxOrigin(_ theModelPt:NSPoint)
    func mySetSelectionBoxActive(_ theBool:Bool)
    func mySetRenderPickBox(_ theBool:Bool)
    
    func addEntity(_ theEntity:MWEntity)
    func addEntityArray(_ theEntity:[MWEntity])
}



class MWDrawingSpace: NSView, MWDrawingController {
    
    //talk directly to the input panel
    var inputPanelDelegate:MWInputController?
    
    //talk to the CommandSequence Objects
    //var lineCommandSequenceDelegate:MWLineCommandDelegate?
    //var idCommandSequenceDelegate:MWIDCommandDelegate?
    
    var viewColor = NSColor.black
    var mouseViewCoords = NSPoint()
   
    //the lines tables
    var masterEntityTable = MWCadEntityCollection()
    var selectedEntityTable = MWCadEntityCollection()
    var unselectedEntityTable = MWCadEntityCollection()
    
    var tempMoveEntityTable = MWCadEntityCollection()
    
    var transformCalcs = MWTransformCalculations()
    var gCadTransforms:MWCadTransforms = MWCadTransforms()
    
    var snapController = MWSnapsController()
    
    var drawTempLine:Bool = false
    var tempLine = MWCadLine()
    
    var drawTempCircle:Bool = false
    var tempCircle = MWCadCircle()
    
    var drawTempArcStartPtSet:Bool = false
    var drawTempArcEndPtSet:Bool = false
    
    var tempArc = MWCadArc()
    
    var drawTempMoveEntities:Bool = false
    
    var renderPickBox = false
    
    
    var selectionBoxActive = false
    var selectionBoxOrigin = NSPoint()
    
    var selectionBoxOriginModelPt:NSPoint{
        get{
            let returnPt = convertFromViewToModelPt(selectionBoxOrigin, zoomScale: gCadTransforms.zoomScale, transPt: gCadTransforms.scaledTrans)
            
            return returnPt
        }
    }
    var renderLeftRightSelectionBox = false
    var renderRighLeftSelectionBox = false
  
   
    //the list of commands
    var cadCommandList = MWCadCommandList()
    
    var currentCommand = MWCadCommand()
    
    
    //MARK: Override Functions
    override func viewDidMoveToWindow() {
        Swift.print("what - \(self.acceptsFirstResponder)")
        
        self.acceptsTouchEvents = true
        let trackingArea:NSTrackingArea = NSTrackingArea(rect: self.bounds, options: [.activeAlways, .mouseMoved, .inVisibleRect], owner: self, userInfo: nil)
        self.addTrackingArea(trackingArea)
        //setTestLines()
        setTestArc()
        unselectedEntityTable = tableCopy(masterEntityTable) // should be a copy
        display()
    }
    
    override func draw(_ dirtyRect: NSRect) {
        
        
        viewColor.setFill()
        NSRectFill(self.bounds)
        
        //snap activate area
        if snapController.endPointActive == true{
            let snapPoint = snapController.snapPoint
            if  snapPoint != nil{
                NSColor.yellow.set()
                let snapIcon = NSMakeRect((snapPoint?.x)! - 5, (snapPoint?.y)! - 5, 10, 10)
                let snapBez = NSBezierPath(rect: snapIcon)
                snapBez.stroke()
                
            }
        }
        
        if snapController.centerPointActive == true{
            let snapPoint = snapController.snapPoint
            if snapPoint != nil{
                NSColor.yellow.set()
                let snapIcon = NSMakeRect((snapPoint?.x)! - 5, (snapPoint?.y)! - 5, 10, 10)
                let snapBez = NSBezierPath(ovalIn: snapIcon)
                snapBez.stroke()
            }
        }
        
        if drawTempLine == true{
            NSColor.white.set()
            tempLine.bezierPath.stroke()
        }
        
        if drawTempCircle == true{
            NSColor.white.set()
            tempCircle.bezierPath.stroke()
        }
        
        if drawTempArcStartPtSet == true{
            NSColor.white.set()
            tempArc.bezierPath.stroke()
        }
        
        if drawTempMoveEntities == true && tempMoveEntityTable.entityArray.count > 0 {
            
            NSColor.white.set()
            for i:Int in 0 ... tempMoveEntityTable.entityArray.count-1{
                
                let moveEntity = tempMoveEntityTable.entityArray[i]
                moveEntity.bezierPath.stroke()
            }
        }
        
        if renderLeftRightSelectionBox == true{
            NSColor.white.set()
            
            let oX = selectionBoxOrigin.x; let oY = selectionBoxOrigin.y
            let w = mouseViewCoords.x - oX; let h = mouseViewCoords.y - oY
            
            let box = NSMakeRect(selectionBoxOrigin.x, selectionBoxOrigin.y, w, h)
            let boxBez = NSBezierPath(rect: box)
            boxBez.stroke()
        }
        
        
        if renderRighLeftSelectionBox == true{
            NSColor.white.set()
            let oX = selectionBoxOrigin.x; let oY = selectionBoxOrigin.y
            let w = mouseViewCoords.x - oX; let h = mouseViewCoords.y - oY
            
            let box = NSMakeRect(selectionBoxOrigin.x, selectionBoxOrigin.y, w, h)
            let boxBez = NSBezierPath(rect: box)
            
            let dashArray:[CGFloat] = [5, 5]
            let solidArray:[CGFloat]=[0,0]
            
            NSGraphicsContext.current()?.cgContext.setLineDash( phase:2,lengths:dashArray)
            boxBez.stroke()
            NSGraphicsContext.current()?.cgContext.setLineDash( phase:2,lengths:solidArray)
        }
        
        
      Swift.print("the number of entities: \(unselectedEntityTable.entities.count)")
        
        NSColor.red.set()
        for (_, unselectedEntities) in unselectedEntityTable.entities{
            unselectedEntities.bezierPath.stroke()
        }
        
        NSColor.white.set()
        let dashArray:[CGFloat] = [5, 5]
        let solidArray:[CGFloat] = [1, 1]
        for (_, selectedEntities) in selectedEntityTable.entities{
            NSGraphicsContext.current()?.cgContext.setLineDash( phase:2,lengths:dashArray)
            selectedEntities.bezierPath.stroke()
            NSGraphicsContext.current()?.cgContext.setLineDash( phase:2,lengths:solidArray)
        }
        
        
        
        
        if renderPickBox == true{
            NSColor.white.set()
            let pickBox = NSMakeRect((mouseViewCoords.x) - 5, (mouseViewCoords.y) - 5, 10, 10)
            let pickBoxBez = NSBezierPath(rect: pickBox)
            pickBoxBez.stroke()
        }
        
    }
    
    
    //MARK:IMPORTANT
    override func keyDown(with theEvent: NSEvent) {
        
        let key:String? = theEvent.charactersIgnoringModifiers
        
        if key == "a" && theEvent.modifierFlags.contains(.control){
            toggleEndSnap() //turn on the end snap
            Swift.print("Control a Press")
            
        }else if key == "c" && theEvent.modifierFlags.contains(.control){
            toggleCenterSnap() // on the or off the center snap
            Swift.print("Control c Press")
            
        }else if theEvent.keyCode == 53{ //press escape
            guard let ipd = inputPanelDelegate else{
                return
            }
            
            guard let commandSequence = currentCommand.commandSequence else{
                self.cancelCommand()
                ipd.cancelCommand()
                return
            }
            
            self.cancelCommand() //standard for all commands
            ipd.cancelCommand() //standard for all commands
            commandSequence.cancelMidCommand() //anything special the current command needs to implement
            
            
        }else if theEvent.keyCode == 36{ // press enter
            
            handleEnterPress(theEvent: theEvent)
            
            
        }else{ //no special key pressed, send the key to the input panel
            
            guard let ipd = inputPanelDelegate else{
                return
            }
            let key:String? = theEvent.characters
            ipd.setFocusWithChar(key!)
        }
        
        self.display()
    }
    
    override func rightMouseDown(with Event: NSEvent) {
        
        handleEnterPress(theEvent: Event)
        
    }
    
    private func handleEnterPress(theEvent:NSEvent){
        Swift.print("Enter was hit")
        if currentCommand.endSelectionOnReturn == true{
            guard let sequence = currentCommand.commandSequence else{
                return
            }
            
            //moves the command string to the next subcommand
            guard let commandString = sequence.commandAfterSelection else{
                return
            }
            
            ///////////////////////////////////////
            sequence.runCommandSequence(cadCommandList.commands[commandString]!)
            
            if renderPickBox == true{
                
                renderPickBox = false
                self.display()
            }
            
            ////////////////////////////////////////
        }else if currentCommand.endCommandOnReturn == true{
            
            guard let ipd = inputPanelDelegate else{
                return
            }
            
            guard let commandSequence = currentCommand.commandSequence else{
                self.cancelCommand()
                ipd.endCommand()
                return
            }
            self.cancelCommand() //standard for all commands
            ipd.endCommand() //standard for all commands
            commandSequence.endMidCommand() //anything special the current
            
        }else{
            guard let ipd = inputPanelDelegate else{
                return
            }
            let key:String? = theEvent.characters
            ipd.setFocusWithChar(key!)
        }

    }
    
    
    override func mouseDown(with theEvent: NSEvent) {
        
        //The first if statment just gets the picked point
        //if a snap is active
        if snapController.snapPoint != nil && (snapController.endPointActive == true || snapController.centerPointActive == true) {
            let modelSnapPt = convertFromViewToModelPt(snapController.snapPoint!, zoomScale: gCadTransforms.zoomScale, transPt: gCadTransforms.scaledTrans)
            
            guard let commandSequence = currentCommand.commandSequence else{
                return
            }
            commandSequence.makePickedPoint(modelSnapPt, isDelta: false)
    
            
        }else{ //a snap is not active
            
            let scaledPt = theEvent.locationInWindow as NSPoint
            let modelPt = convertFromViewToModelPt(scaledPt, zoomScale: gCadTransforms.zoomScale, transPt: gCadTransforms.scaledTrans)
            
            guard let commandSequence = currentCommand.commandSequence else{
                return
            }
            
            commandSequence.makePickedPoint(modelPt, isDelta: false)
          
            
        }
        //End get the picked point
        
        
        guard let commandSequence = currentCommand.commandSequence else{
            return
        }
        
        commandSequence.runCommandSequence(currentCommand)
    }

    
    
    
    override func mouseMoved(with theEvent: NSEvent) {
        
        if currentCommand.name == "copyC"{
            Swift.print(currentCommand.name)
        }
        //track the mouse coords and put the model coords in the title
        mouseViewCoords = theEvent.locationInWindow
        
        let modelCoords = convertFromViewToModelPt(mouseViewCoords, zoomScale: gCadTransforms.zoomScale, transPt: gCadTransforms.scaledTrans)
        
        self.window?.title = "x: \(modelCoords.x.fm(3)) | y: \(modelCoords.y.fm(3))"
        
        
       //set up the correct Cursor
        if currentCommand.acceptsPtInput{
            
            NSCursor.crosshair().set()
            self.window?.disableCursorRects()
            
        }else if currentCommand.acceptsObjectSelection && selectionBoxActive == false{

            NSCursor.iBeam().set()
            self.window?.disableCursorRects()
            renderPickBox = true
            display()
            
        }else if currentCommand.acceptsObjectSelection && selectionBoxActive {
            
            NSCursor.iBeam().set()
            self.window?.disableCursorRects()
            renderPickBox = true
            
            
            if mouseViewCoords.x > selectionBoxOrigin.x {
                renderLeftRightSelectionBox = true
                renderRighLeftSelectionBox = false
            }else{
                renderRighLeftSelectionBox = true
                renderLeftRightSelectionBox = false
            }
            
            display()
        }
        
        
        
        //if the endpoint snap is active then let it display.
        //the logic in the snapController determines if close enough to an endpoint
        if snapController.endPointActive == true || snapController.centerPointActive == true{
            snapController.entityDB = masterEntityTable.entityArray
            snapController.mouseCoords = mouseViewCoords
            display()
        }
        
        
        //drawTempLine will be true when the user is in the middle of a "line" command
        //It is set true in the splitview in this case, because the split view is set to be
        //both a MWCommandController and a MWDrawingSpaceController, which allow interaction
        //between the two controls.
        if drawTempLine == true{
            tempLine.modelLine.endPt = convertFromViewToModelPt(mouseViewCoords, zoomScale: gCadTransforms.zoomScale, transPt: gCadTransforms.scaledTrans)
            
            tempLine.ct = gCadTransforms
            
            display()
        
        }
        
        if drawTempCircle == true{
            
            let radiusPtModel = convertFromViewToModelPt(mouseViewCoords, zoomScale: gCadTransforms.zoomScale, transPt: gCadTransforms.scaledTrans)
            
            let deltaX = radiusPtModel.x - tempCircle.modelCircle.centerPt.x
            
            let deltaY = radiusPtModel.y - tempCircle.modelCircle.centerPt.y
            
            let dist = CGFloat(sqrt(pow(deltaX,2) + pow(deltaY, 2)))
            
            tempCircle.modelCircle.radius = dist
            
            tempLine.ct = gCadTransforms
            
            display()
        }
        
        if drawTempArcStartPtSet == true && drawTempArcEndPtSet == false {
            
            let arcModelEndPt = convertFromViewToModelPt(mouseViewCoords, zoomScale: gCadTransforms.zoomScale, transPt: gCadTransforms.scaledTrans)
            
            let deltaX = arcModelEndPt.x - tempArc.modelArc.startPt.x
            let deltaY = arcModelEndPt.y - tempArc.modelArc.startPt.y
            let dist = CGFloat(sqrt(pow(deltaX,2) + pow(deltaY, 2)))
            let tempRadius = 0.80 * dist
            
            tempArc.modelArc.endPt = arcModelEndPt
            tempArc.modelArc.radius = tempRadius
            
            tempArc.ct = gCadTransforms
            
            guard arcModelEndPt != tempArc.modelArc.startPt else{
                return
            }
            
            display()
            
        }else if drawTempArcEndPtSet == true && drawTempArcEndPtSet == true {
             let radiusPtModel = convertFromViewToModelPt(mouseViewCoords, zoomScale: gCadTransforms.zoomScale, transPt: gCadTransforms.scaledTrans)
            //find the min allowed radius
            let deltaX = tempArc.modelArc.endPt.x - tempArc.modelArc.startPt.x
            let deltaY = tempArc.modelArc.endPt.y - tempArc.modelArc.startPt.y
            let minRadModel = CGFloat(sqrt(pow(deltaX,2) + pow(deltaY, 2))) / 1.99
            
            let maxRadModel = CGFloat(sqrt(pow(deltaX,2) + pow(deltaY, 2))) / 0.002
            
            
            //set the radius based on the mouse location
            let dX = radiusPtModel.x - tempArc.modelArc.endPt.x
            let dY = radiusPtModel.y - tempArc.modelArc.endPt.y
            
            let mouseBasedRadModel = CGFloat(sqrt(pow(dX,2) + pow(dY, 2)))
            
            Swift.print("Calculated R = \(mouseBasedRadModel), minR = \(minRadModel)")
            
            if mouseBasedRadModel > minRadModel && mouseBasedRadModel < maxRadModel{
               tempArc.modelArc.radius = mouseBasedRadModel
            }else if mouseBasedRadModel <= minRadModel{
                tempArc.modelArc.radius = minRadModel
            }else if mouseBasedRadModel >= maxRadModel{
                tempArc.modelArc.radius =  maxRadModel
            }
            
            Swift.print("dY = \(dY)")
            if dY < 0{
                tempArc.isClockwise = false
                Swift.print("tempArc.viewArc.isClockwise: \(tempArc.isClockwise)")
            }else{
                tempArc.isClockwise =  true
               
            }
            Swift.print("tempArc.viewArc.isClockwise: \(tempArc.isClockwise)")
            
            tempArc.ct = gCadTransforms
            display()
        }
        
        
        
        if drawTempMoveEntities == true{
            //we need to find the delta
            
            let basePt = tempLine.modelLine.startPt
            let secondPt = convertFromViewToModelPt(mouseViewCoords, zoomScale: gCadTransforms.zoomScale, transPt: gCadTransforms.scaledTrans)
            let deltaX = secondPt.x - basePt.x
            let deltaY = secondPt.y - basePt.y
            let delta = NSMakePoint(deltaX, deltaY)
            
            //Swift.print("dx: \(deltaX), dy: \(deltaY)")
            
            tempMoveEntityTable = tableCopy(selectedEntityTable)

            tempMoveEntityTable.moveArrayOfHandles(tempMoveEntityTable.handlesAsArray, delta: delta)
            
            display()
        }
        
        
        
        
    }
    
    
    //MARK: Utility Functions
    override var acceptsFirstResponder: Bool {
        return true
    }
    
    func setTestArc(){
        let ptArray1 = [NSMakePoint(200, 1000), NSMakePoint(250, 1020)]
        let testArc = MWArc(thePointDefArray: ptArray1, theLengthDef:90)
        //addEntity(testArc as MWEntity)
    }
    
    func setTestLines(){
        
        let ptArray1 = [NSMakePoint(200, 1000), NSMakePoint(250, 1020)]
        let tempLine1 = MWLine(thePointDefArray: ptArray1, theLengthDef: 0)
        
        let ptArray2 = [NSMakePoint(100, 3000), NSMakePoint(400, 100)]
        let tempLine2 = MWLine(thePointDefArray: ptArray2, theLengthDef: 0)
        
//        let testLine1 = MWCadLine(theModelLine: tempLine1)
//        let testLine2 = MWCadLine(theModelLine: tempLine2)
        
        addEntity(tempLine1 as MWEntity)

        addEntity(tempLine2 as MWEntity)
        
        
        //this throws in a bunch of lines for testing
//        for var i:Int = 0 ; i < 100; ++i {
//            let ptArray1 = [NSMakePoint(CGFloat(i + i), CGFloat(i + i)), NSMakePoint(CGFloat(200 - 4 * i), CGFloat(1000 + 2 * i))]
//            let tempLine1 = MWLine(thePointDefArray: ptArray1, theLengthDef: 0)
//            let testLine1 = MWCadLine(theModelLine: tempLine1)
//            masterEntityTable.appendEntity(testLine1)
//            unselectedEntityTable.appendEntity(testLine1)
//        }
        
        
    }
    
    func min3<T:Comparable>(_ a:T, b:T, c:T)->T{
        var returnVal = a
        if a <= b && a <= c{
            returnVal = a
        }else if b < a && b < c{
            returnVal = b
        }else if c < a && c < b{
            returnVal = c
        }
        return returnVal
    }
    
    func max3<T:Comparable>(_ a:T, b:T, c:T)->T{
        var returnVal = a
        if a >= b && a >= c{
            returnVal = a
        }else if b > a && b > c{
            returnVal = b
        }else if c > a && c > b{
            returnVal = c
        }
        return returnVal
    }
    
    
    override func mouseEntered(with theEvent: NSEvent) {
        
        super.mouseEntered(with: theEvent)
        if currentCommand.name != "none"{
            NSCursor.crosshair().set()
        }
    }
    
    override func mouseExited(with theEvent: NSEvent) {
        super.mouseEntered(with: theEvent)
        if currentCommand.name != "none"{
            NSCursor.crosshair().set()
            
        }
    }
    
    func updateEntityTransforms(_ entityTable: MWCadEntityCollection){
        for (_, var entity) in entityTable.entities{
            entity.ct = gCadTransforms
            
        }
    }
    
    
    
    
    func convertFromViewToModelPt(_ viewPt:NSPoint, zoomScale:CGFloat, transPt:NSPoint) -> NSPoint{
        var modelPoint = NSPoint()
        
        modelPoint.x = (viewPt.x + transPt.x) / zoomScale
        modelPoint.y = (viewPt.y + transPt.y) / zoomScale
        
        return modelPoint
        
    }
    
    func convertFromModelToViewPt(_ modelPt:NSPoint, zoomScale:CGFloat, transPt:NSPoint) -> NSPoint{
        var viewPt = NSPoint()
        
        viewPt.x = (modelPt.x * zoomScale) - transPt.x
        viewPt.y = (modelPt.y * zoomScale) - transPt.y
        
        return viewPt
        
    }
    
    //MARK: VIEW FUNCTIONS
    
    override func scrollWheel(with theEvent: NSEvent) {
        
        guard masterEntityTable.entityArray.count > 0 else{
            return
        }
        
        var scaleChange:CGFloat = 0
        let prevZoomScale = gCadTransforms.zoomScale
        if theEvent.deltaY > 0{
            if gCadTransforms.zoomScale >= 0.1{
                scaleChange = prevZoomScale * 0.02
            }else{
                scaleChange = prevZoomScale * 0.02
            }
        }else if theEvent.deltaY < 0{
            if gCadTransforms.zoomScale >= 0.1{
            scaleChange = prevZoomScale * -0.02
            }else{
                scaleChange = prevZoomScale * -0.02
            }
        }
        
        if scaleChange != 0  && (gCadTransforms.zoomScale + scaleChange) > 0 {
            let transformData = transformCalcs.calculateScrollZoomData(mouseViewCoords, scaleChange: scaleChange, exZoomScale: gCadTransforms.zoomScale, exTrans: gCadTransforms.scaledTrans, testLine: masterEntityTable.entityArray[0])
            
            gCadTransforms.zoomScale = transformData.zoomScale
            gCadTransforms.scaledTrans = transformData.trans
            
            updateEntityTransforms(masterEntityTable)
            updateEntityTransforms(unselectedEntityTable)
            display()
        }
        
    }
    
    func pan(_ horizontal:Bool, val:CGFloat){
        if horizontal == true{
            gCadTransforms.scaledTrans.x = gCadTransforms.scaledTrans.x + val
        }else{
            gCadTransforms.scaledTrans.y = gCadTransforms.scaledTrans.y + val
        }
        
        updateEntityTransforms(masterEntityTable)
        updateEntityTransforms(unselectedEntityTable)
        display()
    }
    
    func zoomExtents(){
        let transformData = transformCalcs.calculateZExtentData(masterEntityTable.entityArray, viewBounds: self.bounds)
        gCadTransforms.zoomScale = transformData.zoomScale
        gCadTransforms.scaledTrans = transformData.trans
        
        updateEntityTransforms(masterEntityTable)
        updateEntityTransforms(unselectedEntityTable)
        display()
    }
    
    
    //vars for 3 finger drag i.e. pan
    var touchStart = NSPoint()
    var touchMid = NSPoint()
    var runningDelta = NSPoint(x:0, y:0)
    var fireCount:Int = 0
    //vars for 3 finger drag i.e. pan
    

        override func touchesBegan(with event: NSEvent) {
            let theTouches:NSSet = event.touches(matching: .moved, in: self) as NSSet
            let touchArray:NSArray = theTouches.allObjects as NSArray
           fireCount = 0
            
            if touchArray.count == 3{
                //do nothing this was a three finger drag
            }
            
            if touchArray.count == 2{
                //maybe do something it could be a pinch
               
            }
            
            if touchArray.count == 1{
                
            }
        }
    
        override func touchesMoved(with event: NSEvent) {
            let theTouches:NSSet = event.touches(matching: .moved, in: self) as NSSet
            let touchArray:NSArray = theTouches.allObjects as NSArray
        

            
            if touchArray.count == 3{// code for a 3 finger drag, i.e. pan
            
                if fireCount == 0{
                    touchStart = (touchArray[0] as AnyObject).normalizedPosition
                    fireCount += 1
                }else{
                    touchMid = (touchArray[0] as AnyObject).normalizedPosition
                    let dx:CGFloat = touchMid.x - touchStart.x
                    let dy:CGFloat = touchMid.y - touchStart.y
                    //Swift.print("moved dx: \(dx), dy: \(dy)")
                    
                    runningDelta.x += dx
                    runningDelta.y += dy
                    
                    gCadTransforms.scaledTrans.x -= dx * 2000 //whole.width
                    gCadTransforms.scaledTrans.y -= dy * 2000 //whole.height
                    
                     Swift.print("transY = \(gCadTransforms.scaledTrans.y)")
                    
                    touchStart = touchMid
                    fireCount += 1
                    
                    if abs(runningDelta.x) > 0.015 || abs(runningDelta.y) > 0.015{
                        updateEntityTransforms(masterEntityTable)
                        updateEntityTransforms(unselectedEntityTable)
                        display()
                        
                        runningDelta.x = 0
                        runningDelta.y = 0
                    }
                }
            }
            
        }
    
    override func touchesEnded(with event: NSEvent) {
        let theTouches:NSSet = event.touches(matching: .moved, in: self) as NSSet
        let touchArray:NSArray = theTouches.allObjects as NSArray
        
        
        if touchArray.count == 3{
            updateEntityTransforms(masterEntityTable)
            updateEntityTransforms(unselectedEntityTable)
            
            display()
            
            Swift.print("transY = \(gCadTransforms.scaledTrans.y)")
        }
        
        fireCount = 0
        runningDelta.x = 0
        runningDelta.y = 0
        
    
    }
    
    
    //MARK:Protocol Functions
    func setFocus(){
       self.window?.makeFirstResponder(self)
    }
    
    func makeCurrentCommand(_ command:MWCadCommand){
         currentCommand = command
    }
    
    func mySetTempLine(_ line:MWCadLine){
        line.ct = gCadTransforms
        tempLine = line
    }
    
    func mySetDrawTempLine(_ theBool:Bool){
        drawTempLine = theBool
    }
    
    func mySetTempCircle(_ circle:MWCadCircle){
        circle.ct = gCadTransforms
        tempCircle = circle
    }
    
    func mySetDrawTempCircle(_ theBool:Bool){
        drawTempCircle = theBool
    }
    
    func mySetTempArc(_ arc:MWCadArc){
        arc.ct = gCadTransforms
        tempArc = arc
    }
    
    func mySetDrawTempArc(_ theBool:Bool, endSet:Bool){
        drawTempArcStartPtSet = theBool
        drawTempArcEndPtSet = endSet
    }
    
    func modifyTempEndPt(_ newEndPoint:NSPoint, isDelta:Bool)-> NSPoint{
        var realEndPt = NSPoint()
        if isDelta == false{
            realEndPt = newEndPoint
            tempLine.modelLine.endPt = newEndPoint
        }else{
            realEndPt.x = tempLine.modelLine.startPt.x + newEndPoint.x
            realEndPt.y = tempLine.modelLine.startPt.y + newEndPoint.y
            tempLine.modelLine.endPt = realEndPt
        }
        
        return realEndPt
    }
    
    func modifyTempCircleRadiusPt(_ newRadiusPt:NSPoint, isDelta:Bool){
        if isDelta == false{
            let EndPt = newRadiusPt
            let StartPt = tempCircle.modelCircle.centerPt
            
            let deltaX = EndPt.x - StartPt.x
            let deltaY = EndPt.y - StartPt.y
            
            let dist = CGFloat(sqrt(pow(deltaX,2) + pow(deltaY, 2)))
            tempCircle.modelCircle.radius = dist
            
        }else{
            var deltaRadiusPt = NSPoint()
            deltaRadiusPt.x = tempCircle.modelCircle.centerPt.x + newRadiusPt.x
            deltaRadiusPt.y = tempCircle.modelCircle.centerPt.y + newRadiusPt.y
            
            let EndPt = deltaRadiusPt
            let StartPt = tempCircle.modelCircle.centerPt
            
            let deltaX = EndPt.x - StartPt.x
            let deltaY = EndPt.y - StartPt.y
            
            let dist = CGFloat(sqrt(pow(deltaX,2) + pow(deltaY, 2)))
            tempCircle.modelCircle.radius = dist
        }
    }
    
    func modifyTempArcRadius(_ newModelRadius:CGFloat, isClockwise:Bool){
        //let viewRadius = newViewRadius * gCadTransforms.zoomScale
        tempArc.modelArc.radius = newModelRadius
        tempArc.isClockwise = isClockwise
    }
    
    func addEntity(_ theEntity:MWEntity){
        if theEntity.kind == "line"{
            let newEntity = MWCadLine(theModelLine: theEntity as! MWLine, cadTransform: gCadTransforms)
            masterEntityTable.appendEntity(newEntity)
            unselectedEntityTable.appendEntity(newEntity)
        }else if theEntity.kind == "circle"{
            let newEntity = MWCadCircle(theModelCircle: theEntity as! MWCircle, cadTransform: gCadTransforms)
            masterEntityTable.appendEntity(newEntity)
            unselectedEntityTable.appendEntity(newEntity)
        }else if theEntity.kind == "arc"{
            let newEntity = MWCadArc(theModelArc: theEntity as! MWArc, cadTransform: gCadTransforms)
            masterEntityTable.appendEntity(newEntity)
            unselectedEntityTable.appendEntity(newEntity)
        }
        
    }
    
    func addEntityArray(_ entities:[MWEntity]){
        for i:Int in 0  ..< entities.count{
            addEntity(entities[i])
        }
    }
    
    func appendLineListWithTemp(){
        masterEntityTable.appendEntity(tempLine)
        unselectedEntityTable.appendEntity(tempLine)
    }
    
    func appendCircleListWithTemp(){
        masterEntityTable.appendEntity(tempCircle)
        unselectedEntityTable.appendEntity(tempCircle)
    }
    
    func appendArcListWithTemp() {
        masterEntityTable.appendEntity(tempArc)
        unselectedEntityTable.appendEntity(tempArc)
    }

    func remoteDisplay(){
        self.display()
    }
    
    func remoteEnableCursorRects() {
      self.window?.enableCursorRects()
    }
    
    func getTempLineStartPt()->NSPoint{
        let startPt = tempLine.modelLine.startPt
        return startPt
    }
    
    func toggleEndSnap() {
        if snapController.endPointActive == false{
            snapController.endPointActive = true
            snapController.centerPointActive = false
        }else{
            snapController.endPointActive = false
        }
        snapController.mouseCoords = mouseViewCoords
        snapController.entityDB = masterEntityTable.entityArray
        display()
    }
    
    func toggleCenterSnap() {
        if snapController.centerPointActive == false{
            snapController.centerPointActive = true
            snapController.endPointActive = false
        }else{
            snapController.centerPointActive = false
        }
        snapController.mouseCoords = mouseViewCoords
        snapController.entityDB = masterEntityTable.entityArray
        display()
    }
    
    func adjustTablesOnEntitySelection(_ handle:Int){
        guard handle > -1 else{
            Swift.print("Nothing Selected")
            return
        }
        
        
        let tempEntityTable = tableCopy(masterEntityTable) //should be a copy of the dictionary
        
        let entity:MWCadEntity = tempEntityTable.entities[handle]!
        
        selectedEntityTable.entities[handle] = entity
        unselectedEntityTable.entities[handle] = nil
        
        
    }
    
    func adjustTablesOnSelectionClear(){
        
        unselectedEntityTable = tableCopy(masterEntityTable)
        selectedEntityTable.entities.removeAll()
        tempMoveEntityTable.entities.removeAll()
    }
    
    func getselectedEntityTable()->MWCadEntityCollection{
        return self.selectedEntityTable
    }
    
    func cancelCommand(){
        makeCurrentCommand(cadCommandList.commands["noCommand"]!)
        mySetRenderPickBox(false)
        self.window?.enableCursorRects()
        self.display()
    }
    
    func deleteEntitiesInSelection(){
        guard selectedEntityTable.entities.count > 0 else{
            return
        }
        
        
        var handleArray = [Int]()
        
        for (handle, _) in selectedEntityTable.entities{
            handleArray.append(handle)
        }
        
        masterEntityTable.deleteArrayOfHandles(handleArray)
        selectedEntityTable.deleteArrayOfHandles(handleArray)
    }
    
    func moveEntitiesInSelection(_ delta: NSPoint) {
        guard selectedEntityTable.entities.count > 0 else{
            return
        }
        
        var handleArray = [Int]()
        
        for (handle, _) in selectedEntityTable.entities{
            handleArray.append(handle)
        }
        
        selectedEntityTable.moveArrayOfHandles(handleArray, delta: delta)
        masterEntityTable.moveArrayOfHandles(handleArray, delta: delta)
    }
    
    func copyEntitiesInSelection(_ delta: NSPoint){
        guard selectedEntityTable.entities.count > 0 else{
            return
        }
        
        var handleArray = [Int]()
        for (handle, _) in selectedEntityTable.entities{
            handleArray.append(handle)
        }
        
        //selectedEntityTable.copyArrayOfHandles(handleArray, delta: delta)
        masterEntityTable.copyArrayOfHandles(handleArray, delta: delta)
        unselectedEntityTable = tableCopy(masterEntityTable)
    }
    
    func adjustTempMoveTableOnSelection(_ handle:Int){
        guard handle > -1 else{
            Swift.print("Nothing Selected")
            selectionBoxActive = true
            return
        }
        
        let tempEntityTable = tableCopy(masterEntityTable)
        
        let entity:MWCadEntity = tempEntityTable.entities[handle]!
        
        tempMoveEntityTable.entities[handle] = entity
        
    }
    
    func mySetDrawTempMoveEntities(_ theBool:Bool){
        drawTempMoveEntities = theBool
    }
    
    
    func tableCopy(_ theTable:MWCadEntityCollection)->MWCadEntityCollection{
        
        let newTable = MWCadEntityCollection()
        
        for (var handle, entity) in theTable.entities{
            
            if entity.kind == "line"{
                let oldEntity = entity as? MWCadLine
                let newLine = MWCadLine()
                
                newLine.modelLine.startPt.x = oldEntity!.modelLine.startPt.x
                newLine.modelLine.startPt.y = oldEntity!.modelLine.startPt.y
                newLine.modelLine.endPt.x = oldEntity!.modelLine.endPt.x
                newLine.modelLine.endPt.y = oldEntity!.modelLine.endPt.y
                newLine.ct = oldEntity!.ct
                newLine.handle = handle
                
                newTable.entities[handle] = newLine
                
            }else if entity.kind == "circle"{
               let oldEntity = entity as? MWCadCircle
               let newCircle = MWCadCircle()
                
                newCircle.modelCircle.centerPt.x = oldEntity!.modelCircle.centerPt.x
                newCircle.modelCircle.centerPt.y = oldEntity!.modelCircle.centerPt.y
                newCircle.modelCircle.radius = oldEntity!.modelCircle.radius
                newCircle.ct = oldEntity!.ct
                newCircle.handle = handle
                
                newTable.entities[handle] = newCircle
            }else if entity.kind == "arc"{
                let oldEntity = entity as? MWCadArc
                let newArc = MWCadArc()
                
               
                newArc.modelArc.startPt.x = oldEntity!.modelArc.startPt.x
                newArc.modelArc.startPt.y = oldEntity!.modelArc.startPt.y
                newArc.modelArc.endPt.x = oldEntity!.modelArc.endPt.x
                newArc.modelArc.endPt.y = oldEntity!.modelArc.endPt.y
                newArc.modelArc.radius = oldEntity!.modelArc.radius
                newArc.ct = oldEntity!.ct
                newArc.handle = handle
                
                newTable.entities[handle] = newArc
            }
            
            
        }
        
        return newTable
    }
    
    
    func testAndAdjustForSelectionBox(_ handle:Int){
        if handle == -1{
            selectionBoxActive = true
        }
    }
    
    func mySetSelectionBoxOrigin(_ theModelPt:NSPoint){
        selectionBoxOrigin = convertFromModelToViewPt(theModelPt, zoomScale: gCadTransforms.zoomScale, transPt: gCadTransforms.scaledTrans)
    }
    
    func mySetSelectionBoxActive(_ theBool: Bool) {
        selectionBoxActive = theBool
        
        if theBool == false{
            renderLeftRightSelectionBox = false
            renderRighLeftSelectionBox = false
        }
    }
    
    func mySetRenderPickBox(_ theBool:Bool){
        renderPickBox = theBool
    }
    
  
    
    
    
}
