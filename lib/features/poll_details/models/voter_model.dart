import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

class Voter extends Equatable {
  final String id;
  final String displayName;
  final Color avatarColor;

  const Voter({
    required this.id,
    required this.displayName,
    required this.avatarColor,
  });
  @override
  List<Object?> get props => [id, displayName, avatarColor];
}
