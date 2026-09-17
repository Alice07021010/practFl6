import '../models/page_result.dart';
import '../models/reader.dart';
import '../models/simple_query.dart';
abstract interface class ReaderRepository {
  Future<PageResult<Reader>> find(SimpleQuery query);
  Future<Reader?> findById(int id);
  Future<Reader> create(Reader value);
  Future<Reader> update(Reader value);
  Future<void> softDelete(int id);
  Future<void> hardDelete(int id);
  Future<void> restore(int id);
  Future<int> deleteMany(List<int> ids);
}
