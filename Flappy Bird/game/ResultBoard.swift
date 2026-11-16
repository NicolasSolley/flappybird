
//
//  ResultBoard.swift
//  FlappyBird
//
//  Created by Brandon Plank on 12/2/19.
//  Modified by ThathcerDev on 3/22/20.
//  Copyright (c) 2016 Brandon Plank. All rights reserved.
//
import SpriteKit
import Network

public class ResultBoard: SKSpriteNode {
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(score: Int) {
        let image = Assets.shared.sprites.textureNamed("scoreboard").then { $0.filteringMode = .nearest }
        self.init(texture: image, color: UIColor.clear, size: image.size())
        
        bestScore.text = "\(ResultBoard.bestScore())"
        bestScoreInside.text = "\(ResultBoard.bestScore())"
        currentScore.text = "0"
        currentScoreInside.text = "0"
        
        addChild(new)
        new.setScale(0)
        addChild(sparkle)
        addChild(newBestLabel)
        addChild(currentScore)
        addChild(bestScore)
        addChild(currentScoreInside)
        addChild(bestScoreInside)
        addChild(medal)
        self.score = score
    }
    
    private lazy var currentScore = SKLabelNode(fontNamed: "04b_19").then {
        $0.zPosition = GamezPosition.resultText + 1
        $0.fontSize = 16
        $0.fontColor = SKColor.black
        $0.position = CGPoint(x: frame.midX + 75, y: frame.midY + 7)
    }
    
    private lazy var currentScoreInside = SKLabelNode(fontNamed: "inside").then {
        $0.zPosition = GamezPosition.resultText
        $0.fontSize = 16
        $0.fontColor = SKColor.white
        $0.position = CGPoint(x: frame.midX + 75 - 0.49, y: frame.midY + 7)
    }
    
    private lazy var bestScore = SKLabelNode(fontNamed: "04b_19").then {
        $0.zPosition = GamezPosition.resultText + 1
        $0.fontSize = 16
        $0.fontColor = SKColor.black
        $0.position = CGPoint(x: frame.midX + 75, y: frame.midY - 35)
    }
    
    private lazy var bestScoreInside = SKLabelNode(fontNamed: "inside").then {
        $0.zPosition = GamezPosition.resultText
        $0.fontSize = 16
        $0.fontColor = SKColor.white
        $0.position = CGPoint(x: frame.midX + 75 - 0.49, y: frame.midY - 35)
    }
    
    private lazy var medal = SKSpriteNode().then {
        $0.zPosition = GamezPosition.resultText
        $0.position = CGPoint(x: frame.midX - 64, y: frame.midY - 6)
    }
    
    private lazy var new = SKSpriteNode(texture: Assets.shared.sprites.textureNamed("new")).then {
        $0.zPosition = GamezPosition.resultText
        $0.position = CGPoint(x: frame.midX + 35, y: frame.midY - 6)
        $0.setScale(0)
    }

    private lazy var newBestLabel = SKLabelNode(
        fontNamed: "04b_19"
    ).then {
        $0.text = "NEW BEST!"
        $0.fontSize = 15
        $0.fontColor = UIColor(
            red: 1.0,
            green: 0.85,
            blue: 0.2
        )
        $0.position = CGPoint(x: frame.midX, y: frame.midY + 78)
        $0.zPosition = GamezPosition.resultText + 1
        $0.alpha = 0
    }
    
    private lazy var sparkle = SKSpriteNode(texture: Assets.shared.sprites.textureNamed("sparkle")).then {
        $0.setScale(0)
        $0.zPosition = GamezPosition.resultText+1
    }
    
    private let sparkleAction = SKAction.repeatForever(SKAction.sequence([
        SKAction.customAction(withDuration: 0.0) { (node, _) in
            let newX = CGFloat(Float.random(in: -88...(-40)))
            let newY = CGFloat(Float.random(in: -26...15))
            node.run(SKAction.move(to: CGPoint(x: newX, y: newY), duration: 0.0))
        },
        SKAction.scale(to: 0.7, duration: 0.3),
        SKAction.wait(forDuration: 0.5),
        SKAction.scale(to: 0.0, duration: 0.3)
    ]))
    
    var score: Int = 0 {
        didSet {
            #if DEBUG
            print(timeTook)
            #endif
            if canShowScore {
                
                DispatchQueue.global().async {
                    let previousHighScore = ResultBoard.bestScore()
                    if(self.score > ResultBoard.bestScore()){
                        ResultBoard.setBestScore(self.score)
                    }

                    let isNewBest =
                        self.score > 0 &&
                        self.score > previousHighScore

                    if isNewBest {
                        DispatchQueue.main.async {
                            self.newBestLabel.alpha = 1
                            self.newBestLabel.run(
                                SKAction.repeatForever(
                                    SKAction.sequence([
                                        SKAction.scale(
                                            to: 1.15,
                                            duration: 0.3
                                        ),
                                        SKAction.scale(
                                            to: 1.0,
                                            duration: 0.3
                                        )
                                    ])
                                )
                            )
                        }
                    }
                    
                    self.currentScore.text = "0"
                    self.currentScoreInside.text = "0"
                    self.new.setScale(0)
                    
                    for i in 0 ... (self.score) {
                        if (self.score > 0) && (i != 0) {
                            usleep(UInt32(1.5/Double(self.score) * 1000000.0))
                        }
                        self.currentScore.text = "\(i)"
                        self.currentScoreInside.text = "\(i)"
                        if (i) > previousHighScore {
                            self.bestScore.text = "\(i)"
                            self.bestScoreInside.text = "\(i)"
                            if (i == self.score) {
                                self.new.run(SKAction.sequence([
                                    SKAction.scale(to: 0.7, duration: 0.05),
                                    SKAction.scale(to: 1.0, duration: 0.05)
                                ]))
                            }
                        }
                    }
                }
            }
            
            if canShowScore {
                // Absolute thresholds, like the original game:
                // copper 10, silver 20, gold 30, platinum 40,
                // diamond 50. There is no diamond texture in
                // the atlas, so diamond is the platinum medal
                // tinted ice-blue — code only, no new art.
                let medalTexture: SKTexture
                var medalTint: UIColor = .clear
                var medalBlend: CGFloat = 0

                switch score {
                case 50...:
                    medalTexture = Assets.shared.sprites
                        .textureNamed("platinum-medal")
                    medalTint = UIColor(
                        red: 0.55,
                        green: 0.85,
                        blue: 1.0
                    )
                    medalBlend = 0.85
                case 40...:
                    medalTexture = Assets.shared.sprites
                        .textureNamed("platinum-medal")
                case 30...:
                    medalTexture = Assets.shared.sprites
                        .textureNamed("gold-medal")
                case 20...:
                    medalTexture = SKTexture(
                        imageNamed: "silver-medal"
                    )
                case 10...:
                    medalTexture = Assets.shared.sprites
                        .textureNamed("copper-medal")
                default:
                    medalTexture = SKTexture()
                }

                medal.run(
                    SKAction.setTexture(medalTexture, resize: true)
                )
                medal.color = medalTint
                medal.colorBlendFactor = medalBlend
                
                sparkle.setScale(0)
                sparkle.removeAllActions()
                if(score > 0){
                    sparkle.run(sparkleAction)
                }
            }
        }
    }
}

public extension ResultBoard {
    class func bestScore() -> Int {
        return UserDefaults.standard.integer(forKey: "bestScore")
    }
    
    class func setBestScore(_ score: Int) {
        UserDefaults.standard.set(score, forKey: "bestScore")
        UserDefaults.standard.synchronize()
    }
}
