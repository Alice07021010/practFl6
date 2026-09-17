import '../models/author.dart';
import '../models/book.dart';
import '../models/genre.dart';
import '../models/library_card.dart';
import '../models/publisher.dart';
import '../models/reader.dart';

const seedGenres = <Genre>[
  Genre(id: 1, name: 'Финансы', description: 'Личные финансы и банковское дело'),
  Genre(id: 2, name: 'Экономика', description: 'Экономика и предпринимательство'),
  Genre(id: 3, name: 'Детектив', description: 'Детективные истории'),
  Genre(id: 4, name: 'Классика', description: 'Классическая литература'),
  Genre(id: 5, name: 'Технологии', description: 'Цифровые технологии'),
  Genre(id: 6, name: 'Психология', description: 'Психология и поведение'),
];

const seedPublishers = <Publisher>[
  Publisher(id: 1, name: 'Капитал Пресс', country: 'Россия'),
  Publisher(id: 2, name: 'Северное издательство', country: 'Россия'),
  Publisher(id: 3, name: 'Лист и цифра', country: 'Беларусь'),
  Publisher(id: 4, name: 'Практикум', country: 'Казахстан'),
];

const seedAuthors = <Author>[
  Author(id: 1, firstName: 'Анна', lastName: 'Белова', country: 'Россия', birthYear: 1984, bookCount: 4),
  Author(id: 2, firstName: 'Максим', lastName: 'Орлов', country: 'Россия', birthYear: 1977, bookCount: 3),
  Author(id: 3, firstName: 'Елена', lastName: 'Ветрова', country: 'Беларусь', birthYear: 1989, bookCount: 3),
  Author(id: 4, firstName: 'Илья', lastName: 'Соколов', country: 'Россия', birthYear: 1991, bookCount: 3),
  Author(id: 5, firstName: 'Мария', lastName: 'Коваль', country: 'Казахстан', birthYear: 1982, bookCount: 3),
  Author(id: 6, firstName: 'Олег', lastName: 'Миронов', country: 'Армения', birthYear: 1975, bookCount: 3),
  Author(id: 7, firstName: 'София', lastName: 'Лебедева', country: 'Россия', birthYear: 1994, bookCount: 3),
  Author(id: 8, firstName: 'Денис', lastName: 'Романов', country: 'Беларусь', birthYear: 1987, bookCount: 2),
];

const seedBooks = <Book>[
  Book(id: 1, title: 'Деньги без паники', isbn: '978-5-001-00001-1', year: 2018, pages: 240, publisherId: 1, authorIds: [1], genreIds: [1], copiesTotal: 8, copiesAvailable: 5),
  Book(id: 2, title: 'Банк на ладони', isbn: '978-5-001-00002-8', year: 2020, pages: 312, publisherId: 3, authorIds: [2], genreIds: [5], copiesTotal: 6, copiesAvailable: 4),
  Book(id: 3, title: 'Тихий процент', isbn: '978-5-001-00003-5', year: 2016, pages: 198, publisherId: 2, authorIds: [3], genreIds: [3], copiesTotal: 7, copiesAvailable: 2),
  Book(id: 4, title: 'Экономика простыми словами', isbn: '978-5-001-00004-2', year: 2019, pages: 356, publisherId: 4, authorIds: [4], genreIds: [2], copiesTotal: 10, copiesAvailable: 7),
  Book(id: 5, title: 'Код финансов', isbn: '978-5-001-00005-9', year: 2022, pages: 420, publisherId: 3, authorIds: [5], genreIds: [1, 5], copiesTotal: 5, copiesAvailable: 1),
  Book(id: 6, title: 'Последний вклад', isbn: '978-5-001-00006-6', year: 2017, pages: 284, publisherId: 2, authorIds: [6], genreIds: [3], copiesTotal: 9, copiesAvailable: 6),
  Book(id: 7, title: 'Психология покупателя', isbn: '978-5-001-00007-3', year: 2021, pages: 268, publisherId: 4, authorIds: [7], genreIds: [6], copiesTotal: 8, copiesAvailable: 8),
  Book(id: 8, title: 'История одной купюры', isbn: '978-5-001-00008-0', year: 2015, pages: 176, publisherId: 1, authorIds: [8], genreIds: [4], copiesTotal: 4, copiesAvailable: 3),
  Book(id: 9, title: 'Финансовая подушка', isbn: '978-5-001-00009-7', year: 2023, pages: 224, publisherId: 1, authorIds: [1], genreIds: [1], copiesTotal: 12, copiesAvailable: 10),
  Book(id: 10, title: 'Рынок без тумана', isbn: '978-5-001-00010-3', year: 2014, pages: 332, publisherId: 4, authorIds: [2], genreIds: [2], copiesTotal: 6, copiesAvailable: 2),
  Book(id: 11, title: 'Цифровой кошелёк', isbn: '978-5-001-00011-0', year: 2024, pages: 390, publisherId: 3, authorIds: [3, 4], genreIds: [5], copiesTotal: 7, copiesAvailable: 5),
  Book(id: 12, title: 'Кредитный след', isbn: '978-5-001-00012-7', year: 2013, pages: 248, publisherId: 2, authorIds: [5], genreIds: [3], copiesTotal: 5, copiesAvailable: 4),
  Book(id: 13, title: 'Человек и цена', isbn: '978-5-001-00013-4', year: 2011, pages: 300, publisherId: 4, authorIds: [6], genreIds: [6], copiesTotal: 9, copiesAvailable: 3),
  Book(id: 14, title: 'Счёт открыт', isbn: '978-5-001-00014-1', year: 2020, pages: 210, publisherId: 1, authorIds: [7], genreIds: [4], copiesTotal: 10, copiesAvailable: 6),
  Book(id: 15, title: 'Пять правил бюджета', isbn: '978-5-001-00015-8', year: 2018, pages: 190, publisherId: 1, authorIds: [1], genreIds: [1], copiesTotal: 15, copiesAvailable: 12),
  Book(id: 16, title: 'Малый бизнес без страха', isbn: '978-5-001-00016-5', year: 2019, pages: 344, publisherId: 4, authorIds: [2], genreIds: [2], copiesTotal: 8, copiesAvailable: 4),
  Book(id: 17, title: 'Алгоритмы кассы', isbn: '978-5-001-00017-2', year: 2022, pages: 476, publisherId: 3, authorIds: [4], genreIds: [5], copiesTotal: 5, copiesAvailable: 2),
  Book(id: 18, title: 'Дело о пропавшем счёте', isbn: '978-5-001-00018-9', year: 2016, pages: 264, publisherId: 2, authorIds: [3], genreIds: [3], copiesTotal: 6, copiesAvailable: 1),
  Book(id: 19, title: 'Доверие в цифрах', isbn: '978-5-001-00019-6', year: 2021, pages: 288, publisherId: 4, authorIds: [5], genreIds: [6], copiesTotal: 11, copiesAvailable: 7),
  Book(id: 20, title: 'Архив кассира', isbn: '978-5-001-00020-2', year: 2012, pages: 154, publisherId: 2, authorIds: [6], genreIds: [4], copiesTotal: 4, copiesAvailable: 2),
  Book(id: 21, title: 'Инвестиции для начинающих', isbn: '978-5-001-00021-9', year: 2024, pages: 360, publisherId: 1, authorIds: [7], genreIds: [1], copiesTotal: 13, copiesAvailable: 9),
  Book(id: 22, title: 'Экономика города', isbn: '978-5-001-00022-6', year: 2010, pages: 412, publisherId: 2, authorIds: [8], genreIds: [2], copiesTotal: 5, copiesAvailable: 5),
  Book(id: 23, title: 'Безопасный платёж', isbn: '978-5-001-00023-3', year: 2023, pages: 328, publisherId: 3, authorIds: [1, 4], genreIds: [1, 5], copiesTotal: 9, copiesAvailable: 8),
  Book(id: 24, title: 'Ночной аудитор', isbn: '978-5-001-00024-0', year: 2017, pages: 296, publisherId: 2, authorIds: [6], genreIds: [3], copiesTotal: 7, copiesAvailable: 5),
];

final seedReaders = <Reader>[
  Reader(id: 1, fullName: 'Иванова Дарья Сергеевна', email: 'd.ivanova@example.com', phone: '+7 999 100-10-10', card: LibraryCard(number: 'CARD-0001', issuedAt: DateTime(2026, 1, 10), expiresAt: DateTime(2027, 1, 10))),
  Reader(id: 2, fullName: 'Петров Артём Ильич', email: 'a.petrov@example.com', phone: '+7 999 200-20-20', card: LibraryCard(number: 'CARD-0002', issuedAt: DateTime(2026, 2, 1), expiresAt: DateTime(2027, 2, 1))),
  Reader(id: 3, fullName: 'Смирнова Елена Олеговна', email: 'e.smirnova@example.com', phone: '+7 999 300-30-30', card: LibraryCard(number: 'CARD-0003', issuedAt: DateTime(2026, 3, 5), expiresAt: DateTime(2027, 3, 5))),
  Reader(id: 4, fullName: 'Козлов Максим Павлович', email: 'm.kozlov@example.com', phone: '+7 999 400-40-40', card: LibraryCard(number: 'CARD-0004', issuedAt: DateTime(2026, 4, 8), expiresAt: DateTime(2027, 4, 8))),
  Reader(id: 5, fullName: 'Орлова Мария Андреевна', email: 'm.orlova@example.com', phone: '+7 999 500-50-50', card: LibraryCard(number: 'CARD-0005', issuedAt: DateTime(2026, 5, 12), expiresAt: DateTime(2027, 5, 12))),
  Reader(id: 6, fullName: 'Волков Илья Денисович', email: 'i.volkov@example.com', phone: '+7 999 600-60-60', card: LibraryCard(number: 'CARD-0006', issuedAt: DateTime(2026, 6, 15), expiresAt: DateTime(2027, 6, 15))),
  Reader(id: 7, fullName: 'Лебедева София Игоревна', email: 's.lebedeva@example.com', phone: '+7 999 700-70-70', card: LibraryCard(number: 'CARD-0007', issuedAt: DateTime(2026, 7, 20), expiresAt: DateTime(2027, 7, 20))),
  Reader(id: 8, fullName: 'Миронов Олег Романович', email: 'o.mironov@example.com', phone: '+7 999 800-80-80', card: LibraryCard(number: 'CARD-0008', issuedAt: DateTime(2026, 8, 1), expiresAt: DateTime(2027, 8, 1))),
];

List<String> get authorCountries => seedAuthors.map((a) => a.country).toSet().toList()..sort();
