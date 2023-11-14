//
//  FloorPlanViewController.swift
//  ReRoot
//
//  Created by Dhanunjay on 26/10/18.
//  Copyright © 2018 ReRoot. All rights reserved.
//

import UIKit
import SDWebImage

protocol FloorPlanDelegate : class {
    func deleteSelectedimage(imageUrl : String,selectedItemID : String)
}
extension FloorPlanDelegate{
    func deleteSelectedimage(imageUrl : String,selectedItemID : String){}
}
class FloorPlanViewController: UIViewController,UIScrollViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource {

    weak var delegate : FloorPlanDelegate?
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var collectionView: UICollectionView!
    var planType : PLAN_TYPE!
    var imageViewsArray : [UIImageView] = []
    var floorPlans : [String] = []
    var towerPlans : [String] = []
    var handOverImages : [String] = []
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var titleView: UIView!
    @IBOutlet weak var deleteButton: UIButton!
    var selectedHandOverItem : TowerHandOverItems!
//    self.selectedHandOverItem
    override func viewWillLayoutSubviews() {
        
        super.viewWillLayoutSubviews()
        
        titleView.clipsToBounds = true
        
        titleView.layer.masksToBounds = false
        titleView.layer.shadowColor = UIColor.lightGray.cgColor
        titleView.layer.shadowOffset = CGSize(width: 0, height: 2)
        
        titleView.layer.shadowOpacity = 0.4
        titleView.layer.shadowRadius = 1.0
        titleView.layer.shouldRasterize = true
        titleView.layer.borderColor = UIColor.lightGray.cgColor
        
        titleView.layer.shouldRasterize = true
        titleView.layer.rasterizationScale = UIScreen.main.scale
        self.view.bringSubviewToFront(titleView)
        
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }

        flowLayout.itemSize = collectionView.frame.size

        flowLayout.invalidateLayout()

        collectionView.collectionViewLayout.invalidateLayout()
        
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        let offset = collectionView.contentOffset
        let width  = collectionView.bounds.size.width

        let index = round(offset.x / width)
        let newOffset = CGPoint(x: index * size.width, y: offset.y)

        collectionView.setContentOffset(newOffset, animated: false)

        coordinator.animate(alongsideTransition: { (context) in
            self.collectionView.reloadData()

            self.collectionView.setContentOffset(newOffset, animated: false)
        }, completion: nil)
    }
    @objc func injected() {
        configureView()
    }
    func configureView(){
        print("")
    }
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if(planType == PLAN_TYPE.FLOOR_PLAN){
            pageControl.numberOfPages = floorPlans.count
            self.titleLabel.text = "Floor Plan"
            self.shouldShowDeleteButton(shouldShow: false)
            self.shouldShowPagination(shouldShow: true)
        }
        else if(planType == PLAN_TYPE.TOWER_PLAN){
            pageControl.numberOfPages = towerPlans.count
            self.titleLabel.text = "Tower Plan"
            self.shouldShowDeleteButton(shouldShow: false)
            self.shouldShowPagination(shouldShow: true)
        }
        else if(planType == PLAN_TYPE.HAND_OVER_ITEM){
            pageControl.numberOfPages = handOverImages.count
            self.titleLabel.text = "Images"
            self.shouldShowDeleteButton(shouldShow: true)
            self.shouldShowPagination(shouldShow: true)
        }
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName:"PlanPreViewCollectionViewCell", bundle: nil), forCellWithReuseIdentifier:"planCell")

    }
    func shouldShowPagination(shouldShow : Bool){
        if(shouldShow){
            pageControl.currentPage = 0
            view.bringSubviewToFront(pageControl)
            
            collectionView.isPagingEnabled = true
            
            pageControl.currentPage = 0
            pageControl.pageIndicatorTintColor = UIColor.gray
            pageControl.currentPageIndicatorTintColor = UIColor.green
        }
    }
    func shouldShowDeleteButton(shouldShow : Bool){
            self.deleteButton.isHidden = !shouldShow
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(planType == PLAN_TYPE.FLOOR_PLAN){
            return floorPlans.count
        }
        else if(planType == PLAN_TYPE.TOWER_PLAN){
            return towerPlans.count
        }
        else if(planType == PLAN_TYPE.HAND_OVER_ITEM){
            return handOverImages.count
        }
        else{
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "planCell", for: indexPath) as! PlanPreViewCollectionViewCell

        print(cell.imageView)
        print(cell.scrollView)
        
        var urlString : String = ""

        if(planType == PLAN_TYPE.FLOOR_PLAN)
        {
//            let floorPlan =  floorPlans[indexPath.row]
            urlString = floorPlans[indexPath.row] //floorPlan.url!
        }
        else if(planType == PLAN_TYPE.TOWER_PLAN){
            urlString = towerPlans[indexPath.row]
        }
        else if(planType == PLAN_TYPE.HAND_OVER_ITEM){
            urlString = handOverImages[indexPath.row]
        }
        
        if(urlString.count > 0){
            cell.layoutIfNeeded()
            // [NSURL URLWithString:[url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]]
//            print(URL(string: urlString.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)!))
            
            if(planType == PLAN_TYPE.HAND_OVER_ITEM){
                
                if(!urlString.hasPrefix("https")){
                    let imageData = try! Data(contentsOf: URL.init(string: urlString)!)
                    cell.imageView.image = UIImage(data: imageData)
                    return cell
                }
            }
            
            DispatchQueue.global().async {
                let url = ServerAPIs.getSingleSingedUrl(url: urlString)
                DispatchQueue.main.async {
                    cell.imageView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "project_image_default"), options:[.highPriority])
                }
            }

        }
        else {
            cell.imageView.image = UIImage.init(named: "project_image_default")
//            cell.imageView.contentMode = .center
        }

        return cell
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
        pageControl.pageIndicatorTintColor = UIColor.gray
        pageControl.currentPageIndicatorTintColor = UIColor.green
    }
    
    func setupFloorPlanImagesScrollView() {
        
        scrollView.isPagingEnabled = true
        scrollView.frame = view.frame
        scrollView.delegate = self
        
        scrollView.showsVerticalScrollIndicator = false;
        scrollView.showsHorizontalScrollIndicator = false;
        scrollView.bouncesZoom = true;
        scrollView.decelerationRate = .fast;

        var planImagesCount : Int = 0
        
        if(planType == PLAN_TYPE.FLOOR_PLAN){
            planImagesCount = floorPlans.count
        }
        else if(planType == PLAN_TYPE.TOWER_PLAN){
            planImagesCount = towerPlans.count
        }
        else if(planType == PLAN_TYPE.HAND_OVER_ITEM){
            planImagesCount = handOverImages.count
        }
        
        for i in 0..<planImagesCount{
            
            let imageView = UIImageView()
            
            if(planType == PLAN_TYPE.FLOOR_PLAN){
                
                DispatchQueue.global().async { [unowned self] in
                    let url = ServerAPIs.getSingleSingedUrl(url: self.floorPlans[i] )
                    DispatchQueue.main.async {
                        imageView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "project_image_default"), options:[.highPriority])
                    }
                }
            }
            else if(planType == PLAN_TYPE.TOWER_PLAN){
                
                DispatchQueue.global().async { [unowned self] in
                    let url = ServerAPIs.getSingleSingedUrl(url: self.towerPlans[i] )
                    DispatchQueue.main.async {
                        imageView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "project_image_default"), options:[.highPriority])
                    }
                }
                
//                imageView.sd_setImage(with: URL(string: towerPlans[i]), placeholderImage: UIImage(named: "project_image_default"), options:[.highPriority])
            }
            imageView.contentMode = .scaleAspectFit
            imageView.isUserInteractionEnabled = true
            
            let xPosition = self.view.frame.size.width * CGFloat(i)
            imageView.frame = CGRect(x: xPosition, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
            scrollView.contentSize.width = scrollView.frame.width * CGFloat(i+1)
            imageViewsArray.append(imageView)
            scrollView.addSubview(imageView)
        }
        
        print(imageViewsArray)
        
    }
    
    @IBAction func deleteImage(_ sender: Any) {
     
            // current index
        print(pageControl.currentPage)
        
        let alertController = UIAlertController(title: NSLocalizedString("Delete This Image?", comment: ""), message: NSLocalizedString("Click on OK to proceed deleting the image", comment: ""), preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("CANCEL", comment: ""), style: .cancel, handler: nil)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
            print("You've pressed default");
            
            if(self.selectedHandOverItem != nil){
                self.delegate?.deleteSelectedimage(imageUrl: self.handOverImages[self.pageControl.currentPage], selectedItemID: self.selectedHandOverItem.id!)
            }
            else{
                self.delegate?.deleteSelectedimage(imageUrl: self.handOverImages[self.pageControl.currentPage], selectedItemID: "")
            }
            print(self.handOverImages[self.pageControl.currentPage])
            let imageURL = self.handOverImages[self.pageControl.currentPage]
            self.handOverImages = self.handOverImages.filter({ $0 != imageURL})
            self.pageControl.numberOfPages = self.handOverImages.count
            self.collectionView.reloadData()
            if(self.handOverImages.count == 0){
                // go back
                self.back(UIButton())
            }
            
        }

        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    @IBAction func back(_ sender: Any) {
        if(planType == PLAN_TYPE.HAND_OVER_ITEM)
        {
            self.dismiss(animated: true, completion: nil)
            return
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
