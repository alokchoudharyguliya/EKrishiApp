import 'package:flutter/material.dart';
// Assume you use a package like flutter_webrtc for actual camera feed
import 'package:flutter_webrtc/flutter_webrtc.dart';

class FarmCCTV extends StatefulWidget {
  const FarmCCTV({Key? key}) : super(key: key);

  @override
  State<FarmCCTV> createState() => _FarmCCTVState();
}

class _FarmCCTVState extends State<FarmCCTV> {
  int _selectedCamera = 1;
  final int _cameraCount = 4; // Assume 4 cameras for demo
  RTCVideoRenderer _renderer =
      RTCVideoRenderer(); // Uncomment if using flutter_webrtc
  MediaStream? _localStream;

  @override
  void initState() {
    super.initState();
    _renderer.initialize(); // Uncomment if using flutter_webrtc
    _connectToCamera(_selectedCamera); // Uncomment if using flutter_webrtc
    _startLocalCamera();
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

  void _connectToCamera(int cameraNumber) async {
    setState(() {
      _selectedCamera = cameraNumber;
    });
    // Actual WebRTC connection code goes here
    // await _renderer.srcObject = await createLocalMediaStream('key');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Text('Farm CCTV', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
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
                      'Camera $_selectedCamera',
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
            itemCount: _cameraCount,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              final camNum = index + 1;
              final isSelected = camNum == _selectedCamera;
              return GestureDetector(
                onTap: () => _connectToCamera(camNum),
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
                      Text(
                        'Cam $camNum',
                        style: TextStyle(
                          color:
                              isSelected ? Colors.green[900] : Colors.grey[800],
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
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
