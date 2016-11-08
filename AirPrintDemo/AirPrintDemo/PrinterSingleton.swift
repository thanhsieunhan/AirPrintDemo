//
//  PrinterSingleton.swift
//  BootStrapDemo
//
//  Created by Lê Hà Thành on 11/7/16.
//  Copyright © 2016 Techmaster Vietnam. All rights reserved.
//

import UIKit

class PrinterSingleton{
    static let sharedInstance = PrinterSingleton()
    private init(){}
    var printer : UIPrinter?
    init(printer: UIPrinter) {
        self.printer = printer
    }
}
