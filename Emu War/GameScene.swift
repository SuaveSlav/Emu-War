//
//  GameScene.swift
//  Emu War
//
//  Created by 90305539 on 10/5/18.
//  Copyright © 2018 Emir Sahbegovic. All rights reserved.
//

import SpriteKit
import GameplayKit


// GLOBAL VARIABLES

/** the amount of emus total the player has killed throughout the entire game */
var emusEliminated = 0
/** the number of birds remaining */
var numOfBirbs = 0
/** the number of birds total for this round */
var numOfBirbsTotal = 0
/** the round number */
var level = 0

struct PhysicsCategory {
    static let none      : UInt32 = 0
    static let all       : UInt32 = UInt32.max
    static let enemy   : UInt32 = 0b1       // 1
    static let bullet: UInt32 = 0b10      // 2
}

class GameScene: SKScene {
    
    var firerate = 1.0
    var currentCD = 1.0
    var damage = 10
    var penetration = 1
    let BG = SKSpriteNode(imageNamed: "land")
    var firearm = SKSpriteNode(imageNamed: "revolver")
    let buttonFire = SKSpriteNode(imageNamed: "fire")
    let arm = SKSpriteNode(imageNamed:"arm")
    let player = SKSpriteNode(imageNamed:"soldier")
    var aimingAngle = 0
    let lowerBound = CGPoint(x:-100,y:0)
    let upperBound = CGPoint(x:-100,y:600)
    let label = SKLabelNode(text: "0")
    
    
    override func didMove(to view: SKView) {
        
        //init new round
        numOfBirbsTotal += Int(Double(level) * 3)
        numOfBirbs = numOfBirbsTotal
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self

        //place initial sprites
        BG.zPosition = 0
        BG.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        addChild(BG)
        buttonFire.zPosition = 1000
        buttonFire.size = CGSize(width: (frame.size.width * 0.10), height: (frame.size.width * 0.10))
        buttonFire.position = CGPoint(x: (frame.size.width * 0.9), y: (frame.size.width * 0.1))
        addChild(buttonFire)
        
        addPlayer()
        
        label.text = String(numOfBirbs)
        label.zPosition = 10
        label.position = CGPoint(x: size.width * 0.1, y: size.height * 0.9)
        label.fontColor = UIColor.red
        label.fontName = "Helvetica"
        addChild(label)
        
        //THIS IS WHERE THE FUN BEGINS
        //add a shitton of enemys
        run(SKAction.repeat(SKAction.sequence([
            SKAction.wait(forDuration: 2),SKAction.run(addEmu),SKAction.wait(forDuration: 4)
            ])
            ,count: numOfBirbsTotal))
    }
    
    /**
        Spawns a new Emu at the right edge of the screen. Also sets its velocity.
    */
    func addEmu(){
        
        //spawns emu and places it to the right
        let newSpawn = Emu(level: level)
        newSpawn.name = String(numOfBirbsTotal)
        let velocity = newSpawn.haste
        let actualY = CGFloat.random(in: newSpawn.size.height/2...(size.height * 0.6))
        newSpawn.position = CGPoint(x: size.width + (newSpawn.size.width), y: actualY)
        newSpawn.zPosition = (size.height * 0.6) - actualY
        
        //The damn kiwis are not rendering properly so i have to do this
        if(newSpawn.type == "kiwi") {
            newSpawn.zPosition -= newSpawn.size.height/2
        }
        
        //set velocity and go!
        newSpawn.physicsBody?.velocity = CGVector(dx: -velocity, dy: 0)
        addChild(newSpawn)
        print(newSpawn)
    }
    
    /**
     Initialize player, arm, and GUN.
     */
    func addPlayer(){
        
        //man's size, height, name
        player.position = CGPoint(x: size.width * 0.1, y: size.height * 0.5)
        let tallness = frame.size.height * 0.5
        player.size = CGSize(width: tallness * 0.6, height: tallness)
        player.name = "player"
        player.zPosition = player.position.y - (player.size.height/2)
        
        //his arm
        arm.size = CGSize(width: tallness * 0.63, height: (tallness * 0.63) * 0.33)
        arm.zPosition = player.zPosition + 2
        arm.position = CGPoint(x: -10, y: player.size.height * 0.22)
        arm.zRotation = 0
        
        //his GUN, 1.5, .666
        firearm.size = CGSize(width: arm.size.height, height: arm.size.height * 0.66)
        firearm.zPosition = -1
        firearm.position = CGPoint(x: arm.size.width * 0.5, y: arm.size.height * -0.3)
        
        addChild(player)
        player.addChild(arm)
        arm.addChild(firearm)
        
    }
    
    /**
        adds a bullet and launches it!
    */
    func fireBullet(){
        
        let bullet = SKSpriteNode(imageNamed: "bullet")
        bullet.size = CGSize(width: firearm.size.height * 0.35, height: firearm.size.height * 0.2)
        bullet.zPosition = 1
        bullet.zRotation = arm.zRotation
        bullet.position = CGPoint(x: firearm.size.width * 0.4, y: firearm.size.height * 0.25)
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bullet.physicsBody?.linearDamping = 0
        bullet.physicsBody?.isDynamic = true // 2
        bullet.physicsBody?.categoryBitMask = PhysicsCategory.bullet // 3
        bullet.physicsBody?.contactTestBitMask = PhysicsCategory.enemy // 4
        bullet.physicsBody?.collisionBitMask = PhysicsCategory.none // 5
        bullet.physicsBody?.usesPreciseCollisionDetection = true
        
        firearm.addChild(bullet)
        bullet.move(toParent: self)
        let smoke = SKEmitterNode.init(fileNamed: "smoke")
        smoke?.position = firearm.position
        smoke?.numParticlesToEmit = 5
        firearm.addChild(smoke!)
        smoke!.move(toParent: self)
        //calculate x and y velocity, HYPOTENOUS/SPEED = 1500
        let y = sin(arm.zRotation) * 1500
        let x = cos(arm.zRotation) * 1500
        bullet.physicsBody?.velocity = CGVector(dx: x, dy: y)
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered

        //Gets the nodes on the left edge, if it is an enemy, delete and change stats
        scene?.physicsWorld.enumerateBodies(alongRayStart: lowerBound, end: upperBound,
                                            using: { (body, point, normal, stop) in
                                                if (body.node?.name != "player") {
                                                    body.node?.removeFromParent()
                                                    numOfBirbs -= 1
                                                    self.label.text = String(numOfBirbs)
                                                    
                                                    //you lost
                                                    
                                                }
        })
        
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 1 - Choose one of the touches to work with
        
        guard let touch = touches.first else {
            return
        }
        
        print(camera?.position)
        let touchLocation = touch.location(in: camera!)
        
        //check if touch is within button range
        if(touchLocation.x > size.width / 2) {
            //touch on the right half
            
            if(buttonFire.contains(touchLocation)){
            //CREATE BULLET AND GO!
                if (currentCD >= firerate){
                
                    currentCD = 0
                    fireBullet()
                
                    let amtOfTicks = Int(firerate * 10)
                    let addAndWait = SKAction.sequence([SKAction.run(plus), SKAction.wait(forDuration: 0.1)])
                
                    run(SKAction.repeat(addAndWait, count: amtOfTicks))
                }
            } else {
            //RELOAD?
            }
        } else {
            //touch on the left half
            
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else {
            return
        }
        
        let newPos = touch.location(in: self.view)
        let origin = touch.previousLocation(in: self.view)
        
        //WHILST the touch is on the left half, move the gun, also range
        
            run(SKAction.sequence([SKAction.run {
                self.arm.zRotation -= 0.0174533 * ((newPos.y - origin.y)/2)
                }, SKAction.wait(forDuration: 1)]))
        
    }
    
    func plus() {
        currentCD += 0.11
    }
    
    /**
        when the bullet hits the emu this is called
    */
    func projectileDidCollideWithMonster(projectile: SKSpriteNode, monster: Emu) {
        //one more enemy
        if (penetration == 1) {
            print("last hit")
            projectile.removeFromParent()
        } else {
            print("penetrated")
        }
        
        monster.HP -= damage
        if (monster.HP <= 0) {
            monster.removeFromParent()
            numOfBirbs -= 1
            print(numOfBirbs)
            label.text = String(numOfBirbs)
        }
    }
}

extension GameScene: SKPhysicsContactDelegate {
    
    //the bullet hit the bird
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
        if ((firstBody.categoryBitMask & PhysicsCategory.enemy != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.bullet != 0)) {
            if let monster = firstBody.node as? Emu,
                let projectile = secondBody.node as? SKSpriteNode {
                projectileDidCollideWithMonster(projectile: projectile, monster: monster)
            }
        }
    }
    
}


