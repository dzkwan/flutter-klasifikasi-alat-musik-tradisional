import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:skripsi/screen/about_screen.dart';
import 'package:skripsi/provider/tflite.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skripsi/screen/webview_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  var isDialOpen = ValueNotifier<bool>(false);

  @override
  void initState() {
    context.read<Tflite>().loadAsset();
    WidgetsBinding.instance.addObserver(this);

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    context.read<Tflite>().interpreterInstance!.close();
    context.read<Tflite>().img!.delete();
    imageCache.clear();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final tfliteProvider = context.read<Tflite>();
    if (state == AppLifecycleState.resumed &&
        tfliteProvider.isLoading == true) {
      tfliteProvider.changeState(TfliteState.loading);
    }
  }

  Future<void> _deleteCacheDir() async {
    var tempDir = await getTemporaryDirectory();

    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  }

  Future<void> _deleteAppDir() async {
    var appDocDir = await getApplicationDocumentsDirectory();

    if (appDocDir.existsSync()) {
      appDocDir.deleteSync(recursive: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tfliteProvider = context.read<Tflite>();

    return WillPopScope(
      onWillPop: () async {
        if (isDialOpen.value) {
          isDialOpen.value = false;
        } else {
          await _deleteCacheDir();
          await _deleteAppDir();
          return true;
        }
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          title: const Text(
            "Klasifikasi Alat Musik Tradisional",
            style: TextStyle(fontSize: 18),
          ),
          actions: [
            IconButton(
              iconSize: 28,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AboutScreen(),
                ),
              ),
              icon: const Icon(Icons.info_rounded),
            )
          ],
        ),
        body: Center(
          child: Consumer<Tflite>(
            builder: (context, value, _) => gambar(tfliteProvider),
          ),
        ),
        floatingActionButton: SpeedDial(
          spacing: 8,
          overlayColor: Colors.black,
          overlayOpacity: 0.5,
          childMargin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
          elevation: 0,
          icon: Icons.add,
          activeIcon: Icons.close,
          children: [
            SpeedDialChild(
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              elevation: 0,
              labelShadow: [const BoxShadow(color: Colors.transparent)],
              label: "galeri",
              shape: const CircleBorder(),
              child: const Icon(Icons.photo),
              onTap: () => tfliteProvider.btnAction(ImageSource.gallery),
            ),
            SpeedDialChild(
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              labelShadow: [const BoxShadow(color: Colors.transparent)],
              elevation: 0,
              label: "kamera",
              shape: const CircleBorder(),
              child: const Icon(Icons.camera_alt),
              onTap: () => tfliteProvider.btnAction(ImageSource.camera),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        bottomNavigationBar: BottomAppBar(
          clipBehavior: Clip.antiAlias,
          child: Consumer<Tflite>(
            builder: (context, value, _) => hasil(tfliteProvider),
          ),
        ),
      ),
    );
  }

  Widget hasil(Tflite tfliteProvider) {
    final isLoading = tfliteProvider.state == TfliteState.loading;
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (tfliteProvider.result.isNotEmpty) {
      return Center(
        child: TextButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  WebviewScreen(title: tfliteProvider.predLabel!),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "${tfliteProvider.predLabel}",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.blue[800],
                ),
              ),
              const SizedBox(width: 3),
              Icon(
                Icons.open_in_new_rounded,
                size: 20,
                color: Colors.blue[800],
              )
            ],
          ),
        ),
      );
    } else {
      return const Center(
        child: Text(
          "Result here",
          style: TextStyle(fontSize: 16),
        ),
      );
    }
  }

  Widget gambar(Tflite tfliteProvider) {
    final isLoading = tfliteProvider.state == TfliteState.loading;

    if (isLoading) {
      return const CircularProgressIndicator();
    } else if (tfliteProvider.img != null) {
      return Image.file(
        tfliteProvider.img!,
        width: MediaQuery.of(context).size.width,
        fit: BoxFit.contain,
      );
    } else {
      return Container(
        width: MediaQuery.of(context).size.width / 1.2,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onInverseSurface,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Silahkan pilih gambar dari galeri atau ambil foto dengan kamera",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
      );
    }
  }
}
