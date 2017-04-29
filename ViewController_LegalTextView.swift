//
//  ViewController_LegalTextView.swift
//  DrawingSpace_CustomTransforms_V0.0.3
//
//  Created by Mark Walker on 1/25/16.
//  Copyright © 2016 Mark Walker. All rights reserved.
//

import Cocoa

@objc protocol MWProgressIndicator{
    var progressBar:NSProgressIndicator! { get set }
    var progressLabel:NSTextField! {get set}
    var progressBarMin:Int { get set}
    var progressBarMax:Int {get set}
    func setProgress(_ byVal:Double)
    func refreshLabel()
    
}

class ViewController_LegalTextView: NSViewController, MWProgressIndicator {
    
    var drawingController:MWDrawingController?
    var inputPanelDelegate:MWInputController?
    
    
    @IBOutlet var theTextView: NSTextView!
    
    @IBOutlet weak var progressBar: NSProgressIndicator!
    
    @IBOutlet weak var progressLabel: NSTextField!
    
    var rules = MWSurveyCallRules()
    
    var reader = MWDescriptionReader()
    
    var progressBarMin:Int{
        get{
            return self.progressBarMin
        }
        set(val){
            self.progressBarMin = val
        }
    }
    
    var progressBarMax:Int{
        get{
            return self.progressBarMax
        }
        set(val){
            self.progressBarMax = val
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        reader.progressBarDelegate = self
    }
    
    @IBAction func highlightCalls_Click(_ sender: AnyObject) {
        //theTextView.findAndHighlightString("mark")
        Swift.print("It fired")
        
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
        self.reader.legalDescription = (self.theTextView.textStorage?.string)!
        let returnVal = self.reader.getAllPotentialCalls()
        
        var entityArray = [MWEntity]()
        var newEntityOrigin =  NSMakePoint(0, 0)
        
        guard let dsd = self.drawingController else{
            return
        }
        
        for i:Int in 0 ... returnVal.foundCalls.count-1{
            let theCall = self.reader.verifyCallIsGood(returnVal.foundCalls[i])
            self.progressBar.doubleValue = (Double(i+1) / Double(returnVal.foundCalls.count)) * 100
            if theCall.isGood{
                self.theTextView.highlightRange(returnVal.callRanges[i])
                
                let newLine = MWLine(call: theCall.call, origin: newEntityOrigin)
                let newEntity = newLine as MWEntity
                entityArray.append(newEntity)
                
                newEntityOrigin = newLine.endPt
                
            }
        }
        
        
        //add the entities to the drawing
        dsd.addEntityArray(entityArray)
        dsd.remoteDisplay()
        dsd.zoomExtents()
        }
        
    }
    
    
    func setProgress(_ byVal:Double){
        //progressBar.incrementBy(Double(byVal))
        
    }
    
    func refreshLabel() {
        self.progressLabel.display()
    }
    
    
    
}
