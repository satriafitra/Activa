import 'package:flutter/material.dart';

class CurvedGreenShape extends StatelessWidget {
  const CurvedGreenShape({super.key});

  // Warna-warna yang digunakan
  static const Color primaryGreen = Color.fromARGB(255, 107, 206, 155);  // Warna Utama (Lapisan Bawah/Outline)
  static const Color secondaryGreen = Color.fromARGB(255, 97, 190, 142); // Warna Tengah (Lapisan Utama)
  
  static const Color treeCrown = Color(0xFFFDC500);  // Kuning Emas
  static const Color treeTrunk = Color(0xFF2E4057);  // Cokelat
  static const double shapeHeight = 250.0;           // Total tinggi container shape

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: shapeHeight,
      width: double.infinity,
      // Menggunakan Stack untuk menumpuk tiga layer shape (gelombang)
      child: Stack(
        children: [
          // 1. Lapisan Paling Bawah (Primary Green)
          ClipPath(
            clipper: BottomWavyClipper(),
            child: Container(
              height: shapeHeight,
              width: double.infinity,
              color: primaryGreen, 
            ),
          ),

          // 2. Lapisan Tengah (Secondary Green) - Ini adalah bidang hijau utama
          ClipPath(
            clipper: MiddleWavyClipper(),
            child: Container(
              height: shapeHeight,
              width: double.infinity,
              color: secondaryGreen, 
            ),
          ),
          
          // 3. Lapisan Paling Atas (Primary Green) - Memberi efek outline tipis
          ClipPath(
            clipper: TopWavyOutlineClipper(),
            child: Container(
              height: shapeHeight,
              width: double.infinity,
              color: primaryGreen, 
            ),
          ),


          // 4. Pohon (Tree Icon)
          const Align(
            // ************ PERUBAHAN DI SINI ************
            // Mengubah y dari 0.45 menjadi 0.25 (atau nilai lebih kecil) untuk memindahkannya ke atas
            alignment: Alignment(0.85, 0.10), 
            child: TreeIcon(),
          ),
        ],
      ),
    );
  }
}

// Widget Pohon Sederhana
class TreeIcon extends StatelessWidget {
  const TreeIcon({super.key});
  
  static const Color treeCrown = Color(0xFFFDC500);
  static const Color treeTrunk = Color(0xFF2E4057);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: const BoxDecoration(
            color: treeCrown, 
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 4,
          height: 10,
          decoration: BoxDecoration(
            color: treeTrunk, 
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}

// Custom Clipper 1: Lapisan Paling Bawah (Paling Tinggi)
class BottomWavyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    double height = size.height;
    double width = size.width;

    // Start from bottom-left
    path.lineTo(0, height);
    path.lineTo(width, height);
    path.lineTo(width, height * 0.4); 

    // Kurva Gelombang Bawah
    var controlPoint1 = Offset(width * 0.75, height * 0.25);
    var endPoint1 = Offset(width * 0.5, height * 0.35);
    path.quadraticBezierTo(controlPoint1.dx, controlPoint1.dy, endPoint1.dx, endPoint1.dy);

    var controlPoint2 = Offset(width * 0.25, height * 0.45);
    var endPoint2 = Offset(0, height * 0.40);
    path.quadraticBezierTo(controlPoint2.dx, controlPoint2.dy, endPoint2.dx, endPoint2.dy);
    
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Custom Clipper 2: Lapisan Tengah
class MiddleWavyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    double height = size.height;
    double width = size.width;

    // Start from bottom-left
    path.lineTo(0, height);
    path.lineTo(width, height);
    path.lineTo(width, height * 0.45); // Sedikit lebih tinggi dari lapisan bawah

    // Kurva Gelombang Tengah
    var controlPoint1 = Offset(width * 0.75, height * 0.3);
    var endPoint1 = Offset(width * 0.5, height * 0.40);
    path.quadraticBezierTo(controlPoint1.dx, controlPoint1.dy, endPoint1.dx, endPoint1.dy);

    var controlPoint2 = Offset(width * 0.25, height * 0.50);
    var endPoint2 = Offset(0, height * 0.45);
    path.quadraticBezierTo(controlPoint2.dx, controlPoint2.dy, endPoint2.dx, endPoint2.dy);
    
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}


// Custom Clipper 3: Lapisan Paling Atas (Outline Tipis)
class TopWavyOutlineClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    double height = size.height;
    double width = size.width;

    // Start from bottom-left
    path.lineTo(0, height);
    path.lineTo(width, height);
    path.lineTo(width, height * 0.50); // Paling tinggi

    // Kurva Gelombang Atas (Outline)
    var controlPoint1 = Offset(width * 0.75, height * 0.35);
    var endPoint1 = Offset(width * 0.5, height * 0.45);
    path.quadraticBezierTo(controlPoint1.dx, controlPoint1.dy, endPoint1.dx, endPoint1.dy);

    var controlPoint2 = Offset(width * 0.25, height * 0.55);
    var endPoint2 = Offset(0, height * 0.50);
    path.quadraticBezierTo(controlPoint2.dx, controlPoint2.dy, endPoint2.dx, endPoint2.dy);
    
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
