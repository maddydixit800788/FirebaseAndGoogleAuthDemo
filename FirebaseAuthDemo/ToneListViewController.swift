//
//  ToneListViewController.swift
//  FirebaseAuthDemo
//
//  Created by Madhav on 25/08/19.
//  Copyright © 2019 Madhav. All rights reserved.
//

import UIKit

class ToneListViewController: UIViewController {

    let arrTones = ["bird_tone","dj_snake","hiyonat","iphone_7_remix","iphone_dhol","iphone_tone1","iphone_tone2","iphone_tone3","iphone_tone4","lai_lai",
    "mission_impossible","naalo_chilipi","nokia_n91","ooh_aina_nai","romantic_tone","run_away","shayari_ringtone"]
    var arrSelectedTones = NSMutableArray()
    
    @IBOutlet weak var tonesTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tonesTableView.tableFooterView = UIView()
    }
    
    @IBAction func backAction(_ sender: Any) {
        let dic = NSDictionary.init(dictionary: ["SelectedArray":arrSelectedTones])
        NotificationCenter.default.post(name: NSNotification.Name.init("SelectedTonesNotification"), object: nil, userInfo:dic as? [AnyHashable : Any])
        navigationController?.popViewController(animated: true)
    }
}

extension ToneListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrTones.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tonesTableView.dequeueReusableCell(withIdentifier: "TVCell", for: indexPath)
        
        cell.textLabel?.text = arrTones[indexPath.row]
        if (arrSelectedTones.contains(arrTones[indexPath.row])) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected index : ",indexPath.row)
        if (arrSelectedTones.contains(arrTones[indexPath.row])) {
            arrSelectedTones.remove(arrTones[indexPath.row])
        } else {
            arrSelectedTones.add(arrTones[indexPath.row])
        }
        
        tonesTableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
    }
    
}
