import 'package:flutter/material.dart';

class SupportSubmit extends StatelessWidget {
  final String feedback;

  const SupportSubmit({Key? key, required this.feedback}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 315,
              height: 241,
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                shadows: [
                  BoxShadow(
                    color: Color(0x3F000000),
                    blurRadius: 4,
                    offset: Offset(0, 4),
                    spreadRadius: 0,
                  )
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 30,
                    top: 174,
                    child: SizedBox(
                      width: 253,
                      height: 42,
                      child: Text(
                        'Your feedback has been submitted for review!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFFC06500),
                          fontSize: 18,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w100,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 67,
                    top: 6,
                    child: Container(
                      width: 180,
                      height: 153,
                      decoration: ShapeDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/images/submit.png"),
                          fit: BoxFit.fill,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        shadows: [
                          BoxShadow(
                            color: Color(0x3F000000),
                            blurRadius: 4,
                            offset: Offset(0, 4),
                            spreadRadius: 0,
                          )
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 283,
                    top: 200,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 22,
                        height: 32,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("assets/images/Next.png"),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
