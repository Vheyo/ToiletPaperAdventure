

import SpriteKit
import UIKit

struct PhysicsCategory {
    static let none       : UInt32 = 0
    static let all        : UInt32 = UInt32.max
    static let monster    : UInt32 = 0b1       // 1
    static let projectile : UInt32 = 0b10      // 2
    static let player     : UInt32 = 0b11
    
}


func +(left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func -(left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func *(point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func /(point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

#if !(arch(x86_64) || arch(arm64))
func sqrt(a: CGFloat) -> CGFloat {
    return CGFloat(sqrtf(Float(a)))
}
#endif

extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
}





class GameScene: SKScene{
    
    
    
    private var walkingPlayerFrames : [SKTexture] = []
    var player = SKSpriteNode(imageNamed: "doc1")
    var scoreLabel = SKLabelNode()
    var ScoreInteger = 0
    var JumpEnded = true
    var LifeCounter = 3
    weak var viewController : UIViewController?
    
    let heart1 = SKSpriteNode(imageNamed: "hearth")
    let heart2 = SKSpriteNode(imageNamed: "hearth")
    let heart3 = SKSpriteNode(imageNamed: "hearth")
    override func didMove(to view: SKView) {
        
        
        //1
        heart1.position = CGPoint(x: frame.minX+heart1.frame.width, y: frame.maxY-30)
        heart2.position = CGPoint(x: heart1.position.x+heart2.size.width+5, y: frame.maxY-30)
        heart3.position = CGPoint(x: heart2.position.x+heart1.size.width+5, y: frame.maxY-30)
        addChild(heart1)
        addChild(heart2)
        addChild(heart3)
        
        
        //2
        
        createBackground()
        createScore()
        createSky()
        createGround()
        
        // 3
        
        
        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run(addMonster),
                SKAction.wait(forDuration: 1.0)
            ])
        ))
        
        
        
        
        run(SKAction.repeatForever(
            
            SKAction.sequence([
                SKAction.run(addToiletPaper),
                SKAction.wait(forDuration: TimeInterval(2.0), withRange: TimeInterval(2.0))
            ])
        ))
        //4
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        buildPlayer()
        
        
        
//        animatePlayer()
        
        
        
        /* Qui inizializzo la Musica*/
        //        let backgroundMusic = SKAudioNode(fileNamed: "background-music-aac.caf")
        //        backgroundMusic.autoplayLooped = true
        //        addChild(backgroundMusic)
    }
    
    func createScore() {
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.fontSize = 24
        
        scoreLabel.position = CGPoint(x: frame.maxX-100, y: frame.maxY - 30)
        scoreLabel.text = "SCORE: 0"
        scoreLabel.fontColor = UIColor.black
        
        addChild(scoreLabel)
    }
    
    
    
    func buildPlayer(){
//        let playerAnimatedAtlas = SKTextureAtlas(named: "Pixeldoctor")
//        var walkFrames : [SKTexture] = []
//        let numImages = playerAnimatedAtlas.textureNames.count
//        for i in 1...numImages {
//            let playerTextureName = "doc\(i)"
//            walkFrames.append(playerAnimatedAtlas.textureNamed(playerTextureName))
//        }
//        walkingPlayerFrames = walkFrames
//        let firstFrameTexture = walkingPlayerFrames[0]
//        player = SKSpriteNode(texture: firstFrameTexture)
        if defaults.integer(forKey: "PlayerChoice") == 1 {
            player = SKSpriteNode(imageNamed: "Pizzaboy")
        }
        if defaults.integer(forKey: "PlayerChoice") == 2 {
            player = SKSpriteNode(imageNamed: "Kim")
        }
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.isDynamic = true // 2
        player.physicsBody?.categoryBitMask = PhysicsCategory.player // 3
        player.physicsBody?.contactTestBitMask = PhysicsCategory.monster // 4
        player.physicsBody?.collisionBitMask = PhysicsCategory.none // 5
        player.zPosition = -5
        player.position = CGPoint(x: size.width * 0.1, y: size.height * 0.25)
        // 4
        addChild(player)
        
    }
    
    
    func animatePlayer(){
        player.run(SKAction.repeatForever(
            SKAction.animate(with: walkingPlayerFrames,
                             timePerFrame: 0.01,
                             resize: false,
                             restore: true)
        ), withKey: "walkInPlacePlayer")
    }
    
    
    func createSky() {
        let topSky = SKSpriteNode(color: UIColor(hue: 0.55, saturation: 0.14, brightness: 0.77, alpha: 1), size: CGSize(width: frame.width, height: frame.height * 0.67))
        topSky.anchorPoint = CGPoint(x: 0.5, y: 1)
        
        let bottomSky = SKSpriteNode(color: UIColor(hue: 0.55, saturation: 0.16, brightness: 0.76, alpha: 1), size: CGSize(width: frame.width, height: frame.height * 0.33))
        bottomSky.anchorPoint = CGPoint(x: 0.5, y: 1)
        
        topSky.position = CGPoint(x: frame.midX, y: frame.height)
        bottomSky.position = CGPoint(x: frame.midX, y: bottomSky.frame.height)
        
        addChild(topSky)
        addChild(bottomSky)
        
        bottomSky.zPosition = -40
        topSky.zPosition = -40
    }
    
    
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    
    
    
    
    func addMonster() {
        
        // Create sprite
        let monster = SKSpriteNode(imageNamed: "virus")
        
        monster.physicsBody = SKPhysicsBody(rectangleOf: monster.size) // 1
        monster.physicsBody?.isDynamic = true // 2
        monster.physicsBody?.categoryBitMask = PhysicsCategory.monster // 3
        monster.physicsBody?.node?.name = "monster"
        monster.physicsBody?.contactTestBitMask = PhysicsCategory.projectile // 4
        monster.physicsBody?.collisionBitMask = PhysicsCategory.none // 5
        
        // Determine where to spawn the monster along the Y axis
        let actualY = random(min: monster.size.height/2, max: size.height - monster.size.height/2)
        
        // Position the monster slightly off-screen along the right edge,
        // and along a random position along the Y axis as calculated above
        monster.position = CGPoint(x: size.width + monster.size.width/2, y: actualY)
        
        // Add the monster to the scene
        addChild(monster)
        
        // Determine speed of the monster
        let actualDuration = random(min: CGFloat(2.0), max: CGFloat(4.0))
        
        // Create the actions
        let actionMove = SKAction.move(to: CGPoint(x: -monster.size.width/2, y: actualY),
                                       duration: TimeInterval(actualDuration))
        
        //        let loseAction = SKAction.run() { [weak self] in
        //            guard let `self` = self else { return }
        //            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
        //            let gameOverScene = GameOverScene(size: self.size, won: false)
        //            self.view?.presentScene(gameOverScene, transition: reveal)
        //        }
        
        
        let actionMoveDone = SKAction.removeFromParent()
        
        monster.run(SKAction.sequence([actionMove, actionMoveDone]))
    }
    
    
    func addToiletPaper() {
        let toiletPaper = SKSpriteNode(imageNamed: "toiletPaper")
        toiletPaper.physicsBody = SKPhysicsBody(rectangleOf: toiletPaper.size) // 1
        toiletPaper.physicsBody?.isDynamic = true // 2
        toiletPaper.physicsBody?.categoryBitMask = PhysicsCategory.monster // 3
        toiletPaper.physicsBody?.node?.name = "toiletPaper"
        toiletPaper.physicsBody?.contactTestBitMask = PhysicsCategory.player // 4
        toiletPaper.physicsBody?.collisionBitMask = PhysicsCategory.none // 5
        
        toiletPaper.position = CGPoint(x: size.width + toiletPaper.size.width/2, y: toiletPaper.size.height/2+20)
        
        addChild(toiletPaper)
        
        
        
        let actionMove = SKAction.move(to: CGPoint(x: -toiletPaper.size.width/2, y:toiletPaper.size.height/2+20),
                                       duration: TimeInterval(2.0))
        
        let actionMoveDone = SKAction.removeFromParent()
        
        toiletPaper.run(SKAction.sequence([actionMove, actionMoveDone]))
        
    }
    
    
    
    
    func createGround() {
        let groundTexture = SKTexture(imageNamed: "street1")
        
        for i in 0 ... 1 {
            let ground = SKSpriteNode(texture: groundTexture)
            ground.zPosition = -10
            ground.position = CGPoint(x: (groundTexture.size().width / 2.0 + (groundTexture.size().width * CGFloat(i))), y: 30)
            
            addChild(ground)
            
            let moveLeft = SKAction.moveBy(x: -groundTexture.size().width, y: 0, duration: 10)
            let moveReset = SKAction.moveBy(x: groundTexture.size().width, y: 0, duration: 0)
            let moveLoop = SKAction.sequence([moveLeft, moveReset])
            let moveForever = SKAction.repeatForever(moveLoop)
            
            ground.run(moveForever)
        }
    }
    
    func createBackground() {
        let backgroundTexture = SKTexture(imageNamed: "hospital")
        
        for i in 0 ... 1 {
            let background = SKSpriteNode(texture: backgroundTexture)
            background.zPosition = -30
            background.anchorPoint = CGPoint.zero
            background.position = CGPoint(x: (backgroundTexture.size().width * CGFloat(i)) - CGFloat(1 * i), y: 80)
            addChild(background)
            let moveLeft = SKAction.moveBy(x: -backgroundTexture.size().width, y: 0, duration: 10)
            let moveReset = SKAction.moveBy(x: backgroundTexture.size().width, y: 0, duration: 0)
            let moveLoop = SKAction.sequence([moveLeft, moveReset])
            let moveForever = SKAction.repeatForever(moveLoop)
            
            background.run(moveForever)
        }
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        let toiletPaper = SKSpriteNode(imageNamed: "toiletPaper")
        if  touchLocation.x < 200 && JumpEnded == true && touchLocation.y < 200{
            // 2 - Set up initial location of projectile
            JumpEnded = false
            let jumpUpAction = SKAction.moveBy(x: 0, y: toiletPaper.size.height+50 ,duration:0.2)
            // move down 20
            let jumpDownAction = SKAction.moveBy(x: 0, y: -toiletPaper.size.height-50,duration:0.4)
            // sequence of move yup then down
            let EndJump = SKAction.run {
                self.JumpEnded = true
            }
            let jumpSequence = SKAction.sequence([jumpUpAction, jumpDownAction, EndJump])
            
            // make player run sequence
            
            player.run(jumpSequence)
            
        }
        else {
                   
                   //            run(SKAction.playSoundFileNamed("pew-pew-lei.caf", waitForCompletion: false))
            var projectile = SKSpriteNode(imageNamed: "projectile")
            if defaults.integer(forKey: "PlayerChoice") == 0{
                projectile = SKSpriteNode(imageNamed: "projectile")
            }
            if defaults.integer(forKey: "PlayerChoice") == 1{
                projectile = SKSpriteNode(imageNamed: "pizzaProjectile")
            }
            if defaults.integer(forKey: "PlayerChoice") == 2{
                projectile = SKSpriteNode(imageNamed: "bomb")
            }
                  
                   projectile.position = player.position
                   
                   projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
                   projectile.physicsBody?.isDynamic = true
                   projectile.physicsBody?.categoryBitMask = PhysicsCategory.projectile
                   projectile.physicsBody?.contactTestBitMask = PhysicsCategory.monster
                   projectile.physicsBody?.collisionBitMask = PhysicsCategory.none
                   projectile.physicsBody?.usesPreciseCollisionDetection = true
                   
                   // 3 - Determine offset of location to projectile
                   let offset = touchLocation - projectile.position
                   
                   // 4 - Bail out if you are shooting down or backwards
                   if offset.x < 0 { return }
                   
                   // 5 - OK to add now - you've DispatchQueue.main.async {
                   addChild(projectile)
                   
                   // 6 - Get the direction of where to shoot
                   let direction = offset.normalized()
                   
                   // 7 - Make it shoot far enough to be guaranteed off screen
                   let shootAmount = direction * 1000
                   
                   // 8 - Add the shoot amount to the current position
                   let realDest = shootAmount + projectile.position
                   
                   // 9 - Create the actions
                   let actionMove = SKAction.move(to: realDest, duration: 2.0)
                   let actionMoveDone = SKAction.removeFromParent()
                   projectile.run(SKAction.sequence([actionMove, actionMoveDone]))
                   
                   
               }
        
    }
    
    
    
    
    
    func projectileDidCollideWithMonster(projectile: SKSpriteNode, monster: SKSpriteNode) {
        
        if projectile != player && monster.physicsBody?.node?.name == "monster" {
            
            if let explosion = SKEmitterNode(fileNamed: "PlayerExplosion") {
                print("esplosione")
                explosion.position = monster.position
                addChild(explosion)
            }
            
            ScoreInteger += 1
            DispatchQueue.main.async {
                self.scoreLabel.text = "SCORE : \(self.ScoreInteger)"
            }
            print("Hit")
            projectile.removeFromParent()
            monster.removeFromParent()
        }
            
        else if projectile == player && monster.physicsBody?.node!.name == "toiletPaper" {
            print("Player hitted by \(String(describing: monster.physicsBody?.node?.name))")
            
            switch LifeCounter {
            case 1 :
                self.heart3.removeFromParent()
                let loseAction = SKAction.run() { [weak self] in
                    guard let `self` = self else { return }
                    let reveal = SKTransition.push(with: .down, duration: 0.5)
                    let gameOverScene = GameOverScene(size: self.size, won: false)
                    
                    
                    self.view?.presentScene(gameOverScene, transition: reveal)
                }
                if ScoreInteger > defaults.integer(forKey: "Score") {
                    defaults.set(ScoreInteger, forKey: "Score")
                    
                }
                
                player.run(loseAction)
                
                //                viewController?.performSegue(withIdentifier: "Lose", sender: self)
                
                
                break
            case 2 :
                self.heart2.removeFromParent()
                LifeCounter -= 1
            case 3 :
                self.heart1.removeFromParent()
                LifeCounter -= 1
            default :
                print("NO LIFE")
            }
            monster.removeFromParent()
        }
            
        else if projectile == player && monster.physicsBody?.node!.name == "monster" {
            print("Player hitted by \(String(describing: monster.physicsBody?.node?.name))")
            
            switch LifeCounter {
            case 1 :
                self.heart3.removeFromParent()
                let loseAction = SKAction.run() { [weak self] in
                    guard let `self` = self else { return }
                    let reveal = SKTransition.push(with: .down, duration: 0.5)
                    let gameOverScene = GameOverScene(size: self.size, won: false)
                    
                    self.view?.presentScene(gameOverScene, transition: reveal)
                    
                }
                if ScoreInteger > defaults.integer(forKey: "Score") {
                    defaults.set(ScoreInteger, forKey: "Score")
                    
                }
                
                
                
                player.run(loseAction)
                
                //                viewController?.performSegue(withIdentifier: "Lose", sender: self)
                
                
                break
            case 2 :
                self.heart2.removeFromParent()
                LifeCounter -= 1
            case 3 :
                self.heart1.removeFromParent()
                LifeCounter -= 1
            default :
                print("NO LIFE")
            }
            monster.removeFromParent()
            
        }
    }
}



extension GameScene: SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact) {
        // 1
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        // 2
        if ((firstBody.categoryBitMask & PhysicsCategory.monster != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.projectile != 0)) {
            if let monster = firstBody.node as? SKSpriteNode,
                let projectile = secondBody.node as? SKSpriteNode {
                projectileDidCollideWithMonster(projectile: projectile, monster: monster)
            }
        }
        
    }
}

