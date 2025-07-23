import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class placeDescription extends StatefulWidget {
  final hasData;

  const placeDescription({super.key, required this.hasData});

  @override
  State<placeDescription> createState() => _placeDescriptionState(hasData);
}

class _placeDescriptionState extends State<placeDescription> {
  late String aboutDetails =
      "Thông tin về địa điểm này đang được cập nhật. Nếu bạn từng ghé thăm, hãy để lại nhận xét nhé!\n\nĐây là một điểm đến thú vị với nhiều điều hấp dẫn đang chờ bạn khám phá. Cùng tìm hiểu chi tiết hơn để lên kế hoạch cho chuyến đi của mình!";
  bool showFullText = false;
  final hasData;
  _placeDescriptionState(this.hasData);

  @override
  Widget build(BuildContext context) {
    return hasData
        ? LayoutBuilder(
      builder: (context, constraints) {
        final textSpan = TextSpan(
          text: aboutDetails,
          style: GoogleFonts.cabin(
            textStyle: const TextStyle(
              color: Color.fromARGB(255, 112, 112, 112),
              fontSize: 11,
              fontWeight: FontWeight.w400,
            ),
          ),
        );
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
          maxLines: 4,
        );
        textPainter.layout(maxWidth: constraints.maxWidth);
        final isTextOverflowed = textPainter.didExceedMaxLines;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: textSpan,
              maxLines: showFullText ? null : 4,
              overflow: TextOverflow.clip,
            ),
            if (isTextOverflowed)
              GestureDetector(
                onTap: () {
                  setState(() {
                    showFullText = !showFullText;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 140),
                  child: Text(
                    showFullText ? 'Thu gọn' : 'Xem thêm',
                    style: GoogleFonts.cabin(
                      textStyle: const TextStyle(
                        color: Color.fromARGB(255, 19, 148, 223),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    )
        : SizedBox(
      height: 100,
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) {
                if (index == 4) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 3, right: 80),
                    child: Container(
                      width: 50,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 3, right: 14),
                    child: Container(
                      width: 100,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
