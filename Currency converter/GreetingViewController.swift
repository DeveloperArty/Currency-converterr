//
//  GreetingViewController.swift
//  Currency converter
//
//  Created by Artem Pavlov on 20.02.17.
//  Copyright © 2017 Den prod. All rights reserved.
//

import UIKit

class GreetingViewController: UIViewController {

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
    
    // Alert Controller
    func notifyAnError(errorMessage: String) {
        print("Oh..")
        let alertController = UIAlertController(title: "Unable to load currency rates",
                                                message: errorMessage,
                                                preferredStyle: .alert)
        let actionOK = UIAlertAction(title: "Ok",
                                     style: .default,
                                     handler: nil)
        alertController.addAction(actionOK)
        self.present(alertController,
                     animated: true,
                     completion: nil)
    }
}
