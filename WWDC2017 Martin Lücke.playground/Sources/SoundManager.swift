import Foundation
import AVFoundation
import UIKit

open class SoundManager : NSObject {

    public static let shared : SoundManager = SoundManager()

    var audioEngine : AVAudioEngine = AVAudioEngine()
    var stepPlayers : [AVAudioPlayerNode] = []
    var backgroundAudioPlayer : AVAudioPlayerNode = AVAudioPlayerNode()
    var stepPitches : [AVAudioUnitTimePitch] = []
    
    var numberOfStepPlayers = 70        //kann auch kleiner gewaehlt werden
    
    var divideBy : Float = 35
    var upperPitch : Float = 5
    var lowerPitch : Float = 0.8
    var upperRate : Float = 3
    var lowerRate : Float = 0.8
    
    override init() {
    }
    
    public func prepareSounds() {
        
        for _ in 0...numberOfStepPlayers-1 {
            stepPlayers.append(AVAudioPlayerNode())
            let pitch = AVAudioUnitTimePitch()
            pitch.pitch = randomValueBetween(lower: lowerPitch, upper: upperPitch)
            pitch.rate = randomValueBetween(lower: lowerRate, upper: upperRate)
            stepPitches.append(pitch)
        }
        let footstepPath = Bundle.main.path(forResource: "footsteps", ofType:"mp3")
        let footstepAudioURL = URL(fileURLWithPath: footstepPath!)
        
        let backgroundAudioPath = Bundle.main.path(forResource: "WWDC 2017 Background", ofType:"m4a")
        let backgroundAudioURL = URL(fileURLWithPath: backgroundAudioPath!)
        
        do {
            //prepare BackgroundAudioplayer
            let backgroundAudioFile = try AVAudioFile(forReading: backgroundAudioURL)
            let backgroundAudioFileBuffer = AVAudioPCMBuffer(pcmFormat: backgroundAudioFile.processingFormat, frameCapacity: AVAudioFrameCount(backgroundAudioFile.length))
            try backgroundAudioFile.read(into: backgroundAudioFileBuffer)
            audioEngine.attach(backgroundAudioPlayer)
            audioEngine.connect(backgroundAudioPlayer, to: audioEngine.mainMixerNode, format: backgroundAudioFile.processingFormat)
            backgroundAudioPlayer.scheduleBuffer(backgroundAudioFileBuffer, at: nil, options: [.loops], completionHandler: nil)
            
            //prepare FootstepAudioPlayers
            let footstepFile = try AVAudioFile(forReading: footstepAudioURL)
            let footstepFileBuffer = AVAudioPCMBuffer(pcmFormat: footstepFile.processingFormat, frameCapacity: AVAudioFrameCount(footstepFile.length))
            try footstepFile.read(into: footstepFileBuffer)
            
            for i in 0...numberOfStepPlayers-1 {
                audioEngine.attach(stepPlayers[i])
                audioEngine.attach(stepPitches[i])
                
                audioEngine.connect(stepPlayers[i], to: stepPitches[i], format: footstepFile.processingFormat)
                audioEngine.connect(stepPitches[i], to: audioEngine.mainMixerNode, format: footstepFile.processingFormat)
                
                stepPlayers[i].scheduleBuffer(footstepFileBuffer, at: nil, options: [.loops], completionHandler: nil)
            }
            
            //prepare Engine
            audioEngine.prepare()
            try audioEngine.start()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    /**
        Plays footstep sounds depending on the parmeters, to make a mass of characters sound convincing
        - parameter duration: duration of the walking action, to time the steps with it
        - parameter characterCount: Number of characters in the scene, depending on this more ore less footsteps wil be heard
     */
    public func playFootstepSound(duration : Float, characterCount : Int) {
        
        var numberOfActivePlayers = Int(ceil(Float(characterCount) / divideBy))
        
        if numberOfActivePlayers > numberOfStepPlayers {
            numberOfActivePlayers = numberOfStepPlayers
        }
        
        Timer.scheduledTimer(withTimeInterval: TimeInterval(duration), repeats: false, block: {timer in
            for i in 0...numberOfActivePlayers-1 {
                self.stepPlayers[i].pause()
            }
            timer.invalidate()
        })
        
        let kStartDelayTime = 0.05 // sec
        
        for i in 0...numberOfActivePlayers-1 {
            let sampleTime = stepPlayers[i].lastRenderTime!.sampleTime
            let sampleRate = stepPlayers[i].lastRenderTime!.sampleRate
            let startSampleTime : AVAudioFramePosition = sampleTime + Int64(Double(i) * kStartDelayTime * sampleRate)
            let startTime = AVAudioTime(sampleTime: startSampleTime, atRate: stepPlayers[i].lastRenderTime!.sampleRate)
            
            self.stepPlayers[i].play(at: startTime)
        }
    }
    
    public func fadeOutBackgroundMusic(duration : Float) {
        var currentVolume : Float = 1.0
        let interval : Float = 0.1
        Timer.scheduledTimer(withTimeInterval: TimeInterval(interval), repeats: true, block: { timer in
            currentVolume = Float(currentVolume - (interval / duration))
            self.backgroundAudioPlayer.volume = currentVolume
            if (currentVolume == 0) {
                timer.invalidate()
                self.backgroundAudioPlayer.pause()
            }
        })
    }

    public func playBackgroundMusic() {
        backgroundAudioPlayer.volume = 1
        backgroundAudioPlayer.play()
    }
    
    func randomValueBetween(lower : Float, upper : Float) -> Float {
        return Float(arc4random_uniform(UInt32(upper * 100 - lower * 100))) / 100.0 + lower
    }

    
    
}
