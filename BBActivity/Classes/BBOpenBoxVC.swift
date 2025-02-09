//
//  BBOpenBoxVC.swift
//  bb_planet_ios
//
//  Created by jack on 2024/8/6.
//

/**
 *  @brief 盲盒详情
 */

import UIKit
import RxSwift
import RxCocoa
import WPCommand
import AVFoundation
import HandyJSON
import MarqueeLabel

class BBOpenBoxVC: BaseVC {
    
    let centerBoxImg = UIImageView().wp.image(UIImage(named: "home_openBox_itemBox")).value()
    
    let bottomImg = UIImageView().wp.image(UIImage(named: "home_openBox_center_pedestal")).value()
    let bgImg = UIImageView().wp.image(UIImage(named: "home_openBox_center_effect")).value()
    let bgImg1 = UIImageView().wp.image(UIImage(named: "home_openBox_center_effect1")).value()
    
    init(viewType: BBOpenBoxVM.MoneyType,normalSelecteId:Int? = nil) {
        self.vm.moneyType.accept(viewType)
        self.vm.selectdToId = normalSelecteId
        super.init()
    }
    
    @MainActor required init() {
        fatalError("init() has not been implemented")
    }
    
    lazy var mScrollView: UIScrollView = {
        if #available(iOS 11.0, *) {
            $0.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        $0.frame = self.view.bounds
        $0.showsVerticalScrollIndicator = false
        $0.backgroundColor = .clear
        return $0
    }(UIScrollView())
    
    let musicBtn = BaseButton().wp.image("mh_music".wp.image,.selected).image("mh_music_colse".wp.image, .normal).value()
    let tipsBtn = UIButton().wp.image("box_help".wp.image).make({ btn in
        btn.rx.touchUpInside().bind(onNext: {
            ActivityMaxImageRuleVC.show(in: .wp.current!,type: .box)
        }).disposed(by: btn.wp.disposeBag)
    })
    
    let bgView = UIImageView().wp.image("bbBox_bg".wp.image).isUserInteractionEnabled(false).contentMode(.scaleAspectFit).value()
    
    
//    let demoCountL = UILabel().wp.font(10.font).textColor(.mainText).value()
//    let listBtn = UIButton().wp.mark("试玩记录").title("try_record".local()).font(10.font).titleColor(.mainYellow).image("sw_r".wp.image).semanticContentAttribute(.forceRightToLeft).padding(.init(4, 10, 4, 4)).wp.backgroundColor(.mainText10).radius([.topLeft,.bottomLeft], radius: 4).value()

//    let ksBtn = SwitchBtnView().wp.make { view in
//        view.iconV.image = "box_swks".wp.image
//        view.btn.wp.mark("试玩").title("try_bb_box".local())
//        view.btn.wp.semanticContentAttribute(.forceRightToLeft)
//    }
//    let bbBtn = SwitchBtnView().wp.make { view in
//        view.btn.wp.mark("BB盲盒").title("my_bb_box".local())
//        view.btn.wp.semanticContentAttribute(.forceRightToLeft)
//    }
    
    lazy var segmentedControl: UISegmentedControl = {
        $0.frame = CGRect.init(x: kScreenW/2-103, y: kStatusBarH+5, width: 206, height: 38)
        $0.layer.cornerRadius = 12
        $0.layer.masksToBounds = true
        // 设置分段的背景色和选中时的颜色
        $0.backgroundColor = .white.withAlphaComponent(0.1)
        $0.selectedSegmentTintColor = .mainYellow
        $0.selectedSegmentIndex = 0
        $0.setTitleTextAttributes([.font: UIFont.boldSystemFont(ofSize: 15),.foregroundColor: UIColor.white.withAlphaComponent(0.6)], for: .normal)
        $0.setTitleTextAttributes([.font: UIFont.boldSystemFont(ofSize: 15),.foregroundColor: UIColor.black], for: .selected)
        // 添加事件监听
        $0.addTarget(self, action: #selector(segmentedControlChanged(_:)), for: .valueChanged)
        return $0
    }(UISegmentedControl(items: ["rewar_key_2".local(),"BB"]))
    
    var type: BBOpenBoxVM.MoneyType = .ks
    
    let boxBg = UIImageView().wp.image(UIImage(named: "home_bbbox_bg")).value()
    let boxTopBg = UIImageView().wp.image(UIImage(named: "home_bbbox_top")).value()
    let boxTopBg1 = UIImageView().wp.image(UIImage(named: "home_bbbox_top1")).value()
    //喇叭
    let laba = UIImageView().wp.image(UIImage(named: "home_bbbox_laba")).value()
    
    ///  滚动标题
    let titleL = MarqueeLabel().wp.make { label in
            label.wp.font(12.font(.PingFangSC_Medium)).textColor(.mainText)
    }
    //图标
    let topIcon = UIImageView().wp.image(UIImage(named: "chatBean_exchange_kuan")).value()
    let topTitle = UILabel().wp.text("jackpot".local()).textColor(.black).font(14.bFont).value()
    let topTips = UILabel().wp.text("bbbox_Tips".local()).textColor(.white).textAlignment(.center).font(11.font).value()
    
    lazy var collectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 2
        layout.itemSize = CGSize(width: (kScreenW - 27*2-8)/5, height: 22)
        
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(BBRewardIntervalCell.classForCoder(), forCellWithReuseIdentifier: "BBRewardIntervalCell")
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        return collectionView
    }()
    
    
    let jianIcon = UIImageView().wp.image(UIImage(named: "home_jian_bg")).value()
    let jianLab = UILabel().wp.text("100%").textColor(.mainYellow).font(17.bFont).value()
    let jianTips = UILabel().wp.text("WIN").textColor(.white).font(14.font).value()
    
    
    lazy var pagerView: BBPagerView = {
        $0.register(UINib(nibName: "BBOpenBoxCell", bundle: Bundle.main), forCellWithReuseIdentifier: "BBOpenBoxCell")
        $0.transformer = BBPagerViewTransformer(type:.linear)
        $0.transformer?.minimumScale = 0.80
//            let transform = CGAffineTransform(scaleX: 0.4, y: 0.85)
//            let size = self.pagerView.frame.size.applying(transform)
        let fixedSize = CGSize(width: 135, height: 163)
        $0.itemSize = fixedSize
        $0.decelerationDistance = BBPagerView.automaticDistance
        $0.isInfinite = true
        $0.delegate = self
        $0.dataSource = self
        return $0
    }(BBPagerView())
    
    let openBtn = UIButton().wp.font(24.bFont).titleColor(.white).title("open_box".local()).backgroundImage(UIImage(named: "open_box")).value()
    //open_box
    
    let vm = BBOpenBoxVM()

    var selectBaseBoxModel: BBBaseBoxModel?
    var selectIndex = 0
    
    /// 活动等待视图
//    let loadingView = ActivityLodingView(text: "wait_block_height".local()).wp.isHidden(true).value()
    
    let alertManager = WPAlertManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startAnimation()
        self.fd_prefersNavigationBarHidden = true
        
    }
    
    deinit {
        BBMusicManger.activityMusic.stop()
    }
    
    override func observeSubViewEvent() {
        
        wp.viewWillAppear.take(1)
            .notice(vm.loadFirstData(type: vm.moneyType.value == .bb ? "BB" : "MINERAIS"))
//            .notice(vm.loadDemoCount())
            .subscribe().disposed(by: wp.disposeBag)

        wp.viewDidAppear.take(1).bind(onNext: { _ in
            if (BBConst.values.wp_elmt(of: { $0.key == .bbBoxMusic })?.relay.value as? Bool) ?? false{
                BBMusicManger.activityMusic.rePlay()
            }
        }).disposed(by: wp.disposeBag)
        
//        wp.viewWillDisappear.take(1).bind { _ in
//            BBMusicManger.activityMusic.stop()
//        }.disposed(by: wp.disposeBag)

        BBConst.values.wp_elmt(of: { $0.key == .bbBoxMusic})?.relay.map({ $0 as? Bool ?? false}).bind(to: musicBtn.rx.isSelected).disposed(by: wp.disposeBag)
        
        // 开关音效
        musicBtn.rx.touchUpInside().bind(onNext: {[weak self] _ in
            let value = self?.musicBtn.isSelected ?? false
            BBConst.set(!value, for: .bbBoxMusic)
            if !value {
                BBMusicManger.activityMusic.rePlay()
            }else{
                BBMusicManger.activityMusic.stop()
            }
        }).disposed(by: wp.disposeBag)
        
        // 购买
        openBtn.rx.touchUpInside().filter({[weak self] _ in
            return (self?.vm.lists.value.count ?? 0) > 0
        }).flatMap({[weak self] _ in
            
            return Middleground.buyBox(id: self?.selectBaseBoxModel?.id?.description ?? "",
                                       price: Double(self?.selectBaseBoxModel?.price ?? 0),
                                       isKs: self?.vm.moneyType.value == .ks,
                                       waitBeging: {[weak self] data in
//                self?.loadingView.isHidden = false
                
                let alert = OpenBoxAlert()
                alert.btn1.setTitle(data?.chain, for: .normal)
                alert.btn2.setTitle(data?.height, for: .normal)
                alert.wp.show(in: self?.view,by: self!.alertManager)
                self?.openBtn.isUserInteractionEnabled = false
                self?.openBtn.isEnabled = false
            },waitEnd: { [weak self] in
                self?.openBtn.isEnabled = true
                //                self?.loadingView.isHidden = true
                self?.alertManager.dismiss()
                self?.openBtn.isUserInteractionEnabled = true
            })
//            },buySuccess: self?.vm.loadDemoCount().void() ?? .empty())
        }).bind(onNext: {[weak self] elmt in
            let vc = BBBoxOpenAnimationVC()
            vc.isKs = self?.vm.moneyType.value == .ks
            vc.height = elmt.2?.height?.intValue
            vc.rewardIntervalArr = elmt.0
            self?.navigationController?.pushViewController(vc, animated: true)
        }).disposed(by: wp.disposeBag)
//        .notice(vm.loadDemoCount()).bind(onNext: {[weak self] elmt in
//            let vc = BBBoxOpenAnimationVC()
//            vc.isKs = self?.vm.moneyType.value == .ks
//            vc.height = elmt.2?.height?.intValue
//            vc.rewardIntervalArr = elmt.0
//            self?.navigationController?.pushViewController(vc, animated: true)
//        }).disposed(by: wp.disposeBag)
        
//        ksBtn.wp.tapGesture.flatMap({[weak self] _ in
//            return self?.vm.loadFirstData(type: "MINERAIS") ?? .empty()
//        }).bind(onNext: {[weak self] _ in
//            self?.vm.moneyType.accept(.ks)
//        }).disposed(by: wp.disposeBag)
        
//        bbBtn.wp.tapGesture.flatMap({[weak self] _ in
//            return self?.vm.loadFirstData(type: "BB") ?? .empty()
//        }).bind(onNext: {[weak self] _ in
//            self?.vm.moneyType.accept(.bb)
//        }).disposed(by: wp.disposeBag)
        
        
//        listBtn.target.rx.touchUpInside().bind(onNext: { _ in
//            DemoBoxFlowVC.show(in: .wp.current!)
//        }).disposed(by: wp.disposeBag)
    }
    
    override func bindViewModel() {
        //vm.demoCount
//        Observable.combineLatest(vm.moneyType).bind(onNext: {[weak self] elmt in
//            guard let self = self else { return }
//            
//            if elmt.0 == .ks {
//                self.openBtn.isUserInteractionEnabled = false
//                self.openBtn.setBackgroundImage("blind_box_detail_submit_no".wp.image, for: .normal)
//            }else{
//                self.openBtn.isUserInteractionEnabled = true
//                self.openBtn.setBackgroundImage("open_box".wp.image, for: .normal)
//            }
//
////            demoCountL.isHidden = elmt.0 != .ks
////            listBtn.isHidden = elmt.0 != .ks
//
//        }).disposed(by: wp.disposeBag)
        
        vm.lists.bind(onNext: {[weak self] list in
            if list.count >= 1 && self?.vm.selectdToId == nil {
                self?.selectBaseBoxModel = list.first
//                self?.navView.leftTitleLabel.text = self?.selectBaseBoxModel?.name
            }
            self?.collectionView.reloadData()
            self?.pagerView.reloadData()
            
            if list.count > 0 && self?.vm.firstLoad == false {
                self?.pagerView.scrollToItem(at: 0, animated: false)
            }
            
        }).disposed(by: wp.disposeBag)
        
        vm.lists.filter {[weak self] res in
            let id = self?.vm.selectdToId ?? -1
            return res.count > 0 && id != -1
        }.delay(.milliseconds(50), scheduler: MainScheduler.asyncInstance).take(1).bind(onNext: {[weak self] res in
            guard let self = self else { return }
            
            if let id = self.vm.selectdToId{
                if let index = res.wp_index(of: { $0.id == id }){
                    self.pagerView.selectItem(at: Int(index), animated: false)
                    self.selectBaseBoxModel = vm.lists.value[Int(index)]
//                    self.navView.leftTitleLabel.text = selectBaseBoxModel?.name
                    self.collectionView.reloadData()
                    self.vm.selectdToId = nil
                }
            }
        }).disposed(by: wp.disposeBag)

//        vm.moneyType.bind(onNext: {[weak self] type in
//            guard let self = self else { return }
//            
//            if type == .ks {
//                self.openBtn.isUserInteractionEnabled = false
//                self.openBtn.setBackgroundImage("blind_box_detail_submit_no".wp.image, for: .normal)
//            }else{
//                self.openBtn.isUserInteractionEnabled = true
//                self.openBtn.setBackgroundImage("open_box".wp.image, for: .normal)
//            }
////            self.bbBtn.isHidden = type != .ks
////            self.ksBtn.isHidden = type != .bb
//            
//        }).disposed(by: wp.disposeBag)
        
//        vm.demoCount.bind(onNext: {[weak self] count in
//            self?.demoCountL.attributedText = "try_number".local().wp.attributed.append(" ").append("\(count)".wp.attributed.font(10.font(.PingFangSC_Semibold)).foregroundColor(.mainYellow)).value()
//        }).disposed(by: wp.disposeBag)
    }
    
    override func initSubView() {
        super.initSubView()

        view.insertSubview(bgView, at: 0)
        bgView.frame = self.view.bounds
        view.insertSubview(mScrollView, at: 1)
        
        navView.rightView.addArrangedSubview(musicBtn)
        navView.rightView.addArrangedSubview(tipsBtn)
        navView.rightView.alignment = .center
        navView.rightView.spacing = 8
        
        
        view.addSubview(segmentedControl)
        
        mScrollView.addSubview(boxBg)
        boxBg.snp.makeConstraints { make in
            make.left.right.equalTo(view)
            make.top.equalTo(kNavBarFullH+15)
            make.height.equalTo(170)
        }
        boxBg.addSubview(boxTopBg)
        boxTopBg.snp.makeConstraints { make in
            make.left.top.right.equalTo(boxBg)
            make.height.equalTo(28)
        }
        boxTopBg.addSubview(laba)
        laba.snp.makeConstraints { make in
            make.left.equalTo(11)
            make.centerY.equalTo(boxTopBg)
            make.width.height.equalTo(28)
        }
        boxTopBg.addSubview(titleL)
        titleL.snp.makeConstraints { make in
            make.left.equalTo(laba.snp.right).offset(5)
            make.right.equalTo(-5)
            make.centerY.equalTo(boxTopBg)
            make.height.equalTo(20)
        }
        boxBg.addSubview(topTitle)
        topTitle.snp.makeConstraints { make in
            make.top.equalTo(boxTopBg.snp.bottom).offset(8)
            make.centerX.equalTo(boxBg)
            make.height.equalTo(18)
        }
        boxBg.addSubview(topIcon)
        topIcon.snp.makeConstraints { make in
            make.right.equalTo(topTitle.snp.left).offset(-3)
            make.centerY.equalTo(topTitle)
            make.width.height.equalTo(18)
        }
        
        boxBg.addSubview(boxTopBg1)
        boxTopBg1.snp.makeConstraints { make in
            make.top.equalTo(topIcon.snp.bottom)
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.height.equalTo(19)
        }
        boxTopBg1.addSubview(topTips)
        topTips.snp.makeConstraints { make in
            make.left.right.equalTo(boxTopBg1)
            make.centerY.equalTo(boxTopBg1)
            make.width.height.equalTo(11)
        }
        boxBg.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.left.equalTo(27)
            make.right.equalTo(-27)
            make.top.equalTo(boxTopBg1.snp.bottom).offset(5)
            make.height.equalTo(48)
        }
        
        mScrollView.addSubview(bottomImg)
        bottomImg.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalTo(boxBg.snp.bottom).offset(120)
            make.width.equalTo(290)
            make.height.equalTo(128)
        }
        mScrollView.addSubview(centerBoxImg)
        centerBoxImg.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalTo(boxBg.snp.bottom).offset(40)
            make.width.equalTo(130)
            make.height.equalTo(122)
        }
        mScrollView.addSubview(bgImg)
        bgImg.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalTo(boxBg.snp.bottom).offset(-40)
            make.width.equalTo(311)
            make.height.equalTo(228)
        }
        mScrollView.addSubview(bgImg1)
        bgImg1.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.bottom.equalTo(bgImg.snp.bottom)
            make.width.equalTo(350)
            make.height.equalTo(135)
        }
        mScrollView.addSubview(jianIcon)
        jianIcon.snp.makeConstraints { make in
            make.left.equalTo(30)
            make.centerY.equalTo(centerBoxImg)
            make.width.height.equalTo(75)
        }
        jianIcon.addSubview(jianLab)
        jianLab.snp.makeConstraints { make in
            make.centerX.equalTo(jianIcon)
            make.top.equalTo(21)
            make.height.equalTo(17)
        }
        jianIcon.addSubview(jianTips)
        jianTips.snp.makeConstraints { make in
            make.centerX.equalTo(jianIcon)
            make.bottom.equalTo(-20)
            make.height.equalTo(14)
        }
        
        mScrollView.addSubview(pagerView)
        pagerView.snp.makeConstraints { make in
            make.left.right.equalTo(view)
            make.top.equalTo(bottomImg.snp.bottom).offset(20)
            make.height.equalTo(163)
        }
        
        mScrollView.addSubview(openBtn)
        openBtn.snp.makeConstraints { make in
            make.top.equalTo(pagerView.snp.bottom).offset(50)
            make.centerX.equalTo(view)
            make.width.equalTo(150)
            make.height.equalTo(55)
        }
        
        self.titleL.type = .continuous// 滚动类型：连续滚动
        self.titleL.speed = .rate(40)// 设置滚动速度
        self.titleL.fadeLength = 15.0 // 渐变长度
        self.titleL.trailingBuffer = 40  // 设置滚动结束后的缓冲区
        self.titleL.text = "activity_top_tips".local()
        self.titleL.triggerScrollStart()
        
        // 旋转角度，12度转为弧度
        let rotationAngle: CGFloat = -12.0 * .pi / 180.0
        // 使用CGAffineTransform来旋转视图
        jianIcon.transform = CGAffineTransform(rotationAngle: rotationAngle)
        
        self.mScrollView.layoutIfNeeded()
        self.mScrollView.contentSize = CGSize.init(width: kScreenW, height: self.openBtn.bottom+20)
    }
    
    override func initSubViewLayout() {
        super.initSubViewLayout()
        
       
//        loadingView.snp.makeConstraints { make in
//            make.center.equalToSuperview()
//        }
        
//        ksBtn.snp.makeConstraints { make in
//            make.right.equalToSuperview()
//            make.centerY.equalToSuperview()
//        }
        
//        bbBtn.snp.makeConstraints { make in
//            make.right.equalToSuperview()
//            make.centerY.equalToSuperview()
//        }
        
//        demoCountL.snp.makeConstraints { make in
//            make.centerX.equalTo(openBtn)
//            make.bottom.equalTo(openBtn.snp.top).offset(-12)
//        }
//        
//        listBtn.snp.makeConstraints { make in
//            make.centerY.equalTo(openBtn)
//            make.right.equalToSuperview()
//        }
    }
    
    @IBAction func bindBoxAction(_ sender: UIButton) {
        let vc = BBMyProductVC()
        navigationController?.pushViewController(vc, animated: true)
    }
  
    
    @IBAction func activitiesAction(_ sender: UIButton) {
        navigationController?.tabBarController?.hidesBottomBarWhenPushed = false
        navigationController?.tabBarController?.selectedIndex = 1
        navigationController?.popToRootViewController(animated: true)
    }
    
    // 监听分段控件的值变化
    @objc func segmentedControlChanged(_ sender: UISegmentedControl) {
        let selectedSegmentIndex = sender.selectedSegmentIndex
        if selectedSegmentIndex == 0 {
            self.vm.loadFirstData(type: "MINERAIS").subscribe().disposed(by: wp.disposeBag)
            self.vm.moneyType.accept(.ks)
            self.topIcon.image = UIImage(named: "chatBean_exchange_kuan")
            self.selectBaseBoxModel = nil
            self.type = .ks
        }
        else {
            self.vm.loadFirstData(type: "BB").subscribe().disposed(by: wp.disposeBag)
            self.vm.moneyType.accept(.bb)
            self.topIcon.image = UIImage(named: "BB100")
            self.selectBaseBoxModel = nil
            self.type = .bb
        }
    }
}

extension BBOpenBoxVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectBaseBoxModel?.rewardInterval?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BBRewardIntervalCell", for: indexPath) as! BBRewardIntervalCell
        let item = selectBaseBoxModel?.rewardInterval?[indexPath.item]
        cell.itemL.text = formatDecimalNumber(Double(item ?? 0))
        if indexPath.item == 4 || indexPath.item == 9 {
            cell.line.isHidden = true
        }
        else {
            cell.line.isHidden = false
        }
        return cell
    }
}

extension BBOpenBoxVC: BBPagerViewDataSource,BBPagerViewDelegate {
    // MARK:- BBPagerViewDataSource
    public func numberOfItems(in pagerView: BBPagerView) -> Int {
//        return baseBoxModels.count
        return vm.lists.value.count
    }
    
    public func pagerView(_ pagerView: BBPagerView, cellForItemAt index: Int) -> BBOpenBoxCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "BBOpenBoxCell", at: index)
//        let model = baseBoxModels[index]
        let model = vm.lists.value[index]
        cell.moneyIconV.image = vm.moneyType.value == .bb ? "BB100".wp.image.wp.scale(height: 24) : "ks_3".wp.image
        cell.nameL.text = model.name ?? ""
        cell.priceL.text = formatDecimalNumber(Double((model.price ?? 0)))
        
        return cell
    }
    
    // MARK:- BBPagerViewDelegate
    func pagerView(_ pagerView: BBPagerView, didSelectItemAt index: Int) {
        pagerView.deselectItem(at: index, animated: true)
        pagerView.scrollToItem(at: index, animated: true)
        
//        selectBaseBoxModel = baseBoxModels[index]
        selectBaseBoxModel = vm.lists.value[index]
        selectIndex = index
//        navView.leftTitleLabel.text = selectBaseBoxModel?.name
        collectionView.reloadData()
    }
    
    func pagerViewWillEndDragging(_ pagerView: BBPagerView, targetIndex: Int) {
//        selectBaseBoxModel = baseBoxModels[targetIndex]
        selectBaseBoxModel = vm.lists.value[targetIndex]
        selectIndex = targetIndex
//        navView.leftTitleLabel.text = selectBaseBoxModel?.name
        collectionView.reloadData()
    }
}

extension BBOpenBoxVC {
    func startAnimation() {
        let keyframes: [(CGFloat, CGAffineTransform)] = [
            (0.0, CGAffineTransform(translationX: 0, y: 0).rotated(by: 0)),
            (0.02, CGAffineTransform(translationX: 6, y: -7).rotated(by: 2.5 * .pi / 180)),
            (0.04, CGAffineTransform(translationX: 8, y: -8).rotated(by: 2.5 * .pi / 180)),
            (0.06, CGAffineTransform(translationX: 1, y: -8).rotated(by: -3.5 * .pi / 180)),
            (0.08, CGAffineTransform(translationX: -3, y: 4).rotated(by: -0.5 * .pi / 180)),
            (0.10, CGAffineTransform(translationX: 0, y: -3).rotated(by: 1.5 * .pi / 180)),
            (0.12, CGAffineTransform(translationX: -1, y: 2).rotated(by: 0.5 * .pi / 180)),
            (0.14, CGAffineTransform(translationX: 6, y: 6).rotated(by: -1.5 * .pi / 180)),
            (0.16, CGAffineTransform(translationX: -7, y: 4).rotated(by: -0.5 * .pi / 180)),
            (0.18, CGAffineTransform(translationX: 7, y: 8).rotated(by: -3.5 * .pi / 180)),
            (0.20, CGAffineTransform(translationX: -6, y: 2).rotated(by: 1.5 * .pi / 180)),
            (0.22, CGAffineTransform(translationX: 9, y: 5).rotated(by: -1.5 * .pi / 180)),
            (0.24, CGAffineTransform(translationX: 7, y: -2).rotated(by: 0.5 * .pi / 180)),
            (0.26, CGAffineTransform(translationX: -7, y: -10).rotated(by: -0.5 * .pi / 180)),
            (0.28, CGAffineTransform(translationX: -10, y: -8).rotated(by: -1.5 * .pi / 180)),
            (0.30, CGAffineTransform(translationX: 8, y: 4).rotated(by: 0.5 * .pi / 180)),
            (0.32, CGAffineTransform(translationX: 0, y: 4).rotated(by: 1.5 * .pi / 180)),
            (0.34, CGAffineTransform(translationX: -8, y: 6).rotated(by: -0.5 * .pi / 180)),
            (0.36, CGAffineTransform(translationX: -5, y: 7).rotated(by: 1.5 * .pi / 180)),
            (0.38, CGAffineTransform(translationX: -4, y: -4).rotated(by: -1.5 * .pi / 180)),
            (0.40, CGAffineTransform(translationX: 9, y: 4).rotated(by: -1.5 * .pi / 180)),
            (0.42, CGAffineTransform(translationX: 9, y: -5).rotated(by: 2.5 * .pi / 180)),
            (0.44, CGAffineTransform(translationX: -5, y: -4).rotated(by: -2.5 * .pi / 180)),
            (0.46, CGAffineTransform(translationX: 7, y: -7).rotated(by: 1.5 * .pi / 180)),
            (0.48, CGAffineTransform(translationX: -5, y: 8).rotated(by: 0.5 * .pi / 180)),
            (0.50, CGAffineTransform(translationX: 9, y: 1).rotated(by: -1.5 * .pi / 180)),
            (0.52, CGAffineTransform(translationX: -9, y: -5).rotated(by: -3.5 * .pi / 180)),
            (0.54, CGAffineTransform(translationX: -2, y: 9).rotated(by: 1.5 * .pi / 180)),
            (0.56, CGAffineTransform(translationX: 6, y: -1).rotated(by: 1.5 * .pi / 180)),
            (0.58, CGAffineTransform(translationX: -6, y: 0).rotated(by: -0.5 * .pi / 180)),
            (0.60, CGAffineTransform(translationX: 3, y: 1).rotated(by: 1.5 * .pi / 180)),
            (0.62, CGAffineTransform(translationX: 5, y: -7).rotated(by: -0.5 * .pi / 180)),
            (0.64, CGAffineTransform(translationX: 9, y: 2).rotated(by: 2.5 * .pi / 180)),
            (0.66, CGAffineTransform(translationX: 6, y: 0).rotated(by: -2.5 * .pi / 180)),
            (0.68, CGAffineTransform(translationX: 5, y: -4).rotated(by: -2.5 * .pi / 180)),
            (0.70, CGAffineTransform(translationX: -8, y: 5).rotated(by: -3.5 * .pi / 180)),
            (0.72, CGAffineTransform(translationX: -6, y: -2).rotated(by: 0.5 * .pi / 180)),
            (0.74, CGAffineTransform(translationX: -3, y: 7).rotated(by: -3.5 * .pi / 180)),
            (0.76, CGAffineTransform(translationX: -7, y: -8).rotated(by: -3.5 * .pi / 180)),
            (0.78, CGAffineTransform(translationX: -1, y: -2).rotated(by: 2.5 * .pi / 180)),
            (0.80, CGAffineTransform(translationX: 8, y: 6).rotated(by: -2.5 * .pi / 180)),
            (0.82, CGAffineTransform(translationX: -2, y: -9).rotated(by: 2.5 * .pi / 180)),
            (0.84, CGAffineTransform(translationX: 8, y: -10).rotated(by: -0.5 * .pi / 180)),
            (0.86, CGAffineTransform(translationX: -6, y: 0).rotated(by: 2.5 * .pi / 180)),
            (0.88, CGAffineTransform(translationX: -1, y: 9).rotated(by: -3.5 * .pi / 180)),
            (0.90, CGAffineTransform(translationX: -7, y: 8).rotated(by: 1.5 * .pi / 180)),
            (0.92, CGAffineTransform(translationX: -10, y: -8).rotated(by: 0.5 * .pi / 180)),
            (0.94, CGAffineTransform(translationX: -8, y: 6).rotated(by: 1.5 * .pi / 180)),
            (0.96, CGAffineTransform(translationX: 4, y: -9).rotated(by: 2.5 * .pi / 180)),
            (0.98, CGAffineTransform(translationX: -4, y: 9).rotated(by: 0.5 * .pi / 180))
        ]
        
        let animator = UIViewPropertyAnimator(duration: 4.0, curve: .linear) {
            UIView.animateKeyframes(withDuration: 4.0, delay: 0, options: [], animations: {
                for (relativeTime, transform) in keyframes {
                    UIView.addKeyframe(withRelativeStartTime: Double(relativeTime), relativeDuration: 0.02) {[weak self] in
                        guard let self = self else { return }
                        self.centerBoxImg.transform = transform
                    }
                }
            }) {[weak self] finish in
                guard let self = self else { return }
                self.startAnimation()
            }
        }
        animator.startAnimation()
    }
}


class BBOpenBoxVM: BaseVM,AVAudioPlayerDelegate {

    enum MoneyType {
      case ks
      case bb
    }
    
    var audioPlayer: AVAudioPlayer?
    
    let music = BBMusic(url: Bundle.main.url(forResource: "musti2", withExtension: "mp3")!,loop: true)

    //第一次加载
    var firstLoad = true
    /// 默认选中盲盒ID
    var selectdToId:Int?
    /// 购买类型
    let moneyType = BehaviorRelay<MoneyType>(value: .bb)
    /// 试玩次数
//    let demoCount = BehaviorRelay<Int>(value: 0)
    /// 分页
    let page = BehaviorRelay(value: PageVo())
    /// 盲盒列表
    let lists = BehaviorRelay<[BBBaseBoxModel]>(value: [])

    var notiftBag = DisposeBag()
    
//    func loadDemoCount() -> Observable<Int> {
//        return BBApi.demoCount.request().resualt(Int.self).map({ $0.data ?? 0}).do(onNext:  {[weak self] elmt in
//            self?.demoCount.accept(elmt)
//        })
//    }
    
    /// 加载第一页 MINERAIS BB
    func loadFirstData(type:String = "BB") -> Observable<[BBBaseBoxModel]> {
        var page = self.page.value
        page.page = 1
        self.page.accept(page)
        
        return BBApi.boxList(page: page, chin: type).request().result(BBOpenBoxVC.DataVo.self).do(onNext: {[weak self] elmt in
            var page = self?.page.value
            page?.page += 1
            self?.page.accept(page ?? .init())
            self?.lists.accept(elmt.data?.records ?? [])
            self?.firstLoad = false
        }).map { elmt in
            return elmt.data?.records ?? []
        }
        
    }
    
    /// 加载下一页
    func loadNextData(type:String = "BB") -> Observable<[BBBaseBoxModel]> {
        return BBApi.boxList(page: page.value, chin: type).request().result(BBOpenBoxVC.DataVo.self).do(onNext: {[weak self] _ in
            var page = self?.page.value
            page?.page += 1
            self?.page.accept(page ?? .init())
        }).map({ elmt in
            return elmt.data?.records ?? []
        }).do(onNext: {[weak self] elmt in
            var array = self?.lists.value ?? []
            array.append(contentsOf: elmt)
            self?.lists.accept(array)
        })
    }
}

extension BBOpenBoxVC{
    /// 开启盲盒
    struct OpenVo:HandyJSON {
        /// 购买ID
        var id:String?
        /// 网络
        var chain:String?
        /// 用户种子
        var seed:String?
        /// 用户盐
        var salt:String?
        /// 未来高度
        var height:String?
        /// 时间戳
        var timestamp:TimeInterval?
        /// 购买时间
        var openTime:TimeInterval?

    }
    
    struct DataVo:HandyJSON {
        /// 盲盒
        var records:[BBBaseBoxModel] = []
    }
}

extension BBOpenBoxVC{
    
    class SwitchBtnView:BaseView {
        
        let bgView = UIImageView().wp.image("box_swbg".wp.image).value()
        let iconV = UIImageView().wp.image("BB100".wp.image.wp.scale(width: 32)).value()
        let btn = UIButton().wp.font(10.font).titleColor(.mainText).isUserInteractionEnabled(false).value()
        
        override func initSubView() {
            super.initSubView()
            
            addSubview(bgView)
            addSubview(iconV)
            addSubview(btn)
        }
        
        override func initSubViewLayout() {
            super.initSubViewLayout()
            
            iconV.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalToSuperview()
            }
            
            bgView.snp.makeConstraints { make in
                make.left.right.bottom.equalToSuperview()
                make.top.equalTo(iconV.snp.centerY)
            }
            
            btn.snp.makeConstraints { make in
                make.left.equalTo(8)
                make.right.equalTo(-8)
                make.centerX.equalToSuperview()
                make.centerY.equalTo(bgView).offset(4)
            }
        }
    }
}
