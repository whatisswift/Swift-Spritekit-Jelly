//
//  GameScene.swift
//  Swift-Spritekit-Jelly
//
//  Created by Daichi Nagahamaya on 1/3/16.
//  Copyright (c) 2016 Intureapp. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate{
    var ballLine: SKShapeNode!
    var circles = [SKShapeNode]()
    
    let radius: CGFloat = 30
    let outerCircleRadius: CGFloat = 15
    let dynamic = true
    let jointDamping: CGFloat = 1.0
    let jointFrequency: CGFloat = 9.0
    let numOfCircles = 22
    let massOfCenterCircle: CGFloat = 4.0
    let massOfOuterCircles: CGFloat = 2.0
    let ballGlowWidth: CGFloat = 5.0
    
    
    override func didMove(to view: SKView) {
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        backgroundColor = SKColor.white
        
        makeCircles()
    }
    
    func makeCircles(){
        //Main circle
        let circleShape = SKShapeNode(circleOfRadius: radius)
        circleShape.fillColor = SKColor.clear
        circleShape.strokeColor = SKColor.clear
        circleShape.position = CGPoint(x: size.width / 2, y: size.height / 2)
        
        
        let circlePhysics = SKPhysicsBody(circleOfRadius: radius)
        circlePhysics.isDynamic = dynamic
        circlePhysics.mass = massOfCenterCircle
        circlePhysics.affectedByGravity = false
        
        circleShape.physicsBody = circlePhysics
        addChild(circleShape)
        circles.append(circleShape)
        
        //Outer circle
        //for var i = 0; i < numOfCircles; ++i{
        for (i, _) in circles.enumerated() {
            let massOfOuterCircle = massOfOuterCircles / CGFloat(numOfCircles)
            
            let angle = (.pi * 2 / Double(numOfCircles)) * Double(i)
            let dy = CGFloat(sin(angle)) * radius
            let dx = CGFloat(cos(angle)) * radius
            
            let point = SKShapeNode(circleOfRadius: outerCircleRadius)
            point.position = CGPoint(x: circles.first!.position.x + dx * 2, y: circles.first!.position.y + dy * 2)
            point.fillColor = SKColor.clear
            point.strokeColor = SKColor.clear
            point.physicsBody = SKPhysicsBody(circleOfRadius: point.frame.size.width / 2)
            point.physicsBody!.mass = massOfOuterCircle
            point.physicsBody!.isDynamic = dynamic
            addChild(point)
            circles.append(point)
            
            makeJointBetween(point: circles.first!, point2: point)
        }
        for (i, _) in circles.enumerated() {
        //for var i = 1; i < circles.count; ++i{
            if i == 0 {
                continue
            } else if i == 1{
                makeJointBetween(point: circles.last!, point2: circles[1])
                
            } else{
                makeJointBetween(point: circles[i], point2: circles[i - 1])
            }
        }
    }
    
    func makeJointBetween(point: SKShapeNode, point2: SKShapeNode){
        let joint = SKPhysicsJointSpring.joint(withBodyA: point.physicsBody!, bodyB: point2.physicsBody!, anchorA: point.position, anchorB: point2.position)
        joint.damping = jointDamping
        joint.frequency = jointFrequency
        physicsWorld.add(joint)
        
    }
    
    
    func drawBallLine(){
        if ballLine != nil{
            ballLine.removeFromParent()
        }
        
        ballLine = SKShapeNode()
        var point = circles.first!
        
        let path = UIBezierPath()
        path.move(to: point.position)
        
        //for var i = 1; i < circles.count; ++i{
        for (i, _) in circles.enumerated() {
            point = circles[i]
            path.addLine(to: point.position)
            
            if i == circles.count - 1 {
                path.addLine(to: circles[1].position)
            }
        }
        
        ballLine.path = path.cgPath
        ballLine.glowWidth = ballGlowWidth
        ballLine.fillColor = SKColor.orange
        ballLine.strokeColor = SKColor.orange
        addChild(ballLine)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        if let touch = touches.first{
            let location = touch.location(in: self)
            
            let circle = circles.first!
            let dx = location.x - circle.position.x
            let dy = location.y - circle.position.y
            let impulse = CGVector(dx: dx * 1000, dy: dy * 1000)
            circles.first!.physicsBody!.applyForce(impulse)
            
            //            for i in 1..<circles.count{
            //                let dx = location.x - circles[i].position.x
            //                let dy = location.y - circles[i].position.y
            //                let impulse = CGVector(dx: dx * 40, dy: dy * 40)
            //
            //                circles[i].physicsBody!.applyForce(impulse)
            //
            //            }
        }
    }
    
    override func update(_ currentTime: CFTimeInterval) {
        drawBallLine()
        
    }
}
