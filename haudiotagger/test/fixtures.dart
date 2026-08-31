import 'dart:typed_data';

/// Minimal valid MP3 bytes with an ID3v2.3 tag.
/// Enough for lofty to parse and write tags.
Uint8List createMinimalMp3({
  String? title,
  String? artist,
  String? album,
}) {
  final tagBytes = _buildId3v2Tag(
    version: 3,
    title: title,
    artist: artist,
    album: album,
  );

  // Minimal MPEG1 Layer III frame (128kbps, 44100Hz, stereo)
  // Sync word: 0xFF 0xFB, then frame data filled with zeros
  final frame = Uint8List(417);
  frame[0] = 0xFF;
  frame[1] = 0xFB; // MPEG1, Layer III, no CRC
  frame[2] = 0x90; // 128kbps, 44100Hz
  frame[3] = 0x00; // stereo
  // Rest is zero (silence)

  final result = Uint8List(tagBytes.length + frame.length);
  result.setAll(0, tagBytes);
  result.setAll(tagBytes.length, frame);
  return result;
}

/// Build an ID3v2 tag with the given fields.
Uint8List _buildId3v2Tag({
  required int version,
  String? title,
  String? artist,
  String? album,
}) {
  final frames = BytesBuilder();

  if (title != null) _addTextFrame(frames, 'TIT2', title);
  if (artist != null) _addTextFrame(frames, 'TPE1', artist);
  if (album != null) _addTextFrame(frames, 'TALB', album);

  final frameData = frames.takeBytes();

  // ID3v2 header: "ID3" + version(2) + flags(1) + size(4, syncsafe)
  final size = _syncsafeInt(frameData.length);
  final header = Uint8List(10);
  header[0] = 0x49; // 'I'
  header[1] = 0x44; // 'D'
  header[2] = 0x33; // '3'
  header[3] = version == 3 ? 0x03 : 0x04; // version
  header[4] = 0x00; // flags
  header[5] = size[0];
  header[6] = size[1];
  header[7] = size[2];
  header[8] = size[3];

  final result = Uint8List(header.length + frameData.length);
  result.setAll(0, header);
  result.setAll(header.length, frameData);
  return result;
}

/// Add a text frame (T*** ) to the ID3v2 tag.
void _addTextFrame(BytesBuilder builder, String frameId, String value) {
  final textBytes = Uint8List.fromList([0x00]); // encoding: ISO-8859-1
  final valueBytes = Uint8List.fromList(value.codeUnits);

  final frameData = Uint8List(textBytes.length + valueBytes.length);
  frameData.setAll(0, textBytes);
  frameData.setAll(textBytes.length, valueBytes);

  final frameHeader = Uint8List(10);
  final idBytes = Uint8List.fromList(frameId.codeUnits);
  frameHeader.setAll(0, idBytes);
  final size = _syncsafeInt(frameData.length);
  frameHeader[4] = size[0];
  frameHeader[5] = size[1];
  frameHeader[6] = size[2];
  frameHeader[7] = size[3];
  frameHeader[8] = 0x00; // flags
  frameHeader[9] = 0x00; // flags

  builder.add(frameHeader);
  builder.add(frameData);
}

/// Convert an integer to a 4-byte syncsafe representation.
List<int> _syncsafeInt(int value) {
  return [
    (value >> 21) & 0x7F,
    (value >> 14) & 0x7F,
    (value >> 7) & 0x7F,
    value & 0x7F,
  ];
}
