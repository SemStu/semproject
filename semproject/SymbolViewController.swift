//
//  SymbolViewController.swift
//  semproject
//
//  Created by Sem Sturkenboom on 27-03-17.
//  Copyright © 2017 Sem Sturkenboom. All rights reserved.
//

import UIKit

class SymbolViewController: UIViewController {
    
    var historicaldata: Any = ""
    
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var volume: UILabel!
    @IBOutlet weak var lastTradingDate: UILabel!
    @IBOutlet weak var marketCap: UILabel!
    @IBOutlet weak var dividendPayDate: UILabel!
    @IBOutlet weak var dividendYield: UILabel!
    @IBOutlet weak var previousClose: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
