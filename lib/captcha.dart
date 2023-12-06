import 'dart:math';
import 'dart:ui' as ui; // Import ui library for TextPainter

import 'package:flutter/material.dart';

class Captcha extends StatefulWidget {
  double lebar, tinggi;
  int jumlahTitikMaks = 10;

  var stokWarna = {
    'merah': Color(0xa9ec1c1c),
    'hijau': Color(0xa922b900),
    'hitam': Color(0xa9000000),
  };
  var warnaTerpakai = {};
  String warnaYangDitanyakan = 'merah';

  Captcha(this.lebar, this.tinggi);

  @override
  State<StatefulWidget> createState() => _CaptchaState();

  bool benarkahJawaban(int jawaban) {
    return jawaban == warnaTerpakai[warnaYangDitanyakan];
  }
}

class _CaptchaState extends State<Captcha> {
  var random = Random();
  TextEditingController jawabanController = TextEditingController();
  bool jawabanBenar = false;

  @override
  void initState() {
    super.initState();
    buatPertanyaan();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: widget.lebar,
            height: widget.tinggi,
            child: CustomPaint(
              painter: jawabanBenar ? BenarPainter() : CaptchaPainter(widget),
            ),
          ),
          SizedBox(height: 20),
          TextField(
            controller: jawabanController,
            keyboardType: TextInputType.number,
            enabled:
                !jawabanBenar, // Disable TextField if the answer is correct
            decoration: InputDecoration(
              labelText: 'Jawaban',
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: jawabanBenar ? null : periksaJawaban,
            child: Text('Periksa Jawaban'),
          ),
          SizedBox(height: 20),
          Text(
            jawabanBenar ? 'BENAR!' : '',
            style: TextStyle(
              color: Colors.green,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  void buatPertanyaan() {
    setState(() {
      widget.warnaYangDitanyakan =
          widget.stokWarna.keys.elementAt(random.nextInt(3));
    });
  }

  void periksaJawaban() {
    int jawabanPengguna = int.tryParse(jawabanController.text) ?? 0;

    setState(() {
      jawabanBenar = widget.benarkahJawaban(jawabanPengguna);

      if (jawabanBenar) {
        // If the answer is correct, disable the TextField and the button
        jawabanController.clear();
        jawabanController.clearComposing();
      } else {
        // If the answer is wrong, reset the points and generate a new question
        buatPertanyaan();
      }
    });
  }
}

class CaptchaPainter extends CustomPainter {
  Captcha captcha;
  var random = Random();

  CaptchaPainter(this.captcha);

  @override
  void paint(Canvas canvas, Size size) {
    var catBingkai = Paint()
      ..color = Color(0xFF000000)
      ..style = PaintingStyle.stroke;
    canvas.drawRect(
        Offset(0, 0) & Size(captcha.lebar, captcha.tinggi), catBingkai);

    captcha.stokWarna.forEach((key, value) {
      var jumlah = random.nextInt(captcha.jumlahTitikMaks + 1);
      if (jumlah == 0) jumlah = 1;
      captcha.warnaTerpakai[key] = jumlah;

      for (var i = 0; i < jumlah; i++) {
        var catTitik = Paint()
          ..color = value
          ..style = PaintingStyle.fill;
        canvas.drawCircle(
          Offset(random.nextDouble() * captcha.lebar,
              random.nextDouble() * captcha.tinggi),
          6,
          catTitik,
        );
      }
    });
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class BenarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var catBingkai = Paint()
      ..color = Color(0xFF000000)
      ..style = PaintingStyle.stroke;
    canvas.drawRect(Offset(0, 0) & size, catBingkai);

    var catText = ui.ParagraphBuilder(ui.ParagraphStyle(
      textAlign: TextAlign.center,
      fontSize: 30.0,
      textDirection: TextDirection.ltr,
    ))
      ..addText('BENAR');

    var paragraph = catText.build();
    paragraph.layout(ui.ParagraphConstraints(width: size.width));
    canvas.drawParagraph(
        paragraph,
        Offset((size.width - paragraph.width) / 2,
            (size.height - paragraph.height) / 2));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
