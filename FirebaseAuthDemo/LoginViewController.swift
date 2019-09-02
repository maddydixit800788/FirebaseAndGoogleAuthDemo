//
//  ViewController.swift
//  FirebaseAuthDemo
//
//  Created by Madhav on 25/08/19.
//  Copyright © 2019 Madhav. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class LoginViewController: UIViewController, GIDSignInDelegate {

    @IBOutlet weak var btnGoogleSignIn: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnGoogleSignIn.layer.masksToBounds = true
        btnGoogleSignIn.layer.cornerRadius = 5
        
        // set delegates
        GIDSignIn.sharedInstance().presentingViewController = self
        GIDSignIn.sharedInstance().delegate = self
        
        if(UserDefaults.standard.bool(forKey: "isLogin")) {
            activityIndicator.isHidden = false
            activityIndicator.color = UIColor.green
            print("Current Auth User : ",Auth.auth().currentUser?.displayName as Any)
            self.performSegue(withIdentifier: "segue_home", sender: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if(UserDefaults.standard.bool(forKey: "isLogin") == false) {
            activityIndicator.isHidden = true
        }
    }

    @IBAction func actionGoogleSignIn(_ sender: Any) {
        activityIndicator.isHidden = false
        activityIndicator.color = UIColor.yellow
        
        GIDSignIn.sharedInstance().signIn()
    }
    
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
        
        guard error == nil else {
            
            let alert = UIAlertController.init(title: "Google Sign In Error", message: "Error while trying to redirect.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction.init(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            present(alert, animated: true, completion: nil)
            
            print("Error while trying to redirect : \(String(describing: error))")
            return
        }
        
        print("Successful Redirection")
    }
    
    
    //MARK: GIDSignIn Delegate
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!)
    {
        if (error == nil) {
            // Perform any operations on signed in user here.
            let userId = user.userID                  // For client-side use only!
            print("User id is \(String(describing: userId))")
            UserDefaults.standard.set(true, forKey: "isLogin")
            
            let idToken = user.authentication.idToken // Safe to send to the server
            print("Authentication idToken is \(String(describing: idToken))")
            let fullName = user.profile.name
            print("User full name is \(String(describing: fullName))")
            let givenName = user.profile.givenName
            print("User given profile name is \(String(describing: givenName))")
            let familyName = user.profile.familyName
            print("User family name is \(String(describing: familyName))")
            let email = user.profile.email
            print("User email address is \(String(describing: email))")
            let accessToken = user.authentication.accessToken
            print("User accessToken is \(String(describing: accessToken))")
            
            guard let authentication = user.authentication else { return }
            let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                           accessToken: authentication.accessToken)
            print("User Name : ",credential.provider)
            
            Auth.auth().signIn(with: credential) { (authResult, error) in
                self.activityIndicator.isHidden = true
                if let error = error {
                    print("error in firebase auth : ",error.localizedDescription)
                    let alert = UIAlertController.init(title: "Google Sign In Error", message: "Error while trying to redirect.", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction.init(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                
                print("firebase user auth finish : ",authResult?.user.displayName as Any)
                self.performSegue(withIdentifier: "segue_home", sender: nil)
            }
            
        } else {
            activityIndicator.isHidden = true
            print("ERROR ::\(error.localizedDescription)")
            let alert = UIAlertController.init(title: "Google Sign In Error", message: "Error while trying to redirect.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction.init(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    // Finished disconnecting |user| from the app successfully if |error| is |nil|.
    public func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!)
    {
        print("User Name : ",user.userID as Any)
        UserDefaults.standard.set(false, forKey: "isLogin")
    }

}

