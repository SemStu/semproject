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
        activityIndicator.startAnimating()
        requestData()
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
    
    func createApiUrl() -> URL {
        // request stock data
        let string = symbol.text
        let url = URL(string: "https://www.quandl.com/api/v3/datasets/WIKI/" + string! + ".json?api_key=L4HUSrsL-AA_jaMQhGaR")
        return url!
    }
    
    func requestData() {
        URLSession.shared.dataTask(with: createApiUrl()) { (data, response, error) in
            if error != nil {
                print(error!)
            } else {
                do {
                    let json = try JSONSerialization.jsonObject(with: data!) as! [String: Any]
                    let dataset = json["dataset"] as? [String: Any]?
                    
                    if let name = dataset??["name"] {
                        // substract companyname from output. example: "Apple Inc. (AAPL) > "Apple Inc."
                        let companyName = (name as AnyObject).components(separatedBy: "(")[0]
                        let symbol = dataset!?["dataset_code"]!
                    
                        // save stock data to firebase database
                        let path = FIRDatabase.database().reference().child("users").child((self.user?.uid)!).child("symbols").childByAutoId()
                        path.child("symbol").setValue(symbol)
                        path.child("name").setValue(companyName)
                  
                        // perform segue after data previous task is completed
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "addStock", sender: Any?.self)
                        }
                    }
                    else {
                        DispatchQueue.main.async {
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
