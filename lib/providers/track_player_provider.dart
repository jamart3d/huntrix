import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:huntrix/models/track.dart';
import 'package:huntrix/utils/duration_formatter.dart';
import 'package:path_provider/path_provider.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;

class TrackPlayerProvider extends ChangeNotifier {
  final audioPlayer = AudioPlayer();
  ConcatenatingAudioSource? _concatenatingAudioSource;
  int _currentIndex = 0;

  // Cached album and artist data
  String? _cachedAlbumArt;
  String? _cachedArtistName;
  String? _cachedAlbumTitle;

  String get formattedCurrentDuration => formatDuration(audioPlayer.position);

  String get formattedTotalDuration =>
      formatDuration(audioPlayer.duration ?? Duration.zero);

  // Getters for playback state
  bool get isPlaying => audioPlayer.playing;
  int get currentIndex => _currentIndex;

  // Getters for durations
  Duration get currentDuration => _currentDuration;
  Duration get totalDuration => _totalDuration;
  Duration get _currentDuration => audioPlayer.position;
  Duration get _totalDuration => audioPlayer.duration ?? Duration.zero;

  final List<Track> _playlist = [];
  List<Track> get playlist => _playlist;

  Track? get currentlyPlayingSong =>
      _currentIndex >= 0 && _currentIndex < _playlist.length
          ? _playlist[_currentIndex]
          : null;

  // Constructor
  TrackPlayerProvider() {
    _listenToAudioPlayerEvents();
  }

  // Load album and artist data, and cache them for current song
  Future<void> loadAlbumAndArtistData() async {
    if (currentlyPlayingSong == null) {
      return;
    }

    // Update cached data directly from Track object
    _cachedAlbumArt = currentlyPlayingSong?.albumArt;
    _cachedArtistName = currentlyPlayingSong?.trackArtistName;
    _cachedAlbumTitle = currentlyPlayingSong?.albumName;

    // Notify listeners after updating the cached data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  // Getters for cached data
  String get currentAlbumArt => _cachedAlbumArt ?? 'assets/images/t_steal.webp';
  String get currentArtistName => _cachedArtistName ?? 'Unknown Artist';
  String get currentAlbumTitle => _cachedAlbumTitle ?? 'Unknown Album';

  void setCurrentAlbumArt(String albumArt) {
    _cachedAlbumArt = albumArt;
    notifyListeners();
  }

  Track? get currentTrack {
    if (_currentIndex >= 0 && _currentIndex < _playlist.length) {
      return _playlist[_currentIndex];
    }
    return null;
  }

  void _listenToAudioPlayerEvents() {
    // Playback State
    audioPlayer.playerStateStream.listen((playerState) {
      // Handle different player states here if needed
    });

    // Song Completion and Playlist Advancement
    audioPlayer.currentIndexStream.listen((newIndex) {
      if (newIndex != null && newIndex >= 0 && newIndex < _playlist.length) {
        _currentIndex = newIndex;

        // Load album and artist data for the new song
        loadAlbumAndArtistData();
      }
    });
  }

  String _createUniqueId(Track track) {
    return '${track.trackName}_${track.trackArtistName}_${track.albumName}'
        .replaceAll(' ', '_');
  }

  String getAlbumArtForTrack(Track track) {
    return track.albumArt ?? 'assets/images/t_steal.webp';
  }

  Future<Uri> _saveAssetToTempFile(String assetPath) async {
    final byteData = await rootBundle.load(assetPath);
    final buffer = byteData.buffer;
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    String fileName = p.basename(assetPath);
    var filePath = p.join(tempPath, fileName);
    return (await File(filePath).writeAsBytes(
            buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes)))
        .uri;
  }

  Future<void> play() async {
    if (currentlyPlayingSong != null) {
      try {
        await loadAlbumAndArtistData();

        if (_concatenatingAudioSource != null) {
          audioPlayer.play();
        } else {
          List<AudioSource> audioSources = [];
          for (var track in _playlist) {
            Uri audioUri;
            Uri artUri;

            // Handle audio file
            if (track.url.startsWith('assets/')) {
              audioUri = await _saveAssetToTempFile(track.url);
            } else {
              audioUri = Uri.parse(track.url);
            }

            // Handle album art
            if (track.albumArt != null) {
              artUri = await _saveAssetToTempFile(track.albumArt!);
            } else {
              artUri = await _saveAssetToTempFile('assets/images/t_steal.webp');
            }

            audioSources.add(AudioSource.uri(
              audioUri,
              tag: MediaItem(
                id: _createUniqueId(track),
                album: track.albumName,
                title: track.trackName,
                artist: track.trackArtistName,
                artUri: artUri,
              ),
            ));
          }

          _concatenatingAudioSource =
              ConcatenatingAudioSource(children: audioSources);
          await audioPlayer.setAudioSource(_concatenatingAudioSource!,
              initialIndex: _currentIndex);
          audioPlayer.play();
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
      } on Exception catch (e) {
        // Handle exceptions appropriately (e.g., show an error message)
        SnackBar(content: Text('Error playing audio: $e'));
      }
    } else {
      const SnackBar(content: Text('No song available to play.'));
    }
  }

  Future<void> addToPlaylist(Track track) async {
    if (_playlist.isEmpty) {
      _playlist.add(track);
      currentIndex = 0;
      play();
    } else {
      _playlist.add(track);
    }

    if (_concatenatingAudioSource != null) {
      Uri audioUri = track.url.startsWith('assets/')
          ? await _saveAssetToTempFile(track.url)
          : Uri.parse(track.url);
      Uri artUri = track.albumArt != null
          ? await _saveAssetToTempFile(track.albumArt!)
          : await _saveAssetToTempFile('assets/images/t_steal.webp');

      _concatenatingAudioSource!.add(AudioSource.uri(
        audioUri,
        tag: MediaItem(
          id: _createUniqueId(track),
          album: track.albumName,
          title: track.trackName,
          artist: track.trackArtistName,
          artUri: artUri,
        ),
      ));
    }
    notifyListeners();
  }

  Future<void> addAllToPlaylist(List<Track> tracks) async {
    if (_playlist.isEmpty) {
      _playlist.addAll(tracks);
      currentIndex = 0;
      play();
    } else {
      _playlist.addAll(tracks);
    }

    if (_concatenatingAudioSource != null) {
      List<AudioSource> newSources =
          await Future.wait(tracks.map((track) async {
        Uri audioUri = track.url.startsWith('assets/')
            ? await _saveAssetToTempFile(track.url)
            : Uri.parse(track.url);
        Uri artUri = track.albumArt != null
            ? await _saveAssetToTempFile(track.albumArt!)
            : await _saveAssetToTempFile('assets/images/t_steal.webp');

        return AudioSource.uri(
          audioUri,
          tag: MediaItem(
            id: _createUniqueId(track),
            album: track.albumName,
            title: track.trackName,
            artist: track.trackArtistName,
            artUri: artUri,
          ),
        );
      }));

      _concatenatingAudioSource!.addAll(newSources);
    }
    notifyListeners();
  }

Future<void> addAllToPlaylist2(List<Track> tracks) async {
    if (_playlist.isEmpty) {
      _playlist.addAll(tracks);
      currentIndex = 0;
      // play();
    } else {
      _playlist.addAll(tracks);
    }

    if (_concatenatingAudioSource != null) {
      List<AudioSource> newSources =
          await Future.wait(tracks.map((track) async {
        Uri audioUri = track.url.startsWith('assets/')
            ? await _saveAssetToTempFile(track.url)
            : Uri.parse(track.url);
        Uri artUri = track.albumArt != null
            ? await _saveAssetToTempFile(track.albumArt!)
            : await _saveAssetToTempFile('assets/images/t_steal.webp');

        return AudioSource.uri(
          audioUri,
          tag: MediaItem(
            id: _createUniqueId(track),
            album: track.albumName,
            title: track.trackName,
            artist: track.trackArtistName,
            artUri: artUri,
          ),
        );
      }));

      _concatenatingAudioSource!.addAll(newSources);
    }
    notifyListeners();
  }
  

  Future<void> addAllToPlaylistAndPlayFromTrack(List<Track> tracks, int initialIndex) async {
      _playlist.addAll(tracks);

    if (_concatenatingAudioSource != null) {
      List<AudioSource> newSources =
          await Future.wait(tracks.map((track) async {
        Uri audioUri = track.url.startsWith('assets/')
            ? await _saveAssetToTempFile(track.url)
            : Uri.parse(track.url);
        Uri artUri = track.albumArt != null
            ? await _saveAssetToTempFile(track.albumArt!)
            : await _saveAssetToTempFile('assets/images/t_steal.webp');

        return AudioSource.uri(
          audioUri,
          tag: MediaItem(
            id: _createUniqueId(track),
            album: track.albumName,
            title: track.trackName,
            artist: track.trackArtistName,
            artUri: artUri,
          ),
        );
      }));

      _concatenatingAudioSource!.addAll(newSources);
    }
    currentIndex = initialIndex;
    play();
    notifyListeners();
  }



  set currentIndex(int index) {
    if (index >= 0 && index < _playlist.length) {
      _currentIndex = index;
      audioPlayer.seek(Duration.zero, index: index);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } else {
      const SnackBar(content: Text('Invalid index for current song.'));
    }
  }

  Future<void> pause() async {
    await audioPlayer.pause();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  Future<void> next() async {
    if (_currentIndex < _playlist.length - 1) {
      _currentIndex++;
      await audioPlayer.seek(Duration.zero, index: _currentIndex);
      play(); // Start playing the next song automatically
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } else {
      // Handle end of playlist (e.g., stop or loop)
      await audioPlayer.stop();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  void previous() {
    if (audioPlayer.position.inSeconds < 2) {
      // If within the first 2 seconds, go to the beginning of the current song
      audioPlayer.seek(Duration.zero);
    } else if (_currentIndex > 0) {
      _currentIndex--;
      audioPlayer.seek(Duration.zero, index: _currentIndex);
    } else {
      // If at the beginning of the playlist, go to the beginning of the first song
      audioPlayer.seek(Duration.zero);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void clearPlaylist() {
    audioPlayer.stop();
    audioPlayer.seek(Duration.zero);
    _playlist.clear();
    _currentIndex = 0;
    _concatenatingAudioSource = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  Stream<Duration?> get positionStream => audioPlayer.positionStream;
  Stream<Duration?> get durationStream => audioPlayer.durationStream;

  Future<void> seekTo(Duration position, {int? index}) async {
    await audioPlayer.seek(position, index: index);
  }

  Future<int> getAlbumIndexFromAlbumName(String albumName) async {
    return _playlist.indexWhere((track) => track.albumName == albumName);
  }


  
}


