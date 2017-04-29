//
//  MWCommandSequenceProto.swift
//  DrawingSpace_CustomTransforms_V0.0.2
//
//  Created by Mark Walker on 1/4/16.
//  Copyright © 2016 Mark Walker. All rights reserved.
//

import Foundation

@objc protocol MWCommandSequence{
    var pickedPt:NSPoint{get set}
    var pickedPtIsDelta:Bool{get set}
    var cadCommandList:MWCadCommandList{get set}
    @objc optional var commandAfterSelection:String{get set}
    @objc optional var selectionSet:MWSelectionSet{get set}
    func runCommandSequence(_ command:MWCadCommand)
    func makePickedPoint(_ pt:NSPoint, isDelta:Bool)
    func cancelMidCommand()
    func endMidCommand()
}
