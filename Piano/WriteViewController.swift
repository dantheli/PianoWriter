//
//  WriteViewController.swift
//  Piano
//
//  Created by Daniel Li on 1/8/16.
//  Copyright © 2016 Dannical. All rights reserved.
//

import UIKit
import AVFoundation
import RealmSwift

class WriteViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBAction func cancelButton(sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "", message: "This will discard all changes.", preferredStyle: .ActionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        let quitAction = UIAlertAction(title: "Quit", style: .Destructive) { Void in
            self.performSegueWithIdentifier("quit", sender: self)
        }
        alertController.addAction(quitAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    @IBAction func doneButton(sender: UIBarButtonItem) {
        let realm = try! Realm()
        try! realm.write {
            realm.add(song, update: true)
        }
        
        performSegueWithIdentifier("save", sender: self)
    }
    @IBOutlet weak var setLabel: UILabel!
    @IBOutlet weak var nextSetButton: UIButton!
    @IBAction func nextSetButton(sender: UIButton) {
        if !song.sequence.indices.contains(currentSet + 1) {
            let set = PlayableSet()
            song.sequence.append(set)
        }
        currentSet++
        updateView()
    }
    @IBOutlet weak var previousSetButton: UIButton!
    @IBAction func previousSetButton(sender: UIButton) {
        if song.sequence.indices.contains(currentSet - 1) {
            currentSet--
        }
        updateView()
    }
    
    
    var keyButtons = [UIButton]()
    
    var song: Song!
    
    /** The set of the song the user is currently looking at */
    var currentSet: Int {
        get {
            return _currentSet
        }
        set {
            if song.sequence.indices.contains(newValue) {
                _currentSet = newValue
            }
        }
    }
    var _currentSet: Int = 0
    
    var newSong = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !newSong {
            currentSet = song.sequence.indices.last!
        }
        
        // Create first set if empty
        if song.sequence.isEmpty {
            let set = PlayableSet()
            song.sequence.append(set)
        }
        
        // Set up piano
        let pianoView = UIView(frame: CGRect(x: scrollView.frame.origin.x, y: scrollView.frame.origin.y, width: PIANO_WIDTH, height: PIANO_HEIGHT))
        pianoView.backgroundColor = UIColor.lightGrayColor()

        // Draw white key buttons
        for key in 0...NUMBER_OF_WHITE_KEYS - 1 {
            let x = CGFloat(key) * (WHITE_KEY_WIDTH + KEY_BORDER_WIDTH)
            let y: CGFloat = 0
            let width = WHITE_KEY_WIDTH
            let height = PIANO_HEIGHT
            
            let whiteKey = UIButton(frame: CGRect(x: x, y: y, width: width, height: height))
            whiteKey.backgroundColor = UIColor.whiteColor()
            
            let label = UILabel(frame: CGRect(x: 0, y: PIANO_HEIGHT - 30, width: WHITE_KEY_WIDTH, height: 30))
            label.text = getWhiteKeys()[key]
            label.textAlignment = .Center
            whiteKey.addSubview(label)
            
            // Action
            whiteKey.addTarget(self, action: "keyPressed:", forControlEvents: .TouchDown)
            whiteKey.setTitle(getWhiteKeys()[key], forState: .Normal)
            whiteKey.titleLabel?.hidden = true
            
            keyButtons.append(whiteKey)
            
            pianoView.addSubview(whiteKey)
        }
        
        // Draw black key buttons
        var blackKeyIndex = 0
        for key in 0...NUMBER_OF_WHITE_KEYS+NUMBER_OF_BLACK_KEYS-1 {
            if KEYS[key].containsString("b") {
                let x = (WHITE_KEY_WIDTH + KEY_BORDER_WIDTH) * CGFloat(blackKeyIndex - 1) + BLACK_KEY_LEFT_SPACING
                let y: CGFloat = 0
                let width = BLACK_KEY_WIDTH
                let height = PIANO_HEIGHT * BLACK_KEY_HEIGHT_RATIO
                
                let blackKey = UIButton(frame: CGRect(x: x, y: y, width: width, height: height))
                blackKey.backgroundColor = UIColor.blackColor()
                blackKey.layer.borderColor = UIColor.darkGrayColor().CGColor
                blackKey.layer.borderWidth = 1
                
                let label = UILabel(frame: CGRect(x: 0, y: height-20, width: BLACK_KEY_WIDTH, height: 20))
                label.text = KEYS[key]
                label.textAlignment = .Center
                label.textColor = UIColor.whiteColor()
                label.font = UIFont.systemFontOfSize(11)
                blackKey.addSubview(label)
                
                // Action
                blackKey.addTarget(self, action: "keyPressed:", forControlEvents: .TouchDown)
                blackKey.setTitle(KEYS[key], forState: .Normal)
                blackKey.setTitleColor(UIColor.blackColor(), forState: .Normal)
                blackKey.titleLabel?.hidden = true
                
                keyButtons.append(blackKey)
                
                pianoView.addSubview(blackKey)
            } else {
                blackKeyIndex++
            }
        }
        
        // Configure ScrollView
        scrollView.layer.borderWidth = 1
        scrollView.layer.borderColor = UIColor.lightGrayColor().CGColor
        scrollView.addSubview(pianoView)
        scrollView.contentSize = pianoView.frame.size
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        updateView()
    }
    
    
    func keyPressed(sender: UIButton) {
        if let pressedKey = sender.titleLabel?.text {
            let note = Note()
            note.key = pressedKey
            if let note = song.sequence[currentSet].notes.filter({ $0.key == pressedKey }).first {
                if let index = song.sequence[currentSet].notes.indexOf(note) {
                    song.sequence[currentSet].notes.removeAtIndex(index)
                    
                    // Uncolor it
                    for button in keyButtons.filter({ $0.titleLabel?.text! == pressedKey }) {
                        if pressedKey.containsString("b") {
                            button.backgroundColor = UIColor.blackColor()
                        } else {
                            button.backgroundColor = UIColor.whiteColor()
                        }
                    }
                }
            }
            // Add if key is not in sequence
            else {
                song.sequence[currentSet].notes.append(note)
                
                // Color the key
                for button in keyButtons.filter({ $0.titleLabel?.text! == note.key }) {
                    button.backgroundColor = UIColor(red:1, green:0.91, blue:0.38, alpha:1)
                }
                
                // Play sound
                if let audioFilePath = NSBundle.mainBundle().pathForResource("Piano.ff." + note.key, ofType: "mp3") {
                    let audioFileUrl = NSURL.fileURLWithPath(audioFilePath)
                    do {
                        let player = try AVAudioPlayer(contentsOfURL: audioFileUrl)
                        player.play()
                        let fader = iiFaderForAvAudioPlayer(player: player)
                        fader.fadeOut(0.5, velocity: 1.0, onFinished: nil)
                    } catch {
                        NSLog("AVAudioPlayer has failed to instantiate. Error details: ")
                        print(error)
                    }
                }
            }
        }
    }
    
    func updateView() {
        for button in keyButtons {
            if button.titleLabel!.text!.containsString("b") {
                button.backgroundColor = UIColor.blackColor()
            } else {
                button.backgroundColor = UIColor.whiteColor()
            }
            for note in song.sequence[currentSet].notes {
                if button.titleLabel?.text! == note.key {
                    button.backgroundColor = UIColor(red:1, green:0.91, blue:0.38, alpha:1)
                }
            }
        }
        
        if currentSet == 0 {
            previousSetButton.enabled = false
        } else {
            previousSetButton.enabled = true
        }
        if song.sequence.indices.contains(currentSet + 1) {
            nextSetButton.setTitle("Next Set", forState: .Normal)
        } else {
            nextSetButton.setTitle("New Set", forState: .Normal)
        }
        setLabel.text = "\(currentSet)"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
    }

}
