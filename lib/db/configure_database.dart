/// Selects the SQLite backend for the current platform before the first
/// database is opened. sqflite itself covers Android, iOS and macOS; Windows
/// and Linux use its FFI build, and the web a WASM build of SQLite
/// (`web/sqlite3.wasm` + `web/sqflite_sw.js`, installed by
/// `dart run sqflite_common_ffi_web:setup`).
///
/// The two implementations are split by conditional import because each
/// depends on a library the other platform cannot compile (`dart:ffi` vs
/// `dart:js_interop`).
library;

export 'configure_database_io.dart' if (dart.library.js_interop) 'configure_database_web.dart';
