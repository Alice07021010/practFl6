import 'package:flutter/foundation.dart';
import '../models/book.dart';
import '../models/book_query.dart';
import '../models/page_result.dart';
import '../repositories/book_repository.dart';
import 'load_status.dart';
class BookListNotifier extends ChangeNotifier {
  final BookRepository _repository; BookListNotifier(this._repository);
  BookQuery _query=const BookQuery(); PageResult<Book> _result=PageResult.empty(); LoadStatus _status=LoadStatus.idle; String? _error; final Set<int> _selected={};
  BookQuery get query=>_query; PageResult<Book> get result=>_result; LoadStatus get status=>_status; String? get error=>_error; Set<int> get selected=>Set.unmodifiable(_selected); bool get hasSelection=>_selected.isNotEmpty;
  Future<void> applyQuery(BookQuery next) async{if(next!=_query){_query=next;_selected.clear();}await load();}
  Future<void> load() async{_status=LoadStatus.loading;_error=null;notifyListeners();try{_result=await _repository.find(_query);_status=LoadStatus.success;}catch(e){_error='Не удалось загрузить список: $e';_status=LoadStatus.error;}notifyListeners();}
  void toggleSelection(int id){_selected.contains(id)?_selected.remove(id):_selected.add(id);notifyListeners();}
  Future<void> deleteSelected() async{await _repository.deleteMany(_selected.toList());_selected.clear();await load();}
  Future<void> softDelete(int id) async{await _repository.softDelete(id);_selected.remove(id);await load();}
  Future<void> hardDelete(int id) async{await _repository.hardDelete(id);_selected.remove(id);await load();}
  Future<void> restore(int id) async{await _repository.restore(id);await load();}
  Future<Book?> findById(int id)=>_repository.findById(id);
  Future<Book> create(Book b) async{final v=await _repository.create(b);await load();return v;}
  Future<Book> update(Book b) async{final v=await _repository.update(b);await load();return v;}
}
