//
//  StateMachineTests.swift
//  StateMachineTests
//
//  Created by Mario Barbosa on 8/4/14.
//  Copyright (c) 2014 Mario Barbosa. All rights reserved.
//

import UIKit
import XCTest


enum StateEnum:Printable {
    case Initial
    case Open
    case OpenHalf
    case OpenCompletely
    case Close
    case CloseLocked
    case CloseUnlocked
    
    var description:String {
        switch self {
        case Initial:
            return "Initial"
        case OpenHalf:
            return "Open"
        default:
            return "Lala"
        }
    }
}


class StateMachineTests: XCTestCase {
    
    var stateMachine:StateMachine<StateEnum>!
    
    override func setUp() {
        super.setUp()
        
        stateMachine = StateMachine<StateEnum>()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testSetInitialState() {
        var passed = false
        
        stateMachine.addState(StateEnum.Initial, onEnter: { (from, to, current) -> Void in
            passed = true
        })
        
        stateMachine.setInitialState(StateEnum.Initial)
        
        XCTAssertEqual(self.stateMachine.state, StateEnum.Initial, "State Not Initialized properly")
        XCTAssert(passed, "onEnter callback not called")
    }
    
    func testChangeState() {
        var passedOnEnter = false
        var passedOnExit = false
        var passedOnTransaction = false
        
        stateMachine.addState(StateEnum.Initial, onExit: { (from, to, current) -> Void in
            passedOnExit = true
        })
        stateMachine.addState(StateEnum.Open, fromStates: [StateEnum.Initial],
            onEnter: { (from, to, current) -> Void in
            passedOnEnter = true
        })
        
        stateMachine.setInitialState(StateEnum.Initial)
        
        stateMachine.onStateChangeSucceeded = { (from, to, current) -> Void in
            passedOnTransaction = true
        }
        
        stateMachine.gotoState(StateEnum.Open)
        
        XCTAssert(passedOnEnter && passedOnExit && passedOnTransaction, "State transaction Didn't worked")
    }
    
    func testCanChangeToState() {
        stateMachine.addState(StateEnum.Initial)
        stateMachine.addState(StateEnum.Open, fromStates:[StateEnum.Initial])
        stateMachine.addState(StateEnum.Close)
        stateMachine.setInitialState(StateEnum.Initial)
        
        XCTAssert(stateMachine.canChangeState(StateEnum.Open), "State change validation failed")
        XCTAssert(!stateMachine.canChangeState(StateEnum.Close), "State change validation failed")
    }
    
    func testParentState() {
        
        var checkpoint1 = false
        var checkpoint2 = false
        var checkpoint3 = false
        
        let onEnterOpenState:(from:StateEnum?, to:StateEnum, current:StateEnum)->Void = {(from, to, current) in
            checkpoint1 = true
        }
        
        let onEnterOpenCompletelyState:(from:StateEnum?, to:StateEnum, current:StateEnum)->Void = {(from, to, current) in
            checkpoint2 = true
        }
        
        let onEnterOpenHalfState:(from:StateEnum?, to:StateEnum, current:StateEnum)->Void = {(from, to, current) in
            checkpoint3 = true
        }
        
        stateMachine.addState(StateEnum.Initial)
        stateMachine.addState(StateEnum.Open, onEnter:onEnterOpenState)
        stateMachine.addState(StateEnum.OpenCompletely, fromStates:[StateEnum.Initial], parent:StateEnum.Open, onEnter:onEnterOpenCompletelyState)
        stateMachine.addState(StateEnum.OpenHalf, fromStates:[StateEnum.Initial], parent:StateEnum.Open, onEnter:onEnterOpenHalfState)
        stateMachine.setInitialState(StateEnum.Initial)
        
        stateMachine.gotoState(StateEnum.OpenCompletely)
        
        XCTAssert(checkpoint1 && checkpoint2 && !checkpoint3, "Change of state with hierarchy failed")
    }
    
    func testParentState2() {
        var checkpoint1 = false
        var checkpoint2 = false
        var checkpoint3 = false
        
        let onEnterOpenState:(from:StateEnum?, to:StateEnum, current:StateEnum)->Void = {(from, to, current) in
            checkpoint1 = true
        }
        
        let onEnterOpenCompletelyState:(from:StateEnum?, to:StateEnum, current:StateEnum)->Void = {(from, to, current) in
            checkpoint2 = true
        }
        
        let onEnterOpenHalfState:(from:StateEnum?, to:StateEnum, current:StateEnum)->Void = {(from, to, current) in
            checkpoint3 = true
        }
        
        stateMachine.addState(StateEnum.Initial)
        stateMachine.addState(StateEnum.Open, fromStates:[StateEnum.Initial], onEnter:onEnterOpenState)
        stateMachine.addState(StateEnum.OpenCompletely, fromStates:[StateEnum.Initial], parent:StateEnum.Open, onEnter:onEnterOpenCompletelyState)
        stateMachine.addState(StateEnum.OpenHalf, fromStates:[StateEnum.Initial], parent:StateEnum.Open, onEnter:onEnterOpenHalfState)
        stateMachine.setInitialState(StateEnum.Initial)
        
        stateMachine.gotoState(StateEnum.Open)
        
        XCTAssert(checkpoint1 && !checkpoint2 && !checkpoint3, "Change of state with hierarchy failed")
    }
}
