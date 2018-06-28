//
//  ViewController.swift
//  Calculator
//
//  Created by Matthew Green on 8/27/17.
//  Copyright © 2017 Matthew Green. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {

    @IBOutlet weak var calcDescription: UILabel!
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var variableDisplay: UILabel!
    
    var userIsInTheMiddleOfTyping = false
    
    var variables = Dictionary<String,Double>()
    
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!
            display.text = textCurrentlyInDisplay + digit
        } else {
            display.text = digit
            userIsInTheMiddleOfTyping = true
        }
    }
    
    var displayValue: Double? {
        get {
            return Double(display.text!)
        }
        set {
            if let val = newValue {
                display.text = String(val)
            }
        }
    }
    
    private var brain = CalculatorBrain()
    
    @IBAction func touchSetVariable(_ sender: UIButton) {
        brain.setOperand(variable: sender.currentTitle!)
        display.text = sender.currentTitle!
    }
    
    @IBAction func touchEvaluateWithVariable(_ sender: UIButton) {
        if let value = displayValue {
            let evalutation = brain.evaluate(using: ["M" : value])
            variables["M"] = value
            variableDisplay.text = "M = \(value)"
            userIsInTheMiddleOfTyping = false
            if let result = evalutation.result {
                display.text = String(result)
            }
        }
    }
    
    
    @IBAction func clearAll(_ sender: UIButton?) {
        brain = CalculatorBrain()
        display.text = " "
        userIsInTheMiddleOfTyping = false
        calcDescription.text = " "
        variables = Dictionary<String,Double>()
        variableDisplay.text = " "
    }
    
    @IBAction func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            if let operand = displayValue {
                brain.setOperand(operand)
            } else {
                clearAll(nil);
            }
            userIsInTheMiddleOfTyping = false
        }
        if let mathmaticalSymbol = sender.currentTitle {
            brain.performOperation(mathmaticalSymbol)
        }
        if let result = brain.evaluate(using: variables).result {
            displayValue = result
        }
        if let description = brain.description {
            if brain.resultIsPending ?? false {
                calcDescription.text = description + "..."
            } else {
                calcDescription.text = description + " ="
            }
        }
    }

}

