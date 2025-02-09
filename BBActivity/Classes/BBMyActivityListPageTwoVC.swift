//
//  BBMyActivityListPageTwoVC.swift
//  bb_planet_ios
//
//  Created by 123 on 2025/1/3.
//

import UIKit
import JXSegmentedView
class BBMyActivityListPageTwoVC: BaseViewController {
    
    //活动类型,key-activityType(1 - 幸运活动,2 - 百人活动,3 - 竞拍活动)
    var activityType: Int = 0
    

    var titleData = [String]()
    
    var segmentedDataSource: JXSegmentedTitleDataSource!
    var segmentedView: JXSegmentedView!
    var listContainerView: JXSegmentedListContainerView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleData = ["rewar_key_2".local(),"BB"]
        
        //1、初始化JXSegmentedView
        segmentedView = JXSegmentedView()
        segmentedView.backgroundColor = .white.withAlphaComponent(0.1)
        segmentedView.layer.cornerRadius = 12
        segmentedView.layer.masksToBounds = true
        segmentedView.defaultSelectedIndex = 0
        segmentedView.frame = CGRect.init(x: kScreenW/2-103, y: kStatusBarH, width: 206, height: 38)
        
        //2、配置数据源
        segmentedDataSource = JXSegmentedTitleDataSource()
        segmentedDataSource.titleNormalFont = UIFont.boldSystemFont(ofSize: 15)
        segmentedDataSource.titleSelectedFont = UIFont.boldSystemFont(ofSize: 15)
        segmentedDataSource.titleNormalColor = .white.withAlphaComponent(0.6)
        segmentedDataSource.titleSelectedColor = .black
        segmentedDataSource.isTitleColorGradientEnabled = true
        segmentedDataSource.itemWidth = 103
        segmentedDataSource.itemSpacing = 0
        segmentedDataSource.titles = self.titleData
        segmentedView.dataSource = segmentedDataSource
        
        //4、配置JXSegmentedView的属性
        view.addSubview(segmentedView)
        
        //配置指示器
        let indicator = JXSegmentedIndicatorBackgroundView()
        indicator.indicatorHeight = 38
        indicator.indicatorCornerRadius = 12
        indicator.indicatorWidthIncrement = 0
        indicator.indicatorColor = UIColor.mainYellow
        segmentedView.indicators = [indicator]
        
        //5、初始化JXSegmentedListContainerView
        listContainerView = JXSegmentedListContainerView(dataSource: self)
        listContainerView.frame = CGRect.init(x: 0, y: kNavBarFullH, width: kScreenW, height: kScreenH-kNavBarFullH)
        listContainerView.backgroundColor = .clear
        //禁止列表容器左右滑动
        listContainerView.scrollView.isScrollEnabled = false
        view.addSubview(listContainerView)

        //6、将listContainerView.scrollView和segmentedView.contentScrollView进行关联
        segmentedView.listContainer = listContainerView
        
    }

}
extension BBMyActivityListPageTwoVC: JXSegmentedListContainerViewDataSource {
    func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
        return titleData.count
    }
    
    func listContainerView(_ listContainerView: JXSegmentedListContainerView, initListAt index: Int) -> JXSegmentedListContainerViewListDelegate {
        if index == 0 {
            let vc = BBMyActivityListPageVC()
            vc.coinType = .coin_MINERAIS
            vc.activityType = self.activityType
            return vc
        }
        else {
            let vc = BBMyActivityListPageVC()
            vc.coinType = .coin_BB
            vc.activityType = self.activityType
            return vc
        }
    }
}
