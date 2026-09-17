const http = require('http');
const url = require('url');
const crypto = require('crypto');

const args = process.argv.slice(2);
const arg = (name, fallback) => {
  const i = args.indexOf(name);
  return i >= 0 && args[i + 1] ? args[i + 1] : fallback;
};

const port = Number(arg('--port', '8080'));
const allowedOrigin = arg('--origin', 'http://localhost:5555');
const accessTtlSeconds = Number(arg('--ttl', '900'));

let genres = [
  {id:1,name:'Финансы',description:'Личные финансы',deletedAt:null},
  {id:2,name:'Экономика',description:'Экономика',deletedAt:null},
  {id:3,name:'Детектив',description:'Детективы',deletedAt:null},
  {id:4,name:'Классика',description:'Классика',deletedAt:null},
  {id:5,name:'Технологии',description:'Технологии',deletedAt:null},
  {id:6,name:'Психология',description:'Психология',deletedAt:null},
];

let publishers = [
  {id:1,name:'Капитал Пресс',country:'Россия',deletedAt:null},
  {id:2,name:'Северное издательство',country:'Россия',deletedAt:null},
  {id:3,name:'Лист и цифра',country:'Беларусь',deletedAt:null},
  {id:4,name:'Практикум',country:'Казахстан',deletedAt:null},
];

let authors = [
  {id:1,firstName:'Анна',lastName:'Белова',country:'Россия',birthYear:1984,bookCount:4,deletedAt:null},
  {id:2,firstName:'Максим',lastName:'Орлов',country:'Россия',birthYear:1977,bookCount:3,deletedAt:null},
  {id:3,firstName:'Елена',lastName:'Ветрова',country:'Беларусь',birthYear:1989,bookCount:3,deletedAt:null},
  {id:4,firstName:'Илья',lastName:'Соколов',country:'Россия',birthYear:1991,bookCount:3,deletedAt:null},
  {id:5,firstName:'Мария',lastName:'Коваль',country:'Казахстан',birthYear:1982,bookCount:3,deletedAt:null},
  {id:6,firstName:'Олег',lastName:'Миронов',country:'Армения',birthYear:1975,bookCount:3,deletedAt:null},
  {id:7,firstName:'София',lastName:'Лебедева',country:'Россия',birthYear:1994,bookCount:3,deletedAt:null},
  {id:8,firstName:'Денис',lastName:'Романов',country:'Беларусь',birthYear:1987,bookCount:2,deletedAt:null},
];

let books = Array.from({length:24}, (_, i) => ({
  id:i+1,
  title:['Деньги без паники','Банк на ладони','Тихий процент','Экономика простыми словами','Код финансов','Последний вклад','Психология покупателя','История одной купюры','Финансовая подушка','Рынок без тумана','Цифровой кошелёк','Кредитный след','Человек и цена','Счёт открыт','Пять правил бюджета','Малый бизнес без страха','Алгоритмы кассы','Дело о пропавшем счёте','Доверие в цифрах','Архив кассира','Инвестиции для начинающих','Экономика города','Безопасный платёж','Ночной аудитор'][i],
  isbn:`978-5-001-${String(i+1).padStart(5,'0')}-${(i*7+1)%10}`,
  year:2010+(i%15),
  pages:180+(i*17)%300,
  publisherId:1+(i%4),
  authorIds:[1+(i%8)],
  genreIds:[1+(i%6)],
  copiesTotal:5+(i%8),
  copiesAvailable:i===4?0:2+(i%5),
  deletedAt:null,
}));

let readers = [
  {id:1,fullName:'Иванов Иван Иванович',email:'reader@example.com',phone:'+7 999 000-00-01',card:{number:'CARD-0001',issuedAt:'2026-01-01T00:00:00.000Z',expiresAt:'2027-01-01T00:00:00.000Z'},deletedAt:null},
  ...Array.from({length:7}, (_, i) => ({
    id:i+2,
    fullName:`Читатель ${i+2}`,
    email:`reader${i+2}@example.com`,
    phone:`+7 999 000-00-0${i+2}`,
    card:{number:`CARD-000${i+2}`,issuedAt:'2026-01-01T00:00:00.000Z',expiresAt:'2027-01-01T00:00:00.000Z'},
    deletedAt:null,
  })),
];

let users = [
  {id:1,username:'reader',password:'Reader!123',displayName:'Иван Иванов',role:'reader'},
  {id:2,username:'librarian',password:'Librarian!123',displayName:'Мария Библиотекарь',role:'librarian'},
  {id:3,username:'admin',password:'Admin!123',displayName:'Алиса Администратор',role:'admin'},
];

let loans = [
  {id:1,bookId:1,readerId:1,issuedAt:'2026-09-01T10:00:00.000Z',dueAt:'2026-09-15T10:00:00.000Z',returnedAt:null},
];

const accessTokens = new Map();
const refreshTokens = new Map();
const sets = {books, authors, genres, publishers, readers};

const body = req => new Promise(resolve => {
  let data = '';
  req.on('data', chunk => data += chunk);
  req.on('end', () => {
    try { resolve(data ? JSON.parse(data) : {}); }
    catch { resolve({}); }
  });
});

const headers = origin => ({
  'Content-Type':'application/json; charset=utf-8',
  ...(origin === allowedOrigin ? {'Access-Control-Allow-Origin':origin} : {}),
  'Access-Control-Allow-Headers':'Content-Type, Authorization',
  'Access-Control-Allow-Methods':'GET,POST,PUT,DELETE,OPTIONS',
});

const send = (res, status, data, origin) => {
  res.writeHead(status, headers(origin));
  res.end(status === 204 ? '' : JSON.stringify(data));
};

const publicUser = user => ({
  id:user.id,
  username:user.username,
  displayName:user.displayName,
  role:user.role,
});

const randomToken = prefix => `${prefix}_${crypto.randomBytes(24).toString('hex')}`;

function createSession(user) {
  const accessToken = randomToken('access');
  const refreshToken = randomToken('refresh');
  accessTokens.set(accessToken, {
    userId:user.id,
    expiresAt:Date.now() + accessTtlSeconds * 1000,
  });
  refreshTokens.set(refreshToken, {
    userId:user.id,
    expiresAt:Date.now() + 7 * 24 * 60 * 60 * 1000,
  });
  return {accessToken, refreshToken, user:publicUser(user)};
}

function authenticatedUser(req) {
  const raw = req.headers.authorization || '';
  const token = raw.startsWith('Bearer ') ? raw.substring(7) : '';
  const session = accessTokens.get(token);
  if (!session) return null;
  if (session.expiresAt <= Date.now()) {
    accessTokens.delete(token);
    return null;
  }
  return users.find(u => u.id === session.userId) || null;
}

function requireAuth(req, res, origin, roles = null) {
  const user = authenticatedUser(req);
  if (!user) {
    send(res, 401, {message:'Требуется вход в систему.'}, origin);
    return null;
  }
  if (roles && !roles.includes(user.role)) {
    send(res, 403, {message:'Недостаточно прав для этого действия.'}, origin);
    return null;
  }
  return user;
}

const nextId = arr => Math.max(0, ...arr.map(x => x.id)) + 1;

function page(arr, q, kind) {
  let rows = arr.filter(x => q.includeDeleted === 'true' || !x.deletedAt);
  const search = (q.search || '').toLowerCase();
  if (search) rows = rows.filter(x => JSON.stringify(x).toLowerCase().includes(search));
  if (kind === 'books') {
    if (q.genreId) rows = rows.filter(x => x.genreIds.includes(Number(q.genreId)));
    if (q.publisherId) rows = rows.filter(x => x.publisherId === Number(q.publisherId));
    if (q.yearFrom) rows = rows.filter(x => x.year >= Number(q.yearFrom));
    if (q.yearTo) rows = rows.filter(x => x.year <= Number(q.yearTo));
  }
  if (kind === 'authors' && q.country) rows = rows.filter(x => x.country === q.country);
  const [field='name', dir='asc'] = (q.sort || 'name,asc').split(',');
  rows.sort((a,b) => String(a[field] ?? '').localeCompare(String(b[field] ?? ''), 'ru', {numeric:true}) * (dir === 'desc' ? -1 : 1));
  const p = Math.max(1, Number(q.page) || 1);
  const size = [10,25,50].includes(Number(q.size)) ? Number(q.size) : 10;
  return {items:rows.slice((p-1)*size, p*size), page:p, size, total:rows.length};
}

async function handleAuth(req, res, parts, origin) {
  const action = parts[2];
  if (req.method === 'POST' && action === 'login') {
    const data = await body(req);
    const user = users.find(u => u.username === String(data.username || '').trim());
    if (!user || user.password !== data.password) {
      return send(res, 401, {message:'Неверный логин или пароль.'}, origin);
    }
    return send(res, 200, createSession(user), origin);
  }
  if (req.method === 'POST' && action === 'register') {
    const data = await body(req);
    const username = String(data.username || '').trim();
    const displayName = String(data.displayName || '').trim();
    const password = String(data.password || '');
    if (username.length < 3 || displayName.length < 2 || password.length < 8 || !/\d/.test(password) || !/[!@#$%^&*(),.?":{}|<>_\-+=]/.test(password)) {
      return send(res, 422, {message:'Ошибка валидации',errors:{password:'Пароль должен содержать минимум 8 символов, цифру и специальный символ.'}}, origin);
    }
    if (users.some(u => u.username.toLowerCase() === username.toLowerCase())) {
      return send(res, 422, {message:'Ошибка валидации',errors:{username:'Такой логин уже занят.'}}, origin);
    }
    const id = nextId(users);
    const user = {id, username, password, displayName, role:'reader'};
    users.push(user);
    readers.push({
      id,
      fullName:displayName,
      email:`${username}@example.com`,
      phone:'',
      card:{number:`CARD-${String(id).padStart(4,'0')}`,issuedAt:new Date().toISOString(),expiresAt:new Date(Date.now()+365*24*60*60*1000).toISOString()},
      deletedAt:null,
    });
    return send(res, 201, createSession(user), origin);
  }
  if (req.method === 'POST' && action === 'refresh') {
    const data = await body(req);
    const token = String(data.refreshToken || '');
    const session = refreshTokens.get(token);
    if (!session || session.expiresAt <= Date.now()) {
      refreshTokens.delete(token);
      return send(res, 401, {message:'Токен обновления недействителен.'}, origin);
    }
    refreshTokens.delete(token);
    const user = users.find(u => u.id === session.userId);
    if (!user) return send(res, 401, {message:'Пользователь не найден.'}, origin);
    return send(res, 200, createSession(user), origin);
  }
  if (req.method === 'GET' && action === 'me') {
    const user = requireAuth(req, res, origin);
    if (!user) return;
    return send(res, 200, publicUser(user), origin);
  }
  return send(res, 404, {message:'Маршрут аутентификации не найден.'}, origin);
}

function loanView(loan) {
  const book = books.find(b => b.id === loan.bookId);
  const reader = readers.find(r => r.id === loan.readerId);
  return {
    ...loan,
    bookTitle:book?.title || `Книга #${loan.bookId}`,
    readerName:reader?.fullName || `Читатель #${loan.readerId}`,
  };
}

async function handleLoans(req, res, parts, origin) {
  const idOrAction = parts[2];
  const action = parts[3];
  if (req.method === 'GET' && idOrAction === 'mine') {
    const user = requireAuth(req, res, origin, ['reader']);
    if (!user) return;
    return send(res, 200, loans.filter(x => x.readerId === user.id).map(loanView), origin);
  }
  if (req.method === 'GET' && !idOrAction) {
    if (!requireAuth(req, res, origin, ['librarian','admin'])) return;
    return send(res, 200, loans.map(loanView), origin);
  }
  if (req.method === 'POST' && !idOrAction) {
    if (!requireAuth(req, res, origin, ['librarian','admin'])) return;
    const data = await body(req);
    const book = books.find(b => b.id === Number(data.bookId) && !b.deletedAt);
    const reader = readers.find(r => r.id === Number(data.readerId) && !r.deletedAt);
    if (!book || !reader) return send(res, 422, {message:'Ошибка валидации',errors:{form:'Книга или читатель не найдены.'}}, origin);
    if (book.copiesAvailable <= 0) return send(res, 409, {message:'Нет свободных экземпляров книги.'}, origin);
    book.copiesAvailable--;
    const now = new Date();
    const loan = {id:nextId(loans),bookId:book.id,readerId:reader.id,issuedAt:now.toISOString(),dueAt:new Date(now.getTime()+14*24*60*60*1000).toISOString(),returnedAt:null};
    loans.push(loan);
    return send(res, 201, loanView(loan), origin);
  }
  const loan = loans.find(x => x.id === Number(idOrAction));
  if (!loan) return send(res, 404, {message:'Выдача не найдена.'}, origin);
  if (req.method === 'POST' && action === 'renew') {
    const user = requireAuth(req, res, origin, ['reader']);
    if (!user) return;
    if (loan.readerId !== user.id) return send(res, 403, {message:'Можно продлевать только свои выдачи.'}, origin);
    if (loan.returnedAt) return send(res, 409, {message:'Выдача уже закрыта.'}, origin);
    loan.dueAt = new Date(new Date(loan.dueAt).getTime()+7*24*60*60*1000).toISOString();
    return send(res, 200, loanView(loan), origin);
  }
  if (req.method === 'POST' && action === 'close') {
    if (!requireAuth(req, res, origin, ['librarian','admin'])) return;
    if (!loan.returnedAt) {
      loan.returnedAt = new Date().toISOString();
      const book = books.find(b => b.id === loan.bookId);
      if (book) book.copiesAvailable = Math.min(book.copiesTotal, book.copiesAvailable + 1);
    }
    return send(res, 200, loanView(loan), origin);
  }
  return send(res, 405, {message:'Метод не поддерживается.'}, origin);
}

async function handleAdmin(req, res, parts, origin) {
  if (!requireAuth(req, res, origin, ['admin'])) return;
  if (parts[2] === 'users') {
    if (req.method === 'GET' && !parts[3]) {
      return send(res, 200, users.map(publicUser), origin);
    }
    if (req.method === 'PUT' && parts[4] === 'role') {
      const user = users.find(u => u.id === Number(parts[3]));
      if (!user) return send(res, 404, {message:'Пользователь не найден.'}, origin);
      const data = await body(req);
      if (!['reader','librarian','admin'].includes(data.role)) return send(res, 422, {message:'Неизвестная роль.'}, origin);
      user.role = data.role;
      return send(res, 200, publicUser(user), origin);
    }
  }
  if (parts[2] === 'stats' && req.method === 'GET') {
    return send(res, 200, {
      'Книг':books.filter(x=>!x.deletedAt).length,
      'Читателей':readers.filter(x=>!x.deletedAt).length,
      'Открытых выдач':loans.filter(x=>!x.returnedAt).length,
      'Пользователей':users.length,
      'Удалённых записей':Object.values(sets).flat().filter(x=>x.deletedAt).length,
    }, origin);
  }
  return send(res, 404, {message:'Административный маршрут не найден.'}, origin);
}

function mutationAllowed(user, hard, restore) {
  if (hard || restore) return user.role === 'admin';
  return user.role === 'librarian' || user.role === 'admin';
}

async function routeCollection(req, res, kind, id, action, q, origin) {
  const arr = sets[kind];
  if (!arr) return send(res, 404, {message:'Ресурс не найден.'}, origin);

  const user = requireAuth(req, res, origin);
  if (!user) return;

  const isRead = req.method === 'GET';
  if (kind === 'readers' && isRead && !['librarian','admin'].includes(user.role)) {
    return send(res, 403, {message:'Список читателей доступен библиотекарю и администратору.'}, origin);
  }
  if (!isRead) {
    const hard = q.hard === 'true';
    const restore = action === 'restore';
    if (!mutationAllowed(user, hard, restore)) {
      return send(res, 403, {message:'Недостаточно прав для изменения данных.'}, origin);
    }
  }

  if (q.__delay) await new Promise(r => setTimeout(r, Number(q.__delay)));
  if (q.__fail) return send(res, Number(q.__fail), {message:'Учебная ошибка сервера'}, origin);

  if (req.method === 'GET' && !id) return send(res, 200, page(arr, q, kind), origin);

  if (id) {
    const index = arr.findIndex(x => x.id === Number(id));
    if (index < 0) return send(res, 404, {message:'Запись не найдена.'}, origin);
    if (req.method === 'GET') return send(res, 200, arr[index], origin);
    if (req.method === 'POST' && action === 'restore') {
      arr[index].deletedAt = null;
      return send(res, 200, arr[index], origin);
    }
    if (kind === 'books' && req.method === 'POST' && action === 'issue') {
      if (!['librarian','admin'].includes(user.role)) return send(res, 403, {message:'Оформлять выдачи может библиотекарь.'}, origin);
      if (arr[index].copiesAvailable <= 0) return send(res, 409, {message:'Нет свободных экземпляров книги'}, origin);
      arr[index].copiesAvailable--;
      return send(res, 200, arr[index], origin);
    }
    if (req.method === 'PUT') {
      const data = await body(req);
      if (kind === 'books' && arr.some(x => x.id !== Number(id) && x.isbn === data.isbn)) return send(res, 422, {message:'Ошибка валидации',errors:{isbn:'Книга с таким ISBN уже существует'}}, origin);
      if (kind === 'readers' && arr.some(x => x.id !== Number(id) && x.email === data.email)) return send(res, 422, {message:'Ошибка валидации',errors:{email:'Читатель с такой почтой уже существует'}}, origin);
      arr[index] = {...arr[index], ...data, id:Number(id), deletedAt:arr[index].deletedAt};
      return send(res, 200, arr[index], origin);
    }
    if (req.method === 'DELETE') {
      if (kind === 'publishers') {
        const linked = books.filter(b => b.publisherId === Number(id) && !b.deletedAt).length;
        if (linked > 0) return send(res, 409, {message:`Нельзя удалить издательство: связано книг — ${linked}`}, origin);
      }
      if (q.hard === 'true') {
        arr.splice(index, 1);
        return send(res, 200, {deleted:1}, origin);
      }
      arr[index].deletedAt = new Date().toISOString();
      return send(res, 200, arr[index], origin);
    }
  }

  if (req.method === 'POST' && action === 'bulk-delete') {
    let count = 0;
    const data = await body(req);
    for (const item of arr) {
      if ((data.ids || []).includes(item.id) && !item.deletedAt) {
        item.deletedAt = new Date().toISOString();
        count++;
      }
    }
    return send(res, 200, {deleted:count}, origin);
  }

  if (req.method === 'POST' && !id) {
    const data = await body(req);
    if (kind === 'books' && arr.some(x => x.isbn === data.isbn)) return send(res, 422, {message:'Ошибка валидации',errors:{isbn:'Книга с таким ISBN уже существует'}}, origin);
    if (kind === 'readers' && arr.some(x => x.email === data.email)) return send(res, 422, {message:'Ошибка валидации',errors:{email:'Читатель с такой почтой уже существует'}}, origin);
    const item = {...data, id:nextId(arr), deletedAt:null};
    arr.push(item);
    return send(res, 201, item, origin);
  }

  return send(res, 405, {message:'Метод не поддерживается.'}, origin);
}

http.createServer(async (req, res) => {
  const origin = req.headers.origin || '';
  if (req.method === 'OPTIONS') return send(res, 204, {}, origin);

  const parsed = url.parse(req.url, true);
  const parts = parsed.pathname.split('/').filter(Boolean);
  if (parts[0] !== 'api') return send(res, 404, {message:'Используйте /api'}, origin);
  if (parts[1] === '__health') return send(res, 200, {ok:true,service:'tmyv-deneg-auth-mock',accessTtlSeconds}, origin);
  if (parts[1] === 'auth') return handleAuth(req, res, parts, origin);
  if (parts[1] === 'loans') return handleLoans(req, res, parts, origin);
  if (parts[1] === 'admin') return handleAdmin(req, res, parts, origin);

  let id = parts[2];
  let action = parts[3];
  if (parts[2] === 'bulk-delete') {
    id = null;
    action = 'bulk-delete';
  }
  return routeCollection(req, res, parts[1], id, action, parsed.query, origin);
}).listen(port, () => {
  console.log(`Mock API PR5: http://localhost:${port}/api`);
  console.log(`CORS origin: ${allowedOrigin}`);
  console.log(`Access token TTL: ${accessTtlSeconds} sec`);
  console.log('Accounts: reader/Reader!123, librarian/Librarian!123, admin/Admin!123');
});
