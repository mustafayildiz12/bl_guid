import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  List<ScanResult> results = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  Future<void> _startScan() async {
    try {
      setState(() {
        isLoading = true;
      });
      await [
        Permission.location,
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
      ].request();

      // 10 saniyede 1 işlem tarama yapıyoruz
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 3));
      FlutterBluePlus.scanResults.listen((scanResults) {
        setState(() {
          results = scanResults;
        });
        if (scanResults.isNotEmpty) {
          print(scanResults.first);
        }
      });
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Scan başlatılamadı: $e")));
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    FlutterBluePlus.stopScan();
    super.dispose();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("UUID Tarayıcı")),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: results.length,
              itemBuilder: (context, index) {
                final device = results[index].device;
                final advData = results[index].advertisementData;

                return ListTile(
                  title: Text(device.platformName.isNotEmpty
                      ? device.platformName
                      : "Bilinmeyen Cihaz"),
                  subtitle: Text(
                      "UUID: ${advData.serviceUuids.isNotEmpty ? advData.serviceUuids.join(', ') : 'Yok'}"),
                  leading: Text(advData.advName),
                );
              },
            ),
    );
  }
}
