
//
//  MWCommandControl.swift
//  DrawingSpaceControl_UsingCustomTransforms
//
//  Created by Mark Walker on 12/27/15.
//  Copyright © 2015 Mark Walker. All rights reserved.
//

import Cocoa
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
private func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
private func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
private func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}


protocol MWInputController{
    func prepareNewLine()
    func outputText(_ outPut:String)
    func setFocusWithChar(_ keyPressed:String)
    func setCommandStatus(_ newStatus:MWCommandStatusEnum)
    func makeCurrentCommand(_ command:MWCadCommand)
    func makeLastMainCommand(_ command:MWCadCommand)
    func cancelCommand()
    func endCommand()
}

class MWCommandControl: NSTextView, MWInputController {

    //call functions in the MWLineSequence Object
    //var lineCommandSequenceDelegate:MWLineCommandDelegate?
    //var idCommandSequenceDelegate:MWIDCommandDelegate?
    
    var drawingController:MWDrawingController?
    //var legalTextViewController:MWLegalTextViewController?
    
    var parentVC:ChildControlAccessibleViewController?
    
    var endCommandChar:String = ">"
    
    //the list of commands
    var cadCommandList = MWCadCommandList()
    
    var commandStatus = MWCommandStatusEnum.noCommand
    
    var currentCommand = MWCadCommand()
    var lastMainCommand = MWCadCommand()
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    func addBasePrompt(){
        let attr = NSAttributedString(string: "Command>")
        self.textStorage?.append(attr)
        
        //    [_myTextView scrollRangeToVisible:NSMakeRange([[_myTextView string] length], 0)];
    }
    

    
    override func keyUp(with theEvent: NSEvent) {
        
        if theEvent.keyCode == 53{ //escape press
            //theCommandHasBeenCanceled
            guard let dsd = drawingController else{
                return
            }
            
            guard let commandSequence = currentCommand.commandSequence else{
                self.cancelCommand()
                dsd.cancelCommand()
                return
            }
            
            self.cancelCommand()
            dsd.cancelCommand()
            commandSequence.cancelMidCommand()
            
            
            
            
            
        }
        
        if theEvent.keyCode == 36{
            insertEndingCharacter()
            
            
            let enteredText = getCommandString()
            
            if enteredText == "descriptionEditor"{
                parentVC?.performSegueWithIdentifier(identifier: enteredText, sender: self)
                return
            }
            
            if enteredText == "" && lastMainCommand != cadCommandList.commands["noCommand"]{
                
                currentCommand = lastMainCommand
                guard let theSequence = currentCommand.commandSequence else{
                    return
                }
                theSequence.runCommandSequence(currentCommand)
                self.prepareNewLine()
            
            }else if currentCommand.commandStatus == .noCommand { //we need to evaluate for commands
                
                guard let com = cadCommandList.commands[enteredText] else{
                    self.prepareNewLine()
                    self.outputText("unrecognized command/")
                    self.prepareNewLine()
                    return
                }
                currentCommand = com
                lastMainCommand = currentCommand
                guard let theSequence = com.commandSequence else{
                    return
                }
                theSequence.runCommandSequence(currentCommand)
                self.prepareNewLine()
                
            }else if currentCommand.commandStatus == .awaitingUserInput{
                if currentCommand.acceptsPtInput == true && currentCommand.acceptsAngleDistInput == false{
                    let userInput = getCommandString()
                    
                    let userPtValid = getPointFromCommandLine(userInput).isValid
                    let enteredPt = getPointFromCommandLine(userInput).pt
          
                    guard userPtValid else{
                        return
                    }
                    
                    guard let theSequence = currentCommand.commandSequence else{
                        return
                    }
                    
                    theSequence.makePickedPoint(enteredPt, isDelta: false)
                    theSequence.runCommandSequence(currentCommand)
                }else if currentCommand.acceptsPtInput == true && currentCommand.acceptsAngleDistInput == true{
                    let userInput = getCommandString()
                    let userPtValid = getPointFromCommandLine(userInput).isValid
                    let userAngleDistValid = getDistAngleFromCommandLine(userInput).isValid
                    
                    guard userPtValid || userAngleDistValid else{
                        self.prepareNewLine()
                        self.outputText("invalid text entry")
                        self.prepareNewLine()
                        return
                    }
                    
                    guard let theSequence = currentCommand.commandSequence else{
                        return
                    }
                   
                    var enteredPt = NSPoint()
                    if userPtValid{
                        
                        enteredPt = getPointFromCommandLine(userInput).pt
                        theSequence.makePickedPoint(enteredPt, isDelta: false)
                    }else if userAngleDistValid{
                        enteredPt = getDistAngleFromCommandLine(userInput).delatPt
                        theSequence.makePickedPoint(enteredPt, isDelta: true)
                    }
                    
                    theSequence.runCommandSequence(currentCommand)
                }else if currentCommand.acceptsObjectSelection == true{
                    guard let theSequence = currentCommand.commandSequence else{
                        return
                    }
                    theSequence.runCommandSequence(currentCommand)
                }
            }
        }
    }
    
    
    
    func insertEndingCharacter(){
        let insertionPoint = self.selectedRanges[0].rangeValue.location
        insertText(endCommandChar, replacementRange: NSMakeRange(insertionPoint-1, 1))
    }
    
    func getCommandString() -> String{
        let wholeString:NSString = (self.textStorage?.string)! as NSString
        
        //find the location of the special ">" Char
        let rangeLength = 1
        var rangePosition = 0
        var obtainedLetter:String = "x"
        
        repeat{
            setSelectedRange(NSMakeRange(rangePosition, rangeLength))
            obtainedLetter = wholeString.substring(with: selectedRange()) as String
            rangePosition += 1
            
        }while(obtainedLetter != endCommandChar)
        
        let totalRangeLength = rangePosition - 1
        let command = wholeString.substring(with: NSMakeRange(0, totalRangeLength))
        
        Swift.print("Command> \(command)")
        
        return command
    }
    
    func prepareNewLine(){
        self.moveToBeginningOfDocument(self)
        self.insertNewline(self)
        self.moveToBeginningOfDocument(self)
    }
    
    func outputText(_ outPut:String){
        
        self.insertText(outPut, replacementRange: NSMakeRange(0, 0))
        
    }
    
    func setFocusWithChar(_ keyPressed: String) {
        self.window?.makeFirstResponder(self)
        self.insertText(keyPressed, replacementRange: NSMakeRange(0,0))
    }
    
    func setCommandStatus(_ newStatus:MWCommandStatusEnum){
        commandStatus = newStatus
    }
   
    func makeCurrentCommand(_ command:MWCadCommand){
        currentCommand = command
    }
    
    func makeLastMainCommand(_ command:MWCadCommand){
        lastMainCommand = command
    }
    
    func getPointFromCommandLine(_ userInput:String)-> (pt : NSPoint , isValid : Bool){
        var thePoint = NSPoint()
        let input = userInput //userInput[0...userInput.characters.count-1]
        //find the position of the comma
        let commaPosition:Int = input.findFirstChar(",")
        
        guard commaPosition > 0 && commaPosition < userInput.characters.count - 1 else{
            return (thePoint, false)
        }
        
        let subString1:String = String.init(input.characters.prefix(commaPosition-1)) //input[0...commaPosition-1]
        let substring2:String = String.init(input.characters.suffix(input.characters.count - commaPosition + 1))
        //input[commaPosition+1...input.characters.count-1]
        
        
        let x = subString1.CGFloatValue //if not a valid float then func will return -10000
        guard x != -10000 else{
            return (thePoint, false)
        }
        
        let y = substring2.CGFloatValue //if not a valid float then func will return -10000
        guard  y != -10000 else{
            return (thePoint, false)
        }
        
        thePoint.x = x!
        thePoint.y = y!
        Swift.print("Input was: \(input)")
        Swift.print("x: \(x) , y: \(y)")
        return (thePoint, true)
    }
    
    func getDistAngleFromCommandLine(_ userInput:String) -> (delatPt : NSPoint, isValid : Bool){
        var thePoint = NSPoint()
        let input = userInput //userInput[0...userInput.characters.count-1]
        
        let symbolPosition = input.findFirstChar("<")
        
        guard symbolPosition > 0 && symbolPosition < userInput.characters.count - 1 else{
            return (thePoint, false)
        }
        
        let iDist1 = input.index(input.startIndex, offsetBy: 1)
        let iDist2 = input.index(input.startIndex, offsetBy: symbolPosition - 1)
        let dist = String.init(input[iDist1...iDist2])
        
        let iAng1 = input.index(input.startIndex, offsetBy: symbolPosition + 1)
        let iAng2 = input.index(input.endIndex, offsetBy: -1)
        let angle = String.init(input[iAng1...iAng2])
        
        
        
        guard input[0] == "@" else{
            return (thePoint, false)
        }
        
        let d = dist?.CGFloatValue
        guard  d != -10000 else{ //if not a valid float then func will return -10000
            return (thePoint, false)
        }
        
        //before we check for a regular angle we need to check to see if we can get an angle from a bearing input
        let bearingCheck = getAngleFromBearingInput(angle!)
        if bearingCheck.isValid == true{
            thePoint = calcDeltasFromAngleDist(bearingCheck.angle, dist: d!)
            return (thePoint,true)
        }
        
        let a = angle?.CGFloatValue
        guard a != -10000 else { //if not a valid float then func will return -10000
            return (thePoint, false) // do not really need this guard due to the next gaurd
        }
        
        guard a >= 0 && a <= 360 else{
            return (thePoint, false)
        }
        
        
        thePoint = calcDeltasFromAngleDist(a!, dist: d!)
        return (thePoint,true)
        
    }
    
    func getAngleFromBearingInput(_ userInput:String)->(isValid:Bool, angle:CGFloat){
        
        
        var returnAngle:CGFloat = -1
        
        guard userInput.characters.count >= 11 else{
            return (false, returnAngle)
        }
        
        let input = userInput//[0...userInput.characters.count-1]
        
        let startDirection:String = input[0]
        let endDirection:String = input[userInput.characters.count-1]
        
        let dPosition = input.findFirstChar("d")
        guard dPosition != -1 else{
           return (false, returnAngle)
        }
        
        let mPosition = input.findFirstChar("m")
        guard mPosition != -1 else {
            return (false, returnAngle)
        }
        
        let sPosition = input.findFirstChar("\"")
        guard sPosition != -1 else{
            return (false, returnAngle)
        }
        
        let degreesString:String = String.init(input.characters.prefix(dPosition-1))//input[1...dPosition - 1]
        
        let im1 = input.index(input.startIndex, offsetBy: dPosition + 1)
        let im2 = input.index(input.startIndex, offsetBy: mPosition - 1)
        
        let minutesString:String = input[im1...im2]
        
        let is1 = input.index(input.startIndex, offsetBy: mPosition + 1)
        let is2 = input.index(input.startIndex, offsetBy: sPosition - 1)
        
        let secondsString:String = input[is1...is2]
        
        
        guard startDirection == "N" || startDirection == "n" || startDirection == "S" || startDirection == "s" else {
            return (false, returnAngle)
        }
        
        if endDirection == "E" || startDirection == "e" || startDirection == "W" || startDirection == "w" {
            return (false, returnAngle)
        }
        
        
        let degrees = degreesString.CGFloatValue
        guard degrees != -10000 else { //if not a valid float then func will return -10000
            return (false, returnAngle)
        }
        
        
        let minutes = minutesString.CGFloatValue
        guard minutes != -10000 else { //if not a valid float then func will return -10000
            return (false, returnAngle)
        }
        
        let seconds = secondsString.CGFloatValue
        guard seconds != -10000 else { //if not a valid float then func will return -10000
            return (false, returnAngle)
        }
        
        let degreesFloat = degrees! + minutes! / 60 + seconds! / 3600
        
        if (startDirection == "N" || startDirection == "n") && (endDirection == "E" || endDirection == "e"){
            returnAngle = 90 - degreesFloat
        }else if (startDirection == "N" || startDirection == "n") && (endDirection == "W" || endDirection == "w"){
            returnAngle = 90 + degreesFloat
        }else if (startDirection == "S" || startDirection == "s") && (endDirection == "W" || endDirection == "w"){
            returnAngle = 270 - degreesFloat
        }else if (startDirection == "S" || startDirection == "s") && (endDirection == "E" || endDirection == "e"){
            returnAngle = 270 + degreesFloat
        }
        
        return (true, returnAngle)
    }
    
    func calcDeltasFromAngleDist(_ angle:CGFloat, dist:CGFloat) -> NSPoint{
        var pt = NSPoint()
        
       
        
        if angle >= 0 && angle <= 90{
            pt.x = cos(degToRad(angle)) * dist
            pt.y = sin(degToRad(angle)) * dist
            
        }else if angle > 90 && angle <= 180{
            pt.x = -sin(degToRad(angle - 90)) * dist
            pt.y = cos(degToRad(angle - 90)) * dist
            
        }else if angle > 180 && angle <= 270{
            pt.x = -cos(degToRad(angle - 180)) * dist
            pt.y = -sin(degToRad(angle - 180)) * dist
            
        }else if angle > 270 && angle <= 360{
            pt.x = sin(degToRad(angle - 270)) * dist
            pt.y = -cos(degToRad(angle - 270)) * dist
        }
        
        
        return pt
    }
    
    func degToRad(_ deg:CGFloat) -> CGFloat{
        return deg * CGFloat(Double.pi) / 180.00
    }
    
    func cancelCommand(){
        prepareNewLine()
        outputText("Command Canceled")
        prepareNewLine()
        makeCurrentCommand(cadCommandList.commands["noCommand"]!)
        setCommandStatus(MWCommandStatusEnum.noCommand)
    }
    
    func endCommand(){
        prepareNewLine()
        outputText("Command Complete")
        prepareNewLine()
        makeCurrentCommand(cadCommandList.commands["noCommand"]!)
        setCommandStatus(MWCommandStatusEnum.noCommand)
    }
    
   
    
}
