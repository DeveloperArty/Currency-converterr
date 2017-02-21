//
//  ViewController.swift
//  Currency converter
//
//  Created by Artem Pavlov on 20.02.17.
//  Copyright © 2017 Den prod. All rights reserved.
//

import UIKit

class ViewController: UIViewController{

    // Outlets
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var pickerFrom: UIPickerView!
    @IBOutlet weak var pickerTo: UIPickerView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // Properties
    var currenciesLoader = CurrenciesLoader()
    var currencies: [String] = []

    // VC Lifelcycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.label.text = "Тут будет курс"
        
        self.pickerTo.dataSource = self
        self.pickerFrom.dataSource = self
        
        self.pickerTo.delegate = self
        self.pickerFrom.delegate = self
        
        self.activityIndicator.hidesWhenStopped = true
        
        self.currenciesLoader.requestCurrentCurrencyRate(senderVC: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func currenciesExeptBase() -> [String] {
        
        var currenciesExeptBase = currencies
        currenciesExeptBase.remove(at: pickerFrom.selectedRow(inComponent: 0))
        
        return currenciesExeptBase
        
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
        
        self.currenciesLoader.requestCurrentCurrencyRate(senderVC: self)
    }
    
}
