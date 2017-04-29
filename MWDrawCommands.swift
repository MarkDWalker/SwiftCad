//
//  MWDrawCommands.swift
//  DrawingSpaceControl_UsingCustomTransforms
//
//  Created by Mark Walker on 12/27/15.
//  Copyright © 2015 Mark Walker. All rights reserved.
//

import Cocoa

enum commandsEnum:String{
    case line = "line"
}


class MWDrawCommands: NSObject {
    
    var commandList = [String]()
    
    override init(){
        super.init()
        
        commandList.append("line")
        
        
    }
    
    
    func checkCommandIsValid(_ commandString:String) -> Bool{
        var returnBool = false
        
        for i:Int in 0  ... commandList.count-1{
            if commandList[i] == commandString{
                returnBool = true
            }
        }
        
        return returnBool
    }
    
    
}
