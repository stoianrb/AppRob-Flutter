// MODERNIZED VideoGalleryScreen
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:animate_do/animate_do.dart';

class VideoGalleryScreen extends StatefulWidget {
  const VideoGalleryScreen({super.key});

  @override
  State<VideoGalleryScreen> createState() => _VideoGalleryScreenState();
}

class _VideoGalleryScreenState extends State<VideoGalleryScreen> {
  late YoutubePlayerController _controller;
  String currentVideoId = '';

  final List<String> videoUrls = const [
    'https://www.youtube.com/watch?v=y0UW042pZJY',
    'https://www.youtube.com/watch?v=d42KWaRI_BI',
    'https://www.youtube.com/watch?v=FNRDysJMTmE',
    'https://www.youtube.com/watch?v=r9dJGK954IY',
    'https://www.youtube.com/watch?v=XnpY9tsrhMo',
    'https://www.youtube.com/watch?v=mifSwgkgsXY',
    'https://www.youtube.com/watch?v=_v0aFbUvJ1Y',
    'https://www.youtube.com/watch?v=81C34WYKJuM',
    'https://www.youtube.com/watch?v=c0Z3oGIFetM',
    'https://www.youtube.com/watch?v=ou71NHazyWU',
    'https://www.youtube.com/watch?v=FfG-3885rlw',
    'https://www.youtube.com/watch?v=NijTxDBPY2g',
    'https://www.youtube.com/watch?v=uv-IN2MUbe4',
    'https://www.youtube.com/watch?v=VC9JYf26xik',
    'https://www.youtube.com/watch?v=Y-fewmWhIYE',
    'https://www.youtube.com/watch?v=2zV6DCzJGAU',
    'https://www.youtube.com/watch?v=tcHUyY4XGDE',
    'https://www.youtube.com/watch?v=YkpIh6qOlE4',
  ];

  @override
  void initState() {
    super.initState();
    currentVideoId = YoutubePlayerController.convertUrlToId(videoUrls[0]) ?? '';
    _controller = YoutubePlayerController.fromVideoId(
      videoId: currentVideoId,
      autoPlay: false,
      params: const YoutubePlayerParams(
        showFullscreenButton: true,
        showControls: true,
        enableCaption: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  void _playVideo(String url) {
    final id = YoutubePlayerController.convertUrlToId(url);
    if (id != null) {
      setState(() => currentVideoId = id);
      _controller.loadVideoById(videoId: id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("🎥 Video Gallery"),
        backgroundColor: Colors.deepPurple.shade700,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple.shade700, Colors.deepPurple.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
            ),
            padding: const EdgeInsets.all(8),
            height: MediaQuery.of(context).size.height * 0.3,
            child: YoutubePlayer(controller: _controller),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Tap a thumbnail to play",
              style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 16 / 9,
              ),
              itemCount: videoUrls.length,
              itemBuilder: (context, index) {
                final videoId = YoutubePlayerController.convertUrlToId(videoUrls[index])!;
                return GestureDetector(
                  onTap: () => _playVideo(videoUrls[index]),
                  child: ZoomIn(
                    duration: Duration(milliseconds: 300 + (index % 6) * 100),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CachedNetworkImage(
                            imageUrl: 'https://img.youtube.com/vi/$videoId/hqdefault.jpg',
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Shimmer.fromColors(
                              baseColor: Colors.grey.shade800,
                              highlightColor: Colors.grey.shade600,
                              child: Container(color: Colors.black),
                            ),
                            errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.red),
                          ),
                          Container(
                            color: Colors.black45,
                            alignment: Alignment.center,
                            child: const Icon(Icons.play_circle_fill, color: Colors.white70, size: 48),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
