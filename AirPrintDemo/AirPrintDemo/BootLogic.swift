//
//  BootLogic.swift
//  TechmasterSwiftApp
//  Techmaster Vietnam

import UIKit
class BootLogic: NSObject {
    
    var menu : [MenuSection]!
    class func boot(_ window:UIWindow){
        let portrait = MenuSection(section: "A4 portrait", menus:[
            Menu(title: "PDF", viewClass: "ViewController", storyBoard: "Main", storyBoardID: "Test"),
            Menu(title: "Image", viewClass: "ViewController", storyBoard: "Main", storyBoardID: "Test"),
            Menu(title: "HTML", viewClass: "ViewController", storyBoard: "Main", storyBoardID: "Test")

            
            ])

        let lanscape = MenuSection(section: "A4 lanscape", menus:[
            Menu(title: "TestPDF", viewClass: "ViewController", storyBoard: "Main", storyBoardID: "Test"),
            Menu(title: "TestImage", viewClass: "ViewController", storyBoard: "Main", storyBoardID: "Test"),
            Menu(title: "TestHTML", viewClass: "ViewController", storyBoard: "Main", storyBoardID: "Test")
            ])
        
        let manyfile = MenuSection(section: "other print", menus:[
            Menu(title: "Print list of file", viewClass: "PrintList", storyBoard: "PrintList", storyBoardID: "PrintList"),
        ])
        
        let mainScreen = MainScreen(style: UITableViewStyle.grouped)
        mainScreen.menu = [portrait, lanscape, manyfile]
        mainScreen.title = "Air Print Test"
        mainScreen.about = "Gesture Recognizer iOS8"
        
        let nav = UINavigationController(rootViewController: mainScreen)
        
        window.rootViewController = nav        
      
    }   
}
