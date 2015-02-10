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
    
    // Set Bools to keep track of if user is typing/if the user has already used the dot button
    var userIsInTheMiddleOfTypingANumber = false
    var userHasNotUsedDot = true
    
    // Function for typing numbers and the dot. If user is typing, appends String. Keeps track of whether dot has been used.
    @IBAction func appendDigit(sender: UIButton){
        if last(history.text!) == "=" {
            history.text = dropLast(history.text!)
        }
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
    
    // The calculator's memory of what has been entered previously - used to compute operations.
    var operandStack = Array<Double>()
    
    // List of operations to be performed. Resets userIsInTheMiddleOfTypingANumber to true.
    @IBAction func operate(sender: UIButton) {
        let operation = sender.currentTitle!
        history.text = history.text! + operation
        
        if userIsInTheMiddleOfTypingANumber == true {
            enter()
        }
        switch operation {
        case "×": performOperation { $0 * $1 }
        case "÷": performOperation { $1 / $0 }
        case "-": performOperation { $1 - $0 }
        case "+": performOperation { $0 + $1 }
        case "√": performOperation { sqrt($0) }
        case "π": displayValue = M_PI
        case "sin": performOperation { sin($0) }
        case "cos": performOperation { cos($0) }
        default: break
        }
        history.text! += "="
    }
    
    // How to perform operations that require two numbers. E.g. +, -, /, *
    func performOperation(operation: (Double, Double) -> Double) {
        if operandStack.count >= 2 {
            displayValue = operation(operandStack.removeLast(), operandStack.removeLast())
            enter()
        }
    }
    
    // How to perform operations that only require one number. E.g. sin, cos, sqrt
    func performOperation(operation: Double -> Double) {
        if operandStack.count >= 1 {
            displayValue = operation(operandStack.removeLast())
            enter()
        }
    }
    
    // When a person hits enter, add the display to the memory stack and reset the typing and dot booleans.
    @IBAction func enter() {
        userIsInTheMiddleOfTypingANumber = false
        userHasNotUsedDot = true
        operandStack.append(displayValue)
        history.text! += ("\(displayValue)")
    }
    
    // A go between for pulling from the display and pushing to the display
    var displayValue: Double {
        get {
            if let value = NSNumberFormatter().numberFromString(display.text!)?.doubleValue {
                return value
            } else {
                return 0
            }
        }
        set {
            display.text = "\(newValue)"
            operandStack.append(newValue)
            userIsInTheMiddleOfTypingANumber = false
        }
    }
    
    // When a person hits clear, the history and display labels should be clear and the two booleans should reset.
    @IBAction func clear() {
        display.text = "0"
        history.text = " "
        userIsInTheMiddleOfTypingANumber = false
        userHasNotUsedDot = true
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
}

