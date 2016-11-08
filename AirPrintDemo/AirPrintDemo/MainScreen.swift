//
//  MainScreen.swift
//  TechmasterSwiftApp


import UIKit

class MainScreen: UITableViewController {
    var about: String!
    
    var menu: [MenuSection]!
    var barButtonItem: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        barButtonItem = UIBarButtonItem(title: "Scan", style: UIBarButtonItemStyle.plain, target: self, action: #selector(MainScreen.onAbout))
        self.navigationItem.rightBarButtonItem = barButtonItem
        
        self.tableView.contentInset = UIEdgeInsetsMake(20,0,0,0)
        
    }
    
    func onAbout(){
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
                        
                    } else {
                        print("Printer is not selected")
                    }
                }
            }
            break
        case .pad:
            printerPicker.present(from: barButtonItem, animated: true, completionHandler: { (printerPickerController, didselect, error) in
                if error != nil {
                    print("Error : \(error)")
                } else {
                    if let printerSelected : UIPrinter = printerPickerController.selectedPrinter {
                        let printerSingleton = PrinterSingleton.sharedInstance
                        printerSingleton.printer = printerSelected
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

    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return menu.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        let menuSection: MenuSection  = self.menu[section]
        let menuArray: [Menu] = menuSection.menus
        
        return menuArray.count
    }
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 15.0
    }
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let menuSection: MenuSection = self.menu[section]
        return menuSection.section
    }

    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "id")
        let menuSection: MenuSection = self.menu[(indexPath as NSIndexPath).section]
        let menuItems = menuSection.menus
        let item: Menu = menuItems[(indexPath as NSIndexPath).row]
        cell.textLabel!.text = item.title
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let menuSection: MenuSection = self.menu[(indexPath as NSIndexPath).section]
        let menuItems = menuSection.menus

        let item: Menu = menuItems[(indexPath as NSIndexPath).row]
        
        
        let xibClass = item.viewClass
        let detailScreen: UIViewController!
        
        if let storyBoard = item.storyBoard {
            let storyboardObject = UIStoryboard(name: storyBoard, bundle: nil)
            detailScreen = storyboardObject.instantiateViewController(withIdentifier: item.storyBoardID!)
            detailScreen.title = item.title
            
            self.navigationController!.pushViewController(detailScreen, animated: true)
        } else {
  
            let appName =  Bundle.main.infoDictionary!["CFBundleName"] as! String
            // check if class exits
            if let aClass = NSClassFromString("\(appName).\(xibClass)") as? UIViewController.Type {
           
                if (Bundle.main.path(forResource: xibClass, ofType: "nib") == nil){
                    //if the xib file does not exits
                    detailScreen = aClass.init() as UIViewController
                }else{
                    detailScreen = aClass.init(nibName:xibClass,bundle:nil) as UIViewController
                    
                }
                
                self.navigationController!.pushViewController(detailScreen, animated: true)
                
            } else {
                let alert = UIAlertController.init(title: "Warning",
                                                   message: "Please implement screen \(xibClass)",
                                                   preferredStyle: .alert)
                
                let defaultAction = UIAlertAction.init(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
                
                alert.addAction(defaultAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
        
    }
    
}
