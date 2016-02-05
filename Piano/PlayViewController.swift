//
//  PlayViewController.swift
//  Piano
//
//  Created by Daniel Li on 1/8/16.
//  Copyright © 2016 Dannical. All rights reserved.
//

import UIKit
import AVFoundation

class PlayViewController: UIViewController, AVAudioPlayerDelegate {
    
    var keyViews = [String:UIView]()
    
    var noteViews = [UIView]()
    
    var pianoView = UIView()
    
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        progressBar.progress = 0.0
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        setPlayers.removeAll()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.multipleTouchEnabled = true
        
        title = song.title
        
        // Set up piano
        pianoView = UIView(frame: CGRect(x: 0, y: 4*SCREEN_HEIGHT/5, width: SCREEN_WIDTH, height: SCREEN_HEIGHT/5))
        pianoView.backgroundColor = UIColor.lightGrayColor()
        
        // Draw white key buttons
        for key in 0...NUMBER_OF_WHITE_KEYS - 1 {
            let x = CGFloat(key) * SCREEN_WIDTH/52
            let y: CGFloat = 0
            let width = SCREEN_WIDTH/52
            let height: CGFloat = pianoView.frame.height
            
            let whiteKey = UIView(frame: CGRect(x: x, y: y, width: width, height: height))
            whiteKey.backgroundColor = UIColor.whiteColor()
            whiteKey.layer.borderColor = UIColor.lightGrayColor().CGColor
            whiteKey.layer.borderWidth = 0.5
            keyViews[getWhiteKeys()[key]] = whiteKey
            
            pianoView.addSubview(whiteKey)
        }
        
        // Draw black key buttons
        var blackKeyIndex = 0
        for key in 0...NUMBER_OF_WHITE_KEYS+NUMBER_OF_BLACK_KEYS-1 {
            if KEYS[key].containsString("b") {
                let y: CGFloat = 0
                let width = (BLACK_KEY_WIDTH/WHITE_KEY_WIDTH)*SCREEN_WIDTH/52
                let x = SCREEN_WIDTH/52 * CGFloat(blackKeyIndex - 1) + SCREEN_WIDTH/52 - width/2
                let height = pianoView.frame.height * BLACK_KEY_HEIGHT_RATIO
                
                let blackKey = UIView(frame: CGRect(x: x, y: y, width: width, height: height))
                blackKey.backgroundColor = UIColor.blackColor()
                blackKey.layer.borderColor = UIColor.darkGrayColor().CGColor
                blackKey.layer.borderWidth = 0.5
                
                keyViews[KEYS[key]] = blackKey
                
                pianoView.addSubview(blackKey)
            } else {
                blackKeyIndex++
            }
        }
        view.addSubview(pianoView)
        pianoView.hidden = true
        
        // Draw Notes
        var setIndex = 0
        for set in song.sequence {
            for note in set.notes {
                let frame = CGRect(x: keyViews[note.key]!.frame.origin.x, y: pianoView.frame.origin.y - CGFloat(setIndex * 20) - 5, width: keyViews[note.key]!.frame.width, height: 10.0)
                let noteView = UIView(frame: frame)
                if note.key.containsString("b") {
                    noteView.backgroundColor = UIColor.blackColor()
                } else {
                    noteView.backgroundColor = UIColor.whiteColor()
                }
                noteView.layer.borderColor = UIColor.lightGrayColor().CGColor
                noteView.layer.borderWidth = 1
                view.addSubview(noteView)
                noteViews.append(noteView)
                noteView.hidden = true
            }
            setIndex++
        }
        view.bringSubviewToFront(pianoView)
        
        loadSong()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("RECEIVED MEMORY WARNING")
    }
    
    func loadSong() {
        var loadIndex = 1
        let backgroundQueue = dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)
        dispatch_async(backgroundQueue) {
            for set in self.song.sequence {
                var players = [AVAudioPlayer]()
                for note in set.notes {
                    if let audioFilePath = NSBundle.mainBundle().pathForResource("Piano.ff." + note.key, ofType: "mp3") {
                        let audioFileUrl = NSURL.fileURLWithPath(audioFilePath)
                        do {
                            let player = try AVAudioPlayer(contentsOfURL: audioFileUrl)
                            if !player.prepareToPlay() {
                                dispatch_async(dispatch_get_main_queue()) {
                                    print("prepareToPlay failed on " + note.key)
                                    self.view.backgroundColor = UIColor.redColor()
                                }
                            }
                            player.delegate = self
                            players.append(player)
                        } catch {
                            NSLog("AVAudioPlayer has failed to instantiate. Error details: ")
                            print(error)
                        }
                    } else {
                        NSLog("Piano.ff." + note.key + ".mp3 not found")
                    }
                }
                self.setPlayers.append(players)
                dispatch_async(dispatch_get_main_queue()) {
                    loadIndex++
                    self.progressBar.setProgress(Float(loadIndex)/Float(self.song.sequence.count), animated: true)
                }
            }
            dispatch_async(dispatch_get_main_queue()) {
                self.ready()
            }
        }
    }
    
    func ready() {
        loadingLabel.hidden = true
        progressBar.hidden = true
        pianoView.hidden = false
        for noteView in noteViews {
            noteView.hidden = false
        }
    }
    
    func advanceSet() {
        self.currentSet++
        for noteView in noteViews {
            let translation = CGAffineTransformMakeTranslation(0.0, CGFloat((self.currentSet) * 20))
            noteView.transform = translation
        }
    }
    
    var song: Song!
    var currentSet = 0
    var touching = false
    var setPlayers = [[AVAudioPlayer]]()
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if self.currentSet < self.song.sequence.count {
            for touch in touches {
                dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) {
                    print(self.currentSet)
                    for player in self.setPlayers[self.currentSet] {
                        player.play()
                    }
                    dispatch_async(dispatch_get_main_queue()) {
                        self.advanceSet()
                    }
                }
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        touching = false
        for touch in touches {
            
        }
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
