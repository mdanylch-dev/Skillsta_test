//
//  PlayerFeature.swift
//  TCA_Player
//
//  Created by Mykyta Danylchenko on 10.08.2024.
//

import Foundation
import AVKit
import ComposableArchitecture

struct PlayerReducer: Reducer {

    @ObservableState
    struct State: Equatable {
        var player: AVAudioPlayer!
        var isPlaying: Bool = false
        var trackSelected: Int = 0
        var playbackEnds: TimeInterval = 100
        var timeCurrent: String = "00:00"
        var timeFull: String = "00:00"
        var timeInterval: TimeInterval = 0
        var speed: String = "1"
        var rate: Float = 1
        var title: String = ""
        var image: Data?
        var songs: [String] = [
            "01 Nightsport",
            "02 Tears Cried Featuring Kylie Auldi",
            "03 Now That You Are Mine Featuring K",
            "04 King Of The Rodeo Featuring Megan",
            "05 Funky Buttercup",
            "06 Can't Help Myself Featuring Ty",
            "07 One Man Entourage",
            "08 Make It Real Featuring Kylie Auld",
            "09 Move On Featuring Paul MacInnes",
            "10 The Side Stepper",
            "11 Amen Brother"
        ]

    }

    @CasePathable
    enum Action {
        case playPause, next, previous, forward10, backward5, speed, jumpToPosition, timerTick
        case position(TimeInterval)
    }

    enum CancelID { case timer }

    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .playPause:
            state.isPlaying.toggle()
            let url = Bundle.main.path(forResource: state.songs[state.trackSelected], ofType: "mp3")

            if state.player == nil {
                state.player = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: url!))
                state.playbackEnds = state.player.duration
                state.player.enableRate = true
                state.player.rate = state.rate
            }

            if state.isPlaying {
                state.player.play()

                return .run { send in
                    while true {
                        try await Task.sleep(for: .seconds(1))
                        await send(.timerTick)
                    }
                }
                .cancellable(id: CancelID.timer)
            } else {
                state.player.pause()
                return .cancel(id: CancelID.timer)
            }
        case .next:
            state.trackSelected = state.trackSelected < state.songs.count - 1 ? state.trackSelected + 1 : 0
            let url = Bundle.main.path(forResource: state.songs[state.trackSelected], ofType: "mp3")
            state.player = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: url!))
            state.playbackEnds = state.player.duration
            state.player.enableRate = true
            state.player.rate = state.rate
            state.timeCurrent  = state.player.currentTime.inSeconds
            state.timeFull = state.player.duration.inSeconds
            if state.isPlaying == false {
                state.isPlaying.toggle()
                state.player.play()
                return .run { send in
                    while true {
                        try await Task.sleep(for: .seconds(1))
                        await send(.timerTick)
                    }
                }
                .cancellable(id: CancelID.timer)
            }
            state.player.play()
            return .none
        case .previous:
            if state.player.currentTime >= 5 {
                state.player.currentTime = 0
                state.timeCurrent  = state.player.currentTime.inSeconds
                state.timeInterval = state.player.currentTime
                state.timeFull = state.player.duration.inSeconds
                return .none
            }
            state.trackSelected = state.trackSelected == 0 ? state.songs.count - 1 : state.trackSelected - 1
            let url = Bundle.main.path(forResource: state.songs[state.trackSelected], ofType: "mp3")
            state.player = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: url!))
            state.playbackEnds = state.player.duration
            state.player.enableRate = true
            state.player.rate = state.rate
            state.timeCurrent  = state.player.currentTime.inSeconds
            state.timeInterval = state.player.currentTime
            state.timeFull = state.player.duration.inSeconds
            if state.isPlaying == false {
                state.isPlaying.toggle()
                state.player.play()
                return .run { send in
                    while true {
                        try await Task.sleep(for: .seconds(1))
                        await send(.timerTick)
                    }
                }
                .cancellable(id: CancelID.timer)
            }
            state.player.play()
            return .none
        case .forward10:
            guard state.player != nil else { return .none }
            if state.player.currentTime < state.playbackEnds - 10 {
                state.player.currentTime += 10
            } else {
                state.player.currentTime = state.playbackEnds
            }
            state.timeCurrent  = state.player.currentTime.inSeconds
            state.timeInterval = state.player.currentTime
            state.timeFull = state.player.duration.inSeconds
            return .none
        case .backward5:
            guard state.player != nil else { return .none }
            if state.player.currentTime > 5 {
                state.player.currentTime -= 5
            } else {
                state.player.currentTime = 0
            }
            state.timeCurrent  = state.player.currentTime.inSeconds
            state.timeInterval = state.player.currentTime
            return .none
        case let .position(position):
            state.timeCurrent  = position.inSeconds
            state.timeInterval = position
            return .none
        case .speed:
            if state.rate < 2 && state.rate >= 1 {
                state.rate += 0.5
            } else {
                state.rate = 1
            }
            state.speed = state.rate.formatted
            if state.player != nil {
                state.player.rate = state.rate
            }
            return .none
        case .jumpToPosition:
            state.player.currentTime = state.timeInterval
            state.timeCurrent  = state.timeInterval.inSeconds
            return .none
        case .timerTick:
            let time = state.player.currentTime
            state.timeInterval = time
            state.timeCurrent  = time.inSeconds
            state.timeFull = state.player.duration.inSeconds
            return .none
        }
    }
}

extension TimeInterval {
    var inSeconds: String {
        let minutes = Int(self / 60)
        let seconds = Int(self.truncatingRemainder(dividingBy: 60))
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

extension Float {
    var formatted: String {
        if self == floor(self) {
            return String(format: "%.0f", self)
        } else {
            return String(format: "%.1f", self)
        }
    }
}
