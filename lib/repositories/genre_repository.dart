import '../models/genre.dart';
import '../models/page_result.dart';
import '../models/simple_query.dart';
abstract interface class GenreRepository {
  Future<PageResult<Genre>> find(SimpleQuery query);
  Future<Genre?> findById(int id);
  Future<List<Genre>> allActive();
  Future<Genre> create(Genre value);
  Future<Genre> update(Genre value);
  Future<void> softDelete(int id);
  Future<void> hardDelete(int id);
  Future<void> restore(int id);
  Future<int> deleteMany(List<int> ids);
}
