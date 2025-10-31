import 'package:flutter/material.dart';
// Assume you use a package like flutter_webrtc for actual camera feed
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:newscalendar/config/camera_config.dart';

class FarmCCTV extends StatefulWidget {
  const FarmCCTV({Key? key}) : super(key: key);

  @override
  State<FarmCCTV> createState() => _FarmCCTVState();
}

class _FarmCCTVState extends State<FarmCCTV> {
  final CameraConfigService _cameraService = CameraConfigService();
  List<CameraConfig> _cameras = [];
  bool _isLoading = true;
  CameraConfig? _selectedCamera;
  RTCVideoRenderer _renderer =
      RTCVideoRenderer(); // Uncomment if using flutter_webrtc
  MediaStream? _localStream;

  @override
  void initState() {
    super.initState();
    _renderer.initialize(); // Uncomment if using flutter_webrtc
    _loadCameras();
    _startLocalCamera();
  }

  /// Load cameras from configuration
  Future<void> _loadCameras() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final cameras = await _cameraService.getEnabledCameras();
      setState(() {
        _cameras = cameras;
        _isLoading = false;
        // Select first camera if available
        if (_cameras.isNotEmpty) {
          _selectedCamera = _cameras.first;
          _connectToCamera(_selectedCamera!);
        }
      });
    } catch (e) {
      print('Error loading cameras: $e');
      setState(() {
        _isLoading = false;
        _cameras = [];
      });
    }
  }

  Future<void> _startLocalCamera() async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': false,
      'video': {
        'facingMode': 'user', // or 'user' for front camera
      },
    };
    try {
      _localStream = await navigator.mediaDevices.getUserMedia(
        mediaConstraints,
      );
      _renderer.srcObject = _localStream;
      setState(() {});
    } catch (e) {
      print('Error starting camera: $e');
    }
  }

  @override
  void dispose() {
    _renderer.dispose();
    _localStream?.dispose();
    super.dispose();
  }

  void _connectToCamera(CameraConfig camera) async {
    setState(() {
      _selectedCamera = camera;
    });
    // Actual WebRTC connection code goes here
    // Use camera.streamId for WebRTC connection
    // await _renderer.srcObject = await createLocalMediaStream(camera.streamId);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Text('Farm CCTV', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),

        // Loading indicator
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(32.0),
            child: CircularProgressIndicator(),
          )
        else if (_cameras.isEmpty)
          // No cameras available message
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: [
                Icon(Icons.videocam_off, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No cameras configured',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add camera configurations to assets/config/cameras.json',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else ...[
          // Main camera player at the top
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green, width: 2),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Uncomment below if using flutter_webrtc
                  RTCVideoView(_renderer),
                  // For demo, show a placeholder image
                  Icon(Icons.videocam, color: Colors.white54, size: 80),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _selectedCamera?.name ?? 'No Camera Selected',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // Simulate a "Live" badge
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'LIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          // Grid of camera buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _cameras.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                final camera = _cameras[index];
                final isSelected = _selectedCamera?.id == camera.id;
                return GestureDetector(
                  onTap: () => _connectToCamera(camera),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.green[100] : Colors.grey[200],
                      border: Border.all(
                        color: isSelected ? Colors.green : Colors.grey,
                        width: isSelected ? 2.5 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.green, width: 2),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                RTCVideoView(
                                  _renderer,
                                  objectFit:
                                      RTCVideoViewObjectFit
                                          .RTCVideoViewObjectFitCover,
                                ),
                                // ... (rest of your overlay widgets)
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Text(
                            camera.name,
                            style: TextStyle(
                              color:
                                  isSelected
                                      ? Colors.green[900]
                                      : Colors.grey[800],
                              fontWeight:
                                  isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
        const SizedBox(height: 18),
      ],
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_webrtc/flutter_webrtc.dart';
// import 'package:socket_io_client/socket_io_client.dart' as IO;
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class FarmCCTV extends StatefulWidget {
//   const FarmCCTV({Key? key}) : super(key: key);

//   @override
//   State<FarmCCTV> createState() => _FarmCCTVState();
// }

// class _FarmCCTVState extends State<FarmCCTV> {
//   RTCVideoRenderer _renderer = RTCVideoRenderer();
//   IO.Socket? _socket;
//   RTCPeerConnection? _pc;
//   String streamId =
//       '0b28d19f-e82f-4a46-af52-655deecaa5b8'; // Use the same as in publisher
//   Map<String, dynamic>? _iceConfig;

//   @override
//   void initState() {
//     super.initState();
//     _renderer.initialize();
//     _initWebRTC();
//   }

//   Future<void> _initWebRTC() async {
//     // 1. Get ICE config
//     final configRes = await http.get(
//       Uri.parse('http://localhost:3000/api/webrtc/config'),
//     );
//     _iceConfig = json.decode(configRes.body)['config'];

//     // 2. Connect to signaling server
//     _socket = IO.io(
//       'http://localhost:3000',
//       IO.OptionBuilder().setTransports(['websocket']).build(),
//     );
//     _socket!.onConnect((_) async {
//       _socket!.emit('join-stream', streamId);

//       // 3. Create PeerConnection
//       _pc = await createPeerConnection(_iceConfig!);

//       _pc!.onTrack = (event) {
//         if (event.streams.isNotEmpty) {
//           _renderer.srcObject = event.streams[0];
//         }
//       };

//       // 4. Handle offer from publisher
//       _socket!.on('offer', (data) async {
//         await _pc!.setRemoteDescription(
//           RTCSessionDescription(data['offer']['sdp'], data['offer']['type']),
//         );
//         final answer = await _pc!.createAnswer();
//         await _pc!.setLocalDescription(answer);
//         _socket!.emit('answer', {
//           'streamId': streamId,
//           'answer': answer.toMap(),
//         });
//       });

//       // 5. ICE candidates
//       _pc!.onIceCandidate = (candidate) {
//         _socket!.emit('ice-candidate', {
//           'streamId': streamId,
//           'candidate': candidate.toMap(),
//         });
//       };
//       _socket!.on('ice-candidate', (data) {
//         if (data['candidate'] != null) {
//           _pc!.addCandidate(
//             RTCIceCandidate(
//               data['candidate']['candidate'],
//               data['candidate']['sdpMid'],
//               data['candidate']['sdpMLineIndex'],
//             ),
//           );
//         }
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _renderer.dispose();
//     _pc?.close();
//     _socket?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: AspectRatio(
//         aspectRatio: 16 / 9,
//         child: Container(
//           decoration: BoxDecoration(
//             color: Colors.black,
//             borderRadius: BorderRadius.circular(16),
//             border: Border.all(color: Colors.green, width: 2),
//           ),
//           child: RTCVideoView(
//             _renderer,
//             objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter_webrtc/flutter_webrtc.dart';
// import 'package:newscalendar/constants/constants.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class FarmCCTV extends StatefulWidget {
//   const FarmCCTV({Key? key}) : super(key: key);

//   @override
//   State<FarmCCTV> createState() => _FarmCCTVState();
// }

// class _FarmCCTVState extends State<FarmCCTV> {
//   RTCVideoRenderer _renderer = RTCVideoRenderer();
//   WebSocketChannel? _channel;
//   RTCPeerConnection? _pc;
//   String streamId =
//       '7a874af7-20ed-440b-9ab4-e9abedf9d5ea'; // Use the same as in publisher
//   Map<String, dynamic>? _iceConfig;

//   @override
//   void initState() {
//     super.initState();
//     _renderer.initialize();
//     _initWebRTC();
//   }

//   Future<void> _initWebRTC() async {
//     // 1. Get ICE config
//     final configRes = await http.get(
//       Uri.parse('${BASE_URL}/api/webrtc/config'),
//     );
//     _iceConfig = json.decode(configRes.body)['config'];

//     // 2. Connect to signaling server using WebSocket
//     _channel = WebSocketChannel.connect(Uri.parse(SOCK_BASE_URL));
//     _channel!.sink.add(
//       json.encode({'action': 'join-stream', 'streamId': streamId}),
//     );

//     // 3. Create PeerConnection
//     _pc = await createPeerConnection(_iceConfig!);

//     _pc!.onTrack = (event) {
//       print('Received remote track');
//       if (event.streams.isNotEmpty) {
//         setState(() {
//           _renderer.srcObject = event.streams[0];
//         });
//       }
//     };

//     // 4. Handle signaling messages
//     _channel!.stream.listen((message) async {
//       final data = json.decode(message);
//       if (data['action'] == 'offer') {
//         print('Received offer');
//         await _pc!.setRemoteDescription(
//           RTCSessionDescription(data['offer']['sdp'], data['offer']['type']),
//         );
//         final answer = await _pc!.createAnswer();
//         await _pc!.setLocalDescription(answer);
//         _channel!.sink.add(
//           json.encode({
//             'action': 'answer',
//             'streamId': streamId,
//             'answer': answer.toMap(),
//           }),
//         );
//         print('Sent answer');
//       }
//       if (data['action'] == 'ice-candidate') {
//         print('Received ICE candidate');
//         if (data['candidate'] != null) {
//           await _pc!.addCandidate(
//             RTCIceCandidate(
//               data['candidate']['candidate'],
//               data['candidate']['sdpMid'],
//               data['candidate']['sdpMLineIndex'],
//             ),
//           );
//         }
//       }
//     });

//     // 5. Send ICE candidates
//     _pc!.onIceCandidate = (candidate) {
//       _channel!.sink.add(
//         json.encode({
//           'action': 'ice-candidate',
//           'streamId': streamId,
//           'candidate': candidate.toMap(),
//         }),
//       );
//     };
//   }

//   @override
//   void dispose() {
//     _renderer.dispose();
//     _pc?.close();
//     _channel?.sink.close();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: AspectRatio(
//         aspectRatio: 16 / 9,
//         child: Container(
//           decoration: BoxDecoration(
//             color: Colors.black,
//             borderRadius: BorderRadius.circular(16),
//             border: Border.all(color: Colors.green, width: 2),
//           ),
//           child: RTCVideoView(
//             _renderer,
//             objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
//           ),
//         ),
//       ),
//     );
//   }
// }
