import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sportsphere_mobile/features/profile/data/photo_upload_repository.dart';

class MockImagePicker extends Mock implements ImagePicker {}

void main() {
  setUpAll(() {
    registerFallbackValue(ImageSource.gallery);
  });

  group('PhotoUploadRepository', () {
    late MockImagePicker mockPicker;
    late PhotoUploadRepository repo;

    setUp(() {
      mockPicker = MockImagePicker();
      repo = PhotoUploadRepository(picker: mockPicker);
    });

    test('pickPhoto returns null when user cancels', () async {
      when(() => mockPicker.pickImage(
            source: any(named: 'source'),
            imageQuality: any(named: 'imageQuality'),
            maxWidth: any(named: 'maxWidth'),
          )).thenAnswer((_) async => null);

      final result = await repo.pickPhoto(fromCamera: false);

      expect(result, isNull);
    });

    test('pickPhoto returns XFile when user selects image', () async {
      final fakeFile = XFile('/fake/path/photo.jpg');
      when(() => mockPicker.pickImage(
            source: any(named: 'source'),
            imageQuality: any(named: 'imageQuality'),
            maxWidth: any(named: 'maxWidth'),
          )).thenAnswer((_) async => fakeFile);

      final result = await repo.pickPhoto(fromCamera: false);

      expect(result, isNotNull);
      expect(result!.path, '/fake/path/photo.jpg');
    });
  });
}
