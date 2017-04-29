//
//  String_Extension.swift
//  DrawingSpace_CustomTransforms_V0.0.2
//
//  Created by Mark Walker on 1/1/16.
//  Copyright © 2016 Mark Walker. All rights reserved.
//

import Foundation

extension String {
    
    subscript (i: Int) -> Character {
        return self[self.characters.index(self.startIndex, offsetBy: i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        return substring(with: (characters.index(startIndex, offsetBy: r.lowerBound) ..< characters.index(startIndex, offsetBy: r.upperBound)))
    }
    
    func findFirstChar(_ theChar:String)->Int{
        var firstPosition:Int = -1
        for i:Int in 0 ... self.characters.count-1{
            if self[i] == theChar{
                firstPosition = i
                break
            }
        }
        
        return firstPosition
    }
    
    func findFirstCharFrom(_ theChar:String, startLoc:Int)->Int{
        var firstPosition:Int = -1
        for i:Int in startLoc ... self.characters.count-1{
            let testChar:String = self[i] as String
            if testChar == theChar{
                firstPosition = i
                break
            }
        }
        
        return firstPosition
    }
    
    
    func findFirstMatchingString(_ searchString:String, startLoc:Int)-> NSRange{
        var foundRange = NSMakeRange(0, 0)
        
        let minWordEnd = searchString.characters.count + startLoc
        
        guard self.characters.count >= minWordEnd else{
            return foundRange
        }
        
        
        var char1MatchLoc:Int = -1
        
        var wordStartSearchLoc = startLoc
        
        repeat{
            
            //begin the testing when we find a match for the first char in the search string
            char1MatchLoc = findFirstCharFrom(searchString[0] as String, startLoc:wordStartSearchLoc)
            
            //if the above finds no match then -1 is returned
            guard char1MatchLoc != -1 else{
                return foundRange
            }
         
            //check to make sure we are not to close to the end
            guard char1MatchLoc + searchString.characters.count <= self.characters.count else{
                return foundRange
            }
            
            //we made it this far, we have have a matching first letter at testStartLocation
          
            var currentSearchLocation  = char1MatchLoc + 1
            var stillMatching:Bool = true
            
            for i:Int in 1 ... searchString.characters.count-1{
                let letterA = self[currentSearchLocation] as String
                let letterB = searchString[i] as String
                if letterA  == letterB{
                    //we are still good
                }else{
                  stillMatching = false
                }
                currentSearchLocation += 1
            }
            
            if stillMatching == true {
                foundRange.location = char1MatchLoc
                foundRange.length = searchString.characters.count
                return foundRange
            }else{
                wordStartSearchLoc = char1MatchLoc + 1
            }
        
            
            
        }while (char1MatchLoc + searchString.characters.count  < self.characters.count)
        
        
        return foundRange //if a word was found then the NSRange will not be location = 0 length = 0
        
    }

    
    
    
    //////
    struct NumberFormatter {
        static let instance = Foundation.NumberFormatter()
    }
    var doubleValue:Double? {
        guard let val = NumberFormatter.instance.number(from: self)?.doubleValue else{
          return -10000
        }
        
        return val
    }
    
    
    var integerValue:Int? {
        guard let val = NumberFormatter.instance.number(from: self)?.intValue else{
            return -10000
        }
        
        return val
    }
    
    var CGFloatValue:CGFloat? {
        guard let doubleVal = NumberFormatter.instance.number(from: self)?.doubleValue else{
            return -10000
        }
        
        let val = CGFloat(doubleVal)
        
        return val
    }
    
}
