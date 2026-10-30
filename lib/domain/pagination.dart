/// Une page d'une liste : les elements, le numero (a partir de 0) et le
/// nombre de pages.
class PageSlice<T> {
  const PageSlice({
    required this.items,
    required this.page,
    required this.pageCount,
    required this.total,
  });

  final List<T> items;
  final int page;
  final int pageCount;
  final int total;

  bool get hasPrevious => page > 0;
  bool get hasNext => page < pageCount - 1;
}

/// Decoupe `all` en pages de `pageSize` elements. Un numero hors limites est
/// ramene dans [0, pageCount - 1] ; une liste vide donne une seule page vide.
PageSlice<T> paginate<T>(List<T> all, {required int page, required int pageSize}) {
  assert(pageSize > 0, 'pageSize doit etre positif');
  final pageCount = all.isEmpty ? 1 : (all.length + pageSize - 1) ~/ pageSize;
  final safe = page.clamp(0, pageCount - 1);
  final start = safe * pageSize;
  final end = start + pageSize > all.length ? all.length : start + pageSize;
  return PageSlice(
    items: all.sublist(start, end),
    page: safe,
    pageCount: pageCount,
    total: all.length,
  );
}
