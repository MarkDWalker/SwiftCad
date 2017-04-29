//
//  ViewController_textInputPanel.swift
//  DrawingSpaceControl_UsingCustomTransforms
//
//  Created by Mark Walker on 12/27/15.
//  Copyright © 2015 Mark Walker. All rights reserved.
//

import Cocoa

protocol ChildControlAccessibleViewController{
    func performSegueWithIdentifier(identifier: String, sender: AnyObject?)
}

class ViewController_textInputPanel: NSViewController, ChildControlAccessibleViewController {

    @IBOutlet var commandControl: MWCommandControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        commandControl.parentVC = self
        
    }
    
    
    func performSegueWithIdentifier(identifier: String, sender: AnyObject?) {
        
        if identifier == "descriptionEditor"{
            //set the values
            let VC_legalTextView = self.storyboard?.instantiateController(withIdentifier:)("legalTextView") as! ViewController_LegalTextView
            self.presentViewControllerAsSheet(VC_legalTextView)
        }
        
    }
   
    
}
