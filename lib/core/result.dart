sealed class Result<T> {
  const Result();
  R when<R>({required R Function(T) ok, required R Function(Object, StackTrace?) err}) =>
      switch (this) {
        Ok(value: final v) => ok(v),
        Err(error: final e, st: final s) => err(e, s),
      };
}
class Ok<T> extends Result<T> { final T value; const Ok(this.value); }
class Err<T> extends Result<T> { final Object error; final StackTrace? st; const Err(this.error,[this.st]); }
