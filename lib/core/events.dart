import 'dart:async';
import '../models/listing_model.dart';

class EventBus {
  EventBus._();

  static final _listingCreatedController = StreamController<Listing>.broadcast();
  static Stream<Listing> get onListingCreated => _listingCreatedController.stream;
  static void fireListingCreated(Listing listing) => _listingCreatedController.add(listing);

  static final _listingDeletedController = StreamController<String>.broadcast();
  static Stream<String> get onListingDeleted => _listingDeletedController.stream;
  static void fireListingDeleted(String id) => _listingDeletedController.add(id);

  static final _listingStatusChangedController = StreamController<ListingStatus>.broadcast();
  static Stream<ListingStatus> get onListingStatusChanged => _listingStatusChangedController.stream;
  static void fireListingStatusChanged(ListingStatus status) => _listingStatusChangedController.add(status);
}
