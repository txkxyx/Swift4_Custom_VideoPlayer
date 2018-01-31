//
//  ViewController.swift
//  VideoPlayer
//
//  Created by 岡本拓也 on 2018/01/30.
//  Copyright © 2018年 takuya okamoto. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import AssetsLibrary

// MARK:- レイヤーをAVPlayerLayerにする為のラッパークラス.

class AVPlayerView: UIView {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
}

class ViewController: UIViewController {
    
    // 再生用のアイテム.
    var playerItem : AVPlayerItem!
    
    // AVPlayer.
    var videoPlayer : AVPlayer!
    
    // シークバー.
    var seekBar : UISlider!
    
    override func viewDidLoad() {
        
        // パスからassetを生成.
        let path = Bundle.main.path(forResource: "test", ofType: "MOV")
        let fileURL = URL(fileURLWithPath: path!)
        let avAsset = AVURLAsset(url: fileURL)
        
        // AVPlayerに再生させるアイテムを生成.
        playerItem = AVPlayerItem(asset: avAsset)
        
        // AVPlayerを生成.
        videoPlayer = AVPlayer(playerItem: playerItem)
        
        // Viewを生成.
        let videoPlayerView = AVPlayerView(frame:  self.view.bounds)
        
        // UIViewのレイヤーをAVPlayerLayerにする.
        let layer = videoPlayerView.layer as! AVPlayerLayer
        layer.videoGravity = AVLayerVideoGravity.resizeAspect
        layer.player = videoPlayer
        
        // レイヤーを追加する.
        self.view.layer.addSublayer(layer)
        
        // 動画のシークバーとなるUISliderを生成.
        seekBar = UISlider(frame: CGRect(x: 0, y: 0, width: self.view.bounds.maxX - 100, height: 50))
        seekBar.layer.position = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.maxY - 100)
        seekBar.minimumValue = 0
        seekBar.maximumValue = Float(CMTimeGetSeconds(avAsset.duration))
        seekBar.addTarget(self, action: #selector(onSliderValueChange(sender:)), for: UIControlEvents.valueChanged)
        self.view.addSubview(seekBar)
        
        /*
         シークバーを動画とシンクロさせる為の処理.
         */
        
        // 0.5分割で動かす事が出来る様にインターバルを指定.
        let interval : Double = Double(0.5 * seekBar.maximumValue) / Double(seekBar.bounds.maxX)
        
        // CMTimeに変換する.
        let time : CMTime = CMTimeMakeWithSeconds(interval, Int32(NSEC_PER_SEC))
        
        // time毎に呼び出される.
        videoPlayer.addPeriodicTimeObserver(forInterval: time, queue: nil, using: {time in
            // 総再生時間を取得.
            let duration = CMTimeGetSeconds(self.videoPlayer.currentItem!.duration)
            
            // 現在の時間を取得.
            let time = CMTimeGetSeconds(self.videoPlayer.currentTime())
            
            // シークバーの位置を変更.
            let value = Float(self.seekBar.maximumValue - self.seekBar.minimumValue) * Float(time) / Float(duration) + Float(self.seekBar.minimumValue)
            self.seekBar.value = value
        })
        
        // 動画の再生ボタンを生成.
        let startButton = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        startButton.layer.position = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.maxY - 50)
        startButton.layer.masksToBounds = true
        startButton.layer.cornerRadius = 20.0
        startButton.backgroundColor = UIColor.orange
        startButton.setTitle("Start", for: UIControlState.normal)
        startButton.addTarget(self, action: #selector(onButtonClick(sender:)), for: UIControlEvents.touchUpInside)
        self.view.addSubview(startButton)
    }
    
    // 再生ボタンが押された時に呼ばれるメソッド.
    @objc func onButtonClick(sender : UIButton){
        
        // 再生時間を最初に戻して再生.
        videoPlayer.seek(to: CMTimeMakeWithSeconds(0, Int32(NSEC_PER_SEC)))
        videoPlayer.play()
    }
    
    // シークバーの値が変わった時に呼ばれるメソッド.
    @objc func onSliderValueChange(sender : UISlider){
        
        // 動画の再生時間をシークバーとシンクロさせる.
        videoPlayer.seek(to: CMTimeMakeWithSeconds(Float64(seekBar.value), Int32(NSEC_PER_SEC)))
    }
   
}
