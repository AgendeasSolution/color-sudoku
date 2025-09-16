import 'package:flutter/material.dart';

enum ModalType { 
  none, 
  noSolution, 
  levelComplete, 
  gameOver, 
  solutionComplete, 
  gameComplete 
}

enum ModalAction { 
  close, 
  nextLevel, 
  restartLevel, 
  restartGame,
  playAgain
}

class ModalContent {
  final String icon;
  final String title;
  final String text;
  final String buttonText;
  final Color buttonColor;
  final ModalAction action;

  const ModalContent({
    required this.icon,
    required this.title,
    required this.text,
    required this.buttonText,
    required this.buttonColor,
    required this.action,
  });
}

class ModalContentProvider {
  static ModalContent getModalContent(ModalType type) {
    switch (type) {
      case ModalType.noSolution:
        return const ModalContent(
          icon: '❌',
          title: 'No Solution Found',
          text: 'It\'s not possible to complete the grid from this position. You\'ll need to restart.',
          buttonText: 'Got It',
          buttonColor: Color(0xFF4A5568),
          action: ModalAction.close,
        );
      case ModalType.levelComplete:
        return const ModalContent(
          icon: '🎉',
          title: 'Level Complete!',
          text: 'Great job! You\'ve successfully completed the level.',
          buttonText: 'Next Level',
          buttonColor: Color(0xFF38A169),
          action: ModalAction.nextLevel,
        );
      case ModalType.gameOver:
        return const ModalContent(
          icon: '💥',
          title: 'Game Over!',
          text: 'All available colors are blocked! No valid moves left. Try a different strategy.',
          buttonText: 'Try Again',
          buttonColor: Color(0xFFE53E3E),
          action: ModalAction.restartLevel,
        );
      case ModalType.solutionComplete:
        return const ModalContent(
          icon: '✨',
          title: 'Solution Complete!',
          text: 'The solution has been revealed. You can see how to complete this level.',
          buttonText: 'Play Again',
          buttonColor: Color(0xFFD69E2E),
          action: ModalAction.playAgain,
        );
      case ModalType.gameComplete:
        return const ModalContent(
          icon: '🏆',
          title: 'You Win!',
          text: 'Congratulations! You\'ve mastered the Color Sudoku puzzle!',
          buttonText: 'Play Again',
          buttonColor: Color(0xFFD69E2E),
          action: ModalAction.restartGame,
        );
      default:
        return const ModalContent(
          icon: '',
          title: '',
          text: '',
          buttonText: '',
          buttonColor: Colors.transparent,
          action: ModalAction.close,
        );
    }
  }
}
