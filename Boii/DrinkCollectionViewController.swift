//
//  DrinkCollectionViewController.swift
//  Boii
//
//  Created by Harin Sanghirun on 4/2/58.
//  Copyright (c) พ.ศ. 2558 Harin Sanghirun. All rights reserved.
//

import UIKit

private let reuseIdentifier = "drinkMenuCell"

class DrinkCollectionViewController:
    UICollectionViewController,
    UICollectionViewDelegateFlowLayout {
    
    let defaultThumbnail : UIImage? = UIImage(named: "starbuck_coffee.jpg")

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.title = "starbuck"

        // Do any additional setup after loading the view.
        
        let barButton = CartBarButtonItem() as CartBarButtonItem
        barButton.viewController = self
        barButton.isLoggedIn = true
        
        self.tabBarController?.navigationItem.rightBarButtonItem = barButton
        
//        self.edgesForExtendedLayout = UIRectEdge.All
//        self.collectionView?
        
            //UIEdgeInsetsMake(0.0, 0.0, CGRectGetHeight(self.tabBarController?.tabBar.frame.height), 0.0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as MenuCollectionViewCell
        
        cell.priceLabel.text = "$500"
        cell.titleLabel.text = "CoCoCrunchies"
        cell.initImage("starbuck_coffee.jpg")
        
        return cell
    }
    
    

    // MARK: UICollectionViewDelegate

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
     /*
        let contentView = UIView()
        contentView.backgroundColor = UIColor.redColor()
        contentView.layer.cornerRadius = 12.0
        contentView.setTranslatesAutoresizingMaskIntoConstraints(false)
        contentView.contentMode = .ScaleAspectFill
        contentView.frame = CGRectMake(0.0, 0.0, 300.0, 400.0)
        
        let imgView = UIImageView(image: defaultThumbnail)
        let addButton = UIButton.buttonWithType( UIButtonType.Custom ) as UIButton
        
        addButton.addTarget(self, action: "addButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        addButton.setTitle("add to Cart", forState: UIControlState.Normal)
        addButton.backgroundColor = UIColor.greenColor()
        addButton.setTranslatesAutoresizingMaskIntoConstraints(false)

        
        let cancelButton = UIButton.buttonWithType(UIButtonType.Custom) as UIButton
        cancelButton.addTarget(self, action: "cancelButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        cancelButton.setTitle("Cancel", forState: UIControlState.Normal)
        cancelButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        cancelButton.backgroundColor = UIColor.purpleColor()
        
        contentView.addSubview(imgView)
        contentView.addSubview(addButton)
        contentView.addSubview(cancelButton)
//        
        let views = ["imgView":imgView, "addButton":addButton, "cancelButton":cancelButton]
//
        let buttonsHorizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|[addButton][cancelButton(==addButton)]|",
            options: NSLayoutFormatOptions.AlignAllCenterY, metrics: nil, views: views)

        let imageViewVerticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|[imgView(200)][addButton]|",
            options: nil, metrics: nil, views: views)

        let imageViewHorizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|[imgView(300)]|",
            options: NSLayoutFormatOptions.AlignAllCenterY, metrics: nil, views: views)
        
//
        contentView.addConstraints(buttonsHorizontalConstraints)
        contentView.addConstraints(imageViewVerticalConstraints)
        contentView.addConstraints(imageViewHorizontalConstraints)
        */
        
        
        let contentView = NSBundle.mainBundle().loadNibNamed("MenuDetailView", owner: self, options: nil).first as UIView

        
        let imageView = contentView.viewWithTag(301) as UIImageView
        imageView.image = defaultThumbnail?.crop( imageView.bounds )

        
        let addToCartButton = contentView.viewWithTag(401) as UIButton
        addToCartButton.addTarget(self, action: "addButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        let cancelButton = contentView.viewWithTag(402) as UIButton
        cancelButton.addTarget(self, action: "cancelButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        
        
        let popup = KLCPopup(contentView: contentView)
        popup.show()
        
    }
    
    func cancelButtonPressed(sender: AnyObject) {
        if sender is UIView {
            sender.dismissPresentingPopup()
        }
    }
    
    func addButtonPressed(sender: AnyObject) {
        println("addButtonPressed")
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    private let sectionInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0,right: 0)
    private let interitemSpacing: CGFloat = 0.5
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let width = self.view.frame.width / 2 -  interitemSpacing
        let height = (4 * width) / 3
        
        return CGSize(width: width, height: height)
    }
    
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return interitemSpacing
    }
    
    
    

}
