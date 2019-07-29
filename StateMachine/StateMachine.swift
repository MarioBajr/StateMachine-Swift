//
//  StateMachine.swift
//  StateMachine
//
//  Created by Mario Barbosa on 8/4/14.
//  Copyright (c) 2014 Mario Barbosa. All rights reserved.
//

import Foundation

class StateMachine <T> where T:Hashable {
    
    typealias StateChangeHandler = (_ from:T?, _ to:T, _ current:T) -> Void
    
    private var currentState:State<T>!
    private var states = [T:State<T>]()
    
    var onStateChangeSucceeded:StateChangeHandler?
    var onStateChangeFailed:StateChangeHandler?
    var state:T {
        return self.currentState.value
    }
    
    init(){
        
    }
    
    func setInitialState(state:T){
        let modelState:State<T>? = self.states[state]
        
        assert(self.currentState == nil, "Initial state already setted")
        assert(modelState != nil, "State not registered")
        
        self.currentState = self.states[state]
        if (self.currentState.root != nil) {
            let parents = self.currentState.parents
            for parent in parents{
                parent.onEnterHandler?(nil, state, parent.value)
            }
        }
        
        self.currentState.onEnterHandler?(nil, state, state)
        self.onStateChangeSucceeded?(nil, state, self.currentState!.value)
    }
    
    func canChangeState(state:T)->Bool{
        assert(states[state] != nil, "State not registered")
        
        if let modelState = states[state]{
            if !modelState.fromStates.isEmpty{
                if let currentState = self.currentState {
                    let isCurrentState = (state == currentState.value)
                    return !isCurrentState && modelState.fromStates.contains(currentState.value)
                }
            }
        }
        
        return false
    }
    
    func addState(state:T, fromStates:[T]? = nil, parent:T? = nil,
        onEnter:StateChangeHandler? = nil, onExit:StateChangeHandler? = nil){
        let fromStatesList = fromStates ?? [T]()
        
        let stateModel = State<T>(value:state, fromStates:fromStatesList)
        stateModel.onEnterHandler = onEnter
        stateModel.onExitHandler = onExit
        
        if let parent = parent {
            stateModel.parent = states[parent]
        }
        
        states[state] = stateModel
    }
    
    func gotoState(state:T){
        
        assert(states[state] != nil, "State not registered")
        
        func findPathToState(from:T, to:T)->(Int, Int){
            var fromState = self.states[from]
            var c = 0, d = 0
            
            while let strongFromState = fromState {
                d = 0
                var toState = self.states[to]
                while let strongToState = toState {
                    if strongFromState.value == strongToState.value {
                        return (c, d)
                    }
                    d += 1
                    toState = strongToState.parent
                }
                c += 1
                fromState = strongFromState.parent
            }
            
            return (c, d)
        }
        
        let fromValue = self.currentState.value
        
        if let toState = states[state] {
            
            if (!canChangeState(state: state)) {
                self.onStateChangeFailed?(fromValue, state, fromValue)
                return
            }
            
            let (a, b) = findPathToState(from: self.currentState.value, to: state)
            
            if (a > 0) {
                self.currentState.onExitHandler?(fromValue, state, fromValue)
                
                var parentState: State<T>! = self.currentState
                for _ in 0..<a-1 {
                    parentState = parentState.parent
                    self.currentState.onExitHandler?(fromValue, state, parentState.value)
                }
            }
            
            self.currentState = toState
            
            if (b > 0){
                if (toState.root != nil){
                    let parentStates = toState.parents
                    (0..<b-1).reversed().forEach { i in
                        let parentState = parentStates[i]
                        parentState.onEnterHandler?(fromValue, toState.value, parentState.value)
                    }
                }
                
                toState.onEnterHandler?(fromValue, toState.value, toState.value)
            }
            
            self.onStateChangeSucceeded?(fromValue, toState.value, toState.value)
        }
    }
    
}

// MARK: -

private class State<T> {
    
    typealias StateChangeHandler = (_ from:T?, _ to:T, _ current:T) -> Void
    
    weak var parent:State<T>? {
        didSet{
            self.parent?.children.append(self)
        }
    }
    
    var root:State<T>? {
        var parentState = self.parent
        while(parentState?.parent != nil){
            parentState = parentState?.parent
        }
        return parentState
    }
    
    var parents:[State<T>] {
        var list:[State<T>] = []
        var parentState = self.parent
        while(parentState != nil){
            list.append(parentState!)
            parentState = parentState?.parent
        }
        return list
    }
    
    var value:T
    var fromStates:[T]
    var children = [State<T>]()
    var onEnterHandler:StateChangeHandler?
    var onExitHandler:StateChangeHandler?
    
    init(value:T, fromStates:[T]){
        self.value = value
        self.fromStates = fromStates
    }
}
