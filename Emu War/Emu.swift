//
//  Emu.swift
//  Emu War
//
//  Created by 90305539 on 10/30/18.
//  Copyright © 2018 Emir Sahbegovic. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

/**
 Emus are SKSpriteNodes with an HP, level, speed, size, and type.
 */
class Emu: SKSpriteNode {
    
    var HP = 0
    var type = ""
    var level = 0
    var haste = 5
    
    //NEW ENEMY SPAWNS
    init (level:Int){
        
        var bigness = CGSize(width: 0, height: 0)
        self.level = level
        let random = arc4random_uniform(3) + 1
        
        switch random {
        case 1:
            self.type = "emu"
            self.HP = level * 5
            self.haste = Int.random(in: 40...60)
            bigness = CGSize(width: 125, height: 150)
        case 2:
            self.type = "ostrich"
            self.HP = level * 7
            self.haste = Int.random(in: 30...50)
            bigness = CGSize(width: 175, height: 175)
        case 3:
            self.type = "kiwi"
            self.HP = level * 3
            self.haste = Int.random(in: 70...90)
            bigness = CGSize(width: 75, height: 75)
        default:
            self.type = "emu"
            self.HP = level * 5
            self.haste = Int.random(in: 40...60)
        }
        
        
        //init for SPRITE
        let texture = SKTexture(imageNamed: type)
        super.init(texture: texture, color: UIColor.clear, size: bigness)
        
        //init for PHYSICS
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size) // 1
        self.physicsBody?.linearDamping = 0
        self.physicsBody?.isDynamic = true // 2
        self.physicsBody?.categoryBitMask = PhysicsCategory.enemy // 3
        self.physicsBody?.contactTestBitMask = PhysicsCategory.bullet // 4
        self.physicsBody?.collisionBitMask = PhysicsCategory.none // 5
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
