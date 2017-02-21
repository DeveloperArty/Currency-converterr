//
//  ViewController.swift
//  Currency converter
//
//  Created by Artem Pavlov on 20.02.17.
//  Copyright © 2017 Den prod. All rights reserved.
//

import UIKit

class ViewController: UIViewController, CurrenciesListRequester {

    // Outlets
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var pickerFrom: UIPickerView!
    @IBOutlet weak var pickerTo: UIPickerView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // Properties
    let currenciesSetup = CurrenciesSetup() 
    var currencies: [String] = [] {
        willSet {
            if let firstElement = newValue.first {
                switch firstElement {
                case "No currencies found", "No \"rates\" field found", "No JSON value parsed":
                    self.notifyAnError(errorMessage: firstElement)
                default:
                    DispatchQueue.main.async(execute: {
                        self.pickerTo.reloadAllComponents()
                        self.pickerFrom.reloadAllComponents()
                        self.requestCurrentCurrencyRate()
                    })
                    print("Currencies were loaded successfully")
                }
            }
        }
    }

    // VC Lifelcycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.label.text = "Тут будет курс"
        
        self.pickerTo.dataSource = self
        self.pickerFrom.dataSource = self
        
        self.pickerTo.delegate = self
        self.pickerFrom.delegate = self
        
        self.activityIndicator.hidesWhenStopped = true
        
        self.currenciesSetup.getCurrenciesList(senderVC: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Curr Gett
    func currenciesExeptBase() -> [String] {
        guard currencies.isEmpty == false else {
            return []
        }
        var currenciesExeptBase = currencies
        currenciesExeptBase.remove(at: pickerFrom.selectedRow(inComponent: 0))
        
        return currenciesExeptBase
        
    }
    
    func parseCurrencyRatesResponce(data: Data?, toCurrency: String) -> String {
        var value = ""
        
        do {
            let json = try JSONSerialization.jsonObject(with: data!, options: []) as? Dictionary<String, Any>
            
            if let parsedJSON = json {
                if let rates = parsedJSON["rates"] as? Dictionary<String, Double> {
                    if let rate = rates[toCurrency] {
                        value = "\(rate)"
                    } else {
                        value = "No rate for currency \"\(toCurrency)\" found"
                    }
                } else {
                    value = "No \"rates\" field found"
                }
            } else {
                value = "No JSON value parsed"
            }
        } catch {
            value = error.localizedDescription
        }
        
        return value
    }
    
    func getCurrencyRates(baseCurrency: String, pasreHandler: @escaping (Data?, Error?) -> Void) {
        let url = URL(string: "https://api.fixer.io/latest?base=" + baseCurrency)!
        
        let dataTask = URLSession.shared.dataTask(with: url) { (dataReceived, response, error) in
            pasreHandler(dataReceived, error)
        }
        
        dataTask.resume()
    }
    
    func retreiveCurrencyRate(baseCurrency: String, toCurrency: String, completion: @escaping (String) -> Void) {
        self.getCurrencyRates(baseCurrency: baseCurrency) { [weak self] (data, error) in
            var string = "No currency retrieved!"
            
            if let currentError = error {
                string = currentError.localizedDescription
            } else {
                if let strongSelf = self {
                    string = strongSelf.parseCurrencyRatesResponce(data: data, toCurrency: toCurrency)
                }
            }
            
            completion(string)
        }
    }
    
    func requestCurrentCurrencyRate() {
        self.activityIndicator.startAnimating()
        self.label.text = ""
        
        let baseCurrencyIndex = self.pickerFrom.selectedRow(inComponent: 0)
        let toCurrencyIndex = self.pickerTo.selectedRow(inComponent: 0)
        
        let baseCurrency = self.currencies[baseCurrencyIndex]
        let toCurrency = self.currenciesExeptBase()[toCurrencyIndex]
        
        
        self.retreiveCurrencyRate(baseCurrency: baseCurrency, toCurrency: toCurrency) { [weak self] (value) in
            DispatchQueue.main.async(execute: {
                if let strongSelf = self {
                    strongSelf.label.text = value
                    strongSelf.activityIndicator.stopAnimating()
                }
            })
            
        }
    }
    
    // UI Notifications
    func notifyAnError(errorMessage: String) {
        print("Oh..")
        let alertController = UIAlertController(title: "Unable to load currency rates",
                                                message: errorMessage,
                                                preferredStyle: .alert)
        let actionOK = UIAlertAction(title: "Ok..",
                                     style: .default,
                                     handler: nil)
        alertController.addAction(actionOK)
        self.present(alertController,
                     animated: true,
                     completion: nil)
    }
}

// MARK: UIPickerViewDataSource
extension ViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == pickerTo {
            return currenciesExeptBase().count
        }
        
        return self.currencies.count
    }
    
}

// MARK: UIPickerViewDelegate
extension ViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == pickerTo {
            return self.currenciesExeptBase()[row]
        }
        
        return currencies[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == pickerFrom {
            self.pickerTo.reloadAllComponents()
        }
        
        if currencies.isEmpty == false {
            self.requestCurrentCurrencyRate()
        }
    }
    
}
