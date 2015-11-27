//
//  LikertScale.swift
//  SurveyManager
//
//  Created by Bruce Collie on 25/06/2014.
//  Copyright (c) 2014 University of Cambridge Computer Laboratory. All rights reserved.
//

import Foundation

//TODO: use of optionals here is really really bad
/**
    Represents a sliding scale of values. This class
    simply encodes information about the state of such
    a slider - it does not have any functionality of its
    own.
*/
public class LikertScale : NSObject, NSCoding {
    
    ///The minimum (far left) score on the slider
    public var minScore : Int?
    
    ///The maximum (far right) score on the slider
    public var maxScore : Int?
    
    ///The initial score to be shown on the slider
    public var initScore : Int?
    
    ///The labels to be shown at each point on the slider
    public var descriptions : [String] = []
    
    /**
        Plain initialiser method. Note that currently the
        properties on this class are optional. This may change
        in a future version of this library,
    
        :param: min The minimum score.
        :param: max The maximum score.
        :param: start The initial score
        :param: descs The labels to use for each slider point.
    */
    init(min: Int?, max: Int?, start: Int?, descs: Array<String>) {
        minScore = min
        maxScore = max
        initScore = start
        descriptions = descs
    }
    
    /**
        Initialises a LikertScale instance from serialized data.
    
        :param: coder The NSCoder used to deserialise the object.
    */
    public required init(coder: NSCoder) {
        self.minScore = coder.decodeIntegerForKey("minScore")
        self.maxScore = coder.decodeIntegerForKey("maxScore")
        self.initScore = coder.decodeIntegerForKey("initScore")
        self.descriptions = coder.decodeObjectForKey("descriptions") as! [String]
    }
    
    /**
        Serialises a LikertScale instance.
    
        :param: coder The NSCoder used to serialise the object.
    */
    public func encodeWithCoder(coder: NSCoder) {
        coder.encodeInteger(self.minScore!, forKey: "minScore")
        coder.encodeInteger(self.maxScore!, forKey: "maxScore")
        coder.encodeInteger(self.initScore!, forKey: "initScore")
        coder.encodeObject(self.descriptions as NSArray, forKey: "descriptions")
    }
    
}