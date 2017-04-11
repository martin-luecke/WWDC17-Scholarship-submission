import Foundation
import SpriteKit


///Name of the choreographic element or indicator for a custom one
public enum ChoreoElement {
    case WWDC, Apple, NegativeApple, iPhone, Watch, Mac, SwiftBird, Custom, WalkToApple
}

///Different modes for characterspawning and -reuse
public enum CharacterUse {
    case reuse, spawnNew, spawnNewOldStay
}

///Options for a specific choreographic element
public enum ChoreoOptions {
    case delayed(Double)
    case duration(Double)
    case custom([UIBezierPath])
    case reuseCharacters(CharacterUse)
    case customSpawnVariance(Int)
    case instant
    case startMusic
    case stopMusicIn(Double)
    case startTiltGame
}


/**
    Responsible for managing duration, form and other properties of choreographic elements.
 */
open class ChoreoManager {
    
    public var liveFeedbackView : SKView
    public var delayBetweenElements = 3.0
    public var elementDuration = 6.0
    public var spawnVariance = 3
    public var backgroundMusicActivated = true
    
    public var peopleScene : PeopleScene
    var choreo : [(element: ChoreoElement, options: [ChoreoOptions])] = []
    var frame : CGRect
    
    
    public convenience init() {
        let realColors = [(top: CIColor(red: 110/255, green: 161/255, blue: 180/255), bottom: CIColor(red: 52/255, green: 54/255, blue: 55/255)), (top: CIColor(red: 52/255, green: 54/255, blue: 55/255), bottom: CIColor(red: 98/255, green: 74/255, blue: 73/255)), (top: CIColor(red: 16/255, green: 90/255, blue: 155/255), bottom: CIColor(red: 23/255, green: 127/255, blue: 200/255)), (top: CIColor(red: 223/255, green: 102/255, blue: 137/255), bottom: CIColor(red: 194/255, green: 155/255, blue: 97/255)), (top: CIColor(red: 216/255, green: 165/255, blue: 21/255), bottom: CIColor(red: 90/255, green: 92/255, blue: 92/255)), (top: CIColor(red: 204/255, green: 201/255, blue: 200/255), bottom: CIColor(red: 23/255, green: 127/255, blue: 200/255)), (top: CIColor(red: 31/255, green: 151/255, blue: 64/255), bottom: CIColor(red: 90/255, green: 92/255, blue: 92/255)), (top: CIColor(red: 121/255, green: 72/255, blue: 150/255), bottom: CIColor(red: 97/255, green: 145/255, blue: 167/255))]
        
        self.init(colors: realColors)
    }
    
    init(colors : [(top: CIColor, bottom: CIColor)]) {
        frame = CGRect(x: 0, y: 0, width: 800, height: 600)
        peopleScene = PeopleScene(size: frame.size)
        peopleScene.scaleMode = .aspectFit
        
        liveFeedbackView = SKView(frame: CGRect(x: 0, y: 0, width: 800, height: 600))
        liveFeedbackView.presentScene(peopleScene)
        
        TextureManager.shared.prepareTextures(characterColors: colors)
        SoundManager.shared.prepareSounds()
    }
    
    /**
        - parameter characterColors: Array of UIColor pairs. First one for color of top (e.g t-shirt). Second for color of bottom (e.g. pants, skirt)
     */
    public convenience init(with characterColors : [(top: UIColor, bottom: UIColor)]) {
        var ciColors : [(CIColor, CIColor)] = []
        for color in characterColors {
            ciColors.append((CIColor(color: color.top), CIColor(color: color.bottom)))
        }
        self.init(colors: ciColors)
    }
    
    public func addToChoreo(choreoElem : ChoreoElement, with options: [ChoreoOptions]) {
        choreo.append((choreoElem, options))
    }
    
    
    ///Starts the execution of the choreographic elements in the order of adding
    public func perform() {
        
        var timeBaseline : DispatchTime = .now()
        var deadline = timeBaseline

        for i in 0...choreo.count-1 {
            
            //Hier können noch Optionen des einzelnen mit einbezogen werden (Extradelay, Spawnvarianz danach oderso)
            var reuseCharacters = CharacterUse.reuse
            var duration = elementDuration
            var delay = delayBetweenElements
            var specificSpawnVariance = spawnVariance
            
            for option in self.choreo[i].options {
                switch option {
                case .reuseCharacters(let customReuse):
                    reuseCharacters = customReuse
                case .delayed(let customDelay):
                    delay = customDelay
                case .duration(let customDuration):
                    duration = customDuration
                case .customSpawnVariance(let customSpawnVariance):
                    specificSpawnVariance = customSpawnVariance
                case .instant:
                    duration = 0
                default:
                    break
                }
            }
            
            deadline = timeBaseline
            timeBaseline = timeBaseline + Double(duration + delay)
            
            //Zeiten stimmen nicht
            DispatchQueue.main.asyncAfter(deadline: deadline, execute: {
                self.peopleScene.duration = duration
                
                switch self.choreo[i].element {
                case .WWDC:
                    let forms = Forms.WWDCForm()
                    self.peopleScene.fill(forms: forms, variance: specificSpawnVariance, reuseCharacters: reuseCharacters)
                case .Apple:
                    //let forms = Forms.AppleForm(baseFrame: CGRect(x: 0, y: 0, width: self.liveFeedbackView.frame.width, height: self.liveFeedbackView.frame.width), leafFrame: CGRect())
                    let forms = Forms.AppleForm()
                    self.peopleScene.fill(forms: forms, variance: specificSpawnVariance, reuseCharacters: reuseCharacters)
                case .NegativeApple:
                    let forms = Forms.negativeApple()
                    self.peopleScene.fill(forms: forms, variance: specificSpawnVariance, reuseCharacters: reuseCharacters)
                case .iPhone:
                    let forms = Forms.iPhoneForm()
                    self.peopleScene.fill(forms: forms, variance: specificSpawnVariance, reuseCharacters: reuseCharacters)
                case .Watch:
                    let forms = Forms.watchForm()
                    self.peopleScene.fill(forms: forms, variance: specificSpawnVariance, reuseCharacters: reuseCharacters)
                case .Mac:
                    let forms = Forms.macForm()
                    self.peopleScene.fill(forms: forms, variance: specificSpawnVariance, reuseCharacters: reuseCharacters)
                case .SwiftBird:
                    let forms = Forms.swiftBirdForm()
                    self.peopleScene.fill(forms: forms, variance: specificSpawnVariance, reuseCharacters: reuseCharacters)
                case .Custom:
                    var forms : [UIBezierPath] = []
                    for option in self.choreo[i].options {
                        switch option {
                        case ChoreoOptions.custom(let paths):
                            forms.append(contentsOf: paths)
                        default:
                            break
                        }
                    }
                    self.peopleScene.fill(forms: forms, variance: self.spawnVariance, reuseCharacters: reuseCharacters)
                case .WalkToApple:
                    self.peopleScene.spawnCharacter(at: CGPoint(x: -50, y: self.frame.height/2), with: CGPoint(x: self.frame.width * (1/4), y: self.frame.height/2), lookAround: true)
                }
                for option in self.choreo[i].options {
                    switch option {
                        case .startMusic:
                            if self.backgroundMusicActivated {
                                SoundManager.shared.playBackgroundMusic()
                            }
                        case .stopMusicIn(let time):
                                SoundManager.shared.fadeOutBackgroundMusic(duration: Float(time))
                        default:
                            break
                    }
                }
            })
        }
    }
}
