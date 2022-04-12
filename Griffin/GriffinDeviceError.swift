//
//  GriffinDeviceError.swift
//  Griffin
//
//  Created by Jules Amalie on 2022/04/12.
//

import Cocoa

public enum GriffinDeviceError {
  case deviceInterfaceNotFound
  case IOKitError(Int32)
}
