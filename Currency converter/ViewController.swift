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
    @IBOutlet weak var fromCurrencyLabel: UILabel!
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // Properties
    var currenciesLoader = CurrenciesLoader()
    var currencies: [String] = []

    // VC Lifelcycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.label.text = "Тут будет курс"
        
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        
        self.activityIndicator.hidesWhenStopped = true
        self.currenciesLoader.requestCurrentCurrencyRate(senderVC: self)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fromCurrencyLabel.text = currencies[pickerView.selectedRow(inComponent: 0)] + "  ="
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func currenciesExeptBase() -> [String] {
        var currenciesExeptBase = currencies
        currenciesExeptBase.remove(at: pickerView.selectedRow(inComponent: 0))
        return currenciesExeptBase
    }
    
}

// MARK: UIPickerViewDataSource
extension ViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 1 {
            return currenciesExeptBase().count
        }
        
        return self.currencies.count
    }
    
}

// MARK: UIPickerViewDelegate
extension ViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 1 {
            return self.currenciesExeptBase()[row]
        }
        
        return currencies[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            self.pickerView.reloadAllComponents()
            fromCurrencyLabel.text = currencies[row] + "  ="
        }
            
        self.currenciesLoader.requestCurrentCurrencyRate(senderVC: self)
        
    }
    
//    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
//        let view = UIView(frame: CGRect(x: 0, y: 0, width: pickerView.frame.width, height: 40))
//        view.backgroundColor = UIColor.darkGray
//        return view
//    }
    
}
