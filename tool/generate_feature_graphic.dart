// ignore_for_file: avoid_print
/// Generates a 1024x500 feature graphic for Google Play Store.
/// Run: dart run tool/generate_feature_graphic.dart
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';

void main() {
  const w = 1024;
  const h = 500;

  final pixels = Uint8List(w * h * 4);

  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      final i = (y * w + x) * 4;

      // Gradient: paprika-dark (#6E002D) -> charcoal (#1A1A2E) -> charcoal-deep (#0F172A)
      final t = x / w;
      if (t < 0.5) {
        final s = t * 2;
        pixels[i] = _lerp(0x6E, 0x1A, s);
        pixels[i + 1] = _lerp(0x00, 0x1A, s);
        pixels[i + 2] = _lerp(0x2D, 0x2E, s);
      } else {
        final s = (t - 0.5) * 2;
        pixels[i] = _lerp(0x1A, 0x0F, s);
        pixels[i + 1] = _lerp(0x1A, 0x17, s);
        pixels[i + 2] = _lerp(0x2E, 0x2A, s);
      }
      pixels[i + 3] = 255;

      // Draw decorative circle (top-right)
      final cx = x - w * 0.85;
      final cy = y - h * 0.15;
      final circDist = (cx * cx + cy * cy);
      if (circDist < 200 * 200 && circDist > 180 * 180) {
        final alpha = 0.08;
        pixels[i] = _blend(pixels[i], 255, alpha);
        pixels[i + 1] = _blend(pixels[i + 1], 255, alpha);
        pixels[i + 2] = _blend(pixels[i + 2], 255, alpha);
      }

      // Draw gold accent line
      if (y >= h * 0.92 && y <= h * 0.93) {
        final lineAlpha = 0.3 * (1.0 - (x / w - 0.1).abs() * 3).clamp(0.0, 1.0);
        if (x > w * 0.05 && x < w * 0.45) {
          pixels[i] = _blend(pixels[i], 0xEF, lineAlpha);
          pixels[i + 1] = _blend(pixels[i + 1], 0xBF, lineAlpha);
          pixels[i + 2] = _blend(pixels[i + 2], 0x04, lineAlpha);
        }
      }
    }
  }

  final png = _encodePng(w, h, pixels);
  final dir = Directory('assets/store');
  if (!dir.existsSync()) dir.createSync(recursive: true);
  File('assets/store/feature_graphic.png').writeAsBytesSync(png);
  print('Generated feature_graphic.png (${png.length} bytes)');
}

int _lerp(int a, int b, double t) => (a + (b - a) * t).round().clamp(0, 255);
int _blend(int bg, int fg, double alpha) =>
    ((bg * (1 - alpha)) + (fg * alpha)).round().clamp(0, 255);

Uint8List _encodePng(int w, int h, Uint8List rgba) {
  final rawRows = BytesBuilder();
  for (var y = 0; y < h; y++) {
    rawRows.addByte(0);
    rawRows.add(rgba.sublist(y * w * 4, (y + 1) * w * 4));
  }
  final rawData = rawRows.toBytes();
  final zlibData = _zlibStore(rawData);
  final out = BytesBuilder();
  out.add([137, 80, 78, 71, 13, 10, 26, 10]);
  final ihdr = BytesBuilder();
  ihdr.add(_uint32(w));
  ihdr.add(_uint32(h));
  ihdr.addByte(8);
  ihdr.addByte(6);
  ihdr.addByte(0);
  ihdr.addByte(0);
  ihdr.addByte(0);
  _writeChunk(out, 'IHDR', ihdr.toBytes());
  _writeChunk(out, 'IDAT', zlibData);
  _writeChunk(out, 'IEND', Uint8List(0));
  return out.toBytes();
}

void _writeChunk(BytesBuilder out, String type, Uint8List data) {
  out.add(_uint32(data.length));
  final typeBytes = ascii.encode(type);
  out.add(typeBytes);
  out.add(data);
  final crcData = BytesBuilder();
  crcData.add(typeBytes);
  crcData.add(data);
  out.add(_uint32(_crc32(crcData.toBytes())));
}

Uint8List _uint32(int v) => Uint8List(4)
  ..[0] = (v >> 24) & 0xFF
  ..[1] = (v >> 16) & 0xFF
  ..[2] = (v >> 8) & 0xFF
  ..[3] = v & 0xFF;

Uint8List _zlibStore(Uint8List data) {
  final out = BytesBuilder();
  out.addByte(0x78);
  out.addByte(0x01);
  var offset = 0;
  while (offset < data.length) {
    final remaining = data.length - offset;
    final blockSize = remaining > 65535 ? 65535 : remaining;
    final isLast = offset + blockSize >= data.length;
    out.addByte(isLast ? 1 : 0);
    out.addByte(blockSize & 0xFF);
    out.addByte((blockSize >> 8) & 0xFF);
    out.addByte((~blockSize) & 0xFF);
    out.addByte(((~blockSize) >> 8) & 0xFF);
    out.add(data.sublist(offset, offset + blockSize));
    offset += blockSize;
  }
  out.add(_uint32(_adler32(data)));
  return out.toBytes();
}

int _adler32(Uint8List data) {
  var a = 1;
  var b = 0;
  for (final byte in data) {
    a = (a + byte) % 65521;
    b = (b + a) % 65521;
  }
  return (b << 16) | a;
}

int _crc32(Uint8List data) {
  var crc = 0xFFFFFFFF;
  for (final byte in data) {
    crc ^= byte;
    for (var j = 0; j < 8; j++) {
      crc = (crc & 1 == 1) ? (crc >> 1) ^ 0xEDB88320 : crc >> 1;
    }
  }
  return crc ^ 0xFFFFFFFF;
}
