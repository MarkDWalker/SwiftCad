//
//  MWCadTransforms.swift
//  DrawSpaceControlUsing_stockTransforms
//
//  Created by Mark Walker on 9/27/15.
//  Copyright © 2015 Mark Walker. All rights reserved.
//

import Cocoa

class MWCadTransforms: NSObject {
    
    ///zoom
    var zoomScale:CGFloat = 1.0
   // var modelTrans = CGPoint(x: 0, y: 0)
    var scaledTrans = CGPoint(x: 0, y: 0)
    

  
    
    ///inits
    override init(){
     super.init()
    }
    
    init(theScale:CGFloat){
        super.init()
        zoomScale = theScale
    }

}
