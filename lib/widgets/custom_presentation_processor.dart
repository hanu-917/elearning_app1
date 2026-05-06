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
  static final Map<int, Size> _slideSizes = {};

  void getPresentationDetails(ArchiveFile presentationFile, Presentation presentation) {
    final fileContent = utf8.decode(presentationFile.content);
    final presentationDoc = xml.XmlDocument.parse(fileContent);

    // Extract slide size
    var sldSz = presentationDoc.findAllElements("p:sldSz").firstOrNull;
    if (sldSz != null) {
      var cx = sldSz.getAttribute("cx");
      var cy = sldSz.getAttribute("cy");
      if (cx != null && cy != null) {
        // Convert EMU to points (1 point = 12700 EMU)
        double w = double.parse(cx) / 12700;
        double h = double.parse(cy) / 12700;
        _slideSizes[presentation.hashCode] = Size(w, h);
      }
    }
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
        var slideFile = archive.singleWhereOrNull((archiveFile) => archiveFile.name.endsWith(slideRelation.target));
        if (slideFile != null && slideFile.isFile) {
          final fileContent = utf8.decode(slideFile.content);
          final slideDoc = xml.XmlDocument.parse(fileContent);
          presentation.slides[i].fileName = slideFile.name.split("/").last;

          // Parse Slide Relationships for local slide (needed for images)
          List<Relationship> slideLevelRelations = [];
          var checkSlideRel = archive.singleWhereOrNull((archiveFile) => archiveFile.name.endsWith("${presentation.slides[i].fileName}.rels"));
          if (checkSlideRel != null) {
            final fileContentRel = utf8.decode(checkSlideRel.content);
            final documentRel = xml.XmlDocument.parse(fileContentRel);
            for (var rel in documentRel.findAllElements("Relationship")) {
              if (rel.getAttribute("Id") != null && rel.getAttribute("Target") != null) {
                slideLevelRelations.add(Relationship(rel.getAttribute("Id")!, rel.getAttribute("Target")!));
              }
            }
          }

          // Combined processing for p:sp (shapes) and p:pic (images)
          var allElements = slideDoc.descendants.whereType<xml.XmlElement>().where((e) => e.name.local == "sp" || e.name.local == "pic");

          for (var element in allElements) {
            double offsetX = 0;
            double offsetY = 0;
            double scaleX = 1.0;
            double scaleY = 1.0;
            double chOffX = 0;
            double chOffY = 0;

            // Handle grouping transformations
            var parentGrp = element.ancestors.whereType<xml.XmlElement>().firstWhereOrNull((e) => e.name.local == "grpSp");
            if (parentGrp != null) {
              var grpSpPr = parentGrp.findAllElements("p:grpSpPr").firstOrNull;
              if (grpSpPr != null) {
                var xfrm = grpSpPr.findAllElements("a:xfrm").firstOrNull;
                if (xfrm != null) {
                  var off = xfrm.findAllElements("a:off").firstOrNull;
                  var ext = xfrm.findAllElements("a:ext").firstOrNull;
                  var chOff = xfrm.findAllElements("a:chOff").firstOrNull;
                  var chExt = xfrm.findAllElements("a:chExt").firstOrNull;

                  if (off != null) {
                    offsetX = double.tryParse(off.getAttribute("x") ?? "0") ?? 0;
                    offsetY = double.tryParse(off.getAttribute("y") ?? "0") ?? 0;
                  }
                  if (chOff != null) {
                    chOffX = double.tryParse(chOff.getAttribute("x") ?? "0") ?? 0;
                    chOffY = double.tryParse(chOff.getAttribute("y") ?? "0") ?? 0;
                  }
                  if (ext != null && chExt != null) {
                    double ex = double.tryParse(ext.getAttribute("cx") ?? "1") ?? 1;
                    double ey = double.tryParse(ext.getAttribute("cy") ?? "1") ?? 1;
                    double cex = double.tryParse(chExt.getAttribute("cx") ?? "1") ?? 1;
                    double cey = double.tryParse(chExt.getAttribute("cy") ?? "1") ?? 1;
                    scaleX = ex / cex;
                    scaleY = ey / cey;
                  }
                }
              }
            }

            Offset offset = const Offset(0, 0);
            Size size = const Size(0, 0);
            var xfrmElement = element.findAllElements("a:xfrm").firstOrNull;
            if (xfrmElement != null) {
              var chkOff = xfrmElement.findAllElements("a:off").firstOrNull;
              if (chkOff != null) {
                var offX = double.tryParse(chkOff.getAttribute("x") ?? "0") ?? 0;
                var offY = double.tryParse(chkOff.getAttribute("y") ?? "0") ?? 0;
                offset = Offset(offsetX + (offX - chOffX) * scaleX, offsetY + (offY - chOffY) * scaleY);
              }
              var chkExt = xfrmElement.findAllElements("a:ext").firstOrNull;
              if (chkExt != null) {
                var extX = double.tryParse(chkExt.getAttribute("cx") ?? "0") ?? 0;
                var extY = double.tryParse(chkExt.getAttribute("cy") ?? "0") ?? 0;
                size = Size(extX * scaleX, extY * scaleY);
              }
            }

            if (element.name.local == "sp") {
              // Text processing
              List<PresentationParagraph> presentationParagraphs = [];
              element.findAllElements("p:txBody").forEach((txt) {
                txt.findAllElements("a:p").forEach((para) {
                  List<PresentationText> presentationTexts = [];
                  para.findAllElements("a:r").forEach((r) {
                    double fontSize = 18;
                    var rPr = r.findAllElements("a:rPr").firstOrNull;
                    if (rPr != null) {
                      var sz = rPr.getAttribute("sz");
                      if (sz != null) fontSize = double.parse(sz) / 100;
                    }
                    var text = "";
                    r.findAllElements("a:t").forEach((t) => text += t.innerText);
                    if (text.isNotEmpty) presentationTexts.add(PresentationText(text, fontSize));
                  });
                  if (presentationTexts.isNotEmpty) {
                    PresentationParagraph paragraph = PresentationParagraph();
                    paragraph.textSpans = presentationTexts;
                    presentationParagraphs.add(paragraph);
                  }
                });
              });

              if (presentationParagraphs.isNotEmpty) {
                PresentationTextBox presentationTextBox = PresentationTextBox(offset, size);
                presentationTextBox.presentationParas = presentationParagraphs;
                presentation.slides[i].presentationTextBoxes.add(presentationTextBox);
              } else {
                // Shape without text
                presentation.slides[i].presentationShapes.add(PresentationShape("shape", "", offset, size));
              }
            } else if (element.name.local == "pic") {
              // Image processing
              var blip = element.findAllElements("a:blip").firstOrNull;
              var embed = blip?.getAttribute("r:embed");
              if (embed != null) {
                var rel = slideLevelRelations.firstWhereOrNull((r) => r.id == embed);
                if (rel != null) {
                  String imgName = rel.target.split("/").last;
                  String imgPath = "$presentationOutputDirectory/$imgName";
                  presentation.slides[i].presentationShapes.add(PresentationShape("image", "IMG|$imgPath", offset, size));
                }
              }
            }
          }

          // Handle Diagrams/Backgrounds as before but cleaner
          if (checkSlideRel != null) {
            final documentRel = xml.XmlDocument.parse(utf8.decode(checkSlideRel.content));
            for (var rel in documentRel.findAllElements("Relationship")) {
              var type = rel.getAttribute("Type") ?? "";
              var target = (rel.getAttribute("Target") ?? "").replaceAll("../", "");
              if (type.endsWith("diagramDrawing")) {
                var diagramFile = archive.singleWhereOrNull((f) => f.name.endsWith(target));
                if (diagramFile != null) getAllShapes(diagramFile, presentation.slides[i]);
              } else if (type.endsWith("slideLayout")) {
                var layoutRel = archive.singleWhereOrNull((f) => f.name.endsWith("${target.split("/").last}.rels"));
                if (layoutRel != null) {
                  var lRelDoc = xml.XmlDocument.parse(utf8.decode(layoutRel.content));
                  var layoutFile = archive.singleWhereOrNull((f) => f.name.endsWith(target));
                  if (layoutFile != null) {
                    var lDoc = xml.XmlDocument.parse(utf8.decode(layoutFile.content));
                    var blip = lDoc.findAllElements("p:bg").firstOrNull?.findAllElements("a:blip").firstOrNull;
                    var embed = blip?.getAttribute("r:embed");
                    if (embed != null) {
                      var lRel = lRelDoc.findAllElements("Relationship").firstWhereOrNull((r) => r.getAttribute("Id") == embed);
                      if (lRel != null) {
                        var imgName = lRel.getAttribute("Target")?.split("/").last;
                        if (imgName != null) presentation.slides[i].backgroundImagePath = "$presentationOutputDirectory/$imgName";
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
  }

  Future<List<Widget>> displayPresentation(Presentation presentation, double screenWidth) async {
    List<Widget> tempList = [];
    List<Widget> slideWidgets = [];
    for (int i = 0; i < presentation.slides.length; i++) {
      List<Widget> tempSlideWidget = await compute(getSlideDetails, {
        'slide': presentation.slides[i],
        'screenWidth': screenWidth,
        'presentationSize': _slideSizes[presentation.hashCode],
      });
      slideWidgets.addAll(tempSlideWidget);
    }
    tempList.add(SizedBox(
      width: screenWidth,
      child: Column(children: slideWidgets),
    ));
    return tempList;
  }

  static List<Widget> getSlideDetails(Map<String, dynamic> params) {
    Slide slide = params['slide'];
    double screenWidth = params['screenWidth'];
    Size? presSize = params['presentationSize'];
    
    List<Widget> tempShapes = [];
    List<Widget> slideWidget = [];
    
    // Default to 16:9 if unknown, but usually we'll have it now
    double maxWidth = presSize?.width ?? 960;
    double maxHeight = presSize?.height ?? 540;
    int divisionFactor = 12700;

    for (int j = 0; j < slide.presentationTextBoxes.length; j++) {
       double dx = slide.presentationTextBoxes[j].offset.dx / divisionFactor;
       double dy = slide.presentationTextBoxes[j].offset.dy / divisionFactor;
       double w = slide.presentationTextBoxes[j].size.width / divisionFactor;
       double h = slide.presentationTextBoxes[j].size.height / divisionFactor;
       
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
       
       String text = slide.presentationShapes[j].text;
       
       if (text.startsWith("IMG|")) {
         String path = text.substring(4);
         tempShapes.add(Positioned(
           top: dy,
           left: dx,
           child: Image.file(File(path), width: w, height: h, fit: BoxFit.fill),
         ));
       } else {
         tempShapes.add(Positioned(
           top: dy,
           left: dx,
           child: Container(
             decoration: BoxDecoration(border: text.isEmpty ? null : Border.all(color: Colors.blue.withOpacity(0.1))),
             height: h,
             width: w,
             child: text.isEmpty ? null : Center(child: Text(text, style: const TextStyle(fontSize: 10))),
           )
         ));
       }
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
