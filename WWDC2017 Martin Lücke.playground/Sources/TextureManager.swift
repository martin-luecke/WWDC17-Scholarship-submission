import Foundation
import SpriteKit

/**
    Manages the creation of textures for characters, including recoloring. Since this is very expensive it should definitely happen only once.
 */
open class TextureManager {
    
    //Singleton
    public static let shared : TextureManager = TextureManager()
    
    private init() {
    }
    
    var textures : [CharacterType : [[SKTexture]]] = [:]

    
    public func getRandomTexture(for character : CharacterType) -> [SKTexture] {
        guard let characterTextures = textures[character] else {
            return []
        }
        let numTextures = characterTextures.count
        return characterTextures[Int(arc4random_uniform(UInt32(numTextures)))]
    }
    
    /**
        Initialize textures with specified colors for later use
     
        - parameter characterColors: Array of CIColor pairs. First one for color of top (e.g t-shirt). Second for color of bottom (e.g. pants, skirt)
     */
    public func prepareTextures(characterColors : [(top: CIColor, bottom: CIColor)]) {
        
        for character in CharacterType.allCharacters {
            
            textures[character] = []
            for _ in characterColors {
                textures[character]?.append([])     //setup Arrays for Textures
            }
            
            switch character {
            case .redGuy:
                let pantsColor = CIColor(red: 98/255, green: 99/255, blue: 112/255)//???
                let shirtColor = CIColor(red: 191/255, green: 52/255, blue: 52/255)
                
                for i in 10...32 {
                    if let cgImage = UIImage(named: "erster Laufender\(i)")?.cgImage {
                        for colorIndex in 0...characterColors.count-1 {
                            
                            let newTexture = SKTexture(cgImage: cgImage.newImageByReplacing(colors: [(shirtColor, characterColors[colorIndex].top), (pantsColor, characterColors[colorIndex].bottom)]))
                            textures[character]![colorIndex].append(newTexture)         //! okay, Arrays setup above
                        }
                    }
                }
                for i in -32 ... -10 {
                    if let cgImage = UIImage(named: "erster Laufender\(-i)")?.cgImage {
                        for colorIndex in 0...characterColors.count-1 {
                            
                            let newTexture = SKTexture(cgImage: cgImage.newImageByReplacing(colors: [(shirtColor, characterColors[colorIndex].top), (pantsColor, characterColors[colorIndex].bottom)]))
                            textures[character]![colorIndex].append(newTexture)         //! okay, Arrays setup above
                        }
                    }
                }
            case .skirtGirl:
                let pantsColor = CIColor(red: 187/255, green: 77/255, blue: 65/255)//???
                let shirtColor = CIColor(red: 98/255, green: 99/255, blue: 112/255)
                
                for i in 110...199 {
                    if let cgImage = UIImage(named: "women\(i)")?.cgImage {
                        for colorIndex in 0...characterColors.count-1 {
                            
                            let newTexture = SKTexture(cgImage: cgImage.newImageByReplacing(colors: [(shirtColor, characterColors[colorIndex].top), (pantsColor, characterColors[colorIndex].bottom)]))
                            //let c = CIColor(color: .yellow)
                            textures[character]![colorIndex].append(newTexture)         //! okay, Arrays setup above
                        }
                    }
                }
            }
        }
    }
}

extension CGImage {
    
    /**
        Returns a new image, where some colors are replaced with others
        - parameter colors: An array of CIColor pairs. The first color of one pair will be replaced with the second color in this pair in the image. This will happen for all pairs of colors.
     */
    func newImageByReplacing(colors: [(CIColor, CIColor)]) -> CGImage {
        
        guard dataProvider != nil else {
            return self
        }
        
        let pixelData = dataProvider!.data //Data aus CGImage
        //Pointer auf die Daten
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        let width = self.width
        let height = self.height
        
        //Mutable Pointer, um Daten verändern zu können
        let mutableData = UnsafeMutablePointer<UInt8>(mutating: data)
        
        for i in stride(from: 0, to: width * height * 4, by: 4) {
            //RGBa, 0 - 255
            for colorIndex in 0...colors.count-1 {
                if mutableData[i] == UInt8(colors[colorIndex].0.red * 255) {
                    if mutableData[i+1] == UInt8(colors[colorIndex].0.green * 255) {
                        if mutableData[i+2] == UInt8(colors[colorIndex].0.blue * 255) {
                            
                            mutableData[i] = UInt8(colors[colorIndex].1.red * 255)
                            mutableData[i+1] = UInt8(colors[colorIndex].1.green * 255)
                            mutableData[i+2] = UInt8(colors[colorIndex].1.blue * 255)
                            
                        }
                    }
                }
            }
        }
        
        //Daraus neues CGImage machen
        if let newCGImage = CGImage(width: width, height: height, bitsPerComponent: self.bitsPerComponent, bitsPerPixel: self.bitsPerPixel, bytesPerRow: self.bytesPerRow, space: self.colorSpace!, bitmapInfo: CGBitmapInfo(rawValue: UInt32(CGImageAlphaInfo.premultipliedLast.rawValue)), provider: CGDataProvider(data: NSData(bytes: mutableData, length: height*width*4))!, decode: nil, shouldInterpolate: true, intent: CGColorRenderingIntent.defaultIntent) {
            return newCGImage
        }
        return self
    }
}
