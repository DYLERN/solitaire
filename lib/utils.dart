extension IterableExtension<T> on Iterable<T> {
  Iterable<T> takeEnd(int n) {
    if (length < n) {
      return this;
    }

    return skip(length - n);
  }
}