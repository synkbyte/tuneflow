import 'dart:collection';

extension UniqueList<E> on Iterable<E> {
  Set<E> toSetBy(dynamic Function(E e) key) {
    final seenKeys = HashSet<dynamic>();
    return where((element) => seenKeys.add(key(element))).toSet();
  }
}
