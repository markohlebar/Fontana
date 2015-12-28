//
//  ViewController.swift
//  Spreadit
//
//  Created by Marko Hlebar on 28/10/2015.
//  Copyright © 2015 Marko Hlebar. All rights reserved.
//

import UIKit
import BIND
import TSMessages

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var historyStack : FNTHistoryStack;
    
    required init(coder aDecoder: NSCoder) {
        historyStack = FNTHistoryStack(forGroup: "group.com.fontanakey.app")
        super.init(coder: aDecoder)!
    
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadData", name: UIApplicationWillEnterForegroundNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        reloadData()
        self.navigationItem.title = "History"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reloadData() {
//        let keyboardBundleID = "com.fontanakey.app.keyboard"
//        print("Keyboard is enabled \(NSUserDefaults.isKeyboardEnabled(keyboardBundleID)) \nfull access is allowed \(NSUserDefaults.isFullAccessAllowed(keyboardBundleID))")
//
//        if NSUserDefaults.isKeyboardEnabled(keyboardBundleID) {
//            self.collectionView.reloadData()
//        }
//        else {
//            self.showTutorial()
//        }
        
        self.collectionView.reloadData()

    }
    
    func showTutorial() {
        self.performSegueWithIdentifier("PresentTutorial", sender: self)
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let nibName = "FNTKeyboardItemCell"
        registerNib(nibName)
        
        let cell : BNDCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(nibName, forIndexPath: indexPath) as! BNDCollectionViewCell

        cell.viewModel = viewModels().objectAtIndex(indexPath.item) as! FNTKeyboardItemCellModel
        
        return cell;
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let viewModel = self.viewModels().objectAtIndex(indexPath.item) as! FNTKeyboardItemCellModel;
        copyURLToPasteboard(viewModel.url)
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
    }
    
    func copyURLToPasteboard(url : NSURL) {
        UIPasteboard.generalPasteboard().URL = url;
        TSMessage.showNotificationInViewController(self.navigationController,
            title: "Link copied to clipboard.",
            subtitle: nil,
            image: nil,
            type: .Success,
            duration: 1.0,
            callback: nil,
            buttonTitle: nil,
            buttonCallback: nil,
            atPosition: .NavBarOverlay,
            canBeDismissedByUser: false)
    }
    
    func registerNib(cellName : String) {
        let nib = UINib(nibName: cellName, bundle: NSBundle.mainBundle())
        self.collectionView.registerNib(nib, forCellWithReuseIdentifier: cellName)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModels().count
    }
    
    func textViewDidChange(textView: UITextView) {
        reloadData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let flowLayout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        
        var itemSize = self.view.frame.size;
        itemSize.width = self.isPortrait() ? itemSize.width : itemSize.width / 2
        itemSize.height = 80
        flowLayout.itemSize = itemSize
        
        flowLayout.invalidateLayout()
    }
    
    func isPortrait() -> Bool {
        let boundsSize : CGSize = UIScreen.mainScreen().bounds.size
        return Float(self.view.frame.size.width) == fminf(Float(boundsSize.width), Float(boundsSize.height))
    }
    
    func viewModels() -> NSArray {
        let items = self.historyStack.allItems
        
        guard items != nil else {
            return NSArray()
        }
        
        let viewModels = NSMutableArray()
        
        for item in items {
            let viewModel = FNTKeyboardItemCellModel(model: item)
            viewModels.addObject(viewModel)
        }
        
        return viewModels.copy() as! NSArray
    }
}

