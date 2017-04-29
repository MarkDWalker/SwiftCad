//
//  MWSurveyCall.swift
//  DrawingSpace_CustomTransforms_V0.0.3
//
//  Created by Mark Walker on 1/27/16.
//  Copyright © 2016 Mark Walker. All rights reserved.
//

import Cocoa

class MWSurveyCallRules: NSObject {

    var callStartFlags = ["North", "N", "South", "S"]
    
    var degreesFlag = ["d", "\u{00B0}"]
    var minutesFlag = ["'"]
    var secondsFlag = ["\""]
    
    var bearingEndFlags = ["East", "E", "West", "W"]
    
    var angleDistSeparaterFlags = [","]
    
    var callEndFlags = ["Feet", "feet", "ft", "ft."]

}


