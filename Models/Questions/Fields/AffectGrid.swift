//
//  AffectGrid.swift
//  SurveyManager
//
//  Created by Bruce Collie on 25/06/2014.
//  Copyright (c) 2014 University of Cambridge Computer Laboratory. All rights reserved.
//

import Foundation
import UIKit

/**
    Plain model object to represent an affect grid.
    Has no functionality - only stores data.
*/
public class AffectGrid : NSObject, NSCoding {
    
    ///The text to be displayed at the top left of the grid.
    public var topLeft : String
    
    ///The text to be displayed at the top of the grid.
    public var topMiddle : String
    
    ///The text to be displayed at the top right of the grid.
    public var topRight : String
    
    ///The text to be displayed at the left of the grid.
    public var middleLeft : String
    
    ///The text to be displayed at the right of the grid.
    public var middleRight : String
    
    ///The text to be displayed at the bottom left of the grid.
    public var bottomLeft : String
    
    ///The text to be displayed at the bottom of the grid.
    public var bottomMiddle : String
    
    ///The text to be displayed at the bottom right of the grid.
    public var bottomRight : String
    
    /**
        Initialise the grid from an Array of Strings. The order
        in which labels are added to the grid is from left to
        right and from top to bottom (i.e. the top left is item
        0 in the array, and the bottom right is item 7). This
        code will crash currently if passed an array of labels
        with less than 8 elements, so care should be taken.
    
        :param: l The array of labels to construct the grid with.
    */
    init(l: [String]) {
        topLeft = l[0]
        topMiddle = l[1]
        topRight = l[2]
        middleLeft = l[3]
        middleRight = l[4]
        bottomLeft = l[5]
        bottomMiddle = l[6]
        bottomRight = l[7]
    }
    
    /**
        Initialises an AffectGrid instance from serialized data.
    
        :param: coder The NSCoder used to deserialise the object.
    */
    public required init(coder: NSCoder) {
        self.topLeft = coder.decodeObjectForKey("topLeft") as! String
        self.topMiddle = coder.decodeObjectForKey("topMiddle") as! String
        self.topRight = coder.decodeObjectForKey("topRight") as! String
        self.middleLeft = coder.decodeObjectForKey("middleLeft") as! String
        self.middleRight = coder.decodeObjectForKey("middleRight") as! String
        self.bottomLeft = coder.decodeObjectForKey("bottomLeft") as! String
        self.bottomMiddle = coder.decodeObjectForKey("bottomMiddle") as! String
        self.bottomRight = coder.decodeObjectForKey("bottomRight") as! String
    }
    
    /**
        Serialises an AffectGrid instance.
    
        :param: coder The NSCoder used to serialise the object.
    */
    public func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.topLeft, forKey: "topLeft")
        coder.encodeObject(self.topMiddle, forKey: "topMiddle")
        coder.encodeObject(self.topRight, forKey: "topRight")
        coder.encodeObject(self.middleLeft, forKey: "middleLeft")
        coder.encodeObject(self.middleRight, forKey: "middleRight")
        coder.encodeObject(self.bottomLeft, forKey: "bottomLeft")
        coder.encodeObject(self.bottomMiddle, forKey: "bottomMiddle")
        coder.encodeObject(self.bottomRight, forKey: "bottomRight")
    }
    
    /**
        Describes the state of the grid - the slider can be in one
        of the 4 quadrants of the grid (as this is a primary answer
        type in EasyM), as well as the exact position of the slider
        and size of the whole affect grid.
    */
    public enum GridState {
        case TopLeft(CGPoint, CGSize)
        case TopRight(CGPoint, CGSize)
        case BottomLeft(CGPoint, CGSize)
        case BottomRight(CGPoint, CGSize)
    }
    
}