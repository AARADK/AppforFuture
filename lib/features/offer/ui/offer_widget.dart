import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/offer/model/offer_model.dart';
import 'package:flutter_application_1/features/offer/repo/offer_repo.dart';
import 'package:flutter_application_1/features/offer/ui/offer_page.dart';

class OfferWidget extends StatefulWidget {
  final Offer? offer; // Nullable offer
  final bool tappable; // Control tap behavior

  const OfferWidget({this.offer, this.tappable = true}); // Default to true

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
      return _buildNoBundleContainer(screenWidth, screenHeight);
    }

    return widget.tappable
        ? GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OfferPage(offer: widget.offer!)),
              );
            },
            child: _buildOfferContainer(screenWidth, screenHeight),
          )
        : _buildOfferContainer(screenWidth, screenHeight);
  }

  Widget _buildNoBundleContainer(double screenWidth, double screenHeight) {
    return Container(
      margin: EdgeInsets.all(screenWidth * 0.02),
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(screenWidth * 0.02),
        border: Border.all(
          color: Color(0xFFFF9933), // Orange border
          width: 2.0, // Set border width
        ),
        color: Colors.white,
      ),
      child: Center(
        child: Text(
          'No bundles available at the moment',
          style: TextStyle(
            fontSize: screenWidth * 0.05, // Responsive font size
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
      ),
    );
  }

  Widget _buildOfferContainer(double screenWidth, double screenHeight) {
    return Container(
      margin: EdgeInsets.all(screenWidth * 0.02),
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(screenWidth * 0.02),
        border: Border.all(
          color: Color(0xFFFF9933), // Orange border
          width: 2.0, // Set border width
        ),
        color: Colors.white,
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
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '\$${widget.offer?.price?.toStringAsFixed(2) ?? '0.00'}',
                style: TextStyle(
                  fontSize: screenWidth * 0.05,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.01),
          // Image container
          widget.offer?.imageData != null
              ? Image.memory(
                  widget.offer!.imageData!,
                  width: screenWidth * 0.9,
                  height: screenHeight * 0.14,
                  fit: BoxFit.cover,
                )
              : Placeholder(
                  fallbackHeight: screenHeight * 0.14,
                  fallbackWidth: screenWidth * 0.9,
                ),
          SizedBox(height: screenHeight * 0.01),
          // Side-by-side counts
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Horoscope Questions: ${widget.offer?.horoscopeQuestionCount ?? 0}',
                  style: TextStyle(
                    fontSize: screenWidth * 0.03,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Compatibility Questions: ${widget.offer?.compatibilityQuestionCount ?? 0}',
                  style: TextStyle(
                    fontSize: screenWidth * 0.03,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.01),
          // Auspicious Question
          Text(
            'Auspicious Question: ${_auspiciousQuestion ?? 'Loading...'}',
            style: TextStyle(
              fontSize: screenWidth * 0.03,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
