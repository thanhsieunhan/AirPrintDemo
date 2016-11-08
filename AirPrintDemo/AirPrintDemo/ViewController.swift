//
//  ViewController.swift
//  AppAirPrint
//
//  Created by Lê Hà Thành on 10/11/16.
//  Copyright © 2016 Lê Hà Thành. All rights reserved.
//

import UIKit

class ViewController: UIViewController{
    
    var imageView : UIImageView!
    var printer : UIPrinter!
    let arrayObj = ["TestPDF.pdf","TestImage.jpg","TestHTML.html"]
    let printerSingleton = PrinterSingleton.sharedInstance
    var i = 0
    var viewsection = ""
    var orientation = "landscape"
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        
        imageView.image = UIImage(named: "TestImage.jpg")
        
        let a = self.navigationItem.title!
        switch a {
        case "TestPDF":
            i = 0
            orientation = "landscape"
        case "TestImage":
            i = 1
            orientation = "landscape"
        case "TestHTML":
            i = 2
            orientation = "landscape"
            
        case "PDF":
            i = 0
            orientation = "portrait"
        case "Image":
            i = 1
            orientation = "portrait"
        case "HTML":
            i = 2
            orientation = "portrait"
            
        case "Print list of file":
            i = 3
        default: break
        }
        
        acitonPrint()
        
    }
    
    
    
    
    func  printerInfo(_ outputType: String) -> UIPrintInfo {
        let printInfo = UIPrintInfo.printInfo()
        if outputType == "photo" {
            printInfo.outputType = .photo
        } else {
            printInfo.outputType = .general
            
        }
        if orientation == "landscape" {
            printInfo.orientation = .landscape
            print(orientation)
        } else {
            printInfo.orientation = .portrait
            print(orientation)
        }
        
        printInfo.jobName = "My Print Job"
        return printInfo
    }
    
    @IBAction func printAction(_ sender: AnyObject) {
        // nếu phiên bản ios có thể dùng máy in :v chưa test

        acitonPrint()
    }
    
    func acitonPrint(){
        print(UIPrintInteractionController.isPrintingAvailable)
        
        let printController = UIPrintInteractionController.shared
        
        if i == 1 {
            printController.printInfo = printerInfo("photo")
            
            printController.printingItem = imageView.image
        } else if i == 0 {
            let pdfURL = URL(fileURLWithPath:Bundle.main.path(forResource: "TestPDF", ofType:"pdf")!)
            printController.printInfo = printerInfo("")
            printController.printingItem = pdfURL
        } else if i == 2 {
            printHTML(printController)
        } else {
            printController.printInfo = printerInfo("")
            let pdfURL = URL(fileURLWithPath:Bundle.main.path(forResource: "TestPDF", ofType:"pdf")!)
            printController.printingItems = [pdfURL, pdfURL, pdfURL, pdfURL]
        }
        
        // 4
        if let printer = printerSingleton.printer {
            
            printController.print(to: printer, completionHandler: nil)
        } else {
            print("No printer")
        }
    }
    
    
    func printHTML(_ printController: UIPrintInteractionController) {
        let testHTML = Bundle.main.path(forResource: "TestHTML", ofType: "html")
        let baseURL = URL(fileURLWithPath: testHTML!)
        let contents = try! String(contentsOf: baseURL, encoding: String.Encoding.utf8)
        
        let formatter = UIMarkupTextPrintFormatter(markupText: contents)
        printController.printFormatter = formatter
        
        printController.printInfo = printerInfo("")
        
    }
    
}

