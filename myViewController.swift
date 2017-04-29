//
//  ViewController.swift
//  DrawSpaceControlUsing_stockTransforms
//
//  Created by Mark Walker on 9/26/15.
//  Copyright © 2015 Mark Walker. All rights reserved.
//

import Cocoa
protocol DrawingSpaceContainer{
    func setCoordsLabel(_ theCoords:String)
}

class myViewController: NSViewController,DrawingSpaceContainer {
    
  
    
    var drawingControl:MWDrawingSpace = MWDrawingSpace()
    
   
  
    
    //protocol Function
    func setCoordsLabel(_ theCoords:String){
        self.view.window?.title = theCoords
    }
    
    override func viewDidLayout() {
        //drawingControl.display()
    }
    override func viewDidLoad() {
        
        super.viewDidLoad()
        //drawingControl.delegate = self
        self.view.addSubview(drawingControl)
        layoutDrawingConrolManually()
        drawingControl.updateTrackingAreas()
       
    }
    
    func layoutDrawingConrolManually(){
        ///////////Dictionary for the layout constraints
        var myDict = Dictionary<String, NSView>()
        
        self.drawingControl.translatesAutoresizingMaskIntoConstraints = false
        
        myDict["DC"] = self.drawingControl
        
        //Layout Constraints
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[DC(>=400)]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: myDict))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[DC(>=400)]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: myDict))
        
        //        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-40-[LG(>=150)]-[SG(==LG)]-[MG(==SG)]-[DG(==SG)]-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: myDict))
        
    }
    
    
}


