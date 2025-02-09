//
//  BBLuckActivityListVC.swift
//  bb_planet_ios
//
//  Created by jack on 2024/8/7.
//

/**
 *  @brief 幸运活动列表、百人活动列表、竞拍活动列表
 */

import UIKit
import Lottie
import WPCommand
import JXSegmentedView

enum ActivityType {
    /// 幸运
    case ActivityType_Luck
    /// 竞拍
    case ActivityType_HundredPerple
    /// 百人
    case ActivityType_Auction
    
    var activityType:Int{
        switch self {
        case .ActivityType_Luck:
            return 1
        case .ActivityType_HundredPerple:
            return 2
        case .ActivityType_Auction:
            return 3
        }
    }
}

enum CoinType {
    //BB
    case coin_BB
    //矿石
    case coin_MINERAIS
}

class BBLuckActivityListVC: UIViewController {
    var activityType: ActivityType?
    var coinType: CoinType?
    
    var page: Int = 1
    var boxType: Int?
    
    var baseBoxModels = [BBBaseBoxModel?]()
    
//    lazy var rightBtn = UIButton.navBtn("my_activity".local()).wp.titleColor(.mainText).make {[weak self] btn in
//        btn.rx.touchUpInside().bind(onNext: {
//            let vc = BBMyActivityListPageVC()
//            vc.activityType = self?.activityType?.activityType ?? 0
//            self?.navigationController?.pushViewController(vc, animated: true)
//        }).disposed(by: btn.wp.disposeBag)
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refreshData(page: 1)
    }
    
//    private func showMyActVC() {
//        switch self.activityType {
//        case .ActivityType_Luck:
//            let vc = BBMyActivityListPageVC()
//            vc.activityType = 1
//            self.navigationController?.pushViewController(vc, animated: true)
//        case .ActivityType_HundredPerple:
//            let vc = BBMyActivityListPageVC()
//            vc.activityType = 2
//            self.navigationController?.pushViewController(vc, animated: true)
//        case .ActivityType_Auction:
//            let vc = BBMyActivityListPageVC()
//            vc.activityType = 3
//            self.navigationController?.pushViewController(vc, animated: true)
//        default:
//            break
//        }
//    }

    override func viewDidLoad() {
        super.viewDidLoad()

        
        switch activityType {
        case .ActivityType_Luck:
            title = "lucky".local()
        case .ActivityType_Auction:
            title = "auction".local()
        case .ActivityType_HundredPerple:
            title = "_100_activity".local()
        default:
            break
        }
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
        
        emptyViewWithScrollView(self.collectionView) {}
    }
    
    lazy var collectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(Cell.classForCoder(), forCellWithReuseIdentifier: "Cell")
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        collectionView.addMJHeader {[weak self] in
            guard let `self` = self else { return }
            self.refreshData(page: 1)
        }
        collectionView.addMJNewFooter {[weak self] in
            guard let `self` = self else { return }
            self.refreshData(page: self.page + 1)
        }
        return collectionView
    }()
}
extension BBLuckActivityListVC: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return view
    }
    func listDidAppear() {
       
//        App.log("listDidAppear")
    }

    func listDidDisappear() {
//        App.log("listDidDisappear")
    }
}
extension BBLuckActivityListVC {
    func refreshData(page: Int) {
        
        switch activityType {
        case .ActivityType_Luck:
            boxType = 1
        case .ActivityType_Auction:
            boxType = 3
        case .ActivityType_HundredPerple:
            boxType = 2
        default:
            break
        }
        
        var params = [String: Any]()
        params["page"] = page
        params["size"] = 20
        params["activityType"] = boxType ?? 0 //boxType: 盲盒模板类型
        if self.coinType == .coin_BB {
            params["coin"] = "BB"
        }
        else {
            params["coin"] = "MINERAIS"
        }
        
        //活动查询
        Networking(url: "/activity/template/pageList", params: params, httpMethod: .post).isHud(false).successBlock {[weak self] response in
            guard let self = self else { return }
            self.collectionView.endMJRefresh()
            
            if response.code == 200, let data = response.data as? NSDictionary {
                if page == 1 {
                    self.baseBoxModels.removeAll()
                }
                
                self.page = page
                
                let records = data["records"] as? NSArray
                
                if let models = [BBBaseBoxModel].deserialize(from: records) {
                    self.baseBoxModels.append(contentsOf: models)
                }
                
//                self.collectionView.showPlaceholder(self.baseBoxModels.count<=0)
                self.collectionView.hasMoreData(records?.count != 0)
                self.collectionView.mj_footer?.isHidden = (records?.count ?? 0) < 20
                
            }
            
            self.collectionView.reloadData()
            
        }.failureBlock { failure in
            self.collectionView.endMJRefresh()
        }
    }
}

extension BBLuckActivityListVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return baseBoxModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = baseBoxModels[indexPath.item]
        
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BBLuckActivityListCell", for: indexPath) as! BBLuckActivityListCell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! Cell

        cell.label.target.text = model?.activityNumString
        cell.nameL.text = model?.name
        cell.moneyV.label.text = model?.price?.double.wp.accuracy(length: 2)

        cell.imageV.bbLoadImage(model?.picture?.normalUrl, isLoad: { res in
            if res{
                cell.contentView.wp.addNormalJb(["352555".wp.color,"0D0E18".wp.color],horizontal: false)
                cell.contentView.backgroundColor = .clear
            }else{
                cell.contentView.wp.removeJb()
                cell.contentView.backgroundColor = .mainText10
            }
        })
        
        if model?.coin == "BB" {
            cell.moneyV.iconV.image = "BB100".wp.image.wp.scale(width: 16)
        }
        else {
            cell.moneyV.iconV.image = "chatBean_exchange_kuan".wp.image.wp.scale(width: 16)
        }
        
        switch activityType {
        case .ActivityType_Luck:
            cell.partNumV.target.label.text = "\(model?.reportNum ?? 0)/\(model?.joinNum ?? 0)"
        case .ActivityType_Auction:
            cell.partNumV.target.label.text = "\(model?.reportNum ?? 0)"
        case .ActivityType_HundredPerple:
            cell.partNumV.target.label.text = "\(model?.reportNum ?? 0)"
        default: break
        }
        
        
//        partNumV.target.label.text = info.reportNum?.description ?? "0"
//        label.target.text = info.activityNumString
//        nameL.text = info.name
//        moneyV.label.text = Double(info.price ?? 0).wp.accuracy(length: 2)
        
        

//        cell.partNumL.text = "\(model?.reportNum ?? 0)/\(model?.joinNum ?? 0)"
////        cell.activityImg.kf.setImage(with: URL(string: model?.picture ?? ""))
//        cell.activityImg.bbLoadImage(model?.picture?.normalUrl)
//        cell.label.target.text = model?.activityNumString
//        cell.nameL.text = model?.name
//        cell.priceL.text = formatDecimalNumber(Double(model?.price ?? 0))
//        
//        if model?.activityType == 4 {
//            cell.buyStateL.text = "gift_sold_out".local()
//            cell.buyStateL.textColor = .colorD9C8FF
//            cell.buyNowBgView.backgroundColor = .colorE7E0FF.withAlphaComponent(0.1)
//        }else {
//            cell.buyStateL.text = "buy".local()
//            cell.buyStateL.textColor = .colorF2EDFF
//            cell.buyNowBgView.js_AddGradientLayerCommon()
//        }
//      
//        switch activityType {
//        case .ActivityType_Luck:
//        
//            cell.partNumL.text = "\(model?.reportNum ?? 0)/\(model?.joinNum ?? 0)"
//            break
//        case .ActivityType_Auction:
//            
//            cell.partNumL.text = "\(model?.reportNum ?? 0)"
//            break
//        case .ActivityType_HundredPerple:
//
//            cell.partNumL.text = "\(model?.reportNum ?? 0)"
//            break
//        default: break
//        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let margin: CGFloat = 15
        let space: CGFloat = 15
        return CGSize(width: (kScreenW - margin*2 - space)/2, height: 200)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = baseBoxModels[indexPath.item]
        
        if model?.activityType == 4 {
            
            switch activityType {
            case .ActivityType_Luck:
                ToastHud.toast("removed".local())
                break
            case .ActivityType_Auction:
                ToastHud.toast("removed".local())
                break
            case .ActivityType_HundredPerple:
                ToastHud.toast("removed".local())
                break
            default:
                break
            }
        }else {
            
            switch activityType {
            case .ActivityType_Luck:
                let vc = BBLuckActivityDetailVC()
                vc.activityId = model?.activityId
                navigationController?.pushViewController(vc, animated: true)
            case .ActivityType_Auction:
                // 新竞拍详情
                AuctionDetailVC.show(in: self, id: model?.activityId ?? 0)
            case .ActivityType_HundredPerple:
                let vc = BBNewhundredActDetailVC()
//                let vc = BBHundredActivityDetailVC()
                vc.activityId = model?.activityId
                navigationController?.pushViewController(vc, animated: true)
                break
            default:
                break
            }
        }
    }
}


extension BBLuckActivityListVC{
    class Cell: ShareActivityVC.Cell {
        
        let buyBtn = UILabel().wp.textColor(.mainText).font(10.font(.PingFangSC_Regular)).text("buy".local()).padding(.init(3, 6, 3, 6)).wp.cornerRadius(4).clipsToBounds(true).noramlJb().value()

        override func initSubView() {
            super.initSubView()
            statusBtn.isHidden = true

            contentView.addSubview(buyBtn)
        }
        
        override func initSubViewLayout() {
            super.initSubViewLayout()
            
            buyBtn.snp.makeConstraints { make in
                make.centerY.equalTo(moneyV)
                make.right.equalToSuperview().offset(-10)
            }
        }
    }
}
