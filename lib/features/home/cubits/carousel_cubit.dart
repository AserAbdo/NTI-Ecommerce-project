import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'carousel_state.dart';

class CarouselCubit extends Cubit<CarouselState> {
  Timer? _autoScrollTimer;
  Timer? _progressTimer;

  CarouselCubit() : super(CarouselInitial()) {
    _loadDeals();
  }

  // Static deals data
  static const List<DealData> _dealsData = [
    DealData(
      image: 'assets/images/carousel-1.png',
      title: 'Special Offers',
      subtitle: 'Up to 50% OFF',
      badge: 'HOT',
    ),
    DealData(
      image: 'assets/images/carousel-2.png',
      title: 'Fast Delivery',
      subtitle: 'Shop & Save',
      badge: 'NEW',
    ),
    DealData(
      image: 'assets/images/carousel-3.png',
      title: 'Winter Collection',
      subtitle: 'Stay Warm',
      badge: 'SALE',
    ),
  ];

  void _loadDeals() {
    emit(
      const CarouselLoaded(
        deals: _dealsData,
        currentIndex: 0,
        progress: 0.0,
        isUserInteracting: false,
      ),
    );
    _startAutoScroll();
    _startProgress();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      final currentState = state;
      if (currentState is CarouselLoaded && !currentState.isUserInteracting) {
        goToNext();
      }
    });
  }

  void _startProgress() {
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      final currentState = state;
      if (currentState is CarouselLoaded && !currentState.isUserInteracting) {
        double newProgress = currentState.progress + 0.01;
        if (newProgress >= 1.0) {
          newProgress = 0.0;
        }
        emit(currentState.copyWith(progress: newProgress));
      }
    });
  }

  void goToNext() {
    final currentState = state;
    if (currentState is CarouselLoaded) {
      int nextIndex = currentState.currentIndex + 1;
      if (nextIndex >= currentState.deals.length) {
        nextIndex = 0;
      }
      emit(currentState.copyWith(currentIndex: nextIndex, progress: 0.0));
    }
  }

  void goToPage(int index) {
    final currentState = state;
    if (currentState is CarouselLoaded) {
      emit(currentState.copyWith(currentIndex: index, progress: 0.0));
    }
  }

  void setUserInteracting(bool isInteracting) {
    final currentState = state;
    if (currentState is CarouselLoaded) {
      emit(
        currentState.copyWith(
          isUserInteracting: isInteracting,
          progress: isInteracting ? currentState.progress : 0.0,
        ),
      );
    }
  }

  void onPageChanged(int index) {
    final currentState = state;
    if (currentState is CarouselLoaded) {
      emit(currentState.copyWith(currentIndex: index, progress: 0.0));
    }
  }

  @override
  Future<void> close() {
    _autoScrollTimer?.cancel();
    _progressTimer?.cancel();
    return super.close();
  }
}
