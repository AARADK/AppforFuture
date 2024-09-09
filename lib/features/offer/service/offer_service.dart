import 'dart:convert'; // For JSON decoding
import 'package:flutter_application_1/features/offer/model/offer_model.dart';
import 'package:flutter_application_1/features/offer/repo/offer_repo.dart';
import 'package:http/http.dart' as http; // Assuming you're using http package


class OfferService {
  final OfferRepository _repository = OfferRepository();

  // Method to fetch and return top offers (top 5)
  Future<List<Offer>> getTopOffers() async {
    List<Offer> offers = await _repository.fetchOffers();
    return offers.take(5).toList(); // Return the top 5 offers
  }

  // Method to fetch and return all offers
  Future<List<Offer>> getAllOffers() async {
    List<Offer> offers = await _repository.fetchOffers();
    return offers; // Return all offers
  }
}
