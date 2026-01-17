import '../database/storage_factory.dart';
import '../models/business_trip.dart';

class BusinessTripRepository {
  Future<int> insert(BusinessTrip trip) async {
    return await StorageFactory.instance.insertBusinessTrip(trip);
  }

  Future<void> delete(int id) async {
    await StorageFactory.instance.deleteBusinessTrip(id);
  }

  Future<BusinessTrip?> getById(int id) async {
    return await StorageFactory.instance.getBusinessTripById(id);
  }

  Future<List<BusinessTrip>> getByMonth(int year, int month) async {
    return await StorageFactory.instance.getBusinessTripsByMonth(year, month);
  }
}
