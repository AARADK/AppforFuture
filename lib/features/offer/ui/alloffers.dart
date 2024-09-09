import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/offer/model/offer_model.dart';
import 'package:flutter_application_1/features/offer/service/offer_service.dart';
import 'package:flutter_application_1/features/offer/ui/offer_widget.dart';

class AllOffersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('All Offers'),
        backgroundColor: Color(0xFFFF9933),
      ),
      body: FutureBuilder<List<Offer>>(
        future: OfferService().getAllOffers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final offers = snapshot.data!;
            return ListView.builder(
              itemCount: offers.length,
              itemBuilder: (context, index) {
                final offer = offers[index];
                return OfferWidget(offer: offer);
              },
            );
          } else {
            return Center(child: Text('No offers available'));
          }
        },
      ),
    );
  }
}
