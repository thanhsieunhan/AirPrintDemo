//
//  ViewController.swift
//  AppAirPrint
//
//  Created by Lê Hà Thành on 10/11/16.
//  Copyright © 2016 Lê Hà Thành. All rights reserved.
//

import UIKit

class FilePrint {
    var nameFile = ""
    var fileOfType = ""
    
    init(stringPath: String){
        let nameAndType = stringPath.components(separatedBy: ".")
        self.nameFile = nameAndType[0]
        self.fileOfType = nameAndType[1]
    }
}

class PrintList: UIViewController{
    
    @IBOutlet weak var namePrint: UILabel!
    @IBOutlet weak var scanButton: UIButton!
    
    var printer : UIPrinter?
    
    var filePrints = [FilePrint]()
    var numsOfFile = 0
    let printInteraction = UIPrintInteractionController.shared
    let printerSingleton = PrinterSingleton.sharedInstance
    let paths = ["TestPDF.pdf",
                 "TestHTML.html",
                 "TestPDF1.pdf",
                 "TestPDF2.pdf",
                 "TestImage.jpg"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        numsOfFile = filePrints.count
        
        // Notification Center
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(PrintList.catchNotification),
                                       name: NSNotification.Name(rawValue: "SilentPrintProgress"),
                                       object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if printerSingleton.printer == nil {
            showPrinterPicker()
            namePrint.text = "nil"
        } else {
            printer = printerSingleton.printer
            namePrint.text = printer?.displayName
        }
    }
    
    func catchNotification(notification:NSNotification) -> Void {
        print("=============================================")
        if let userInfo = notification.userInfo {
            if let eventType = userInfo["eventType"] {
                print("eventType: ", eventType)
            }
            
            if let eventData = userInfo["eventData"] {
                print("eventData: ", eventData)
            }
            
            if let errorReason = userInfo["errorReason"] {
                print("errorReason: ", errorReason)
            }
        }
        print("=============================================")
        
        
        
    }
    
    
    func  printerInfo(_ outputType: String) -> UIPrintInfo {
        let printInfo = UIPrintInfo.printInfo()
        if outputType == "jpg" {
            printInfo.outputType = .photo
        } else {
            printInfo.outputType = .general
        }
        
        printInfo.jobName = "My Print Job"
        
        return printInfo
    }
    
    
    @IBAction func startPrint1(_ sender: AnyObject) {
        printer = printerSingleton.printer
        if printer != nil {
            silentPrint(paths, timeInterval: 1000)
        } else {
            print("Please scan print")
        }
    }
    
    
    /**
     - Parameter fileNums: location in array
     */
    func printFile(_ fileNums : Int, timeInterval interval: Int = 0){
        // lấy file theo mảng
        let file = filePrints[fileNums]
        
        // set info
        let info = self.printerInfo(file.fileOfType)
        
        printInteraction.printInfo = info
        
        switch file.fileOfType {
        case "pdf":
            printInteraction.printingItem = printPDF(file.nameFile)
        case "html":
            printInteraction.printFormatter = printHTML(file.nameFile)
        case "jpg":
            printInteraction.printingItem = printImage(file.nameFile)
        default:
            print("Không hỗ trợ định dạng \(file.fileOfType)")
            break
        }
        
        printInteraction.print(to: printer!) { (_, complete, error) in
            if error != nil{
                let dataDict = ["eventType": ["printFailed"], "errorReason": ["\(error)"]]
                self.postNotificationCenter(dataDict)
            } else if complete {
                var dataDict = [String: [String]]()
                if interval != 0 {
                    let precent = Float(fileNums+1)/Float(self.filePrints.count) * 100
                    dataDict = ["eventType": ["numberFinished", "precentDone"], "eventData": ["\(fileNums+1) of files printed", "\(precent) % complete"]]
                } else {
                    dataDict = ["eventType": ["numberFinished"], "eventData": ["\(fileNums+1) of files printed"]]
                }
                self.postNotificationCenter(dataDict)
                if fileNums >= self.filePrints.count-1 {
                    let dataDict = ["eventType": ["printComplete"], "eventData": ["Success"]]
                    self.postNotificationCenter(dataDict)
                    return
                }
                DispatchQueue.main.async {
                    self.printFile(fileNums+1, timeInterval: interval)
                }
            }
        }
    }
    
    
    
    /**
     - Parameter nameHTML: Name of file HTML
     */
    func printHTML(_ nameHTML: String) -> UIMarkupTextPrintFormatter{
        let htmlPath = Bundle.main.path(forResource: nameHTML, ofType: "html")
        let htmlURL = URL(fileURLWithPath: htmlPath!)
        let contents = try! String(contentsOf: htmlURL, encoding: String.Encoding.utf8)
        
        let formatter = UIMarkupTextPrintFormatter(markupText: contents)
        return formatter
        
    }
    
    /**
     - Parameter namePDF: Name of file PDF
     */
    func printPDF(_ namePDF: String) -> URL{
        return URL(fileURLWithPath: Bundle.main.path(forResource: namePDF, ofType: "pdf")!)
    }
    
    /**
     - Parameter nameImage: Name of file Image
     */
    func printImage(_ nameImage: String) -> UIImage {
        return UIImage(named: nameImage+".jpg")!
    }
    
    /**
     - Parameter filePaths: NSArray chứa mảng String về full filePath của file cần copy
     
     - Parameter interval:	NSInteger in milliseconds used to post “silentPrintProgress” notifications if non-zero. Otherwise, this parameter is ignored
     */
    func silentPrint(_ filePaths: [String], timeInterval interval: Int = 0) {
        filePrints = [FilePrint]()
        for file in filePaths {
            let objPrint = FilePrint(stringPath: file)
            filePrints.append(objPrint)
        }
        printFile(0, timeInterval: interval)
        
    }
    
    @IBAction func scanPrint(_ sender: AnyObject) {
        showPrinterPicker()
    }
    
    func showPrinterPicker() {
        let printerPicker = UIPrinterPickerController(initiallySelectedPrinter: nil)
        switch traitCollection.userInterfaceIdiom {
        case .phone:
            printerPicker.present(animated: true) { (printerPickerController, didselect, error) in
                if error != nil {
                    print("Error : \(error)")
                } else {
                    if let printerSelected : UIPrinter = printerPickerController.selectedPrinter {
                        let printerSingleton = PrinterSingleton.sharedInstance
                        printerSingleton.printer = printerSelected
                        self.namePrint.text = printerSelected.displayName
                        
                    } else {
                        print("Printer is not selected")
                    }
                }
            }
            break
        case .pad:
            printerPicker.present(from: self.scanButton.frame, in: self.view , animated: true, completionHandler: { (printerPickerController, didselect, error) in
                if error != nil {
                    print("Error : \(error)")
                } else {
                    if let printerSelected : UIPrinter = printerPickerController.selectedPrinter {
                        let printerSingleton = PrinterSingleton.sharedInstance
                        printerSingleton.printer = printerSelected
                        self.namePrint.text = printerSelected.displayName
                    } else {
                        print("Printer is not selected")
                    }
                }
            })
            break
        default:
            break
        }
    }
    
    func postNotificationCenter(_ dataDict: [String: [String]]){
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "SilentPrintProgress"), object: nil, userInfo: dataDict)
    }
}

