//
//  GreetingViewController.swift
//  Currency converter
//
//  Created by Artem Pavlov on 20.02.17.
//  Copyright © 2017 Den prod. All rights reserved.
//

import UIKit

class GreetingViewController: UIViewController {

    // Outlets
    @IBOutlet weak var retryButton: UIButton!
    
    // Properties
    let currenciesSetup = CurrenciesSetup()
    var currencies: [String] = [] {
        willSet {
            if newValue.count == 1 {
                self.notifyAnError(errorMessage: newValue.first!)
            } else {
                self.performSegue(withIdentifier: "toViewController", sender: newValue)
                print("Currencies were loaded successfully")
            }
        }
    }

    // VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        retryButton.isEnabled = false
        retryButton.isHidden = true
        retryButton.layer.cornerRadius = retryButton.frame.height/2
        
        currenciesSetup.getCurrenciesList(senderVC: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard let vc = segue.destination as? ViewController else {
            return
        }
        vc.currencies = sender as! [String]
    }
    
    // UI Events
    @IBAction func retryButtonPressed(_ sender: UIButton) {
        currenciesSetup.getCurrenciesList(senderVC: self)
    }
    
    
    // Alert Controller
    func notifyAnError(errorMessage: String) {
        retryButton.isEnabled = true
        retryButton.isHidden = false
        let alertController = UIAlertController(title: "Unable To Load Currency Rates!",
                                                message: errorMessage,
                                                preferredStyle: .alert)
        let actionOK = UIAlertAction(title: "Oh...",
                                     style: .default,
                                     handler: nil)
        alertController.addAction(actionOK)
        self.present(alertController,
                     animated: true,
                     completion: nil)
    }
}
