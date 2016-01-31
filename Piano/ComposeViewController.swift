//
//  ComposeViewController.swift
//  Piano
//
//  Created by Daniel Li on 1/8/16.
//  Copyright © 2016 Dannical. All rights reserved.
//

import UIKit

class ComposeViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var composerTextField: UITextField!
    @IBAction func continueButton(sender: UIButton) {
        
    }
    
    var newSong = true
    var song: Song!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if !newSong && song != nil {
            title = "Editing"
            titleTextField.text = song.title
            composerTextField.text = song.composer
        }
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
        
        if let destination = segue.destinationViewController as? WriteViewController {
            if newSong {
                song = Song()
            }
            song.title = titleTextField.text!
            song.composer = composerTextField.text
            destination.newSong = newSong
            destination.song = song
        }
        
    }

}
