import 'package:bellamarble/core/utils/image_url.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const raw = 'https://belamarble.com/admin/images/product/IMG-1.jpg';

  test('strips the scheme and requests a resized webp', () {
    final u = AppImageUrl.sized(raw, width: 200);
    expect(u, contains('images.weserv.nl'));
    expect(u, contains('output=webp'));
    expect(u, contains('w=200'));
    expect(u, isNot(contains('https%3A')), reason: 'scheme must be stripped');
  });

  test('snaps arbitrary widths to cache-friendly buckets', () {
    expect(AppImageUrl.sized(raw, width: 150), contains('w=200'));
    expect(AppImageUrl.sized(raw, width: 201), contains('w=400'));
    expect(AppImageUrl.sized(raw, width: 900), contains('w=1200'));
    expect(AppImageUrl.sized(raw, width: 5000), contains('w=1200'));
  });

  test('full() caps at 1200 so we never over-fetch', () {
    expect(AppImageUrl.full(raw), contains('w=1200'));
  });

  test('empty input stays empty so isNotEmpty checks still work', () {
    expect(AppImageUrl.sized('', width: 200), '');
    expect(AppImageUrl.full(''), '');
  });

  test('handles http:// and bare hosts', () {
    expect(AppImageUrl.sized('http://x.com/a.jpg', width: 200),
        contains('x.com%2Fa.jpg'));
    expect(AppImageUrl.sized('x.com/a.jpg', width: 200),
        contains('x.com%2Fa.jpg'));
  });
}
