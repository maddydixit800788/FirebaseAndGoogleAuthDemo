//
//  MainViewController.swift
//  FirebaseAuthDemo
//
//  Created by Madhav on 25/08/19.
//  Copyright © 2019 Madhav. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import AVFoundation

let PlaySound = "PlaySound"
let TrueUsers = "TrueUsers"
let StatusOnline = "Online"
let StatusOffine = "Offline"
let DateFormate = "yyyy-MM-dd HH:mm:ss"

class MainViewController: UIViewController {
    
    @IBOutlet weak var lblNoSelected: UILabel!
    @IBOutlet weak var tonesCollectionView: UICollectionView!
    var player: AVAudioPlayer?
    var lastCustomCell: CustomCell?
    var arrSelectedTone = NSMutableArray()
    var timer = Timer()
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        let uid = Auth.auth().currentUser?.uid ?? "-NA-"
        
        print("Current uid : ",uid)
        
        let name = Auth.auth().currentUser?.displayName ?? "-NA-"
        
        print("Current user name : ",name)
        
        self.tonesCollectionView.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(receiveNotificationCenter(_:)), name: NSNotification.Name.init(rawValue: "SelectedTonesNotification"), object: nil)
        
        setCurrentUesrIsOnline(uid,name)
        getActiveUsers()
        getSyncingTone()
    }
    
    func setCurrentUesrIsOnline(_ userId:String, _ userName:String) {
        self.ref.child(TrueUsers).child(userId).setValue(["username": userName, "status": StatusOnline])
    }
    
    func getActiveUsers() {
        self.ref.child("TrueUsers").observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            print("All Users : ",value as Any)
        }) { (error) in
            print("error in firebase database : ",error.localizedDescription)
        }
    }
    
    func getSyncingTone() {
        self.ref.child(PlaySound).observe(.value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let soundName = value?["soundName"] as? String ?? ""
            print("Selected Sound Name : ",soundName)
            
            let fireDate = value?["fireDate"] as? String ?? ""
            print("Fire Date : ",fireDate)
            
            let userId = value?["userId"] as? String ?? ""
            
            let dateFormatterGet = DateFormatter()
            dateFormatterGet.dateFormat = DateFormate
            
            let date2 = Date()
            
            if let date1 = dateFormatterGet.date(from: fireDate) {
                if (userId != Auth.auth().currentUser?.uid) {
                    if date1 > date2  {
                        if (self.arrSelectedTone.contains(soundName)) {
                            print("Play Sound")
                            self.playSongWithTitle(soundName)
                            self.blinkSelectedButton(soundName, date1)
                            self.timer.invalidate()
                            self.timer = Timer(fireAt: date1, interval: 0, target: self, selector: #selector(self.runCode), userInfo: nil, repeats: false)
                            RunLoop.main.add(self.timer, forMode: .common)
                        } else {
                            print("this sound Not selected")
                        }
                    } else {
                        print("this is old Date")
                    }
                }
            } else {
                print("There was an error decoding the string")
            }
            
        }) { (error) in
            print("error in firebase database : ",error.localizedDescription)
        }
    }
    
    @objc func receiveNotificationCenter(_ notification:Notification) {
        let dic = notification.userInfo! as NSDictionary
        let arrSelectedTone = dic.object(forKey: "SelectedArray") as! NSArray
        print("Selected Notification : ",arrSelectedTone)
        
        if (self.arrSelectedTone.count > 0) {
            self.arrSelectedTone.removeAllObjects()
        }
        
        if (arrSelectedTone.count>0) {
            for str in arrSelectedTone {
                self.arrSelectedTone.add(str as! String)
            }
            self.tonesCollectionView.isHidden = false
        } else {
            self.tonesCollectionView.isHidden = true
        }
        
        tonesCollectionView.reloadData()
    }
    
    @IBAction func actionSignOut(_ sender: Any) {
        GIDSignIn.sharedInstance().signOut()
        do{
            try Auth.auth().signOut()
        } catch let error {
            print(error.localizedDescription)
        }
        UserDefaults.standard.set(false, forKey: "isLogin")
        navigationController?.popViewController(animated: true)
    }

}

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, CustomCellDelegate, AVAudioPlayerDelegate {
    
    func playPauseAction(CustomCell customCell: CustomCell, IsPlaying isPlaying: Bool) {
        let index = tonesCollectionView.indexPath(for: customCell)
        
        if (isPlaying) {
            customCell.btnPlayPause.setImage(UIImage.init(named: "icon_play"), for: UIControl.State.normal)
            player?.pause()
        } else {
            let soundName = arrSelectedTone.object(at: index!.row) as! String
            playSongWithTitle(soundName)
            customCell.btnPlayPause.setImage(UIImage.init(named: "icon_pause"), for: UIControl.State.normal)
        }
        
        customCell.btnPlayPause.blink(duration: 0.3, stopAfter: 5.0)
        
        print("selected Index : ",index?.row ?? 0)
        
        let currentDate = Date()
        
        print("Current Time : \(currentDate.toString(dateFormat: DateFormate))")
        
        let date = Date().addingTimeInterval(5)
        
        let strDate = date.toString(dateFormat: DateFormate)
        
        let soundName = arrSelectedTone.object(at: index!.row) as! String
        
        let userId = Auth.auth().currentUser?.uid ?? "-NA-"
        
        self.ref.child(PlaySound).setValue(["soundName": soundName, "fireDate": strDate, "userId": userId])
        
        print("Adding '15' Sec into Current time : ",strDate)
        
        timer.invalidate()
        timer = Timer(fireAt: date, interval: 0, target: self, selector: #selector(runCode), userInfo: nil, repeats: false)
        RunLoop.main.add(timer, forMode: .common)
        
        if (lastCustomCell != nil && lastCustomCell != customCell) {
            stopPreviusTone(lastCustomCell!)
        }
        
        lastCustomCell = customCell
    }
    
    @objc func runCode() {
        player?.play()
    }
    
    func blinkSelectedButton(_ soundName: String, _ fireDate: Date) {
        let index = arrSelectedTone.index(of: soundName)
        let cellIndex = IndexPath(row: index, section: 0)
        let cell = tonesCollectionView.cellForItem(at: cellIndex) as! CustomCell
        let elapsed = fireDate.timeIntervalSince(Date())
        lastCustomCell = cell
        
        cell.btnPlayPause.setImage(UIImage.init(named: "icon_pause"), for: UIControl.State.normal)
        cell.btnPlayPause.blink(duration: 0.3, stopAfter: elapsed)
    }
    
    func stopPreviusTone(_ lastCustomCell:CustomCell) {
        lastCustomCell.isPlaying = false
        lastCustomCell.btnPlayPause.setImage(UIImage.init(named: "icon_play"), for: UIControl.State.normal)
        lastCustomCell.btnPlayPause.blink(enabled:false)
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        lastCustomCell?.isPlaying = false
        lastCustomCell?.btnPlayPause.setImage(UIImage.init(named: "icon_play"), for: UIControl.State.normal)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrSelectedTone.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = tonesCollectionView.dequeueReusableCell(withReuseIdentifier: "CVCell", for: indexPath) as! CustomCell
        
        cell.contentView.layer.masksToBounds = true
        cell.contentView.layer.cornerRadius = 10
        
        cell.lblTitle.text = arrSelectedTone.object(at: indexPath.row) as? String ?? "-NA-"
        cell.delegate = self
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (tonesCollectionView.frame.size.width/3)-7, height: (tonesCollectionView.frame.size.width/3)-7)
    }
    
    func playSongWithTitle(_ songTitle:String) {
        guard let url = Bundle.main.url(forResource: songTitle, withExtension: "mp3") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            if (player != nil) {
                player = nil
            }
            
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            player?.delegate = self
        } catch let error {
            print(error.localizedDescription)
        }
    }
}

extension Date {
    
    func toString( dateFormat format  : String ) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}

extension UIButton {
//    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
//        return self.bounds.contains(point) ? self : nil
//    }
    func blink(enabled: Bool = true, duration: CFTimeInterval = 1.0, stopAfter: CFTimeInterval = 0.0 ) {
        enabled ? (UIView.animate(withDuration: duration, //Time duration you want,
            delay: 0.0,
            options: [.curveEaseInOut, .autoreverse, .repeat],
            animations: { [weak self] in self?.alpha = 0.0 },
            completion: { [weak self] _ in self?.alpha = 1.0 })) : self.layer.removeAllAnimations()
        if !stopAfter.isEqual(to: 0.0) && enabled {
            DispatchQueue.main.asyncAfter(deadline: .now() + stopAfter) { [weak self] in
                self?.layer.removeAllAnimations()
            }
        }
    }
}
