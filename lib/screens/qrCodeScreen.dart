import 'package:barberbud_rider_project/resources/constant.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';

class QrCodeScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PrimaryColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: SecondaryColor,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        backgroundColor: PrimaryColor,
        title: Text(
          'QR Code',
          style: TextStyle(
            color: SecondaryColor,
          ),
        ),
      ),
      body: Center(
        child: BarcodeWidget(
          barcode: Barcode.qrCode(
            errorCorrectLevel: BarcodeQRCorrectionLevel.high,
          ),
          color: SecondaryColor,
          data: "myapp://transfer",
          width: 250,
          height: 250,
        ),
      ),
    );
  }
}
