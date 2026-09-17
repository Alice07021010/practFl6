import '../models/page_result.dart';
import '../models/publisher.dart';
import '../models/simple_query.dart';
abstract interface class PublisherRepository {
  Future<PageResult<Publisher>> find(SimpleQuery query);
  Future<Publisher?> findById(int id);
  Future<List<Publisher>> allActive();
  Future<Publisher> create(Publisher value);
  Future<Publisher> update(Publisher value);
  Future<void> softDelete(int id);
  Future<void> hardDelete(int id);
  Future<void> restore(int id);
  Future<int> deleteMany(List<int> ids);
}
