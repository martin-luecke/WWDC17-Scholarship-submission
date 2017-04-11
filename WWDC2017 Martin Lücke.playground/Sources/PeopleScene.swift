import Foundation
import SpriteKit
import UIKit
import CoreMotion

open class PeopleScene : SKScene {
    

    
    var characters : [Character] = []
    
    var midPoint : CGPoint?
    let minOutsideSpawnDistance = 30
    let maxOutsideSpawnDistance = 150
    
    public var duration = 6.0
    
    
    public override init(size: CGSize) {
        super.init(size: size)
        setupBackground(size: size)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
        Iterates through a specified form and creates enough characters to fill it.
        - parameter forms: the specified form as multiple UIBezierPaths
        - parameter variance: upper bound for a random spawningoffset, so that no grid is visible
        - parameter reuseCharacters: Should existing characters in the scene be reused or everything spawned new
     */
    public func fill(forms : [UIBezierPath], variance : Int, reuseCharacters : CharacterUse) {
        guard forms.count > 0 else {
            return
        }
        var positions : [CGPoint] = []
        
        for x in stride(from: 0, to: 800, by: 10) {
            for y in stride(from: 0, to: 600, by: 10) {
                for form in forms {
                    if form.contains(CGPoint(x: x, y: y)) {
                        let saltedPosition = salt(position: CGPoint(x: x, y: y), with: variance)
                        positions.append(saltedPosition)
                    }
                }
            }
        }
        
        positions.shuffle() //otherwise it would not look random
        
        //spawn new characters or use existing ones
        for i in 0...positions.count-1 {
            if i >= characters.count || !(reuseCharacters == .reuse) {
                spawnCharacter(at: randomPositionOutside(of: self.frame, minDistance: minOutsideSpawnDistance, maxDistance: maxOutsideSpawnDistance), with: positions[i], lookAround: false)
            } else {
                walk(character: characters[i], textures: characters[i].getTextures(), from: characters[i].position, to: positions[i], completion: nil)
            }
        }
        
        //if there are too much characters in the scene send some outside
        if (characters.count > positions.count) && reuseCharacters == .reuse {
            for i in positions.count...characters.count-1 {
                let characterToRemove = characters[i]
                walk(character: characters[i], textures: characters[i].getTextures(), from: characters[i].position, to: randomPositionOutside(of: self.frame, minDistance: minOutsideSpawnDistance, maxDistance: maxOutsideSpawnDistance), completion: {
                    characterToRemove.removeFromParent()
                    self.characters.remove(at: self.characters.index(of: characterToRemove)!)
                })
            }
        //send characters of old forms off the scene
        } else if (characters.count > positions.count) && reuseCharacters == .spawnNew {
            for i in 0...(characters.count - positions.count) {
                let characterToRemove = characters[i]
                walk(character: characters[i], textures: characters[i].getTextures(), from: characters[i].position, to: randomPositionOutside(of: self.frame, minDistance: minOutsideSpawnDistance, maxDistance: maxOutsideSpawnDistance), completion: {
                    characterToRemove.removeFromParent()
                    self.characters.remove(at: self.characters.index(of: characterToRemove)!)
                })
            }
        }
        
        SoundManager.shared.playFootstepSound(duration: Float(duration), characterCount: positions.count)
        
    }
    
    
    
    /**
        Spawns a random character at a specified position and lets him walk to another position
        - parameter position: spawning point of the character
        - parameter destination: point for the character to walk to
     */
    public func spawnCharacter(at position:CGPoint, with destination: CGPoint, lookAround : Bool) {
        let character = Character(with: CharacterType.random())
        character.position = position
        character.setScale(0.15)
        
        characters.append(character)
    
        if lookAround {
            SoundManager.shared.playFootstepSound(duration: Float(duration), characterCount: 1)
        }
        
        walk(character: character, textures: character.getTextures(), from: position, to: destination, completion: {
            if lookAround {
                let turnActionLeft = SKAction.rotate(toAngle: CGFloat(-(Double.pi / 6)), duration: 0.5, shortestUnitArc: true)
                //turnActionLeft.timingMode = .easeInEaseOut
                let turnActionRight = SKAction.rotate(toAngle: CGFloat(-(Double.pi * (5/6))), duration: 1, shortestUnitArc: true)
                //turnActionRight.timingMode = .easeInEaseOut
                let turnActionStraight = SKAction.rotate(toAngle: CGFloat(-(Double.pi / 2)), duration: 0.5, shortestUnitArc: true)
                //turnActionRight.timingMode = .easeInEaseOut
                
                character.run(SKAction.sequence([turnActionLeft, turnActionRight, turnActionStraight]))
            }
        })
        
        addChild(character)
    }
    
    /**
        Animates the moving of a character from one point to another
        - parameter character: The character, that should walk somewhere
        - parameter textures: The animationFrames for the walking animation
        - parameter position: Starting position of the character
        - parameter destination: Final position of the character
     */
    func walk(character : Character, textures : [SKTexture], from position: CGPoint, to destination: CGPoint, completion : (()->Void)?) {

        let timePerFrame = 0.01
        
        character.removeAllActions()
        
        let walkingAnimation = SKAction.animate(with: textures, timePerFrame: timePerFrame)
        let repeatingWalkingAction = SKAction.repeat(walkingAnimation, count: Int(duration / (Double(textures.count) * timePerFrame)))        //duration / (numberofFrames * timePerFrame)
        
        repeatingWalkingAction.timingMode = .easeInEaseOut
        
        if completion != nil {
            character.run(repeatingWalkingAction, completion: completion!)
        } else {
            character.run(repeatingWalkingAction)
        }
        
        
        
        let moveAction = SKAction.move(to: destination, duration: TimeInterval(duration))
        moveAction.timingMode = .easeInEaseOut
        character.run(moveAction, completion: {
            //guy1.removeAllActions()
        })
        
        let turnAction = SKAction.rotate(toAngle: CGFloat(getOrientationforJourney(from: position, to: destination)), duration: TimeInterval(duration/10), shortestUnitArc: true)
        turnAction.timingMode = .easeInEaseOut
        character.run(turnAction)
    }
    
    func getOrientationforJourney(from: CGPoint, to:CGPoint) -> Double {
        return atan2(Double(from.y - to.y), Double(from.x - to.x)) + Double.pi / 2
    }
    
    /**
        Apply a small random offset to a position
        - parameter position: The initial position
        - parameter variance: The maximum offset
     */
    func salt(position: CGPoint, with variance:Int) -> CGPoint {
        let randomSaltX = Int(arc4random_uniform(2 * UInt32(variance) + 1)) - variance
        let randomSaltY = Int(arc4random_uniform(2 * UInt32(variance) + 1)) - variance
        return CGPoint(x: Int(position.x) + randomSaltX, y: Int(position.y) + randomSaltY)
    }
    
    func randomPosition(in frame:CGRect) -> CGPoint {
        let randomX = arc4random_uniform(UInt32(frame.width)+1)
        let randomY = arc4random_uniform(UInt32(frame.height)+1)
        return CGPoint(x: Int(frame.minX) + Int(randomX), y: Int(frame.minY) + Int(randomY))
    }
    
    /**
        Creates a random position outside of a specified frame
        - parameter frame: The frame that the final position should be outside of
        - parameter minDistance: The minimal distance from the frame
        - parameter maxDistance: The maximal distance from the frame
     */
    func randomPositionOutside(of frame : CGRect, minDistance : Int , maxDistance : Int) -> CGPoint {
        guard maxDistance > minDistance else {
            return CGPoint(x: 0, y: 0)
        }
        
        //get the surrounding areas as Rects:
        let topFrame = CGRect(x: -maxDistance, y: Int(frame.height) + minDistance , width: Int(frame.width) + 2 * maxDistance, height: maxDistance - minDistance)
        let rightFrame = CGRect(x: Int(frame.width) + minDistance, y: Int(frame.minY), width: maxDistance - minDistance, height: Int(frame.height))
        let bottomFrame = CGRect(x: -maxDistance, y: -maxDistance, width: Int(frame.width) + 2 * maxDistance, height: maxDistance - minDistance)
        let leftFrame = CGRect(x: -maxDistance, y: Int(frame.minY), width: maxDistance - minDistance, height: Int(frame.height))
        
        //choose one of them randomly and return a random position inside
        let randomFrame = arc4random_uniform(4)
        switch randomFrame {
        case 3:
            return randomPosition(in: topFrame)
        case 2:
            return randomPosition(in: rightFrame)
        case 1:
            return randomPosition(in: bottomFrame)
        case 0:
            return randomPosition(in: leftFrame)
        default:
            return CGPoint(x: 0, y: 0)
        }
    }
    
    func setupBackground(size: CGSize) {
        let context = CIContext(options: nil)
        
        let filter = CIFilter(name: "CIRadialGradient")!
        let color1 = CIColor(color: .white)
        let color2 = CIColor(color: .gray)
        let center = CIVector(x: size.width / 2, y: size.height / 2)
        let maxDimension = size.width > size.height ? size.width : size.height
        
        filter.setValue(center, forKey: "inputCenter")
        filter.setValue(0, forKey: "inputRadius0")
        filter.setValue(maxDimension + 250, forKey: "inputRadius1")
        filter.setValue(color1, forKey: "inputColor0")
        filter.setValue(color2, forKey: "inputColor1")
        
        if let filteredImage = filter.outputImage, let backgroundImage = context.createCGImage(filteredImage, from: CGRect(x: 0, y: 0, width: size.width, height: size.height)) {
            let backgroundTexture = SKTexture(cgImage: backgroundImage)
            let backgroundNode = SKSpriteNode(texture: backgroundTexture)
            backgroundNode.position = CGPoint(x: size.width/2, y: size.height/2)
            
            self.addChild(backgroundNode)
        }
    }
}

extension Array {

    ///Shuffles the elements inside this Array by random.
    mutating func shuffle() {
        for i in 0..<(count - 1) {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            if i != j {                               //For some reason the same two elements cannot be swappped in an iOS Playground
                swap(&self[i], &self[j])
            }
        }
    }
}
