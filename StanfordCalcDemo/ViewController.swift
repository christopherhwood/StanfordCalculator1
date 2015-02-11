//
//  ViewController.swift
//  StanfordCalcDemo
//
//  Created by Christopher Wood on 2/10/15.
//  Copyright (c) 2015 Christopher Wood. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var history: UILabel!
    
    // Set Bools to keep track of if user is typing/if the user has already used the dot button, set up brain
    var userIsInTheMiddleOfTypingANumber = false
    var userHasNotUsedDot = true
    let brain = CalculatorBrain()
    
    // Function for typing numbers and the dot. If user is typing, appends String. Keeps track of whether dot has been used.
    @IBAction func appendDigit(sender: UIButton){
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTypingANumber && userHasNotUsedDot {
            display.text = display.text! + digit
            if digit == "." {
                userHasNotUsedDot = false
            }
        } else if userIsInTheMiddleOfTypingANumber && userHasNotUsedDot == false {
            if digit != "." {
                display.text = display.text! + digit
            }
        } else{
            display.text = digit
            userIsInTheMiddleOfTypingANumber = true
            if digit == "." {
                userHasNotUsedDot = false
            }
        }
    }
    
    // If the last value in the history label is "=", then delete it. Updates history label to show operation and an equals sign. Resets userIsInTheMiddleOfTypingANumber to true. Enter is pressed, then the operation is performed in brain.
    @IBAction func operate(sender: UIButton) {
        let operation = sender.currentTitle!
        if userIsInTheMiddleOfTypingANumber == true {
            enter()
        }
        displayValue = brain.performOperation(operation)
        if let historyNote = brain.description {
            history.text = historyNote + "="
        } else {
            history.text = " "
        }
    }
    
    
    // When a person hits enter, add the display to the memory stack and reset the typing and dot booleans. Operand is pushed through brain, added to opStack.
    @IBAction func enter() {
        userIsInTheMiddleOfTypingANumber = false
        userHasNotUsedDot = true
        displayValue = brain.pushOperand(displayValue!)
    }
    
    // The on display, in the form of an optional Double rather than a String.
    var displayValue: Double? {
        get {
            if let value = NSNumberFormatter().numberFromString(display.text!)?.doubleValue {
                return value
            } else {
                return nil
            }
        }
        set {
            if let value = newValue {
                display.text = "\(value)"
            } else{
                display.text = "Error"
            }
            userIsInTheMiddleOfTypingANumber = false
        }
    }
    
    // When a person hits clear, the history and display labels should be clear and the two booleans should reset. The brain's opStack is cleared.
    @IBAction func clear() {
        display.text = "0"
        history.text = " "
        userIsInTheMiddleOfTypingANumber = false
        userHasNotUsedDot = true
        brain.clear()
    }
    
    // When a person hits backspace, the last digit entered will disappear. If everything is backspaced, a 0 will appear in the display.
    @IBAction func backspace() {
        if countElements(display.text!) > 1 {
            if last(display.text!) == "." {
                userHasNotUsedDot = true
            }
            display.text = dropLast(display.text!)
        } else{
            display.text = "0"
            userHasNotUsedDot = true
            userIsInTheMiddleOfTypingANumber = false
        }
    }
    
    // When a person hits the +- button, the sign of the number in the display will change.
    @IBAction func changeSign() {
        if first(display.text!) != "-" {
            display.text!.insert("-", atIndex: display.text!.startIndex)
        } else{
            display.text = dropFirst(display.text!)
        }
    }
    
    // Save what is in the display as variable M
    @IBAction func saveVariable() {
        if let value = displayValue {
            brain.variableValues["M"] = value
        }
        displayValue = brain.pushOperand("M")
        userIsInTheMiddleOfTypingANumber = false
    }
    
    @IBAction func appendVariable() {
        displayValue = brain.pushOperand("M")
    }
}

