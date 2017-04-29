//
//  MWDescriptionReader.swift
//  DrawingSpace_CustomTransforms_V0.0.3
//
//  Created by Mark Walker on 1/29/16.
//  Copyright © 2016 Mark Walker. All rights reserved.
//

import Cocoa

class MWDescriptionReader: NSObject {
    
    var progressBarDelegate:MWProgressIndicator?
    
    
    var legalDescription:String = ""
    
    var legalDescriptionNSString:NSString{
        return legalDescription as NSString
    }
    
    var rules = MWSurveyCallRules()
    var calls = [MWSurveyCall]()
    
    var callForChecks = MWSurveyCall()
    
    var progressLocation:Int = 0
    var progressTotal:Int{
        return legalDescription.characters.count
    }
    
    
    func verifyCallIsGood(_ theString:String)->(isGood:Bool, call:MWSurveyCall){
       let blankCall = MWSurveyCall()
       let theNSString = theString as NSString
        
        let startDirectionRange = findNextFlaginString(theString, flagType:rules.callStartFlags, beginLoc: 0)
        guard startDirectionRange.length != 0 else{
            return (false, blankCall)
        }
        
        
        
        let degreesFlagRange = findNextFlaginString(theString, flagType:rules.degreesFlag, beginLoc: 0)
        guard degreesFlagRange.length != 0 else{
            return (false, blankCall)
        }
        
        
        let minutesFlagRange = findNextFlaginString(theString, flagType:rules.minutesFlag, beginLoc: 0)
        guard minutesFlagRange.length != 0 else{
            return (false, blankCall)
        }
        
        let secondsFlagRange = findNextFlaginString(theString, flagType:rules.secondsFlag, beginLoc: 0)
        guard secondsFlagRange.length != 0 else{
            return (false, blankCall)
        }
        
        let endDirectionRange = findNextFlaginString(theString, flagType:rules.bearingEndFlags, beginLoc: 0)
        guard endDirectionRange.length != 0 else{
            return (false, blankCall)
        }
        
        
        
        let seperatorRange = findNextFlaginString(theString, flagType:rules.angleDistSeparaterFlags, beginLoc: 0)
        guard seperatorRange.length != 0 else{
            return (false, blankCall)
        }
        
        let endFlagRange = findNextFlaginString(theString, flagType:rules.callEndFlags, beginLoc: 0)
        guard endFlagRange.length != 0 else{
            return (false, blankCall)
        }
        
        let degreesTestLoc = startDirectionRange.location + startDirectionRange.length
        let degreesTestLen = degreesFlagRange.location - degreesTestLoc
        let testDegreesRange = NSMakeRange(degreesTestLoc, degreesTestLen)
        guard let degrees = theNSString.substring(with: testDegreesRange).doubleValue else{
            return (false, blankCall)
        }
        
        let minutesTestLoc = degreesFlagRange.location + degreesFlagRange.length
        let minutesTestLen = minutesFlagRange.location - minutesTestLoc
        let testMinutesRange = NSMakeRange(minutesTestLoc, minutesTestLen)
        guard let minutes = theNSString.substring(with: testMinutesRange).doubleValue else{
            return (false, blankCall)
        }
        
        let secondsTestLoc = minutesFlagRange.location + minutesFlagRange.length
        let secondsTestLen = secondsFlagRange.location - secondsTestLoc
        let testsecondsRange = NSMakeRange(secondsTestLoc, secondsTestLen)
        guard let seconds = theNSString.substring(with: testsecondsRange).doubleValue else{
            return (false, blankCall)
        }
        
        let distTestLoc = seperatorRange.location + seperatorRange.length
        let distTestLen = endFlagRange.location - distTestLoc
        let testDistRange = NSMakeRange(distTestLoc, distTestLen)
        guard let dist = theNSString.substring(with: testDistRange).doubleValue else{
            return (false, blankCall)
        }
        
        let startDirectionString = theNSString.substring(with: startDirectionRange) as String
        let endDirectionString = theNSString.substring(with: endDirectionRange) as String
        
        let returnSurveyCall = MWSurveyCall()
        
        returnSurveyCall.startDirection = startDirectionEnumFromString(startDirectionString)
        returnSurveyCall.endDirection = startDirectionEnumFromString(endDirectionString)
        returnSurveyCall.degrees = degrees
        returnSurveyCall.minutes = minutes
        returnSurveyCall.seconds = seconds
        returnSurveyCall.distance = dist
        
        return (true, returnSurveyCall)
    }
    
    func startDirectionEnumFromString(_ theString:String)-> MWSurveyCallDirectionEnum{
        var returnVal = MWSurveyCallDirectionEnum.badValue
        if theString == "North"{
            returnVal = .North
        }else if theString == "South"{
            returnVal = .South
        }else if theString == "East"{
            returnVal = .East
        }else if theString == "West"{
            returnVal = .West
        }
        
        return returnVal
        
    }
    
    func getAllPotentialCalls()->(foundCalls:[String], callRanges:[NSRange]){
        var callStrings:[String] = [String]()
        var ranges:[NSRange] = [NSRange]()
        
        var locationOfLastFoundRange:Int = 0
        var conditionString = ""
        var progressi:Int = 1
        
        
            repeat{
                
                let theTuple = self.getNextPotentialCall(locationOfLastFoundRange)
                conditionString = theTuple.foundCall
                
                if theTuple.foundCall != ""{
                    DispatchQueue.main.async {
                        self.progressBarDelegate?.progressLabel.stringValue = "\(progressi) course(s) found"
                    }
                    
                    callStrings.append(theTuple.foundCall)
                    ranges.append(theTuple.callRange)
                    locationOfLastFoundRange = theTuple.callRange.location + theTuple.callRange.length
                    self.progressLocation = locationOfLastFoundRange + theTuple.callRange.length
                    progressi += 1
                }
                
            }while conditionString != ""
       
        
        return (callStrings, ranges)
    }
    
    
    
    
    func getNextPotentialCall(_ startLoc:Int)->(foundCall:String, callRange:NSRange){
        var returnString = ""
        var returnRange = NSRange()
        
        let rangeOfStart = findNextFlaginString(legalDescription,flagType: rules.callStartFlags, beginLoc: startLoc)
        let rangeOfEnd = findNextFlaginString(legalDescription, flagType: rules.callEndFlags, beginLoc: rangeOfStart.location + rangeOfStart.length + 1)
        
        if rangeOfStart.location < rangeOfEnd.location{ //we have a potential Call
            let potentialCallRange = NSMakeRange(rangeOfStart.location, rangeOfEnd.location + rangeOfEnd.length - rangeOfStart.location)
            let potentialCall:String = legalDescriptionNSString.substring(with: potentialCallRange) as String
            returnString = potentialCall
            returnRange = potentialCallRange
        }
        
        return (returnString, returnRange)
    }
    
    
    
    
    func findNextFlaginString(_ inString:String, flagType:[String], beginLoc:Int)->NSRange{
        var returnRange = NSMakeRange(0, 0)
        
        returnRange = inString.findFirstMatchingString(flagType[0], startLoc: beginLoc)
        for i:Int in 1  ... flagType.count-1{
            
            let anotherRange = inString.findFirstMatchingString(flagType[i], startLoc: beginLoc)
            
            if returnRange.length == 0{
                
                returnRange = anotherRange
                
            }else if anotherRange.location <= returnRange.location && anotherRange.length >= returnRange.length{
                
                returnRange = anotherRange
            }
            
        }
        
        return returnRange
        
    }

}
