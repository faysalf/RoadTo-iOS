//
//  ViewController.swift
//  Slide-Collection-View
//
//  Created by Md. Faysal Ahmed on 25/10/22.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var img0: UIImageView!
    @IBOutlet weak var img1: UIImageView!
    @IBOutlet weak var img2: UIImageView!
    @IBOutlet weak var img3: UIImageView!
    
    @IBOutlet weak var pageView: UIPageControl!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: Constraints update for relatable devices
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var view1TopConstraint: NSLayoutConstraint!
    @IBOutlet weak var view2Constraint: NSLayoutConstraint!
    @IBOutlet weak var view3Constraint: NSLayoutConstraint!
    @IBOutlet weak var view4Constraint: NSLayoutConstraint!
    @IBOutlet weak var submitTopConst: NSLayoutConstraint!
    @IBOutlet weak var submitBottomConst: NSLayoutConstraint!
    @IBOutlet weak var submitHeightConst: NSLayoutConstraint!
    
    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var view3: UIView!
    @IBOutlet weak var view4: UIView!
    
    @IBOutlet weak var lbl11: UILabel!
    @IBOutlet weak var lbl12: UILabel!
    @IBOutlet weak var lbl21: UILabel!
    @IBOutlet weak var lbl22: UILabel!
    @IBOutlet weak var lbl31: UILabel!
    @IBOutlet weak var lbl32: UILabel!
    @IBOutlet weak var lbl41: UILabel!
    @IBOutlet weak var lbl42: UILabel!
    
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var smallLabel: UILabel!
    @IBOutlet weak var smallLabel2: UILabel!
    @IBOutlet weak var recommendLable: UILabel!
    @IBOutlet weak var noCommit: UILabel!
    
    let images = [UIImage(named: "a"),
                  UIImage(named: "b"),
                  UIImage(named: "c"),
                  UIImage(named: "d"),
                  UIImage(named: "e"),
                  UIImage(named: "f"),
                  UIImage(named: "g")]
                    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCollectionView()
        timeToScroll()
        corenerRadius()
        submitButton.pulsate()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if view.frame.width <= 380 {
            view1TopConstraint.constant =  20
            view2Constraint.constant = 11
            view3Constraint.constant = 13
            view4Constraint.constant = 12
            submitTopConst.constant = 26
            submitBottomConst.constant = 10
            submitHeightConst.constant = 45
            collectionViewHeightConstraint.constant = 200
        }

    }
    

    func corenerRadius(){
        let viewArr = [view1, view2, view3, view4, smallLabel, smallLabel2]
        for v in viewArr {
            v?.layer.cornerRadius = 10
            v?.layer.masksToBounds = true
        }
        submitButton.layer.cornerRadius = 25
        
    }
    
    func setUpCollectionView() {
        let nib = UINib(nibName: "CollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "cell")
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    @IBAction func btnCancel_click(_ sender: UIButton) {
        print("Button Pressed")
    }
    
    // MARK: submit button bounce on user interaction
//    @IBAction func btnCancel_click(_ sender: UIButton) {                  // MARK: On click
//        submitButton.transform = CGAffineTransform(scaleX: 0.50, y: 0.50)
//        UIView.animate(withDuration: 3.0,
//                       delay: 0,
//                       usingSpringWithDamping: 0.3,
//                       initialSpringVelocity: 2.0,
//                       options: .allowUserInteraction,
//                       animations: { [weak self] in
//            self?.submitButton.transform = .identity
//        },
//                       completion: nil)
//    }
    
    // MARK: Without Click - Button Bouncing
//    func animateLabels() {
//        UIView.animate(withDuration: 0.1, delay: 0, options: [.repeat, .autoreverse], animations: {
//            self.submitButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
//        })
//    }
    
    
    // MARK: Auto-slider
    
    var timer = Timer()
    var counter = 0
    
    func timeToScroll() {
        pageView.numberOfPages = images.count
        pageView.currentPage = 0
        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(self.changeImage), userInfo: nil, repeats: true)
        }
    }
    @objc func changeImage() {
             
         if counter < images.count {
              let index = IndexPath.init(item: counter, section: 0)
              self.collectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: true)
              pageView.currentPage = counter
              counter += 1
         } else {
              counter = 0
              let index = IndexPath.init(item: counter, section: 0)
              self.collectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: false)
               pageView.currentPage = counter
               counter = 1
           }
      }
    
    // MARK: Selection button action
    @IBAction func buttonAction(_ sender: UIButton){
        
        let btnTag = sender.tag
        
        img0.image = img0.image?.withRenderingMode(.alwaysTemplate)
        img1.image = img1.image?.withRenderingMode(.alwaysTemplate)
        img2.image = img2.image?.withRenderingMode(.alwaysTemplate)
        img3.image = img3.image?.withRenderingMode(.alwaysTemplate)
        
        switch btnTag {
        case 0:
            img0.tintColor = UIColor.black
            img1.tintColor = UIColor.systemGray2
            img2.tintColor = UIColor.systemGray2
            img3.tintColor = UIColor.systemGray2
            
            lbl11.textColor = UIColor.black
            lbl12.textColor = UIColor.black
            lbl21.textColor = UIColor.darkGray
            lbl22.textColor = UIColor.darkGray
            lbl31.textColor = UIColor.darkGray
            lbl32.textColor = UIColor.darkGray
            lbl41.textColor = UIColor.darkGray
            lbl42.textColor = UIColor.darkGray
            
            view1.layer.borderWidth = 2
            view2.layer.borderWidth = 0
            view3.layer.borderWidth = 0
            view4.layer.borderWidth = 0
            noCommit.textColor = UIColor.darkGray
            break
        case 1:
            img0.tintColor = UIColor.systemGray2
            img1.tintColor = UIColor.black
            img2.tintColor = UIColor.systemGray2
            img3.tintColor = UIColor.systemGray2
            
            lbl11.textColor = UIColor.darkGray
            lbl12.textColor = UIColor.darkGray
            lbl21.textColor = UIColor.black
            lbl22.textColor = UIColor.black
            lbl31.textColor = UIColor.darkGray
            lbl32.textColor = UIColor.darkGray
            lbl41.textColor = UIColor.darkGray
            lbl42.textColor = UIColor.darkGray
            
            view1.layer.borderWidth = 0
            view2.layer.borderWidth = 2
            view3.layer.borderWidth = 0
            view4.layer.borderWidth = 0
            noCommit.textColor = UIColor.darkGray
            break
        case 2:
            img0.tintColor = UIColor.systemGray2
            img1.tintColor = UIColor.systemGray2
            img2.tintColor = UIColor.black
            img3.tintColor = UIColor.systemGray2
            
            lbl11.textColor = UIColor.darkGray
            lbl12.textColor = UIColor.darkGray
            lbl21.textColor = UIColor.darkGray
            lbl22.textColor = UIColor.darkGray
            lbl31.textColor = UIColor.black
            lbl32.textColor = UIColor.black
            lbl41.textColor = UIColor.darkGray
            lbl42.textColor = UIColor.darkGray
            
            view1.layer.borderWidth = 0
            view2.layer.borderWidth = 0
            view3.layer.borderWidth = 2
            view4.layer.borderWidth = 0
            noCommit.textColor = UIColor.darkGray
            break
        default:
            img0.tintColor = UIColor.systemGray2
            img1.tintColor = UIColor.systemGray2
            img2.tintColor = UIColor.systemGray2
            img3.tintColor = UIColor.black
            
            lbl11.textColor = UIColor.darkGray
            lbl12.textColor = UIColor.darkGray
            lbl21.textColor = UIColor.darkGray
            lbl22.textColor = UIColor.darkGray
            lbl31.textColor = UIColor.darkGray
            lbl32.textColor = UIColor.darkGray
            lbl41.textColor = UIColor.black
            lbl42.textColor = UIColor.black
            
            view1.layer.borderWidth = 0
            view2.layer.borderWidth = 0
            view3.layer.borderWidth = 0
            view4.layer.borderWidth = 2
            noCommit.textColor = UIColor.systemBackground
            break
        }
    }

}

extension ViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        cell.img.image = images[indexPath.row]
        
        return cell
    }

}

extension ViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

}
// MARK: Submit Button Bouncing without user interaction
extension UIView {
    func pulsate() {
        
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = 1.0
        pulse.fromValue = 0.95
        pulse.toValue = 1.1
        pulse.autoreverses = true
        pulse.repeatCount = 1000
        pulse.initialVelocity = 0.5
        pulse.damping = 8.2
        
        layer.add(pulse, forKey: "pulse")
    }
}
