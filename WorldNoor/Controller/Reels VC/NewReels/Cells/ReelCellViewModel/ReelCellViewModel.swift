//
//  ReelCellViewModel.swift
//  WorldNoor
//
//  Created by Asher Azeem on 17/04/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit
import SDWebImage
import Foundation
import Combine

class ReelCellViewModel {
    
    // MARK: - Publishers -
    @Published var tapGesturePublisher: UITapGestureRecognizer? = nil
    @Published var heightPublisher: CGFloat? = nil
    @Published var sliderPublisher: UIGestureRecognizer? = nil
    // MARK: - Properties -
    private var subscription: Set<AnyCancellable> = []
    private var apiService: APIService?
    
    // MARK: - Initilizer -
    init(apiService: APIService? = nil) {
        self.apiService = apiService
    }

    // MARK: - Methods -
    func enableGestureOnView(on view: UIView) {
        let singleTapGesture = addGesture(tap: 1, action:  #selector(handleTap(_:)), on: view)
        let doubleTapGesture = addGesture(tap: 2, action:  #selector(handleDoubleTap(_:)), on: view)
        singleTapGesture.require(toFail: doubleTapGesture)
    }
    
    func addGesture(tap: Int, action: Selector?, on view: UIView?) -> UITapGestureRecognizer {
        let tapGesture = UITapGestureRecognizer(target: self, action: action)
        tapGesture.numberOfTapsRequired = tap
        view?.addGestureRecognizer(tapGesture)
        return tapGesture
    }
    
    // Function to handle tap gesture
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        tapGesturePublisher = gesture
    }
    
    @objc func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        tapGesturePublisher = gesture
    }
    
    // MARK: - Animation -
    func animateButton(view: UIView?, image: UIImageView?, selectedImage: UIImage) {
        UIView.animate(withDuration: 0.2, animations: {
            view?.isHidden = false
            view?.transform = CGAffineTransform(scaleX: 1.12, y: 1.12)
            image?.image = selectedImage
        }) { _ in
            UIView.animate(withDuration: 0.3) {
                view?.transform = .identity
                view?.isHidden = true
            }
        }
    }
    
    // MARK: - Dimension -
    func calculateHeight(width: Int?, height: Int?) {
        if height != nil && width != nil && (height ?? 0 > 0) && (width ?? 0 > 0) {
            let cellWidth = UIScreen.main.bounds.width
            
            let videoHeight = CGFloat(height ?? 0)
            let videoWidth = CGFloat(width ?? 0)
            
            let aspectRation = Double(videoWidth) / Double(videoHeight)
            var calculatedHeight = cellWidth / aspectRation
            // Calculate full screen% of screen height
            let maxHeight = UIScreen.main.bounds.height
            if calculatedHeight > maxHeight {
                calculatedHeight = maxHeight
            }
            heightPublisher = calculatedHeight
        } else {
            heightPublisher = nil
        }
    }
    
    // MARK: - Play -
    private func getTimeString(seconds: Int) -> String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }

    func setVideo(_ playerView: VideoPlayerView?, of postID: Int?, at url: URL, isVoice: Bool, _ thumbnailImage: UIImageView?, slider: UISlider?, _ timeLabel: UILabel?) {
       playerView?.contentMode = .scaleAspectFill
        AppLogger.log(tag: .success, "Is Mute All Reels", isVoice)
        AppLogger.log(tag: .warning, "Playing URL == \(url)")
        playerView?.play(for: url)
        playerView?.isMuted = false
        playerView?.stateDidChanged = { state in
            switch state {
            case .none:
                AppLogger.log(tag: .warning, "none")
            case .error(let error):
                AppLogger.log(tag: .error, "error - \(error.localizedDescription)")
                thumbnailImage?.isHidden = false
            case .loading:
                AppLogger.log(tag: .success, "loading")
                thumbnailImage?.isHidden = false
            case .paused(let playing, let buffering):
                AppLogger.log(tag: .success, "paused - progress \(Int(playing * 100))% buffering \(Int(buffering * 100))%")
                let hasDuration = playerView?.currentDuration ?? 0.0 > 0
                thumbnailImage?.isHidden = hasDuration
            case .playing:
                AppLogger.log(tag: .success, "playing")
                thumbnailImage?.isHidden = true
                if let postId = postID {
                    SocketSharedManager.sharedSocket.playVideoSocket(postID: String(postId))
                }
            }
            switch state {
            case .playing, .paused:
                slider?.isEnabled = true
                slider?.isHidden = !(playerView?.currentDuration ?? 0.0 > 0) && ((playerView?.totalDuration ?? 0 <= 20.0))
            default:
                slider?.isEnabled = false
                slider?.isHidden = true
            }
        }
        
        playerView?.replay = { [weak self] in
            guard self != nil else { return }
            timeLabel?.text = "00:00"
            slider?.setValue(0, animated: false)
        }
        
        playerView?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 60), using: { [weak self] _ in
            guard let self else { return }
            slider?.value = Float((playerView?.currentDuration ?? 0.0) / (playerView?.totalDuration ?? 0.0))
            let formattedTime = formatDurationString(currentDuration: playerView?.currentDuration ?? 0.0, totalDuration: playerView?.totalDuration ?? 0.0)
            timeLabel?.text = formattedTime
            self.sliderVisibility(of: playerView, at: slider)
        })
        slider?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapSlider(_:))))
    }
    
    func sliderVisibility(of playerView: VideoPlayerView?, at slider: UISlider?) {
        switch playerView?.state {
        case .playing, .paused:
            slider?.isEnabled = true
            slider?.isHidden = !(playerView?.currentDuration ?? 0.0 > 0) && ((playerView?.totalDuration ?? 0 <= 20.0))
        default:
            slider?.isEnabled = false
            slider?.isHidden = true
        }
    }
    
    func formatDuration(duration: Double) -> String {
        let minutes = Int(duration / 60)
        let seconds = Int(duration.truncatingRemainder(dividingBy: 60))
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func formatDurationString(currentDuration: Double, totalDuration: Double) -> String {
        let formattedCurrent = formatDuration(duration: currentDuration)
        let formattedTotal = formatDuration(duration: totalDuration)
        return "\(formattedCurrent) / \(formattedTotal)"
    }
    
    func setPause(playerView: VideoPlayerView?) {
        playerView?.pause(reason: .hidden)
    }
    
    func setTextDirection(_ text: String?) -> NSTextAlignment{
        let langDirection = SharedManager.shared.detectedLangauge(for: text ?? .emptyString)
        var alignment: NSTextAlignment = .left
        if langDirection == Const.right {
            alignment = .right
        }
        return alignment
    }
    
    func setFontStyleForText(_ str: String) -> UIFont? {
        guard let langCode = SharedManager.shared.detectedLangaugeCode(for: str) else { return nil }
        return fontDecision(langCode)
    }
    
    func fontDecision(_ str: String) -> UIFont? {
        switch str {
        case "ar":
            return UIFont(name: "BahijTheSansArabicPlain", size: 11)
        case "ur":
            return UIFont(name: "Jameel-Noori-Nastaleeq", size: 11)
        default:
            return UIFont(name: "HelveticaNeue-Regular", size: 11)
        }
    }
    
    // MARK: - IBActions -
    @IBAction func tapSlider(_ gestureRecognizer: UIGestureRecognizer) {
        sliderPublisher = gestureRecognizer
    }
    
        
    // MARK: - Methods -
    func dislikeLike(_ feedObj: FeedData, _ indexPath: IndexPath, successCompletion: @escaping(FeedData, IndexPath) -> Void) {
        let userToken = SharedManager.shared.userToken()
        let parameters = ["action": "react",
                          "token": userToken,
                          "type": feedObj.isReaction ?? .emptyString,
                          "post_id": String(feedObj.postID!)]
        DispatchQueue.global(qos: .userInitiated).async {
            RequestManager.fetchDataPost(Completion: { response in
                Loader.stopLoading()
                DispatchQueue.main.async {
                    switch response {
                    case .failure(let error):
                        SwiftMessages.apiServiceError(error: error)
                    case .success(let res):
                        if res is Int {
                            AppDelegate.shared().loadLoginScreen()
                        } else if res is String {
                            SwiftMessages.showMessagePopup(theme: .error, title: "Failed", body: res as? String ?? .emptyString)
                        } else {
//                            if let reactionsMobile = feedObj.reationsTypesMobile, !reactionsMobile.isEmpty {
//                                if let index = reactionsMobile.firstIndex(where: { $0.type == feedObj.isReaction }) {
//                                    reactionsMobile[index].count! -= 1
//                                    if reactionsMobile[index].count! == 0 {
//                                        feedObj.reationsTypesMobile!.remove(at: index)
//                                    }
//                                }
//                            }
//                            feedObj.likeCount = (feedObj.likeCount) == nil ? 0 : (feedObj.likeCount ?? 0) - 1
                            
                             feedObj.isReaction = ""
                            successCompletion(feedObj, indexPath)
                        }
                    }
                }
            }, param: parameters)
        }
    }
}
