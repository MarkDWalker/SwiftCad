//
//  NSTextView_Extension.swift
//  DrawingSpace_CustomTransforms_V0.0.3
//
//  Created by Mark Walker on 1/26/16.
//  Copyright © 2016 Mark Walker. All rights reserved.
//

import Cocoa

extension NSTextView{
    
    func findAndHighlightString(_ theString:String){
        let containerString = self.textStorage?.string
        
        let range = containerString?.findFirstMatchingString(theString, startLoc: 0)
        
        guard range?.length != 0 else{
            return
        }
        
        highlightRange(range!)
    }
    
    
    
    func highlightRange(_ range:NSRange){
        
        //let myFont:NSFont = NSFont(name: "Marker Felt Thin", size: 16)!
        
        
        //self.setFont(myFont, range:myRange)
        
        
        
        
        self.textStorage?.addAttribute(NSForegroundColorAttributeName, value: NSColor.blue, range: range)
        
        self.textStorage?.addAttribute(NSBackgroundColorAttributeName, value: NSColor.yellow, range: range)
        
    }
    
    
}
