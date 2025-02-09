//
//  BBBoxOpenAnimationVC.swift
//  bb_planet_ios
//
//  Created by Jack-iOS on 2024/9/10.
//

import UIKit
import SVGAPlayer

class BBBoxOpenAnimationVC: UIViewController {
    lazy var svg: BBPlaySvgaManager = {
        let svg = BBPlaySvgaManager.init(vc: self)
        return svg
    }()
    
    var isKs = false
    
    var height:Int?

    var buyId: Int?
    
    var price: String?
    var rewardIntervalArr: [Int]?
    
    var updateUIBlock:(() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fd_prefersNavigationBarHidden = true
        fd_interactivePopDisabled = true
        
        svgaPlayer()
    }
    
    func svgaPlayer() {
        if let url = Bundle.main.url(forResource: "BaseBox_open", withExtension: "svga"){
            self.svg.playSvgUrl(url: url)
            self.svg.svgaPlayerDidFinishedBlock = {[weak self] in
                guard let self = self else { return }
                
                var value = 0
                self.rewardIntervalArr?.forEach({ elmt in
                    value = elmt + value
                })

                let alert = BoxResAlert()
                alert.moneyView.label.text = value.description
                alert.labelsV.set(data: self.rewardIntervalArr ?? [])
                alert.labelsV.reloadData()
                if self.isKs{
                    alert.moneyView.iconV.image = "ks_3".wp.image
                }else{
                    alert.moneyView.iconV.image = "BB100".wp.image.wp.scale(width: 16)
                }

                weak var wAlert = alert
                alert.labelsV.snp.updateConstraints { make in
                    make.height.equalTo(wAlert?.labelsV.contentHeight ?? 0)
                }
                alert.wp.show()
                
                alert.btn.rx.touchUpInside().bind(onNext: {[weak self] in
                    
                    guard let self = self else { return }
                    
                    if let url = URL(string: "https://tronscan.org/#/block/" + "\(self.height ?? 0)") {
                        UIApplication.shared.open(url)
                    }

                }).disposed(by: alert.wp.disposeBag)

                alert.closeBtn.rx.touchUpInside().bind(onNext: {
                    wAlert?.wp.dissmissBy {
                        self.updateUIBlock?()
                        self.navigationController?.popViewController(animated: true)
                    }
                }).disposed(by: alert.wp.disposeBag)
                

//                let v = BBOpenNowUnpackedView.show()
//                v.price = self?.price ?? ""
//                v.rewardIntervalArr = self?.rewardIntervalArr ?? []
//                v.closeActionBlock = {
//                    self?.updateUIBlock?()
//                    self?.navigationController?.popViewController(animated: true)
//                }
            }
        }
    }
}
