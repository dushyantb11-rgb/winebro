// ignore_for_file: avoid_print
/// Run: dart run tool/generate_icons.dart
/// Generates a simple app icon PNG from scratch using pure Dart.
/// The icon is a dark background with the WineBro "WB" monogram.
///
/// For a production icon, replace assets/icon/app_icon.png with
/// a designer-created 1024x1024 PNG, then run:
///   dart run flutter_launcher_icons
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';

// Minimal PNG encoder — creates a simple solid-color icon with text overlay
void main() {
  const size = 1024;

  // Create pixel data (RGBA)
  final pixels = Uint8List(size * size * 4);

  // Background: charcoal #1A1A2E
  for (var y = 0; y < size; y++) {
    for (var x = 0; x < size; x++) {
      final i = (y * size + x) * 4;

      // Gradient: #1A1A2E at top -> #0F172A at bottom
      final t = y / size;
      pixels[i] = (0x1A + (0x0F - 0x1A) * t).round().clamp(0, 255); // R
      pixels[i + 1] = (0x1A + (0x17 - 0x1A) * t).round().clamp(0, 255); // G
      pixels[i + 2] = (0x2E + (0x2A - 0x2E) * t).round().clamp(0, 255); // B
      pixels[i + 3] = 255; // A

      // Draw paprika circle in center (wine glass abstraction)
      final dx = x - size / 2;
      final dy = y - size * 0.38;
      final dist = (dx * dx / (140 * 140) + dy * dy / (180 * 180));
      if (dist < 1.0) {
        final alpha = (1.0 - dist).clamp(0.0, 1.0);
        pixels[i] = _blend(pixels[i], 0x93, alpha);
        pixels[i + 1] = _blend(pixels[i + 1], 0x00, alpha);
        pixels[i + 2] = _blend(pixels[i + 2], 0x3C, alpha);
      }

      // Draw lighter wine level inside glass
      final dy2 = y - size * 0.42;
      final dist2 = (dx * dx / (110 * 110) + dy2 * dy2 / (120 * 120));
      if (dist2 < 1.0) {
        final alpha = (1.0 - dist2).clamp(0.0, 1.0) * 0.5;
        pixels[i] = _blend(pixels[i], 0xB8, alpha);
        pixels[i + 1] = _blend(pixels[i + 1], 0x14, alpha);
        pixels[i + 2] = _blend(pixels[i + 2], 0x5E, alpha);
      }

      // Draw stem
      if (x >= size / 2 - 14 && x <= size / 2 + 14 &&
          y >= size * 0.54 && y <= size * 0.72) {
        pixels[i] = 0x93;
        pixels[i + 1] = 0x00;
        pixels[i + 2] = 0x3C;
      }

      // Draw base (ellipse)
      final bx = x - size / 2;
      final by = y - size * 0.74;
      if (bx * bx / (90 * 90) + by * by / (18 * 18) < 1.0) {
        pixels[i] = 0x93;
        pixels[i + 1] = 0x00;
        pixels[i + 2] = 0x3C;
      }
    }
  }

  // Encode as PNG
  final png = _encodePng(size, size, pixels);
  File('assets/icon/app_icon.png').writeAsBytesSync(png);
  File('assets/icon/app_icon_foreground.png').writeAsBytesSync(png);
  print('Generated app_icon.png (${png.length} bytes)');
}

int _blend(int bg, int fg, double alpha) {
  return ((bg * (1 - alpha)) + (fg * alpha)).round().clamp(0, 255);
}

/// Minimal PNG encoder (uncompressed for simplicity)
Uint8List _encodePng(int w, int h, Uint8List rgba) {
  // Build IDAT data (raw, no compression — uses zlib store)
  final rawRows = BytesBuilder();
  for (var y = 0; y < h; y++) {
    rawRows.addByte(0); // Filter: None
    rawRows.add(rgba.sublist(y * w * 4, (y + 1) * w * 4));
  }
  final rawData = rawRows.toBytes();

  // Zlib "store" (no compression) wrapper
  final zlibData = _zlibStore(rawData);

  final out = BytesBuilder();

  // PNG signature
  out.add([137, 80, 78, 71, 13, 10, 26, 10]);

  // IHDR
  final ihdr = BytesBuilder();
  ihdr.add(_uint32(w));
  ihdr.add(_uint32(h));
  ihdr.addByte(8); // bit depth
  ihdr.addByte(6); // RGBA
  ihdr.addByte(0); // compression
  ihdr.addByte(0); // filter
  ihdr.addByte(0); // interlace
  _writeChunk(out, 'IHDR', ihdr.toBytes());

  // IDAT
  _writeChunk(out, 'IDAT', zlibData);

  // IEND
  _writeChunk(out, 'IEND', Uint8List(0));

  return out.toBytes();
}

void _writeChunk(BytesBuilder out, String type, Uint8List data) {
  out.add(_uint32(data.length));
  final typeBytes = ascii.encode(type);
  out.add(typeBytes);
  out.add(data);
  // CRC32 of type + data
  final crcData = BytesBuilder();
  crcData.add(typeBytes);
  crcData.add(data);
  out.add(_uint32(_crc32(crcData.toBytes())));
}

Uint8List _uint32(int v) {
  return Uint8List(4)
    ..[0] = (v >> 24) & 0xFF
    ..[1] = (v >> 16) & 0xFF
    ..[2] = (v >> 8) & 0xFF
    ..[3] = v & 0xFF;
}

/// Zlib store (no compression) — wraps raw data in zlib format
Uint8List _zlibStore(Uint8List data) {
  final out = BytesBuilder();
  // Zlib header: CMF=0x78, FLG=0x01
  out.addByte(0x78);
  out.addByte(0x01);

  // Deflate stored blocks
  var offset = 0;
  while (offset < data.length) {
    final remaining = data.length - offset;
    final blockSize = remaining > 65535 ? 65535 : remaining;
    final isLast = offset + blockSize >= data.length;

    out.addByte(isLast ? 1 : 0); // BFINAL + BTYPE=00 (stored)
    out.addByte(blockSize & 0xFF);
    out.addByte((blockSize >> 8) & 0xFF);
    out.addByte((~blockSize) & 0xFF);
    out.addByte(((~blockSize) >> 8) & 0xFF);
    out.add(data.sublist(offset, offset + blockSize));
    offset += blockSize;
  }

  // Adler-32 checksum
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
      if (crc & 1 == 1) {
        crc = (crc >> 1) ^ 0xEDB88320;
      } else {
        crc >>= 1;
      }
    }
  }
  return crc ^ 0xFFFFFFFF;
}
