import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/ask_a_question/model/question_model.dart';

class QuestionListWidget extends StatelessWidget {
  final Future<List<Question>> questionsFuture;
  final String title;
  final void Function(BuildContext context, Question question) onTapQuestion;

  const QuestionListWidget({
    required this.questionsFuture,
    required this.title,
    required this.onTapQuestion,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: screenHeight * 0.01), // Reduced space before the title
        Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
            child: Text(
              title,
              style: TextStyle(
                color: Color(0xFFFF9933),
                fontSize: screenWidth * 0.04,
                fontFamily: 'Inter',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(height: screenHeight * 0.005), // Small space after the title
        SizedBox(
          height: screenHeight * 0.19, // Adjust the height for the list
          child: FutureBuilder<List<Question>>(
            future: questionsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                  child: Text(
                    'Error loading questions: ${snapshot.error}',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: screenWidth * 0.03,
                      fontFamily: 'Inter',
                    ),
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                  child: Text(
                    'No related questions available.',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: screenWidth * 0.03,
                      fontFamily: 'Inter',
                    ),
                  ),
                );
              } else {
                final questions = snapshot.data!;
                return ListView.builder(
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    final question = questions[index];
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.06,
                        vertical: screenHeight * 0.002, // Reduced vertical padding between items
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Color(0xFFFF9933)), // Orange border
                          borderRadius: BorderRadius.circular(8), // Small rounded corners
                        ),
                        child: ListTile(
                          dense: true, // This reduces the height of the ListTile
                          contentPadding: EdgeInsets.symmetric(
                            vertical: screenHeight * 0, // Reduce ListTile internal padding
                            horizontal: screenWidth * 0.04, // Adjust horizontal padding
                          ),
                          title: Text(
                            question.question,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: screenWidth * 0.03,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          trailing: Text(
                            '\$${question.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Color.fromARGB(255, 20, 59, 17),
                              fontSize: screenWidth * 0.03,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          onTap: () {
                            onTapQuestion(context, question);
                          },
                        ),
                      ),
                    );
                  },
                );
              }
            },
          ),
        ),
      ],
    );
  }
}
