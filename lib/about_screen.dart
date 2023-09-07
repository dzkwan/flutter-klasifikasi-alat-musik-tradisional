import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        title: const Text(
          "Tentang Aplikasi",
          style: TextStyle(fontSize: 18),
        ),
      ),
      body: Container(
        margin: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onInverseSurface,
                borderRadius: const BorderRadius.all(Radius.circular(10)),
              ),
              child: const Text(
                """ Aplikasi ini dibuat sebagai demo aplikasi klasifikasi alat musik tradisional yang dapat digunakan untuk mendeteksi alat musik tradisional\n
  Untuk saat ini, aplikasi hanya dapat mendeteksi alat musik tradisional yang terdiri dari:
1. Angklung
2. Kecapi
3. Kolintang
4. Saluang
5. Sasando""",
                textAlign: TextAlign.justify,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
