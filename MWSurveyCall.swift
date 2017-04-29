//
//  MWSurveyCall.swift
//  DrawingSpace_CustomTransforms_V0.0.3
//
//  Created by Mark Walker on 1/29/16.
//  Copyright © 2016 Mark Walker. All rights reserved.
//

import Cocoa

class MWSurveyCall: NSObject {

    var startDirection = MWSurveyCallDirectionEnum.North
    
    var endDirection = MWSurveyCallDirectionEnum.East
    
    var degrees:Double = 0.0
    var minutes:Double = 0.0
    var seconds:Double = 0.0
    
    var distance:Double = 0.0
    
    var rules = MWSurveyCallRules()
    
    override init(){
        super.init()
    }
    
    
    
}
