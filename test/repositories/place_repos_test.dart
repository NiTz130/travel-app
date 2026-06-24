import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_app/repositories/attractions/attractionList_repo.dart';
import 'package:travel_app/repositories/city/city_repo.dart';
import 'package:travel_app/repositories/restaurants/restaurants_repo.dart';

Map<String, dynamic> placeData({
  required String placeId,
  List reviews = const [],
  List userIds = const [],
}) {
  return {
    'placeId': placeId,
    'title': 'Sample place',
    'imageUrls': ['photo.jpg'],
    'address': '1 Test Street',
    'searchString': 'test',
    'phone': '123',
    'reviews': reviews,
    'userIds': userIds,
    'openingHours': [],
    'location': {'lat': 10.0, 'lng': 20.0},
  };
}

Map<String, dynamic> reviewData({
  required String reviewId,
  required String userId,
  required String text,
}) {
  return {
    'reviewId': reviewId,
    'userId': userId,
    'name': 'Reviewer $userId',
    'publishAt': '2026-01-01T00:00:00.000',
    'reviewerPhotoUrl': 'photo-$userId.jpg',
    'text': text,
  };
}

void main() {
  test('cityRepo.getcityDetailes throws StateError when place is missing', () {
    final repo = cityRepo(
      firestore: FakeFirebaseFirestore(),
      firebaseAuth: MockFirebaseAuth(
        mockUser: MockUser(uid: 'user-1'),
        signedIn: true,
      ),
    );

    expect(
      repo.getcityDetailes('missing-city'),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          'City not found: missing-city',
        ),
      ),
    );
  });

  test(
    'attractionListRepo.deleteReview updates reviews and userIds by placeId',
    () async {
      final firestore = FakeFirebaseFirestore();
      final repo = attractionListRepo(firestore: firestore);
      final docRef = firestore.collection('attractions').doc('attraction-doc');

      final originalReviews = [
        reviewData(reviewId: 'review-1', userId: 'user-1', text: 'Remove me'),
        reviewData(reviewId: 'review-2', userId: 'user-2', text: 'Keep me'),
      ];
      final remainingReviews = [
        reviewData(reviewId: 'review-2', userId: 'user-2', text: 'Keep me'),
      ];

      await docRef.set(
        placeData(
          placeId: 'attraction-place',
          reviews: originalReviews,
          userIds: ['user-1', 'user-2'],
        ),
      );

      await repo.deleteReview(
        placeId: 'attraction-place',
        reviews: remainingReviews,
        userId: 'user-1',
      );

      final saved = await docRef.get();
      expect(saved.data()?['reviews'], remainingReviews);
      expect(saved.data()?['userIds'], ['user-2']);
    },
  );

  test(
    'attractionListRepo.addReview writes the same userIds to duplicate place docs',
    () async {
      final firestore = FakeFirebaseFirestore();
      final repo = attractionListRepo(firestore: firestore);
      final firstDocRef = firestore.collection('attractions').doc('first-doc');
      final secondDocRef = firestore
          .collection('attractions')
          .doc('second-doc');

      await firstDocRef.set(
        placeData(placeId: 'duplicate-attraction', userIds: ['stale-user']),
      );
      await secondDocRef.set(
        placeData(placeId: 'duplicate-attraction', userIds: ['other-user']),
      );

      final reviews = [
        reviewData(reviewId: 'review-1', userId: 'user-1', text: 'Great'),
        reviewData(reviewId: 'review-2', userId: 'user-2', text: 'Nice'),
        reviewData(reviewId: 'review-3', userId: 'user-1', text: 'Again'),
      ];

      await repo.addReview(
        placeId: 'duplicate-attraction',
        reviews: reviews,
        userId: 'user-2',
      );

      final firstDoc = await firstDocRef.get();
      final secondDoc = await secondDocRef.get();
      expect(firstDoc.data()?['reviews'], reviews);
      expect(secondDoc.data()?['reviews'], reviews);
      expect(firstDoc.data()?['userIds'], ['user-1', 'user-2']);
      expect(secondDoc.data()?['userIds'], ['user-1', 'user-2']);
    },
  );

  test(
    'attractionListRepo.deleteReview writes the same userIds to duplicate place docs',
    () async {
      final firestore = FakeFirebaseFirestore();
      final repo = attractionListRepo(firestore: firestore);
      final firstDocRef = firestore.collection('attractions').doc('first-doc');
      final secondDocRef = firestore
          .collection('attractions')
          .doc('second-doc');

      final remainingReviews = [
        reviewData(reviewId: 'review-2', userId: 'user-2', text: 'Keep me'),
      ];

      await firstDocRef.set(
        placeData(
          placeId: 'duplicate-attraction',
          reviews: [
            reviewData(
              reviewId: 'review-1',
              userId: 'user-1',
              text: 'Remove me',
            ),
            ...remainingReviews,
          ],
          userIds: ['user-1', 'user-2'],
        ),
      );
      await secondDocRef.set(
        placeData(
          placeId: 'duplicate-attraction',
          reviews: remainingReviews,
          userIds: ['stale-user'],
        ),
      );

      await repo.deleteReview(
        placeId: 'duplicate-attraction',
        reviews: remainingReviews,
        userId: 'user-1',
      );

      final firstDoc = await firstDocRef.get();
      final secondDoc = await secondDocRef.get();
      expect(firstDoc.data()?['reviews'], remainingReviews);
      expect(secondDoc.data()?['reviews'], remainingReviews);
      expect(firstDoc.data()?['userIds'], ['user-2']);
      expect(secondDoc.data()?['userIds'], ['user-2']);
    },
  );

  test(
    'RestaurantsRepo.addReview updates parent reviews and mirrors subcollection',
    () async {
      final firestore = FakeFirebaseFirestore();
      final repo = RestaurantsRepo(firestore: firestore);
      final docRef = firestore.collection('restaurants').doc('restaurant-doc');

      await docRef.set(placeData(placeId: 'restaurant-place'));
      await docRef
          .collection('reviews')
          .doc('stale-review')
          .set(
            reviewData(
              reviewId: 'stale-review',
              userId: 'old-user',
              text: 'Old review',
            ),
          );

      final reviews = [
        reviewData(reviewId: 'review-1', userId: 'user-1', text: 'Great'),
        reviewData(reviewId: 'review-2', userId: 'user-2', text: 'Excellent'),
      ];

      await repo.addReview(placeId: 'restaurant-place', reviews: reviews);

      final saved = await docRef.get();
      expect(saved.data()?['reviews'], reviews);

      final reviewDocs = await docRef.collection('reviews').get();
      expect(
        reviewDocs.docs.map((doc) => doc.id),
        unorderedEquals(['review-1', 'review-2']),
      );
      expect(
        (await docRef.collection('reviews').doc('review-1').get()).data(),
        reviews.first,
      );
      expect(
        (await docRef.collection('reviews').doc('review-2').get()).data(),
        reviews.last,
      );
      expect(
        (await docRef.collection('reviews').doc('stale-review').get()).exists,
        isFalse,
      );
    },
  );

  test(
    'RestaurantsRepo.getReviews dedupes duplicate parent docs by reviewId',
    () async {
      final firestore = FakeFirebaseFirestore();
      final repo = RestaurantsRepo(firestore: firestore);
      final firstDocRef = firestore.collection('restaurants').doc('first-doc');
      final secondDocRef = firestore
          .collection('restaurants')
          .doc('second-doc');

      await firstDocRef.set(placeData(placeId: 'duplicate-restaurant'));
      await secondDocRef.set(placeData(placeId: 'duplicate-restaurant'));

      final reviews = [
        reviewData(reviewId: 'review-1', userId: 'user-1', text: 'Great'),
        reviewData(reviewId: 'review-2', userId: 'user-2', text: 'Excellent'),
      ];

      for (final docRef in [firstDocRef, secondDocRef]) {
        for (final review in reviews) {
          await docRef
              .collection('reviews')
              .doc(review['reviewId'] as String)
              .set(review);
        }
      }

      final savedReviews = await repo.getReviews('duplicate-restaurant');

      expect(savedReviews, hasLength(2));
      expect(
        savedReviews.map((review) => review.reviewId),
        unorderedEquals(['review-1', 'review-2']),
      );
    },
  );
}
