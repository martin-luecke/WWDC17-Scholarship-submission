import Foundation
import SpriteKit

public enum CharacterType : Int {
    case redGuy = 1, skirtGirl
    
    static func random() -> CharacterType {
        let randomNumber = arc4random_uniform(2) + 1
        guard let character = CharacterType(rawValue: Int(randomNumber)) else {
            return .redGuy
        }
        return character
    }
    
    static let allCharacters : [CharacterType] = [.redGuy, .skirtGirl]
}

/**
    One entity, walking around and being a part of a form with many other characters.
 */
open class Character : SKSpriteNode {

    public var type : CharacterType
    var textures : [SKTexture] = []
    
    public init(with type:CharacterType) {
        self.type = type
        textures = TextureManager.shared.getRandomTexture(for: self.type)
        super.init(texture: textures[0], color: .clear, size: textures[0].size())
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func getTextures() -> [SKTexture] {
        if textures.count == 0 {
            textures = TextureManager.shared.getRandomTexture(for: self.type)
        }
        return textures
    }
}


