//
//  PlayerView.swift
//  TCA_Player
//
//  Created by Mykyta Danylchenko on 10.08.2024.
//

import SwiftUI
import ComposableArchitecture

struct PlayerView: View {
    @Bindable var store: StoreOf<PlayerReducer>

    var body: some View {
        VStack(spacing: 0) {
            info

            sliderAndSpeedButtons

            controlButtons
                .padding(.top, 50)

            Spacer()
        }
        .padding()
        .background(.white)
    }

    private var info: some View {
        Group {
            if let uiImage = UIImage(named: "album") {
                Image(uiImage: uiImage)
                    .resizable()
                    .frame(maxWidth: .infinity)
                    .aspectRatio(1, contentMode: .fit)
                    .background(.blue)
                    .padding(.top, 40)
            }

            Text("Key points \(store.trackSelected + 1) of \(store.songs.count)".uppercased())
                .foregroundColor(.gray)
                .padding(.top, 50)

            Text(store.songs[store.trackSelected])
                .multilineTextAlignment(.center)
                .foregroundColor(.black)
                .padding(.top, 4)
        }
    }

    private var sliderAndSpeedButtons: some View {
        Group {
            Slider(
                value: $store.timeInterval.sending(\.position),
                in: 0...store.playbackEnds,
                step: 1,
                onEditingChanged: { editing in
                    if !editing {
                        store.send(.jumpToPosition)
                    }
                },
                minimumValueLabel: Text(store.timeCurrent).foregroundColor(.gray),
                maximumValueLabel: Text(store.timeFull).foregroundColor(.gray),
                label: {
                    Text("playback time")
                }
            )
            .padding(.top, 30)

            Button(action: {
                store.send(.speed)
            }, label: {
                Text("Speed \(store.speed)")
                    .fontWeight(.bold)
                    .foregroundColor(.black)

            })
            .buttonStyle(.bordered)
            .padding(.top, 16)
        }
    }

    private var controlButtons: some View {
        HStack(spacing: 30) {
            Button(action: {
                store.send(.previous)
            }, label: {
                Image(systemName: "backward.end")
                    .resizable()
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .aspectRatio(1, contentMode: .fit)
                    .padding(8)
            })

            Button(action: {
                store.send(.backward5)
            }, label: {
                Image(systemName: "gobackward.5")
                    .resizable()
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .aspectRatio(1, contentMode: .fit)
            })

            Button(action: {
                store.send(.playPause)
            }, label: {
                let imageName = store.isPlaying ? "pause.fill" : "play.fill"
                Image(systemName: imageName)
                    .resizable()
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .aspectRatio(1, contentMode: .fit)
            })

            Button(action: {
                store.send(.forward10)
            }, label: {
                Image(systemName: "goforward.10")
                    .resizable()
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .aspectRatio(1, contentMode: .fit)
            })

            Button(action: {
                store.send(.next)
            }, label: {
                Image(systemName: "forward.end")
                    .resizable()
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .aspectRatio(1, contentMode: .fit)
                    .padding(8)
            })
        }
        .padding(.horizontal, 50)
    }
}
