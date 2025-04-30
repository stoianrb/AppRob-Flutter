import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';

class VideoGalleryScreen extends StatefulWidget {
  const VideoGalleryScreen({super.key});

  @override
  State<VideoGalleryScreen> createState() => _VideoGalleryScreenState();
}

class _VideoGalleryScreenState extends State<VideoGalleryScreen> {
  late YoutubePlayerController _controller;
  bool isVideoFullscreen = false; // Variabila care controlează fullscreen-ul

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
    final firstId = YoutubePlayerController.convertUrlToId(videoUrls.first)!;

    _controller = YoutubePlayerController.fromVideoId(
      videoId: firstId,
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

  void _onVideoTap(String url) {
    final id = YoutubePlayerController.convertUrlToId(url);
    if (id != null) {
      setState(() {
        // La apăsarea pe un video, facem fullscreen
        _controller.loadVideoById(videoId: id);
        isVideoFullscreen = true; // Setăm variabila pentru fullscreen
      });
    }
  }

  void _exitFullscreen() {
    setState(() {
      isVideoFullscreen = false; // Ieși din fullscreen
    });
    _controller.loadVideoById(videoId: videoUrls.first); // Încarcă primul video sau poate un alt comportament dorit
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Video Gallery"),
        actions: [
          if (isVideoFullscreen) // Butonul de "Back" când suntem în fullscreen
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: _exitFullscreen,
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              // Dacă e fullscreen, arată player-ul mare, altfel afișează grila
              if (isVideoFullscreen)
                Container(
                  margin: const EdgeInsets.all(12),
                  height: MediaQuery.of(context).size.height * 0.6, // Înălțimea playerului pe întregul ecran
                  child: YoutubePlayer(controller: _controller),
                )
              else
                Container(
                  margin: const EdgeInsets.all(12),
                  height: 250, // Înălțimea playerului normal
                  child: YoutubePlayer(controller: _controller),
                ),
              // Grila de video-uri
              if (!isVideoFullscreen)
                GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: videoUrls.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 16 / 11,
                  ),
                  itemBuilder: (context, index) {
                    final videoId = YoutubePlayerController.convertUrlToId(videoUrls[index])!;
                    return GestureDetector(
                      onTap: () => _onVideoTap(videoUrls[index]),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          imageUrl: 'https://img.youtube.com/vi/$videoId/hqdefault.jpg',
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: Colors.grey.shade300,
                            highlightColor: Colors.grey.shade100,
                            child: Container(color: Colors.white),
                          ),
                          errorWidget: (context, url, error) =>
                              const Center(child: Icon(Icons.error, color: Colors.red)),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
