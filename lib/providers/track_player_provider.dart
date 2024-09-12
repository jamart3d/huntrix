import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logger/logger.dart';
import 'package:huntrix/models/track.dart';
import 'package:huntrix/utils/duration_formatter.dart';

class TrackPlayerProvider extends ChangeNotifier {
  final audioPlayer = AudioPlayer();
  final Logger _logger;

  ConcatenatingAudioSource? _concatenatingAudioSource;
  int _currentIndex = 0;

  // Cached album and artist data
  String? _cachedAlbumArt;
  String? _cachedArtistName;
  String? _cachedAlbumTitle;


  String get formattedCurrentDuration =>
      formatDuration(audioPlayer.position);

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

  // Constructor - receive the Logger instance
  TrackPlayerProvider({required Logger logger}) : _logger = logger {
    _listenToAudioPlayerEvents();
  }

  // Load album and artist data, and cache them for current song
  Future<void> loadAlbumAndArtistData() async {
    _logger.d("Entering loadAlbumAndArtistData");
    if (currentlyPlayingSong == null) {
      _logger.w("Currently playing song is null. Exiting.");
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

  void _listenToAudioPlayerEvents() {
    _logger.d("Entering _listenToAudioPlayerEvents");

    // Playback State
    audioPlayer.playerStateStream.listen((playerState) {
      _logger.d('Player state changed: ${playerState.processingState}');
      // Handle different player states here if needed
    });

    // Song Completion and Playlist Advancement
    audioPlayer.currentIndexStream.listen((newIndex) {
      _logger.d('Current Index Stream changed to $newIndex');

      if (newIndex != null && newIndex >= 0 && newIndex < _playlist.length) {
        _currentIndex = newIndex;
        _logger.i('Now playing: ${_playlist[_currentIndex].trackName}');

        // Load album and artist data for the new song
        loadAlbumAndArtistData();
      }
    });
  }

  // Core playback methods
  Future<void> play() async {
    if (currentlyPlayingSong != null) {
      try {
        // Load the artist and album data for the current song
        await loadAlbumAndArtistData();

        // Check if the audio source is already set
        if (_concatenatingAudioSource != null) {
          audioPlayer.play();
        } else {
          _concatenatingAudioSource = ConcatenatingAudioSource(
            children: _playlist.map((track) {
              return AudioSource.uri(Uri.parse(track.url));
            }).toList(),
          );
          await audioPlayer.setAudioSource(_concatenatingAudioSource!,
              initialIndex: _currentIndex);
          audioPlayer.play();
        }

        // Notify listeners after playing has started
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
      } on Exception catch (e) {
        _logger.e('Error playing audio: $e');
      }
    } else {
      _logger.w('No song available to play.');
    }
  }

  set currentIndex(int index) {
    if (index >= 0 && index < _playlist.length) {
      _logger.d('Changing song index to: $index');
      _currentIndex = index;
      audioPlayer.seek(Duration.zero, index: index);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } else {
      _logger.e('Invalid song index: $index');
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

  // Playlist management methods
  void addToPlaylist(Track track) {
    if (_playlist.isEmpty) {
      _playlist.add(track);
      currentIndex = 0;
      play(); // Start playing if it's the first song added
    } else {
      _playlist.add(track);
    }

    if (_concatenatingAudioSource != null) {
      _concatenatingAudioSource!.add(AudioSource.uri(Uri.parse(track.url)));
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
    _logger.d('Playlist cleared.');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void addAllToPlaylist(List<Track> tracks) async {
    if (_playlist.isEmpty) {
      _playlist.addAll(tracks);
      currentIndex = 0;
      play(); // Start playing if the playlist was empty
    } else {
      _playlist.addAll(tracks);
    }

    if (_concatenatingAudioSource != null) {
      _concatenatingAudioSource!.addAll(
        tracks.map((track) => AudioSource.uri(Uri.parse(track.url))).toList(),
      );
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }



  Stream<Duration?> get positionStream => audioPlayer.positionStream;
  Stream<Duration?> get durationStream => audioPlayer.durationStream;

  Future<void> seekTo(Duration position, {int? index}) async {
    await audioPlayer.seek(position, index: index);
  }
}
