import 'package:flutter/material.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';

class DocumentScannerView extends StatelessWidget {
  final Function(List<String>) onScanned;

  const DocumentScannerView({super.key, required this.onScanned});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan Document")),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            try {
              List<String>? scannedImages =
                  await CunningDocumentScanner.getPictures();

              if (scannedImages != null && scannedImages.isNotEmpty) {
                onScanned(scannedImages);
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No documents scanned.')),
                );
              }

            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error scanning: $e')),
              );
            }
          },
          child: const Text("Start Scanning"),
        ),
      ),
    );
  }
}