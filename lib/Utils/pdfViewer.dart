import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';
import 'package:flutter/material.dart';
import 'package:umbrella_care/Constants/colors.dart';
class PdfViewer extends StatefulWidget {
  final String pdfUrl;
  const PdfViewer({Key? key, required this.pdfUrl}) : super(key: key);
  @override
  State<PdfViewer> createState() => _PdfViewerState();
}
class _PdfViewerState extends State<PdfViewer> {
  PDFDocument? document;
  bool _isLoading = true;
  void initializePdf() async{
    document = await PDFDocument.fromURL(widget.pdfUrl);
    setState(() {
      _isLoading = false;
    });
  }
  @override
  void initState() {
    super.initState();
    initializePdf();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
            onPressed:() {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.arrow_back,
              color: primary,
            )
        ),
        title: const Text(
          'Report Pdf',
          style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.w700,
              color: primary
          ),
        ),
      ),
      body: _isLoading? const Center(
        child: CircularProgressIndicator(),
      ) : document!=null? PDFViewer(
        document: document!,
      ) : const Center(
        child: Text(
          'There seems to be some error while opening the report',
          style: TextStyle(
            fontSize: 24,
            color: primary,
            fontWeight: FontWeight.w700
          ),
        ),
      ),
    );
  }
}
