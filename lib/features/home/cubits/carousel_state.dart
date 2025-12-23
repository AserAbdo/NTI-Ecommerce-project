import 'package:equatable/equatable.dart';

class DealData extends Equatable {
  final String image;
  final String title;
  final String subtitle;
  final String badge;

  const DealData({
    required this.image,
    required this.title,
    required this.subtitle,
    required this.badge,
  });

  @override
  List<Object?> get props => [image, title, subtitle, badge];
}

abstract class CarouselState extends Equatable {
  const CarouselState();

  @override
  List<Object?> get props => [];
}

class CarouselInitial extends CarouselState {}

class CarouselLoaded extends CarouselState {
  final List<DealData> deals;
  final int currentIndex;
  final double progress;
  final bool isUserInteracting;

  const CarouselLoaded({
    required this.deals,
    required this.currentIndex,
    this.progress = 0.0,
    this.isUserInteracting = false,
  });

  CarouselLoaded copyWith({
    List<DealData>? deals,
    int? currentIndex,
    double? progress,
    bool? isUserInteracting,
  }) {
    return CarouselLoaded(
      deals: deals ?? this.deals,
      currentIndex: currentIndex ?? this.currentIndex,
      progress: progress ?? this.progress,
      isUserInteracting: isUserInteracting ?? this.isUserInteracting,
    );
  }

  @override
  List<Object?> get props => [deals, currentIndex, progress, isUserInteracting];
}
