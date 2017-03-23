//
//  AddViewController.swift
//  semproject
//
//  Created by Sem Sturkenboom on 21-03-17.
//  Copyright © 2017 Sem Sturkenboom. All rights reserved.
//

import UIKit
import Firebase

class AddViewController: UIViewController {
    
    let user = FIRAuth.auth()?.currentUser
    
    @IBOutlet weak var symbol: UITextField!
    @IBAction func addStockToWatchlist(_ sender: Any) {
        apiRequest()
        }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? TableViewController {
            viewController.requestTable()
        }
    }
    
    func apiRequest() {
        
        // request stock data
        let string = symbol?.text
        let url = URL(string: "https://www.quandl.com/api/v3/datasets/WIKI/" + string!)
        
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil {
                print(error!)
            } else {
                do {
                    let json = try JSONSerialization.jsonObject(with: data!) as! [String: Any]
                    let dataset = json["dataset"] as? [String: Any]
                    let date = dataset!["newest_available_date"] as! String
                    let name = dataset!["name"]!
                    let symbol = dataset!["dataset_code"]!
                    
                    // save stock data to firebase database
                    let ref = FIRDatabase.database().reference()
                    let path = ref.child("users").child((self.user?.uid)!).child("symbols").childByAutoId()
                    path.setValue(["symbol":symbol])
                    path.child("date").setValue(date)
                    path.child("name").setValue(name)
                    
                    // perform segue after data previous task is completed
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "addStock", sender: Any?.self)
                    }
                    
                } catch let error as NSError {
                    print(error)
                }
            }
        }.resume()
        
    }
    
}
