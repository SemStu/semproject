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
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var symbol: UITextField!
    @IBAction func addStockToWatchlist(_ sender: Any) {
        apiRequest()
    }

    override func viewDidLoad() {
        
        activityIndicator.hidesWhenStopped = true;
        activityIndicator.activityIndicatorViewStyle  = UIActivityIndicatorViewStyle.gray;
        activityIndicator.center = view.center;
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
        activityIndicator.startAnimating()
        let string = symbol.text
        let url = URL(string: "https://www.quandl.com/api/v3/datasets/WIKI/" + string! + ".json?api_key=L4HUSrsL-AA_jaMQhGaR")
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil {
                print(error!)
            } else {
                do {
                    let json = try JSONSerialization.jsonObject(with: data!) as! [String: Any]
                    let incorrectsymbol = json["quandl_error"] as? [String: Any]
                    
                    // check if symbol is valid
                    if incorrectsymbol == nil {
                        let dataset = json["dataset"] as? [String: Any]
                        let date = dataset!["newest_available_date"]
                        let name = dataset!["name"]
                        let companyName = (name as AnyObject).components(separatedBy: "(")[0]
                        let historicaldata = dataset!["data"]
                        print(historicaldata!)
                        let symbol = dataset!["dataset_code"]!
                    
                        // save stock data to firebase database
                        let ref = FIRDatabase.database().reference()
                        let path = ref.child("users").child((self.user?.uid)!).child("symbols").childByAutoId()
                        path.child("symbol").setValue(symbol)
                        path.child("date").setValue(date)
                        path.child("name").setValue(companyName)
                  
                        // perform segue after data previous task is completed
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "addStock", sender: Any?.self)
                        }
                    }
                    else {
                        DispatchQueue.main.async {
                            print("incorrect symbol")
                            self.symbol.text = ""
                            self.activityIndicator.stopAnimating()
                        }
                    }
                } catch let error as NSError {
                    print(error)
                }
            }
        }.resume()
    }
    
}
