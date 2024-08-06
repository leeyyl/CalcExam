//
//  HomeViewController.swift
//  CalcExam
//
//  Created by Li YongYi on 2024/8/6.
//

import UIKit

class HomeViewController: UIViewController {
    // UI orientation of shown, not the device orientation
    private var orientationUICur: UIDeviceOrientation = .unknown
    
    private var viewCalcuPortrait: CalculatorView?
    private var viewCalcuLandscapeL: CalculatorView?
    private var viewCalcuLandscapeR: CalculatorView?
    
    private var btnLeftLandscape: UIButton?
    private var btnRightLandscape: UIButton?
    private var btnDelLandscape: UIButton?
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(orientaionDidChange), name: UIDevice.orientationDidChangeNotification, object: nil)
        
        self.view.backgroundColor = .black
        self.initUI()
        self.initShowFromCurOrientation()
    }
    
    private func initUI() {
        let (widthReal, heightReal) = ScreenSize.realScreenSize
        let xInter = FontSize.instance.standardFontSize * 0.4
        let yInter = xInter
        let yBottomInter = FontSize.instance.standardFontSize * 0.6
        let sizeOpeBtn = heightReal/15.5
        let fontSizeOpeBtn = sizeOpeBtn/2.0
        let wCalculateLandscape = (heightReal-4.0*xInter-sizeOpeBtn)*0.5
        
        viewCalcuPortrait = CalculatorView(frame: CGRectMake(0, 0, widthReal, heightReal-yBottomInter), alignment: .center, tag: 0)
        viewCalcuLandscapeL = CalculatorView(frame: CGRectMake(xInter, 0, wCalculateLandscape, widthReal-yBottomInter), alignment: .right, tag: 1)
        viewCalcuLandscapeR = CalculatorView(frame: viewCalcuLandscapeL!.frame.xOffest(2.0*xInter+sizeOpeBtn+wCalculateLandscape), alignment: .left, tag: 2)
        self.view.addSubview(viewCalcuPortrait!)
        self.view.addSubview(viewCalcuLandscapeL!)
        self.view.addSubview(viewCalcuLandscapeR!)
        
        let cornerRadiusBtn: CGFloat = sizeOpeBtn * 0.25
        let colorDelBtnBnd: UIColor = .lightGray
        let colorDelBtnText: UIColor = .white
        let rectDivBtn = viewCalcuLandscapeL!.divisionOperatorRect
        let xOpeBtn = (viewCalcuLandscapeL!.left + viewCalcuLandscapeR!.right)*0.5 - sizeOpeBtn*0.5
        
        btnLeftLandscape = UIButton().getWithBindClickEventWith(target: self, action: #selector(leftArrowAction(_:)), tag: nil)
        btnLeftLandscape?.setImage(UIImage(named: "leftArrow"), for: .normal)
        btnLeftLandscape?.layer.masksToBounds = true
        btnLeftLandscape?.layer.cornerRadius = cornerRadiusBtn
        btnLeftLandscape?.frame = CGRectMake(xOpeBtn, rectDivBtn.minY, sizeOpeBtn, sizeOpeBtn)
        
        btnRightLandscape = UIButton().getWithBindClickEventWith(target: self, action: #selector(rightArrowAction(_:)), tag: nil)
        btnRightLandscape?.setImage(UIImage(named: "rightArrow"), for: .normal)
        btnRightLandscape?.layer.masksToBounds = true
        btnRightLandscape?.layer.cornerRadius = cornerRadiusBtn
        btnRightLandscape?.frame = btnLeftLandscape!.frame.yOffset(yInter+sizeOpeBtn)
        
        btnDelLandscape = UIButton().getWithBindClickEventWith(target: self, action: #selector(delAction(_:)), tag: nil)
        btnDelLandscape?.backgroundColor = colorDelBtnBnd
        btnDelLandscape?.setTitle("DEL", for: .normal)
        btnDelLandscape?.setTitleColor(colorDelBtnText, for: .normal)
        btnDelLandscape?.titleLabel?.font = UIFont.systemFont(ofSize: fontSizeOpeBtn)
        btnDelLandscape?.layer.masksToBounds = true
        btnDelLandscape?.layer.cornerRadius = cornerRadiusBtn
        btnDelLandscape?.frame = CGRectMake(btnLeftLandscape!.left, viewCalcuLandscapeL!.bottom - yInter - sizeOpeBtn, sizeOpeBtn, sizeOpeBtn)
        
        self.view.addSubview(btnLeftLandscape!)
        self.view.addSubview(btnRightLandscape!)
        self.view.addSubview(btnDelLandscape!)
    }
    
    @objc func leftArrowAction(_ sender: UIButton) {
        sender.shine()
        viewCalcuLandscapeL?.transferShowResult(viewCalcuLandscapeR!.curShowResult)
    }
    
    @objc func rightArrowAction(_ sender: UIButton) {
        sender.shine()
        viewCalcuLandscapeR?.transferShowResult(viewCalcuLandscapeL!.curShowResult)
    }
    
    @objc func delAction(_ sender: UIButton) {
        sender.shine()
        
        let canDelLeft = viewCalcuLandscapeL!.canDelOneChar
        let canDelRight = viewCalcuLandscapeR!.canDelOneChar
        
        if canDelLeft && !canDelRight {
            viewCalcuLandscapeL?.onDelOneChar()
            return
        } else if !canDelLeft && canDelRight {
            viewCalcuLandscapeR?.onDelOneChar()
            return
        } else if !canDelLeft && !canDelRight {
            return
        }
        
        var isClickLeft = true
        
        if viewCalcuLandscapeL!.timeStampLatestClick >= 0 && viewCalcuLandscapeR!.timeStampLatestClick >= 0 {
            
            if viewCalcuLandscapeL!.timeStampLatestClick < viewCalcuLandscapeR!.timeStampLatestClick {
                
                isClickLeft = false
            }
            
        } else if viewCalcuLandscapeL!.timeStampLatestClick >= 0 && viewCalcuLandscapeR!.timeStampLatestClick < 0 {
            
        } else if viewCalcuLandscapeL!.timeStampLatestClick < 0 && viewCalcuLandscapeR!.timeStampLatestClick >= 0 {
            
            isClickLeft = false
            
        } else {
        }
        
        if isClickLeft {
            viewCalcuLandscapeL?.onDelOneChar()
        } else {
            viewCalcuLandscapeR?.onDelOneChar()
        }
    }
    
    @objc fileprivate func orientaionDidChange() {
        self.refreshShowAccordCurOrientation()
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .allButUpsideDown
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    // only called when initialized, so in any orientation, it should be set landscape or portrait
    private func initShowFromCurOrientation() {
        if UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight {
            
            showLandScape()
        } else {
            showPortrait()
        }
    }
    
    // only when ui orientation changed, the orientation is not same with current and the orientation is portrait, landscapeleft or landscaperight, it has to be called
    private func refreshShowAccordCurOrientation() {
        if orientationUICur != UIDevice.current.orientation {
            if UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight {
                
                var needCopyInfo = false
                if orientationUICur == .portrait {
                    needCopyInfo = true
                }
                
                showLandScape()
                
                if needCopyInfo {
                    viewCalcuLandscapeL?.setCurInfo(viewCalcuPortrait!.getCurInfo())
                }
                
            } else if UIDevice.current.orientation == .portrait {
                showPortrait()
                viewCalcuPortrait?.setCurInfo(viewCalcuLandscapeL!.getCurInfo())
            }
        }
    }
    
    private func showLandScape() {
        orientationUICur = UIDevice.current.orientation
        
        viewCalcuPortrait?.isHidden = true
        viewCalcuLandscapeL?.isHidden = false
        viewCalcuLandscapeR?.isHidden = false
        btnLeftLandscape?.isHidden = false
        btnRightLandscape?.isHidden = false
        btnDelLandscape?.isHidden = false
    }
    
    private func showPortrait() {
        orientationUICur = .portrait
        
        viewCalcuPortrait?.isHidden = false
        viewCalcuLandscapeL?.isHidden = true
        viewCalcuLandscapeR?.isHidden = true
        btnLeftLandscape?.isHidden = true
        btnRightLandscape?.isHidden = true
        btnDelLandscape?.isHidden = true
    }
}
