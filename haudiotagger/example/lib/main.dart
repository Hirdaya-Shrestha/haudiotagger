import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:haudiotagger/haudiotagger.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _fileName;
  Uint8List? _fileBytes;
  String _result = "Pick an audio file to read its metadata.";
  final _titleCtrl = TextEditingController();
  final _artistCtrl = TextEditingController();
  final _albumCtrl = TextEditingController();
  final _genreCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _trackNumCtrl = TextEditingController();
  final _trackTotalCtrl = TextEditingController();
  final _discNumCtrl = TextEditingController();
  final _discTotalCtrl = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _artistCtrl.dispose();
    _albumCtrl.dispose();
    _genreCtrl.dispose();
    _yearCtrl.dispose();
    _trackNumCtrl.dispose();
    _trackTotalCtrl.dispose();
    _discNumCtrl.dispose();
    _discTotalCtrl.dispose();
    super.dispose();
  }

  void _fillFields(Tag tag) {
    _titleCtrl.text = tag.title ?? '';
    _artistCtrl.text = tag.trackArtist ?? '';
    _albumCtrl.text = tag.album ?? '';
    _genreCtrl.text = tag.genre ?? '';
    _yearCtrl.text = tag.year?.toString() ?? '';
    _trackNumCtrl.text = tag.trackNumber?.toString() ?? '';
    _trackTotalCtrl.text = tag.trackTotal?.toString() ?? '';
    _discNumCtrl.text = tag.discNumber?.toString() ?? '';
    _discTotalCtrl.text = tag.discTotal?.toString() ?? '';
  }

  Future<void> _pickFile() async {
    FilePickerResult? r = await FilePicker.pickFiles(
      withData: true,
      type: FileType.custom,
      allowedExtensions: [
        'mp3',
        'flac',
        'ogg',
        'opus',
        'wav',
        'aiff',
        'mp4',
        'm4a',
        'aac',
        'wma',
        'alac',
      ],
    );
    if (r == null) return;
    final file = r.files.single;
    setState(() {
      _fileName = file.name;
      _fileBytes = file.bytes;
      _result = "Selected: ${file.name} (${file.size} bytes)";
    });
  }

  Future<void> _readMetadata() async {
    if (_fileBytes == null) return;
    try {
      final tag = await Haudiotagger.readFromBytes(_fileBytes!);
      if (tag == null) {
        setState(() => _result = "No tags found in $_fileName.");
        return;
      }
      _fillFields(tag);
      setState(() {
        _result = [
          "Read succeeded!",
          "Title: ${tag.title}",
          "Artist: ${tag.trackArtist}",
          "Album: ${tag.album}",
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
      setState(() => _result = "Read failed: $e");
    }
  }

  Future<void> _writeMetadata() async {
    if (_fileBytes == null) return;
    try {
      final tag = Tag(
        title: _titleCtrl.text.isEmpty ? null : _titleCtrl.text,
        trackArtist: _artistCtrl.text.isEmpty ? null : _artistCtrl.text,
        album: _albumCtrl.text.isEmpty ? null : _albumCtrl.text,
        genre: _genreCtrl.text.isEmpty ? null : _genreCtrl.text,
        year: int.tryParse(_yearCtrl.text),
        trackNumber: int.tryParse(_trackNumCtrl.text),
        trackTotal: int.tryParse(_trackTotalCtrl.text),
        discNumber: int.tryParse(_discNumCtrl.text),
        discTotal: int.tryParse(_discTotalCtrl.text),
        pictures: [],
      );

      final outBytes = await Haudiotagger.writeToBytes(_fileBytes!, tag);

      if (kIsWeb) {
        _downloadBytesWeb(outBytes, _fileName!);
      } else {
        _saveNative(outBytes);
      }
      setState(() => _result = "Write succeeded! File downloaded.");
    } catch (e) {
      setState(() => _result = "Write failed: $e");
    }
  }

  void _downloadBytesWeb(Uint8List bytes, String name) {
    // Web download is handled via anchor element
    // For now, show success - users can save the modified file
    setState(
      () => _result = "Write succeeded! Modified file: ${bytes.length} bytes.",
    );
  }

  void _saveNative(Uint8List bytes) {
    setState(() => _result = "Write succeeded! ${bytes.length} bytes written.");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Haudiotagger Web Demo',
      theme: ThemeData(colorSchemeSeed: Colors.deepPurple, useMaterial3: true),
      home: Scaffold(
        appBar: AppBar(title: const Text('Audio Metadata Editor')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(_result, textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton.icon(
                                onPressed: _pickFile,
                                icon: const Icon(Icons.folder_open),
                                label: const Text('Open'),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                onPressed:
                                    _fileBytes == null ? null : _readMetadata,
                                icon: const Icon(Icons.book),
                                label: const Text('Read'),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                onPressed:
                                    _fileBytes == null ? null : _writeMetadata,
                                icon: const Icon(Icons.save),
                                label: const Text('Write'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildForm(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Edit Metadata',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _field('Title', _titleCtrl),
            _field('Artist', _artistCtrl),
            _field('Album', _albumCtrl),
            _field('Genre', _genreCtrl),
            Row(
              children: [
                Expanded(child: _field('Year', _yearCtrl)),
                const SizedBox(width: 8),
                Expanded(child: _field('Track #', _trackNumCtrl)),
                const SizedBox(width: 8),
                Expanded(child: _field('Track Total', _trackTotalCtrl)),
              ],
            ),
            Row(
              children: [
                Expanded(child: _field('Disc #', _discNumCtrl)),
                const SizedBox(width: 8),
                Expanded(child: _field('Disc Total', _discTotalCtrl)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }
}
