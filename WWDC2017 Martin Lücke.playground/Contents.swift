/*:
 ## Welcome to my WWDC 2017 playground
 It is inspired by the WWDC wallpapers and features a dynamic trailer for this years WWDC.
 If you run the code without changing anything you will see my default trailer.
 However, after seeing it for the first time check out some of the available options below.
 The trailer is best experienced on an iPad in fullscreen mode.
 */

import PlaygroundSupport
import UIKit

let choreoManager = ChoreoManager()

//: Initialize the choreoManager like this instead, to set custom colors for the characters:
/*
let characterColors = [(top: UIColor.yellow, bottom: UIColor.darkGray),
                       (top: UIColor.green, bottom: UIColor.red),
                       (top: UIColor.cyan, bottom: UIColor.gray),
                       (top: UIColor.blue, bottom: UIColor.gray),
                       (top: UIColor.orange, bottom: UIColor.gray)]
let choreoManager = ChoreoManager(with: characterColors)
*/

choreoManager.delayBetweenElements = 2
choreoManager.elementDuration = 7
choreoManager.spawnVariance = 4
PlaygroundPage.current.liveView = choreoManager.liveFeedbackView

/*:
 Here is the construction of the choreo.
 The available elements are: 
 - Apple
 - iPhone
 - Mac
 - Watch
 - SwiftBird
 - WWDC
 - NegativeApple
 
 Custom options can be set for every element.
 */

choreoManager.addToChoreo(choreoElem: .Apple, with: [.instant])
choreoManager.addToChoreo(choreoElem: .WalkToApple, with: [.duration(5), .delayed(2)])
choreoManager.addToChoreo(choreoElem: .iPhone, with: [.startMusic])
choreoManager.addToChoreo(choreoElem: .Mac, with: [.customSpawnVariance(3)])
choreoManager.addToChoreo(choreoElem: .Watch, with: [])
choreoManager.addToChoreo(choreoElem: .SwiftBird, with: [])
choreoManager.addToChoreo(choreoElem: .WWDC, with: [.reuseCharacters(.spawnNew)])
choreoManager.addToChoreo(choreoElem: .NegativeApple, with: [.stopMusicIn(8)])

//: If those are not enough, even custom forms can be designed as Beziercurve and added to the choreo:
//let customForm : [UIBezierPath] = Forms.CircleForm(radius: 150)
//choreoManager.addToChoreo(choreoElem: .Custom, with: [.custom(customForm)])



//: Let the show begin!
choreoManager.perform()
