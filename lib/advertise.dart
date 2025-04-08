import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';
import 'package:uuid/uuid.dart';

class AdvertisePage extends StatefulWidget {
  const AdvertisePage({super.key});

  @override
  State<AdvertisePage> createState() => _AdvertisePageState();
}

class _AdvertisePageState extends State<AdvertisePage> {
  final FlutterBlePeripheral flutterBlePeripheral = FlutterBlePeripheral();
  final String uuid = const Uuid().v4();

  bool isAdvertising = false;
  bool isLoading = false;
  bool _isSupported = false;

  @override
  void dispose() {
    flutterBlePeripheral.stop();
    super.dispose();
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  Future<void> init() async {
    try {
      setState(() {
        isLoading = true;
      });
      final isSupported = await flutterBlePeripheral.isSupported;

      setState(() {
        _isSupported = isSupported;
        isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(": $e")));
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("UUID Yayını")),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : _isSupported
              ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text("Yayınlanan UUID:\n$uuid",
                          style: const TextStyle(fontSize: 16),
                          textAlign: TextAlign.center),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed:
                            isAdvertising ? stopAdvertising : startAdvertising,
                        child: Text(
                            isAdvertising ? "Yayını Durdur" : "Yayına Başla"),
                      ),
                      StreamBuilder(
                        stream: FlutterBlePeripheral().onPeripheralStateChanged,
                        initialData: PeripheralState.unknown,
                        builder: (BuildContext context,
                            AsyncSnapshot<dynamic> snapshot) {
                          return Text(
                            'State: ${(snapshot.data as PeripheralState).name}',
                          );
                        },
                      ),
                    ],
                  ),
                )
              : Center(
                  child: Text("Advertise özelliği desteklenmiyor"),
                ),
    );
  }

  Future<void> startAdvertising() async {
    try {
      setState(() {
        isLoading = true;
      });
      //? Low Power Destekliyor
      final advertiseData = AdvertiseData(
        serviceUuid: uuid, // bu uuid ikisinde de çalışıyor
        // manufacturerId: 1234, // sadece android
        // manufacturerData: Uint8List.fromList([1, 2, 3, 4]), // sadece android
        //  serviceData: [1, 2, 3],
        // serviceDataUuid: serviceDataUuid,
        // serviceSolicitationUuid: serviceSolicitationUuid,
      );

      await flutterBlePeripheral.start(
          advertiseData: advertiseData,
          advertiseSettings: AdvertiseSettings(connectable: true));

      setState(() {
        isAdvertising = true;
        isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Advertise başlatılamadı: $e")));
      setState(() {
        isLoading = false;
      });
      print(e.toString());
    }
  }

  Future<void> stopAdvertising() async {
    try {
      setState(() {
        isLoading = true;
      });
      await flutterBlePeripheral.stop();
      setState(() {
        isAdvertising = false;
        isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Advertise durdurulamadı: $e"),
        ),
      );
      setState(() {
        isLoading = false;
      });
    }
  }
}
