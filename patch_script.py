import re

file_path = r'd:\Documents\individuals\genesis\genesis\lib\navs\admin\fleet_tracking.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Update variables
content = content.replace(
    'final RxList<LatLng> _replayPath = <LatLng>[].obs;',
    'final RxList<ReplayPoint> _replayPath = <ReplayPoint>[].obs;\n  final RxList<StoppageMarker> _stoppageMarkers = <StoppageMarker>[].obs;\n  final RxDouble _replayRotation = 0.0.obs;\n  AnimationController? _replayAnimController;'
)

content = content.replace(
    '_replayTimer?.cancel();',
    '_replayTimer?.cancel();\n    _replayAnimController?.dispose();'
)

# 2. Update Polyline
content = content.replace(
    'points: _replayPath,',
    'points: _replayPath.map((p) => p.latLng).toList(),'
)

# 3. Update Markers
content = content.replace(
    '''                          markerId: const MarkerId('replay_start'),
                          position: _replayPath.first,
                          infoWindow: const InfoWindow(title: 'Start Location'),
                          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                        ),
                        Marker(
                          markerId: const MarkerId('replay_end'),
                          position: _replayPath.last,
                          infoWindow: const InfoWindow(title: 'End Location'),
                          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                        ),''',
    '''                          markerId: const MarkerId('replay_start'),
                          position: _replayPath.first.latLng,
                          infoWindow: const InfoWindow(title: 'Start Location'),
                          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                        ),
                        Marker(
                          markerId: const MarkerId('replay_end'),
                          position: _replayPath.last.latLng,
                          infoWindow: const InfoWindow(title: 'End Location'),
                          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                        ),
                        ..._stoppageMarkers.map((s) => Marker(
                          markerId: MarkerId('stop_${s.index}'),
                          position: s.latLng,
                          infoWindow: InfoWindow(title: 'Stopped Here', snippet: 'Duration: ${s.durationMins} mins'),
                          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                        )),'''
)

content = content.replace(
    '''                          markerId: const MarkerId('replay_vehicle'),
                          position: _replayPosition.value!,
                          anchor: const Offset(0.5, 0.5),
                          icon: vehicleIcon ?? BitmapDescriptor.defaultMarker,
                        ),''',
    '''                          markerId: const MarkerId('replay_vehicle'),
                          position: _replayPosition.value!,
                          rotation: _replayRotation.value,
                          anchor: const Offset(0.5, 0.5),
                          icon: vehicleIcon ?? BitmapDescriptor.defaultMarker,
                        ),'''
)

# 4. Update Replay Logic
old_replay_logic = '''  void _fetchAndStartReplay(String vehicleId, DateTime date) async {
    final dateString = date.toIso8601String().split("T")[0];
    Toaster.showInfo("Fetching history for $dateString...");
    
    final response = await Net.get("/vehicle/$vehicleId/history", queryParameters: {"date": dateString});
    if (response.hasError) {
      Toaster.showError("Failed to load history: ${response.response}");
      return;
    }
    
    final pointsList = (response.body['points'] as List?) ?? [];
    if (pointsList.isEmpty) {
      Toaster.showError("No movement logs found for this vehicle on $dateString.");
      return;
    }
    
    final path = pointsList.map((p) => LatLng(
      (p['lat'] as num).toDouble(),
      (p['lng'] as num).toDouble(),
    )).toList();
    
    _stopReplay(); // Clean up if already running
    
    _replayPath.assignAll(path);
    _isReplaying.value = true;
    _replayIndex.value = 0;
    _replayPosition.value = path.first;
    
    // Zoom/Move camera to start of path
    final controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(path.first, 15));
    
    _startReplayAnimation();
  }

  void _startReplayAnimation() {
    _replayTimer?.cancel();
    _isReplayPlaying.value = true;
    
    // Duration decreases as speed increases
    final intervalMs = (1500 / _replaySpeed.value).round();
    
    _replayTimer = Timer.periodic(Duration(milliseconds: intervalMs), (timer) async {
      if (_replayIndex.value < _replayPath.length - 1) {
        _replayIndex.value++;
        _replayPosition.value = _replayPath[_replayIndex.value];
        
        final controller = await _mapController.future;
        controller.animateCamera(CameraUpdate.newLatLng(_replayPosition.value!));
      } else {
        _isReplayPlaying.value = false;
        _replayTimer?.cancel();
        Toaster.showSuccess("Replay finished.");
      }
    });
  }

  void _pauseReplay() {
    _replayTimer?.cancel();
    _isReplayPlaying.value = false;
  }

  void _stopReplay() {
    _replayTimer?.cancel();
    _isReplaying.value = false;
    _isReplayPlaying.value = false;
    _replayPath.clear();
    _replayPosition.value = null;
    _replayIndex.value = 0;
  }'''

new_replay_logic = '''  void _fetchAndStartReplay(String vehicleId, DateTime date) async {
    final dateString = date.toIso8601String().split("T")[0];
    Toaster.showInfo("Fetching history for $dateString...");
    
    final response = await Net.get("/vehicle/$vehicleId/history", queryParameters: {"date": dateString});
    if (response.hasError) {
      Toaster.showError("Failed to load history: ${response.response}");
      return;
    }
    
    final pointsList = (response.body['points'] as List?) ?? [];
    if (pointsList.isEmpty) {
      Toaster.showError("No movement logs found for this vehicle on $dateString.");
      return;
    }
    
    final List<ReplayPoint> path = [];
    final List<StoppageMarker> stops = [];
    
    for (int i = 0; i < pointsList.length; i++) {
      final p = pointsList[i];
      final timestamp = DateTime.parse(p['timestamp']);
      path.add(ReplayPoint(
        latLng: LatLng((p['lat'] as num).toDouble(), (p['lng'] as num).toDouble()),
        speed: (p['speed'] as num?)?.toDouble() ?? 0.0,
        heading: (p['heading'] as num?)?.toDouble() ?? 0.0,
        timestamp: timestamp,
      ));
      
      if (i > 0) {
        final prevTimestamp = DateTime.parse(pointsList[i - 1]['timestamp']);
        final diffMins = timestamp.difference(prevTimestamp).inMinutes;
        if (diffMins > 15) {
          stops.add(StoppageMarker(
            index: i,
            latLng: LatLng((p['lat'] as num).toDouble(), (p['lng'] as num).toDouble()),
            durationMins: diffMins,
          ));
        }
      }
    }
    
    _stopReplay(); // Clean up if already running
    
    _replayPath.assignAll(path);
    _stoppageMarkers.assignAll(stops);
    _isReplaying.value = true;
    _replayIndex.value = 0;
    _replayPosition.value = path.first.latLng;
    _replayRotation.value = path.first.heading;
    
    // Zoom/Move camera to start of path
    final controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(path.first.latLng, 15));
    
    _startReplayAnimation();
  }

  void _startReplayAnimation() {
    _isReplayPlaying.value = true;
    _animateNextPoint();
  }

  void _animateNextPoint() async {
    if (!_isReplayPlaying.value) return;
    
    if (_replayIndex.value < _replayPath.length - 1) {
      final currentPoint = _replayPath[_replayIndex.value];
      final nextPoint = _replayPath[_replayIndex.value + 1];
      
      // Calculate duration between points
      final realDurationMs = nextPoint.timestamp.difference(currentPoint.timestamp).inMilliseconds;
      // Cap duration between 500ms and 5000ms for smooth playback
      int animDurationMs = (realDurationMs / _replaySpeed.value).round().clamp(500, 5000);
      
      _replayAnimController?.dispose();
      _replayAnimController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: animDurationMs),
      );
      
      final positionTween = LatLngTween(begin: currentPoint.latLng, end: nextPoint.latLng)
          .animate(CurvedAnimation(parent: _replayAnimController!, curve: Curves.linear))
        ..addListener(() {
          _replayPosition.value = positionTween.value;
        });
        
      double startRot = currentPoint.heading;
      double endRot = nextPoint.heading;
      
      double diff = endRot - startRot;
      if (diff > 180) endRot -= 360;
      else if (diff < -180) endRot += 360;
      
      final rotationTween = Tween<double>(begin: startRot, end: endRot)
          .animate(CurvedAnimation(parent: _replayAnimController!, curve: Curves.linear))
        ..addListener(() {
          _replayRotation.value = rotationTween.value;
        });
        
      _replayAnimController!.addStatusListener((status) async {
        if (status == AnimationStatus.completed) {
          _replayIndex.value++;
          if (_isReplayPlaying.value) {
            final controller = await _mapController.future;
            controller.animateCamera(CameraUpdate.newLatLng(_replayPosition.value!));
            _animateNextPoint();
          }
        }
      });
      
      _replayAnimController!.forward();
    } else {
      _isReplayPlaying.value = false;
      Toaster.showSuccess("Replay finished.");
    }
  }

  void _pauseReplay() {
    _isReplayPlaying.value = false;
    _replayAnimController?.stop();
  }

  void _stopReplay() {
    _isReplaying.value = false;
    _isReplayPlaying.value = false;
    _replayAnimController?.stop();
    _replayAnimController?.dispose();
    _replayAnimController = null;
    _replayPath.clear();
    _stoppageMarkers.clear();
    _replayPosition.value = null;
    _replayRotation.value = 0.0;
    _replayIndex.value = 0;
  }'''

content = content.replace(old_replay_logic, new_replay_logic)

# 5. Bottom of file classes
classes_str = '''
class ReplayPoint {
  final LatLng latLng;
  final double speed;
  final double heading;
  final DateTime timestamp;

  ReplayPoint({
    required this.latLng,
    required this.speed,
    required this.heading,
    required this.timestamp,
  });
}

class StoppageMarker {
  final int index;
  final LatLng latLng;
  final int durationMins;

  StoppageMarker({
    required this.index,
    required this.latLng,
    required this.durationMins,
  });
}
'''
if 'class ReplayPoint' not in content:
    content += classes_str

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

print('Success')
