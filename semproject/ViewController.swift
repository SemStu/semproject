//
//  ViewController.swift
//  semproject
//
//  Created by Sem Sturkenboom on 20-03-17.
//  Copyright © 2017 Sem Sturkenboom. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {
    
    static let kUserLoggedInSegueIdentifier = "userLoggedIn"
    

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    //reference to the last signed in user to compare
    weak var currentUser: FIRUser?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let auth = FIRAuth.auth() {
            
            /* Add a state change listener to firebase
             to get a notification if the user signed in.
             */
            auth.addStateDidChangeListener({ (auth, user) in
                if user != nil && user != self.currentUser {
                    self.currentUser = user
                    self.performSegue(withIdentifier: ViewController.kUserLoggedInSegueIdentifier,
                                      sender: self)
                }
            })
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if let auth = FIRAuth.auth() {
            /* Following the balance principle in iOS,
             Stop listening to user state changes while not on screen.
             */
            auth.removeStateDidChangeListener(self)
        }
    }
    
    @IBAction func login() {
        if let email = self.emailField.text,
            let password = self.passwordField.text,
            let auth = FIRAuth.auth() {
            
            /* If both email and password fields are not empty,
             call firebase signin
             */
            auth.signIn(withEmail: email,
                        password: password)
            
        }
    }
    
    @IBAction func register() {
        if let email = self.emailField.text,
            let password = self.passwordField.text,
            let auth = FIRAuth.auth() {
            /* Note: creating a user automatically signs in.
             */
            auth.createUser(withEmail: email,
                            password: password) { user, error in
                                if error != nil {
                                    print(error)
                                    self.present(UIAlertController(coder: error as! NSCoder)!,
                                                 animated: true,
                                                 completion: nil)
                                }
            }
        }
    }
    
    @IBAction func signOut(segue: UIStoryboardSegue) {
        /* When Sign out is pressed, and the task list controller closes,
         call Firebase sign out.
         */
        if let auth = FIRAuth.auth() {
            do {
                try auth.signOut()
                print("signed out")
            } catch {
                print(error)
                self.present(UIAlertController(title: "Error",
                                               message: error as? String,
                                               preferredStyle: UIAlertControllerStyle.alert),
                             animated: true,
                             completion: nil)
            }
        }
    }
    
    
}
