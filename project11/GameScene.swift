//
//  GameScene.swift
//  project11
//
//  Created by Ivan Pavic on 27.1.22..
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var editLabel: SKLabelNode!
    var edit: Bool = false {
        didSet {
            if edit {
                editLabel.text = "Done"
            } else {
                editLabel.text = "Edit"
            }
        }
    }
    var balls = [SKSpriteNode]()
    var ballCount = 0 {
        didSet {
            ballCountLabel.text = "Balls remaining: \(5 - ballCount)"
        }
    }
    var ballCountLabel: SKLabelNode!
    
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: 980, y: 700)
        addChild(scoreLabel)
        
        editLabel = SKLabelNode(fontNamed: "Chalkduster")
        editLabel.text = "Edit"
        editLabel.horizontalAlignmentMode = .left
        editLabel.position = CGPoint(x: 80, y: 700)
        addChild(editLabel)
        
        ballCountLabel = SKLabelNode(fontNamed: "Chalkduster")
        ballCountLabel.text = "Balls remaining: 5"
        ballCountLabel.horizontalAlignmentMode = .center
        ballCountLabel.position = CGPoint(x: 500, y: 700)
        addChild(ballCountLabel)
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.contactDelegate = self
        
        makeSlot(at: CGPoint(x: 128, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 384, y: 0), isGood: false)
        makeSlot(at: CGPoint(x: 640, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 896, y: 0), isGood: false)
        
        makeBouncer(at: CGPoint(x: 0, y: 0))
        makeBouncer(at: CGPoint(x: 256, y: 0))
        makeBouncer(at: CGPoint(x: 512, y: 0))
        makeBouncer(at: CGPoint(x: 768, y: 0))
        makeBouncer(at: CGPoint(x: 1024, y: 0))

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        let location = touch.location(in: self)
        let objects = nodes(at: location)
        
        if objects.contains(editLabel) {
            edit.toggle()
        } else {
            if edit {
                let size = CGSize(width: Int.random(in: 16...128), height: 16)
                let box = SKSpriteNode(color: UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1), size: size)
                box.position = location
                box.zRotation = CGFloat.random(in: 0...3)
                box.physicsBody = SKPhysicsBody(rectangleOf: size)
                box.physicsBody?.isDynamic = false
                box.name = "box"
                addChild(box)
            
            } else if ballCount < 5 {
                balls = [SKSpriteNode(imageNamed: "ballBlue"), SKSpriteNode(imageNamed: "ballCyan"), SKSpriteNode(imageNamed: "ballGreen"), SKSpriteNode(imageNamed: "ballGrey"), SKSpriteNode(imageNamed: "ballRed"), SKSpriteNode(imageNamed: "ballPurple"), SKSpriteNode(imageNamed: "ballYellow")]
                guard let ball = balls.randomElement() else {return}
                ball.position = CGPoint(x: location.x, y: 750)
                ball.name = "ball"
                ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2)
                ball.physicsBody?.restitution = 0.4
                ball.physicsBody?.contactTestBitMask = ball.physicsBody?.collisionBitMask ?? 0
                addChild(ball)
                ballCount += 1
            }
        }
    }
    
    func makeBouncer(at position: CGPoint) {
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.position = position
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2)
        bouncer.physicsBody?.isDynamic = false
        addChild(bouncer)
    }
    
    func makeSlot(at position: CGPoint, isGood: Bool) {
        var slotBase: SKSpriteNode
        var slotGlow: SKSpriteNode
        
        if isGood {
            slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
            slotBase.name = "good"
        } else {
            slotBase = SKSpriteNode(imageNamed: "slotBaseBad")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
            slotBase.name = "bad"
        }
        slotBase.position = position
        slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
        slotBase.physicsBody?.isDynamic = false
        slotGlow.position = position
        addChild(slotBase)
        addChild(slotGlow)
        
        let spin = SKAction.rotate(byAngle: .pi, duration: 10)
        let spinForever = SKAction.repeatForever(spin)
        slotGlow.run(spinForever)
    }
    
    func collisionBetween (ball: SKNode, object: SKNode) {
        if object.name == "good" {
            destroy(ball: ball)
            ballCount -= 1
        } else if object.name == "bad" {
            destroy(ball: ball)
            if ballCount == 5 {
                let ac = UIAlertController(title: "Game Over", message: "You ran out of balls. Final score: \(score)", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "New Game", style: .default, handler: newGame))
                self.view?.window?.rootViewController?.present(ac, animated: true)
            }
        } else if object.name == "box" {
            removeBox(box: object)
            score += 1
        }
    }
    
    func destroy (ball: SKNode) {
        if let fireParticle = SKEmitterNode(fileNamed: "FireParticles") {
            fireParticle.position = ball.position
            addChild(fireParticle)
        }
        ball.removeFromParent()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else {return}
        guard let nodeB = contact.bodyB.node else {return}
        
        if nodeA.name == "ball" {
            collisionBetween(ball: nodeA, object: nodeB)
        } else if nodeB.name == "ball" {
            collisionBetween(ball: nodeB, object: nodeA)
        } else if nodeA.name == "box" {
            collisionBetween(ball: nodeB, object: nodeA)
        } else if nodeB.name == "box" {
            collisionBetween(ball: nodeA, object: nodeB)
        }
    }
    
    func removeBox(box: SKNode) {
        if let destroyParticle = SKEmitterNode(fileNamed: "Particle2") {
            destroyParticle.position = box.position
            addChild(destroyParticle)
        }
        box.removeFromParent()
    }
    
    func newGame(action: UIAlertAction) {
        ballCount = 0
        score = 0
        
        for child in children {
            if child.name == "box" {
                child.removeFromParent()
            }
        }
    }
    
}
