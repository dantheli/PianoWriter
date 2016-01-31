//
//  SongsViewController.swift
//  Piano
//
//  Created by Daniel Li on 12/29/15.
//  Copyright © 2015 Dannical. All rights reserved.
//

import UIKit
import RealmSwift

class SongsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var songList: Results<Song>!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.view.multipleTouchEnabled = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        realmToModel()
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // TableView Data Source Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("songCell", forIndexPath: indexPath)
        cell.textLabel!.text = songList[indexPath.row].title
        cell.detailTextLabel!.text = songList[indexPath.row].composer
        return cell
    }
    
    func realmToModel() {
        let realm = try! Realm()
        songList = realm.objects(Song)
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let alertController = UIAlertController(title: "Really delete this song?", message: "You cannot undo this.", preferredStyle: .ActionSheet)
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            alertController.addAction(cancelAction)
            let deleteAction = UIAlertAction(title: "Delete", style: .Destructive, handler: { Void in
                let realm = try! Realm()
                try! realm.write {
                    realm.delete(self.songList[indexPath.row])
                }
                self.realmToModel()
                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                
            })
            alertController.addAction(deleteAction)
            
            presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    // Navigation
    
    @IBAction func unwindCancel(segue: UIStoryboardSegue) {    }
    @IBAction func unwindSave(segue: UIStoryboardSegue) {
        let beforeCount = songList.count
        realmToModel()
        let afterCount = songList.count
        
        // EDIT LATER FOR MULTIPLE INSERTIONS
        if beforeCount + 1 == afterCount {
            tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: songList.count - 1, inSection: 0)], withRowAnimation: .Automatic)
        } else {
            tableView.reloadData()
        }
    }
    
    var selectedAccessoryIndexPath: NSIndexPath?
    func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        selectedAccessoryIndexPath = indexPath
        performSegueWithIdentifier("edit", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destination = segue.destinationViewController as? PlayViewController {
            if let indexPath = tableView.indexPathForSelectedRow {
                destination.song = Song()
                destination.song.title = songList[indexPath.row].title
                destination.song.composer = songList[indexPath.row].composer
                destination.song.id = songList[indexPath.row].id
                for set in songList[indexPath.row].sequence {
                    let playableSet = PlayableSet()
                    for note in set.notes {
                        let newNote = Note()
                        newNote.key = note.key
                        playableSet.notes.append(newNote)
                    }
                    destination.song.sequence.append(playableSet)
                }
            }
        }
        if segue.identifier == "edit" {
            if let destination = (segue.destinationViewController as? UINavigationController)?.topViewController as? ComposeViewController {
                if let indexPath = selectedAccessoryIndexPath {
                    destination.song = Song()
                    destination.song.title = songList[indexPath.row].title
                    destination.song.composer = songList[indexPath.row].composer
                    destination.song.id = songList[indexPath.row].id
                    for set in songList[indexPath.row].sequence {
                        let playableSet = PlayableSet()
                        for note in set.notes {
                            let newNote = Note()
                            newNote.key = note.key
                            playableSet.notes.append(newNote)
                        }
                        destination.song.sequence.append(playableSet)
                    }
                    destination.newSong = false
                }
            }
        }
    }
}

