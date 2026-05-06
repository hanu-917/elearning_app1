import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:microsoft_viewer/models/presentation.dart';
import 'package:microsoft_viewer/models/relationship.dart';
import 'package:xml/xml.dart' as xml;

// We can still use models from the original package
import 'package:microsoft_viewer/models/presentation_paragraph.dart';
import 'package:microsoft_viewer/models/presentation_shape.dart';
import 'package:microsoft_viewer/models/presentation_text.dart';
import 'package:microsoft_viewer/models/presentation_text_box.dart';
import 'package:microsoft_viewer/models/slide.dart';

/// Class for processing .pptx files (Custom to remove horizontal scroll)
class CustomPresentationProcessor {
  void getPresentationDetails(ArchiveFile presentationFile, Presentation presentation) {
    final fileContent = utf8.decode(presentationFile.content);
    final presentationDoc = xml.XmlDocument.parse(fileContent);
    var slidesRoot = presentationDoc.findAllElements("p:sldIdLst");
    if (slidesRoot.isNotEmpty) {
      var slides = slidesRoot.first.findAllElements("p:sldId");
      if (slides.isNotEmpty) {
        for (var slide in slides) {
          int id = 0;
          String rId = "";
          var tempId = slide.getAttribute("id");
          if (tempId != null) id = int.parse(tempId);
          var tempRid = slide.getAttribute("r:id");
          if (tempRid != null) rId = tempRid;
          presentation.slides.add(Slide(id, rId, ""));
        }
      }
    }
    var masterSlidesRoot = presentationDoc.findAllElements("p:sldMasterIdLst");
    if (masterSlidesRoot.isNotEmpty) {
      var masterSlides = masterSlidesRoot.first.findAllElements("p:sldMasterId");
      if (masterSlides.isNotEmpty) {
        for (var slide in masterSlides) {
          int id = 0;
          String rId = "";
          var tempId = slide.getAttribute("id");
          if (tempId != null) id = int.parse(tempId);
          var tempRid = slide.getAttribute("r:id");
          if (tempRid != null) rId = tempRid;
          presentation.masterSlides.add(Slide(id, rId, ""));
        }
      }
    }
  }

  void getAllShapes(ArchiveFile presentationFile, Slide slide) {
    final fileContent = utf8.decode(presentationFile.content);
    final diagramDoc = xml.XmlDocument.parse(fileContent);
    var diagramsRoot = diagramDoc.findAllElements("dsp:sp");
    if (diagramsRoot.isNotEmpty) {
      for (var diagram in diagramsRoot) {
        String id = "";
        String text = "";
        double offsety = 0;
        Offset offset = const Offset(0, 0);
        Size size = const Size(0, 0);
        var tempId = diagram.getAttribute("modelId");
        if (tempId != null) id = tempId;
        var checkTxtBody = diagram.findAllElements("dsp:txBody");
        if (checkTxtBody.isNotEmpty) {
          var checkParaElement = checkTxtBody.first.findAllElements("a:p");
          if (checkParaElement.isNotEmpty) {
            var txtElement = checkParaElement.first.findAllElements("a:t");
            if (txtElement.isNotEmpty) text = txtElement.first.innerText;
          }
        }
        var checkSlFrm = diagram.findAllElements("a:xfrm");
        if (checkSlFrm.isNotEmpty) {
          var checkOffE = checkSlFrm.first.findAllElements("a:off");
          if (checkOffE.isNotEmpty) {
            var tempY = checkOffE.first.getAttribute("y");
            if (tempY != null) offsety = double.parse(tempY);
          }
        }
        var checkTxFrm = diagram.findAllElements("dsp:txXfrm");
        if (checkTxFrm.isNotEmpty) {
          var checkOffE = checkTxFrm.first.findAllElements("a:off");
          if (checkOffE.isNotEmpty) {
            double x = 0;
            double y = 0;
            var tempX = checkOffE.first.getAttribute("x");
            if (tempX != null) x = double.parse(tempX);
            var tempY = checkOffE.first.getAttribute("y");
            if (tempY != null) y = double.parse(tempY);
            offset = Offset(x, y + offsety);
          }
          var checkExtE = checkTxFrm.first.findAllElements("a:ext");
          if (checkExtE.isNotEmpty) {
            double x = 0;
            double y = 0;
            var tempX = checkExtE.first.getAttribute("cx");
            if (tempX != null) x = double.parse(tempX);
            var tempY = checkExtE.first.getAttribute("cy");
            if (tempY != null) y = double.parse(tempY);
            size = Size(x, y);
          }
        }
        slide.presentationShapes.add(PresentationShape(id, text, offset, size));
      }
    }
  }

  void readAllSlides(Presentation presentation, List<Relationship> relationShips, Archive archive, String presentationOutputDirectory) {
    for (int i = 0; i < presentation.slides.length; i++) {
      var slideRelation = relationShips.firstWhereOrNull((rel) => rel.id == presentation.slides[i].rId);
      if (slideRelation != null) {
        var slideFile = archive.singleWhere((archiveFile) => archiveFile.name.endsWith(slideRelation.target));
        if (slideFile.isFile) {
          final fileContent = utf8.decode(slideFile.content);
          final slideDoc = xml.XmlDocument.parse(fileContent);
          presentation.slides[i].fileName = slideFile.name.split("/").last;
          var spElement = slideDoc.findAllElements("p:sp");
          if (spElement.isNotEmpty) {
            for (int j = 0; j < spElement.length; j++) {
              Offset offset = const Offset(0, 0);
              Size size = const Size(0, 0);
              double offsetY = 0;
              double offsetX = 0;
              if (spElement.elementAt(j).parentElement != null && spElement.elementAt(j).parentElement?.name.toString() == "p:grpSp") {
                var grpSpPr = spElement.elementAt(j).parentElement?.findAllElements("p:grpSpPr");
                if (grpSpPr != null && grpSpPr.isNotEmpty) {
                  var chckOff = grpSpPr.first.findAllElements("a:off");
                  if (chckOff.isNotEmpty) {
                    var offX = chckOff.first.getAttribute("x");
                    if (offX != null) offsetX = double.parse(offX);
                    var offY = chckOff.first.getAttribute("y");
                    if (offY != null) offsetY = double.parse(offY);
                  }
                }
              }
              var xfrmElement = spElement.elementAt(j).findAllElements("a:xfrm");
              if (xfrmElement.isNotEmpty) {
                var chkOff = xfrmElement.first.findAllElements("a:off");
                if (chkOff.isNotEmpty) {
                  var offX = chkOff.first.getAttribute("x");
                  var offY = chkOff.first.getAttribute("y");
                  if (offX != null && offY != null) offset = Offset(double.parse(offX) + offsetX, double.parse(offY) + offsetY);
                }
                var chkExt = xfrmElement.first.findAllElements("a:ext");
                if (chkExt.isNotEmpty) {
                  var extX = chkExt.first.getAttribute("cx");
                  var extY = chkExt.first.getAttribute("cy");
                  if (extX != null && extY != null) size = Size(double.parse(extX), double.parse(extY));
                }
              }
              List<PresentationParagraph> presentationParagraphs = [];
              spElement.elementAt(j).findAllElements("p:txBody").forEach((txt) {
                var chkPara = txt.findAllElements("a:p");
                if (chkPara.isNotEmpty) {
                  for (var para in chkPara) {
                    List<PresentationText> presentationTexts = [];
                    var chkR = para.findAllElements("a:r");
                    if (chkR.isNotEmpty) {
                      for (var r in chkR) {
                        double fontSize = 20;
                        var rPr = r.findAllElements("a:rPr");
                        if (rPr.isNotEmpty) {
                          var tempSize = rPr.first.getAttribute("sz");
                          if (tempSize != null) fontSize = double.parse(tempSize) / 150;
                        }
                        var text = "";
                        r.findAllElements("a:t").forEach((txt2) => text += txt2.innerText);
                        if (text.isNotEmpty) presentationTexts.add(PresentationText(text, fontSize));
                      }
                    }
                    if (presentationTexts.isNotEmpty) {
                      PresentationParagraph paragraph = PresentationParagraph();
                      paragraph.textSpans = presentationTexts;
                      presentationParagraphs.add(paragraph);
                    }
                  }
                }
              });
              if (presentationParagraphs.isNotEmpty) {
                PresentationTextBox presentationTextBox = PresentationTextBox(offset, size);
                presentationTextBox.presentationParas = presentationParagraphs;
                presentation.slides[i].presentationTextBoxes.add(presentationTextBox);
              }
            }
          }

          var checkSlideRel = archive.singleWhereOrNull((archiveFile) => archiveFile.name.endsWith("${presentation.slides[i].fileName}.rels"));
          if (checkSlideRel != null) {
            List<Relationship> slideLevelRelations = [];
            final fileContentRel = utf8.decode(checkSlideRel.content);
            String drawingTarget = "";
            String layoutTarget = "";
            final documentRel = xml.XmlDocument.parse(fileContentRel);
            final relationshipsElement = documentRel.findAllElements("Relationship");
            for (var rel in relationshipsElement) {
              if (rel.getAttribute("Id") != null) slideLevelRelations.add(Relationship(rel.getAttribute("Id").toString(), rel.getAttribute("Target").toString()));
              if (rel.getAttribute("Type") != null && rel.getAttribute("Type")!.endsWith("relationships/diagramDrawing")) drawingTarget = rel.getAttribute("Target").toString().replaceAll("../", "");
              if (rel.getAttribute("Type") != null && rel.getAttribute("Type")!.endsWith("relationships/slideLayout")) layoutTarget = rel.getAttribute("Target").toString().replaceAll("../", "");
            }
            if (drawingTarget.isNotEmpty) {
              var diagramFile = archive.singleWhereOrNull((archiveFile) => archiveFile.name.endsWith(drawingTarget));
              if (diagramFile != null) getAllShapes(diagramFile, presentation.slides[i]);
            }
            if (layoutTarget.isNotEmpty) {
              var checkLayoutRel = archive.singleWhereOrNull((archiveFile) => archiveFile.name.endsWith("${layoutTarget.split("/").last}.rels"));
              List<Relationship> layoutRelations = [];
              if (checkLayoutRel != null) {
                final fileContentL = utf8.decode(checkLayoutRel.content);
                final documentL = xml.XmlDocument.parse(fileContentL);
                for (var rel in documentL.findAllElements("Relationship")) {
                  if (rel.getAttribute("Id") != null) layoutRelations.add(Relationship(rel.getAttribute("Id").toString(), rel.getAttribute("Target").toString()));
                }
              }
              var layoutFile = archive.singleWhereOrNull((archiveFile) => archiveFile.name.endsWith(layoutTarget));
              if (layoutFile != null) {
                final fileContentLF = utf8.decode(layoutFile.content);
                final documentLF = xml.XmlDocument.parse(fileContentLF);
                var chkBg = documentLF.findAllElements("p:bg");
                if (chkBg.isNotEmpty) {
                  var chkBlip = chkBg.first.findAllElements("a:blip");
                  if (chkBlip.isNotEmpty) {
                    var chkEmbed = chkBlip.first.getAttribute("r:embed");
                    if (chkEmbed != null) {
                      var layoutRelTarget = layoutRelations.firstWhereOrNull((rel) => rel.id == chkEmbed);
                      if (layoutRelTarget != null) presentation.slides[i].backgroundImagePath = "$presentationOutputDirectory/${layoutRelTarget.target.split("/").last}";
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  Future<List<Widget>> displayPresentation(Presentation presentation, double screenWidth) async {
    List<Widget> tempList = [];
    List<Widget> slideWidgets = [];
    for (int i = 0; i < presentation.slides.length; i++) {
      List<Widget> tempSlideWidget = await compute(getSlideDetails, {
        'slide': presentation.slides[i],
        'screenWidth': screenWidth,
      });
      slideWidgets.addAll(tempSlideWidget);
    }
    tempList.add(Container(
      color: Colors.grey[200],
      width: screenWidth,
      child: Column(children: slideWidgets),
    ));
    return tempList;
  }

  static List<Widget> getSlideDetails(Map<String, dynamic> params) {
    Slide slide = params['slide'];
    double screenWidth = params['screenWidth'];
    
    List<Widget> tempSlide = [];
    List<Widget> tempShapes = [];
    List<Widget> slideWidget = [];
    double maxWidth = 600;
    double maxHeight = 450;
    int divisionFactor = 12700;

    for (int j = 0; j < slide.presentationTextBoxes.length; j++) {
       double dx = slide.presentationTextBoxes[j].offset.dx / divisionFactor;
       double dy = slide.presentationTextBoxes[j].offset.dy / divisionFactor;
       double w = slide.presentationTextBoxes[j].size.width / divisionFactor;
       double h = slide.presentationTextBoxes[j].size.height / divisionFactor;
       
       if (dx + w > maxWidth) maxWidth = dx + w;
       if (dy + h > maxHeight) maxHeight = dy + h;

       List<Widget> textBoxTexts = [];
       for (var para in slide.presentationTextBoxes[j].presentationParas) {
         List<TextSpan> textSpans = [];
         for (var span in para.textSpans) {
           textSpans.add(TextSpan(text: span.text, style: TextStyle(fontSize: span.fontSize, color: Colors.black)));
         }
         textBoxTexts.add(RichText(text: TextSpan(children: textSpans)));
       }
       
       tempShapes.add(Positioned(
         top: dy,
         left: dx,
         child: SizedBox(
           height: h != 0 ? h : null,
           width: w != 0 ? w : null,
           child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: textBoxTexts),
         )
       ));
    }
    
    for (int j = 0; j < slide.presentationShapes.length; j++) {
       double dx = slide.presentationShapes[j].offset.dx / divisionFactor;
       double dy = slide.presentationShapes[j].offset.dy / divisionFactor;
       double w = slide.presentationShapes[j].size.width / divisionFactor;
       double h = slide.presentationShapes[j].size.height / divisionFactor;
       
       if (dx + w > maxWidth) maxWidth = dx + w;
       if (dy + h > maxHeight) maxHeight = dy + h;

       tempShapes.add(Positioned(
         top: dy,
         left: dx,
         child: Container(
           decoration: BoxDecoration(border: Border.all(color: Colors.blue.withOpacity(0.3))),
           height: h,
           width: w,
           child: Center(child: Text(slide.presentationShapes[j].text, style: const TextStyle(fontSize: 10))),
         )
       ));
    }

    if (tempShapes.isNotEmpty) {
      tempSlide.add(SizedBox(
        height: maxHeight,
        width: maxWidth,
        child: Stack(children: tempShapes),
      ));
    }

    // FIX: Optimized to ensure zero horizontal overflow
    slideWidget.add(Container(
      constraints: BoxConstraints(maxWidth: screenWidth),
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 3))],
        image: slide.backgroundImagePath != "" 
          ? DecorationImage(image: FileImage(File(slide.backgroundImagePath)), fit: BoxFit.fill) 
          : null,
      ),
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: maxWidth,
          height: maxHeight,
          child: Stack(children: tempShapes),
        ),
      ),
    ));
    
    return slideWidget;
  }
}
