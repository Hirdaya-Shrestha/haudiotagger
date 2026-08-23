import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:haudiotagger/haudiotagger.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String path = "";
  String result = "Pick a file, then Read or Write metadata.";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Haudiotagger Example')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(result, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (Platform.isAndroid || Platform.isIOS) {
                    await Permission.storage.request();
                  }
                  FilePickerResult? r = await FilePicker.platform.pickFiles();
                  if (r != null && r.files.single.path != null) {
                    setState(() {
                      path = r.files.single.path!;
                      result = "Selected: ${path.split('/').last}";
                    });
                  }
                },
                child: const Text("Open"),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: path.isEmpty
                    ? null
                    : () async {
                        Tag tag = Tag(
                          title: "Title",
                          trackArtist: "Track Artist",
                          album: "Album",
                          albumArtist: "Album Artist",
                          genre: "Genre",
                          year: 2000,
                          trackNumber: 1,
                          trackTotal: 2,
                          discNumber: 1,
                          discTotal: 3,
                          pictures: [
                            Picture(
                              bytes: Uint8List.fromList([0, 0, 0, 0]),
                              mimeType: null,
                              pictureType: PictureType.other,
                            ),
                          ],
                        );
                        try {
                          await Haudiotagger.write(path, tag);
                          setState(() => result = "Write succeeded!");
                        } catch (e) {
                          setState(() => result = "Write failed: $e");
                        }
                      },
                child: const Text("Write"),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: path.isEmpty
                    ? null
                    : () async {
                        try {
                          Tag? tag = await Haudiotagger.read(path);
                          if (tag == null) {
                            setState(() => result = "No tags found.");
                            return;
                          }
                          setState(() {
                            result = [
                              "Title: ${tag.title}",
                              "Artist: ${tag.trackArtist}",
                              "Album: ${tag.album}",
                              "Album Artist: ${tag.albumArtist}",
                              "Genre: ${tag.genre}",
                              "Year: ${tag.year}",
                              "Track: ${tag.trackNumber}/${tag.trackTotal}",
                              "Disc: ${tag.discNumber}/${tag.discTotal}",
                              "Duration: ${tag.duration}s",
                              "BPM: ${tag.bpm}",
                              "Pictures: ${tag.pictures.length}",
                            ].join("\n");
                          });
                        } catch (e) {
                          setState(() => result = "Read failed: $e");
                        }
                      },
                child: const Text("Read"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
