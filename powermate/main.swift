//
//  main.swift
//  powermate
//
//  Created by Jules Amalie on 2022/04/12.
//

import Cocoa
import Griffin

class GriffinDelegate: GriffinDeviceDelegate {
  private var precision: UInt
  private var knobValue: Int
  private var knobButtonState: Bool
  private var lastButtonChangeTime: Date
  
  init(precision: UInt = 3) {
    knobValue = 0
    knobButtonState = false
    lastButtonChangeTime = Date(timeIntervalSinceNow: 0)
    self.precision = precision
  }
  
  func griffinConnected(_ griffin: GriffinUSBDevice) -> Bool {
    print("Connected to new Griffin `\(griffin.name)` (VID: \(griffin.vendorId), PID: \(griffin.productId))")
    
    return true
  }
  
  func griffinDisconnected(_ deviceId: UInt64, _ isCurrentDevice: Bool) {
    print("Disconnected from Griffin (\(deviceId))")
    if isCurrentDevice {
      print("No device is currently selected")
    }
  }
  
  func griffinKnobTurn(_ offset: Int8) {
    let lastKnobValue = knobValue
    knobValue += Int(offset)
    
    if lastKnobValue != knobValue {
      print("New absolute knob value: \(knobValue)")
    }
  }
  
  func griffinButtonStateChanged(_ buttonState: Bool) {
    let currentTime = Date(timeIntervalSinceNow: 0)
    let lastState = knobButtonState
    
    knobButtonState = buttonState
    
    if lastState == true && knobButtonState == false {
      let plainTimeDifference = currentTime.timeIntervalSince(lastButtonChangeTime)
      
      let timeDifference = round(plainTimeDifference * pow(10, Double(precision))) / pow(10, Double(precision))
      
      print("")
      print("Button was held for: \(timeDifference) seconds")
      print("Current Time: \(currentTime)")
      print("Last Change Time: \(lastButtonChangeTime)")
    }
    
    if knobButtonState != lastState {
      print("")
      print("New button state: \(knobButtonState)")
      lastButtonChangeTime = currentTime
    }
  }
  
  func griffinErrorOccurred(_ error: GriffinDeviceError) {
    print("An error occurred: \(error)")
  }
}

let delegate = GriffinDelegate(precision: 2)
let powermate = GriffinDevice(delegate: delegate)
powermate.run()
