//
//  ViewController.swift
//  soundBoard
//
//  Created by Cameron Krischel on 7/14/19.
//  Copyright © 2019 Cameron Krischel. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices

var player: AVQueuePlayer?

var soundFiles = [URL]()
var buttonNames = [String]()
var currentSoundList = [Int]()

let screenSize = UIScreen.main.bounds

var sequenceDisplay = UILabel()
var isPlaying = 2   // 0 = finished, 1 = playing, 2 = paused

var add = UIButton()
var remove = UIButton()
var toggle = UIButton()
var play = UIButton()
var stop = UIButton()
var reset = UIButton()

var darkGray = UIColor(red: 38/255, green: 38/255, blue: 38/255, alpha: 1.0)
var myGray = UIColor(red: 64/255, green: 64/255, blue: 64/255, alpha: 1.0)
var myPurple = UIColor(red: 189/255, green: 70/255, blue: 240/255, alpha: 1.0)
var myYellow = UIColor(red: 225/255, green: 195/255, blue: 50/255, alpha: 1.0)

var buttonArray = [UIButton]()

class ViewController: UIViewController, UIDocumentPickerDelegate
{
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //=======================================================================
//        downloadURL(myURL: "http://freetone.org/ring/stan/iPhone_5-Alarm.mp3")
//        downloadURL(myURL: "https://drive.google.com/open?id=1HPHq60yCTCVSVYeS171a17ToP-F71rhN")
        //=======================================================================
        
        //Player
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemDidReachEnd(notification:)),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: player?.currentItem)
        
        // Sequence Display
        sequenceDisplay = UILabel(frame: CGRect(x: screenSize.width/32, y: screenSize.width/32, width: screenSize.width*15/16, height: screenSize.height/4 - screenSize.width/16))
        sequenceDisplay.text = "Current Sequence\n"
        sequenceDisplay.textColor = .white
        sequenceDisplay.adjustsFontSizeToFitWidth = true
        sequenceDisplay.font = UIFont(name: sequenceDisplay.font.fontName, size: screenSize.height/32)
        sequenceDisplay.textAlignment = .center
        sequenceDisplay.numberOfLines = 10
        self.view.addSubview(sequenceDisplay)
        
        self.view.backgroundColor = darkGray
        
        // Make scrollview
        scrollView.frame = CGRect(x: 0, y: screenSize.height*2/8, width: screenSize.width, height: screenSize.height/2)
        scrollView.contentSize = CGSize(width: screenSize.width, height: screenSize.height/2)
        scrollView.layer.borderWidth = 4.0
        scrollView.layer.borderColor = UIColor.black.cgColor
        scrollView.backgroundColor = darkGray
        
        updateButtons()
        var buttonWidth = screenSize.width/3
        var buttonHeight = screenSize.width/3
        
        add = UIButton(frame: CGRect(x: 0, y: 0, width: buttonWidth/2, height: buttonHeight/2))
        add.center.x = screenSize.width*7/8
        add.center.y = screenSize.height*1/16
        add.layer.borderColor = myYellow.cgColor
        add.layer.borderWidth = 1.0
        add.setTitleColor(myYellow, for: .normal)
        add.backgroundColor = darkGray
        add.setTitle("Import", for: .normal)
        add.addTarget(self, action: #selector(clickFunction), for: .touchDown)
        add.titleLabel!.adjustsFontSizeToFitWidth = true
        add.titleLabel!.textAlignment = .center
        add.contentHorizontalAlignment = .center
        add.contentVerticalAlignment = .center
        self.view.addSubview(add)
        
        remove = UIButton(frame: CGRect(x: 0, y: 0, width: buttonWidth/2, height: buttonHeight/2))
        remove.center.x = screenSize.width*1/8
        remove.center.y = screenSize.height*1/16
        remove.layer.borderColor = myYellow.cgColor
        remove.layer.borderWidth = 1.0
        remove.setTitleColor(myYellow, for: .normal)
        remove.backgroundColor = darkGray
        remove.setTitle("Delete", for: .normal)
        remove.addTarget(self, action: #selector(removeSound), for: .touchDown)
        remove.titleLabel!.adjustsFontSizeToFitWidth = true
        remove.titleLabel!.textAlignment = .center
        remove.contentHorizontalAlignment = .center
        remove.contentVerticalAlignment = .center
        self.view.addSubview(remove)
        
        toggle = UIButton(frame: CGRect(x: 0, y: 0, width: buttonWidth*2, height: buttonHeight/2))
        toggle.center.x = screenSize.width/2
        toggle.center.y = toggle.frame.height + screenSize.height*3/4
        toggle.layer.borderColor = myYellow.cgColor
        toggle.layer.borderWidth = 1.0
        toggle.titleLabel!.numberOfLines = 2
        toggle.setTitleColor(myYellow, for: .normal)
        toggle.backgroundColor = darkGray
        toggle.setTitle("Toggle Mode\nSingle", for: .normal)
        toggle.addTarget(self, action: #selector(toggleMode), for: .touchDown)
        toggle.titleLabel!.adjustsFontSizeToFitWidth = true
        toggle.titleLabel!.textAlignment = .center
        toggle.contentHorizontalAlignment = .center
        toggle.contentVerticalAlignment = .center
        self.view.addSubview(toggle)
        
        play = UIButton(frame: CGRect(x: 0, y: 0, width: buttonWidth/3, height: buttonHeight/3))
        play.center.x = screenSize.width/2 + play.frame.width*2
        play.center.y = play.frame.height*6/2 + screenSize.height*3/4
        play.setTitleColor(myPurple, for: .normal)
        play.backgroundColor = darkGray
        play.setTitle("▶", for: .normal)
        play.addTarget(self, action: #selector(playSound), for: .touchDown)
        play.titleLabel!.font = UIFont.boldSystemFont(ofSize: buttonHeight/3)
        play.titleLabel!.adjustsFontSizeToFitWidth = true
        play.contentHorizontalAlignment = .center
        play.contentVerticalAlignment = .center
        self.view.addSubview(play)
        
        reset = UIButton(frame: CGRect(x: 0, y: 0, width: buttonWidth/3, height: buttonHeight/3))
        reset.center.x = screenSize.width/2 - reset.frame.width*2
        reset.center.y = reset.frame.height*6/2 + screenSize.height*3/4
        reset.setTitleColor(myPurple, for: .normal)
        reset.backgroundColor = darkGray
        reset.setTitle("⟲", for: .normal)//⌫
        reset.addTarget(self, action: #selector(resetSequence), for: .touchDown)
        reset.titleLabel!.font = UIFont.boldSystemFont(ofSize: buttonHeight/3)
        //UIFont(name: reset.titleLabel!.font.fontName, size: buttonHeight/3)
        reset.titleLabel!.adjustsFontSizeToFitWidth = true
        reset.contentHorizontalAlignment = .center
        reset.contentVerticalAlignment = .bottom
        self.view.addSubview(reset)
        
        stop = UIButton(frame: CGRect(x: 0, y: 0, width: buttonWidth/3, height: buttonHeight/3))
        stop.center.x = screenSize.width/2
        stop.center.y = stop.frame.height*6/2 + screenSize.height*3/4
        stop.setTitleColor(myPurple, for: .normal)
        stop.backgroundColor = darkGray
        stop.setTitle("■", for: .normal)
        stop.addTarget(self, action: #selector(stopSequence), for: .touchDown)
        stop.titleLabel!.font = UIFont.boldSystemFont(ofSize: buttonHeight/3)
        //UIFont(name: stop.titleLabel!.font.fontName, size: buttonHeight/3)
        stop.titleLabel!.adjustsFontSizeToFitWidth = true
        stop.contentHorizontalAlignment = .center
        stop.contentVerticalAlignment = .center
        self.view.addSubview(stop)
        
        if(screenSize.height/screenSize.width < 1.5)
        {
            toggle.center.y -= toggle.frame.height/2
            play.center.y -= toggle.frame.height/2
            reset.center.y -= toggle.frame.height/2
            stop.center.y -= toggle.frame.height/2
        }
    }
    @objc func removeSound()
    {
        if(buttonArray.count > 0)
        {
            var keepGoing = true
            for i in 0...buttonArray.count - 1
            {
                if(buttonArray[i].backgroundColor == myPurple && keepGoing)
                {
                    let fileManager = FileManager.default
                    do
                    {
                        try fileManager.removeItem(at: soundFiles[i])
                    }
                    catch let error as NSError
                    {
                        print(error.debugDescription)
                    }
                    keepGoing = false
                }
            }
            sequenceDisplay.text = "Current Sequence\n"
            player?.removeAllItems()
            stopSequence()
            updateButtons()
        }
    }
    @objc func addSoundToList(_ sender: UIButton)
    {
        for i in 0...buttonArray.count - 1
        {
            buttonArray[i].backgroundColor = myGray
        }
        sender.backgroundColor = myPurple
        if(toggle.titleLabel!.text == "Toggle Mode\nSingle")
        {
            stopSequence()
            currentSoundList.removeAll()
            sequenceDisplay.text = "Current Sequence\n"
        }
        
        print("Adding \(sender.tag)")
        
        if(currentSoundList.count > 0)
        {
            sequenceDisplay.text = sequenceDisplay.text! + " + "
        }
        sequenceDisplay.text = String(sequenceDisplay.text! + sender.titleLabel!.text!)
        
        currentSoundList.append(sender.tag)
    }
    @objc func resetSequence()
    {
        if(buttonArray.count > 0)
        {
            for i in 0...buttonArray.count - 1
            {
                buttonArray[i].backgroundColor = myGray
            }
            sequenceDisplay.text = "Current Sequence\n"
            currentSoundList.removeAll()
            stopSequence()
        }
    }
    @objc func toggleMode()
    {
        if(buttonArray.count > 0)
        {
            for i in 0...buttonArray.count - 1
            {
                buttonArray[i].backgroundColor = myGray
            }
            stopSequence()
            currentSoundList.removeAll()
            sequenceDisplay.text = "Current Sequence\n"
        }
            
        if(toggle.titleLabel!.text == "Toggle Mode\nSingle")
        {
            toggle.setTitle("Toggle Mode\nAdd to Sequence", for: .normal)
        }
        else
        {
            toggle.setTitle("Toggle Mode\nSingle", for: .normal)
        }
    }
    @objc func stopSequence()
    {
        player?.pause()
        player?.removeAllItems()
        isPlaying = 2
        play.setTitle("▶", for: .normal)
    }
    @objc func downloadURL(myURL: String)
    {
        if let audioUrl = URL(string: myURL)
        {
            let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent)
            print(destinationUrl)
            
            if FileManager.default.fileExists(atPath: destinationUrl.path)
            {
                print("The file already exists at path")
            }
            else
            {
                URLSession.shared.downloadTask(with: audioUrl) { location, response, error in
                guard let location = location, error == nil else { return }
                do
                {
                    // after downloading your file you need to move it to your destination url
                    try FileManager.default.moveItem(at: location, to: destinationUrl)
                    print("File moved to documents folder")
                    print("Your item is: \(audioUrl)")
                }
                catch
                {
                    print(error)
                }}.resume()
            }
        }
    }
    @objc func playSound()
    {
        if(!currentSoundList.isEmpty)
        {
            print("Not empty sound list")
            if(player?.currentItem == nil)      // If starting new
            {
                var queue = AVQueuePlayer()
                var itemList = [AVPlayerItem]()
                if(!soundFiles.isEmpty)
                {
                    for i in 0...currentSoundList.count - 1
                    {
                        let item = AVPlayerItem(url: soundFiles[currentSoundList[i]])
                        itemList.append(item)
                        print(soundFiles[currentSoundList[i]])
                    }
                    queue = AVQueuePlayer(items: itemList)
                    player = queue
                    player!.play()
                    
                    play.setTitle("Ⅱ", for: .normal)
                }
            }
            else if(isPlaying == 1)     // If paused
            {
                player?.play()
                isPlaying = 2
                if(play.titleLabel!.text == "▶")
                {
                    play.setTitle("Ⅱ", for: .normal)
                }
                else
                {
                    play.setTitle("▶", for: .normal)
                }
            }
            else if(isPlaying == 2)     // If playing
            {
                player?.pause()
                isPlaying = 1
                if(play.titleLabel!.text == "▶")
                {
                    play.setTitle("Ⅱ", for: .normal)
                }
                else
                {
                    play.setTitle("▶", for: .normal)
                }
            }
        }
    }
    @objc func playerItemDidReachEnd(notification: Notification)
    {
        if let playerItem = notification.object as? AVPlayerItem
        {
            playerItem.seek(to: CMTime.zero, completionHandler: nil)
            print("reached end")
            play.setTitle("▶", for: .normal)
        }
    }
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL)
    {
        if controller.documentPickerMode == UIDocumentPickerMode.import
        {
            
//            avItems.append(AVPlayerItem(url: url))
            do
            {
                let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                
                let destinationUrl = documentsDirectoryURL.appendingPathComponent(url.lastPathComponent)
                
                try FileManager.default.moveItem(at: url, to: destinationUrl)
                soundFiles.append(destinationUrl)
                buttonNames.append(destinationUrl.path.components(separatedBy: "/").last!.components(separatedBy: ".")[0])
                print("File moved to documents folder")
            }
            catch
            {
                print(error)
            }
            print("ZOOP")
            print(soundFiles.last)
            print(buttonNames.last)
            updateButtons()
        }
    }
    public func documentMenu(_ documentMenu:UIDocumentPickerViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController)
    {
        documentPicker.delegate = self as UIDocumentPickerDelegate
        present(documentPicker, animated: true, completion: nil)
    }
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController)
    {
        print("view was cancelled")
        dismiss(animated: true, completion: nil)
    }
    @objc func clickFunction()
    {
        let importMenu = UIDocumentPickerViewController(documentTypes: [kUTTypeMP3 as String], in: .import)
        importMenu.delegate = self as! UIDocumentPickerDelegate
        importMenu.modalPresentationStyle = .formSheet
        self.present(importMenu, animated: true, completion: nil)
    }
    @objc func updateButtons()
    {
        soundFiles.removeAll()
        buttonNames.removeAll()
        if(!buttonArray.isEmpty)
        {
            for i in 0...buttonArray.count - 1
            {
                buttonArray[i].removeFromSuperview()
            }
        }
        buttonArray.removeAll()
        
        // File Manager
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsUrl,
                                                                       includingPropertiesForKeys: nil,
                                                                       options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants])
            for fileURL in fileURLs
            {
                let suffix = String(fileURL.absoluteString).suffix(4)
                var components = String(fileURL.absoluteString).components(separatedBy: "/")
                if(suffix == ".mp3")
                {
                    print("Found \(components.last)")
                    soundFiles.append(fileURL)
                    buttonNames.append(components.last!.components(separatedBy: ".")[0])
                }
            }
        }
        catch  { print(error) }
        
        // Make all sound buttons
        var buttonWidth = screenSize.width/3
        var buttonHeight = screenSize.width/3
        if(!buttonNames.isEmpty)
        {
            for i in 0...buttonNames.count - 1
            {
                var testButton = UIButton(frame: CGRect(x: 0, y: 0, width: buttonWidth - 2, height: buttonHeight))
                testButton.center.x = buttonWidth/2 + CGFloat(i%3)*testButton.frame.width + 1
                testButton.center.y = CGFloat(i/3)*buttonHeight + testButton.frame.height/2
                testButton.layer.borderColor = UIColor.black.cgColor
                testButton.layer.borderWidth = 1.0
                testButton.tag = i
                testButton.titleLabel!.numberOfLines = 3
                testButton.setTitleColor(.white, for: .normal)
                testButton.backgroundColor = myGray
                testButton.setTitle(buttonNames[i], for: .normal)
                testButton.addTarget(self, action: #selector(addSoundToList(_:)), for: .touchDown)
                testButton.titleLabel!.adjustsFontSizeToFitWidth = true
                testButton.titleLabel!.textAlignment = .center
                testButton.contentHorizontalAlignment = .center
                testButton.contentVerticalAlignment = .center
                buttonArray.append(testButton)
                self.scrollView.addSubview(testButton)
            }
        }
        if(buttonNames.count/3 >= Int(screenSize.height/2/buttonHeight))
        {
            if(buttonNames.count % 3 != 0)
            {
                scrollView.contentSize = CGSize(width: screenSize.width, height: CGFloat(buttonNames.count/3 + 1)*buttonHeight)
            }
            else
            {
                scrollView.contentSize = CGSize(width: screenSize.width, height: CGFloat(buttonNames.count/3)*buttonHeight)
            }
        }
    }
    override var prefersStatusBarHidden: Bool
    {
        return true
    }
}
