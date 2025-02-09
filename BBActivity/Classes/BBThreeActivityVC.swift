//
//  BBThreeActivityVC.swift
//  bb_planet_ios
//
//  Created by 123 on 2024/12/18.
//

import UIKit
import JXSegmentedView

class BBThreeActivityVC: BaseViewController {

    var titleData = [String]()
    
    var segmentedDataSource: JXSegmentedTitleDataSource!
    var segmentedView: JXSegmentedView!
    var listContainerView: JXSegmentedListContainerView!
    
    var activityType: ActivityType?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //处于第一个item的时候，才允许屏幕边缘手势返回
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = (self.segmentedView.selectedIndex == 0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .color0A0A14
        self.titleData = ["rewar_key_2".local(),"BB"]
        rightImg = UIImage(named: "Activity_home")
        
        view.addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.top.equalTo(kNavBarFullH+16)
            make.height.equalTo(71)
        }
        bgView.addSubview(titleLab)
        titleLab.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(-91)
            make.centerY.equalTo(bgView)
        }
        
        //1、初始化JXSegmentedView
        segmentedView = JXSegmentedView()
        segmentedView.delegate = self
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
        listContainerView.frame = CGRect.init(x: 0, y: kNavBarFullH+16+71+8, width: kScreenW, height: kScreenH-(kNavBarFullH+16+71+8))
        listContainerView.backgroundColor = .clear
        //禁止列表容器左右滑动
//        listContainerView.scrollView.isScrollEnabled = false
        view.addSubview(listContainerView)

        //6、将listContainerView.scrollView和segmentedView.contentScrollView进行关联
        segmentedView.listContainer = listContainerView
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    lazy var bgView: UIImageView = {
        $0.image = UIImage(named: "Activity_home_bg")
        return $0
    }(UIImageView())
    
    lazy var titleLab: UILabel = {
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.text = "activity_top_tips".local()
        $0.textColor = .white
        $0.numberOfLines = 0
        return $0
    }(UILabel())
    
    override func rightAction() {
        let vc = BBMyActivityListPageTwoVC()
        vc.activityType = self.activityType?.activityType ?? 0
        self.navigationController?.pushViewController(vc, animated: true)
    }

}
extension BBThreeActivityVC: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
extension BBThreeActivityVC: JXSegmentedViewDelegate {
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = (self.segmentedView.selectedIndex == 0)
    }
}
extension BBThreeActivityVC: JXSegmentedListContainerViewDataSource {
    func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
        return titleData.count
    }
    
    func listContainerView(_ listContainerView: JXSegmentedListContainerView, initListAt index: Int) -> JXSegmentedListContainerViewListDelegate {
        if index == 0 {
            let vc = BBLuckActivityListVC()
            vc.activityType = self.activityType
            vc.coinType = .coin_MINERAIS
            return vc
        }
        else {
            let vc = BBLuckActivityListVC()
            vc.activityType = self.activityType
            vc.coinType = .coin_BB
            return vc
        }
    }
}
