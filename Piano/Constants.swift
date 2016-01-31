//
//  Constants.swift
//  Piano
//
//  Created by Daniel Li on 1/8/16.
//  Copyright © 2016 Dannical. All rights reserved.
//

import Foundation
import UIKit

/** How long in seconds to delay playing a note to determine force */
let PLAY_NOTE_DELAY: NSTimeInterval = 0.03

let NUMBER_OF_WHITE_KEYS = 52
let NUMBER_OF_BLACK_KEYS = 36

let WHITE_KEY_WIDTH: CGFloat = 40
let BLACK_KEY_WIDTH: CGFloat = 25
let BLACK_KEY_HEIGHT_RATIO: CGFloat = 0.6
let BLACK_KEY_LEFT_SPACING: CGFloat = WHITE_KEY_WIDTH - BLACK_KEY_WIDTH/2
let KEY_BORDER_WIDTH: CGFloat = 1

var PIANO_WIDTH: CGFloat {
    return (WHITE_KEY_WIDTH + KEY_BORDER_WIDTH) * CGFloat(NUMBER_OF_WHITE_KEYS) - KEY_BORDER_WIDTH
}

let PIANO_HEIGHT: CGFloat = 150

let SCREEN_WIDTH = UIScreen.mainScreen().bounds.size.width
let SCREEN_HEIGHT = UIScreen.mainScreen().bounds.size.height

// Threading
let DISPATCH_NOTE_END_QUEUE = dispatch_queue_create("endQueue", DISPATCH_QUEUE_CONCURRENT)

let PLAYER_REMOVE_QUEUE = dispatch_queue_create("removeQueue", nil)