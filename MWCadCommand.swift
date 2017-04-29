//
//  MWCadCommand.swift
//  DrawingSpace_CustomTransforms_V0.0.2
//
//  Created by Mark Walker on 1/3/16.
//  Copyright © 2016 Mark Walker. All rights reserved.
//

import Cocoa



class MWCadCommand: NSObject {
    var name:String = "none"
    var acceptsPtInput:Bool = false
    var acceptsAngleDistInput:Bool = false
    var acceptsObjectSelection:Bool = false
    var endSelectionOnReturn:Bool = false
    var endCommandOnReturn:Bool = false
    var commandStatus = MWCommandStatusEnum.awaitingUserInput
    
    var commandSequence:MWCommandSequence?
    
    
    
    init(name:String, acceptsPtInput:Bool, acceptsAngleDistInput:Bool){
        super.init()
        self.name = name
        self.acceptsPtInput = acceptsPtInput
        self.acceptsAngleDistInput = acceptsAngleDistInput
    }
    
    override init(){
        super.init()
    }
    
//        func sharePoint(modelPt:NSPoint) {
//            commandSequence!.makePickedPoint(modelPt)
//            commandSequence!.runCommandSequence(self)
//        }

}
