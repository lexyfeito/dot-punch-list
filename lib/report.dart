import 'dart:io';

import 'package:image/image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'entry.dart';

class Report {
  Future<File> createReport(List<Entry> entries) async {
    final pdf = PdfDocument(deflate: zlib.encode);
    final page = PdfPage(pdf, pageFormat: PdfPageFormat.letter);
    final g = page.getGraphics();
    final font = g.defaultFont;
    final top = page.pageFormat.height;

    g.setColor(PdfColor(0.0, 1.0, 1.0));
    g.drawRect(50.0 * PdfPageFormat.mm, top - 80.0 * PdfPageFormat.mm,
        100.0 * PdfPageFormat.mm, 50.0 * PdfPageFormat.mm);
    g.fillPath();

    g.setColor(PdfColor(0.3, 0.3, 0.3));
    g.drawString(font, 12.0, "Hello World!", 10.0 * PdfPageFormat.mm,
        top - 10.0 * PdfPageFormat.mm);

    var image = getImage(entries[0].Images[0], pdf);
    g.drawImage(image, 100.0, 100.0, 80.0);

    Directory tempDir = await getTemporaryDirectory();
    String tempPath = "${tempDir.path}/report.pdf";
    final File file = File(tempPath);
    file.writeAsBytesSync(pdf.save());
    return file;
  }

  Iterable<List<String>> buildRows(List<Entry> entries) {
    var data = new List<List<String>>();
    data.add(<String>['Element', 'Location', 'Title', 'Comments', 'Images', 'Status']);
    entries.forEach((Entry entry) {
      data.add(<String>[entry.element, "lat, lng", entry.Title, entry.Comments, "images", entry.status]);
    });
    return data;
  }

  PdfImage getImage(File file, pdf) {
    var img = decodeImage(file.readAsBytesSync());
    PdfImage image = PdfImage(
        pdf,
        image: img.data.buffer.asUint8List(),
        width: img.width,
        height: img.height);
    return image;
  }

}