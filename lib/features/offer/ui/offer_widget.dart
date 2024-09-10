import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/offer/model/offer_model.dart';
import 'package:flutter_application_1/features/offer/repo/offer_repo.dart';
import 'package:flutter_application_1/features/offer/ui/offer_page.dart';

class OfferWidget extends StatefulWidget {
  final Offer? offer; // Changed to nullable

  const OfferWidget({this.offer});

  @override
  _OfferWidgetState createState() => _OfferWidgetState();
}

class _OfferWidgetState extends State<OfferWidget> {
  String? _auspiciousQuestion;

  @override
  void initState() {
    super.initState();
    if (widget.offer != null) {
      _fetchQuestion();
    }
  }

  Future<void> _fetchQuestion() async {
    try {
      final repository = OfferRepository();
      final questions = await repository.fetchQuestions();
      setState(() {
        _auspiciousQuestion = questions[widget.offer!.auspiciousQuestionId] ?? 'N/A';
      });
    } catch (e) {
      setState(() {
        _auspiciousQuestion = 'Error fetching question';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    if (widget.offer == null) {
      return Container(
        margin: EdgeInsets.all(screenWidth * 0.02), // Responsive margin
        padding: EdgeInsets.all(screenWidth * 0.04), // Responsive padding
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(screenWidth * 0.02), // Responsive border radius
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0xFFFF9933).withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
            ),
          ],
        ),
        child: Center(
          child: Text(
            'Bundle Not Available',
            style: TextStyle(
              fontSize: screenWidth * 0.05, // Responsive font size
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => OfferPage(offer: widget.offer!)),
        );
      },
      child: Container(
        margin: EdgeInsets.all(screenWidth * 0.02), // Responsive margin
        padding: EdgeInsets.all(screenWidth * 0.04), // Responsive padding
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(screenWidth * 0.02), // Responsive border radius
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0xFFFF9933).withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with name and price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.offer?.name ?? 'No Name Available',
                    style: TextStyle(
                      fontSize: screenWidth * 0.04, // Responsive font size
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis, // Handle overflow
                  ),
                ),
                Text(
                  '\$${widget.offer?.price?.toStringAsFixed(2) ?? '0.00'}',
                  style: TextStyle(
                    fontSize: screenWidth * 0.05, // Responsive font size
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.01), // Responsive spacing
            // Image container
            widget.offer?.imageData != null
                ? Image.memory(
                    widget.offer!.imageData!,
                    width: screenWidth * 0.9, // Full width
                    height: screenHeight * 0.14, // Responsive height
                    fit: BoxFit.cover,
                  )
                : Placeholder(
                    fallbackHeight: screenHeight * 0.14, // Responsive height
                    fallbackWidth: screenWidth * 0.9, // Full width
                  ),
            SizedBox(height: screenHeight * 0.01), // Responsive spacing
            // Side-by-side counts
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Horoscope Questions: ${widget.offer?.horoscopeQuestionCount ?? 0}',
                    style: TextStyle(
                      fontSize: screenWidth * 0.03, // Responsive font size
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Compatibility Questions: ${widget.offer?.compatibilityQuestionCount ?? 0}',
                    style: TextStyle(
                      fontSize: screenWidth * 0.03, // Responsive font size
                    ),
                    textAlign: TextAlign.right, // Align text to the right
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.01), // Responsive spacing
            // Auspicious Question
            Text(
              'Auspicious Question: ${_auspiciousQuestion ?? 'Loading...'}',
              style: TextStyle(
                fontSize: screenWidth * 0.03, // Responsive font size
              ),
              overflow: TextOverflow.ellipsis, // Handle overflow
            ),
          ],
        ),
      ),
    );
  }
}
