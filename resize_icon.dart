import 'dart:io';
import 'package:image/image.dart' as img;

void main() async {
  final iconPath = 'assets/images/ic_launcher.png';
  
  try {
    // Read the image file
    final file = File(iconPath);
    final bytes = await file.readAsBytes();
    
    // Decode image
    final image = img.decodeImage(bytes);
    if (image == null) {
      print('Failed to decode image');
      return;
    }
    
    print('Original size: ${image.width} x ${image.height}');
    
    // Resize to 90% (reduce by 10%)
    final newWidth = (image.width * 0.9).toInt();
    final newHeight = (image.height * 0.9).toInt();
    
    final resized = img.copyResize(image,
        width: newWidth, height: newHeight, interpolation: img.Interpolation.average);
    
    // Create new image with original dimensions, transparent background
    final newImage = img.Image(width: image.width, height: image.height);
    
    // Paste resized image in center
    final pasteX = (image.width - newWidth) ~/ 2;
    final pasteY = (image.height - newHeight) ~/ 2;
    
    img.compositeImage(newImage, resized, dstX: pasteX, dstY: pasteY);
    
    // Encode and save
    final encoded = img.encodePng(newImage);
    await file.writeAsBytes(encoded);
    
    print('Resized to $newWidth x $newHeight');
    print('Centered at ($pasteX, $pasteY)');
    print('Icon saved successfully!');
  } catch (e) {
    print('Error: $e');
  }
}
