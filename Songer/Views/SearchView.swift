//
//  SearchView.swift
//  Songer
//
//  Created by Bogdan Pohidnya on 23.10.2020.
//  Copyright © 2020 Bogdan Pohidnya. All rights reserved.
//

import SwiftUI

struct SearchView: View {
    
    @State private var searchText: String = "Oxxxymiron"
    @State private var songs: [SongInfo] = []
    @State private var showSong: Bool = false
    @Environment(\.managedObjectContext) var viewContext
    
    var body: some View {
        VStack{
            HStack{
                TextField("Enter text", text: $searchText)
                Spacer()
                Button("Search") {
                    
                    songs.removeAll()
                    
                    searchSongs()
                    
                }
            }.padding()
            
            List {
                ForEach(songs) { song in
                    
                    Button(action: {
                        showSong.toggle()
                    }, label: {
                        SongCell(isAddButtonShow: true,
                                urlImage: song.artworkUrl350,
                                songName: song.trackName,
                                author: song.artistName) {
                            self.addSong(song)
                        }
                    })
                    .sheet(isPresented: $showSong) {
                        SongInfoView(songInfo: song)
                    }
                }
            }
        }
        
    }
    
    private func addSong(_ song: SongInfo) {
        let newSong = Music(context: self.viewContext)

        newSong.name = song.trackName
        newSong.artist = song.artistName
        newSong.album = song.album
        newSong.date = song.stringDate
        newSong.text = "Text song..."
        
        ItunesDataFetcher().fetchCoverFromUrl(url: song.artworkUrl350) { image in
            if let image = image {
                newSong.pictures = image.pngData()!
            }
        }
        
        do {
            try self.viewContext.save()
        } catch {
            print(error)
        }
    }
    
    private func searchSongs() {
        ItunesDataFetcher().fetchSongsByArtist(query: searchText) { (songs) in
            guard let songs = songs else { return }
            
            self.songs = songs
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
