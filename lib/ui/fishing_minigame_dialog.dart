import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../game/valley_moon_game.dart';
import '../models/fishing_system.dart';

/// Interactive Vertical Tension Fishing Minigame Overlay.
class FishingMinigameDialog extends StatefulWidget {
  final ValleyMoonGame game;
  final FishData fish;
  final VoidCallback onClose;

  const FishingMinigameDialog({
    super.key,
    required this.game,
    required this.fish,
    required this.onClose,
  });

  @override
  State<FishingMinigameDialog> createState() => _FishingMinigameDialogState();
}

class _FishingMinigameDialogState extends State<FishingMinigameDialog> {
  static const double trackHeight = 220.0;
  static const double bobberHeight = 52.0;

  // Bobber (Green Catch Zone) Physics: 0.0 (top) to trackHeight - bobberHeight (bottom)
  double _bobberY = trackHeight - bobberHeight;
  double _bobberVelocity = 0.0;
  bool _isPulling = false;

  // Fish Position Physics: 0.0 (top) to trackHeight - 20 (bottom)
  double _fishY = trackHeight / 2;
  double _fishTargetY = trackHeight / 2;
  double _fishTimer = 0.0;

  // Capture Progress: 0.0 to 1.0 (Starts at 0.3)
  double _catchProgress = 0.30;
  bool _isGameOver = false;
  bool _isVictory = false;
  int _fishSizeCm = 30;

  Timer? _gameLoopTimer;
  final Random _rng = Random();

  @override
  void initState() {
    super.initState();
    _fishSizeCm = widget.fish.generateRandomSize(_rng);
    widget.game.playSFX(GameConstants.sfxFishingCast);

    // 60 FPS Physics Loop (approx. 16ms)
    _gameLoopTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (_isGameOver) return;
      _updatePhysics(0.016);
    });
  }

  void _updatePhysics(double dt) {
    // 1. Bobber Physics (Gravity & Pull)
    const gravity = 480.0;
    const pullForce = -560.0;

    if (_isPulling) {
      _bobberVelocity += pullForce * dt;
    } else {
      _bobberVelocity += gravity * dt;
    }

    _bobberVelocity = _bobberVelocity.clamp(-350.0, 350.0);
    _bobberY += _bobberVelocity * dt;

    final maxBobberY = trackHeight - bobberHeight;
    if (_bobberY > maxBobberY) {
      _bobberY = maxBobberY;
      _bobberVelocity = -_bobberVelocity * 0.25; // Gentle bounce off bottom
    } else if (_bobberY < 0.0) {
      _bobberY = 0.0;
      _bobberVelocity = 0.0;
    }

    // 2. Fish AI Movement
    _fishTimer -= dt;
    if (_fishTimer <= 0) {
      _fishTimer = 0.4 + _rng.nextDouble() * (1.2 - widget.fish.difficulty * 0.6);

      // Behavior patterns
      switch (widget.fish.behavior) {
        case FishBehavior.smooth:
          _fishTargetY = _rng.nextDouble() * (trackHeight - 24.0);
          break;
        case FishBehavior.sinker:
          _fishTargetY = _rng.nextDouble() > 0.4
              ? trackHeight - 40.0 + _rng.nextDouble() * 20.0
              : _rng.nextDouble() * (trackHeight - 24.0);
          break;
        case FishBehavior.floater:
          _fishTargetY = _rng.nextDouble() > 0.4
              ? _rng.nextDouble() * 50.0
              : _rng.nextDouble() * (trackHeight - 24.0);
          break;
        case FishBehavior.dart:
          _fishTargetY = (_rng.nextBool())
              ? 10.0 + _rng.nextDouble() * 40.0
              : trackHeight - 60.0 + _rng.nextDouble() * 40.0;
          break;
      }
    }

    final fishSpeed = 120.0 + widget.fish.difficulty * 180.0;
    final diff = _fishTargetY - _fishY;
    if (diff.abs() > 2.0) {
      _fishY += (diff.sign * min(diff.abs(), fishSpeed * dt));
    }

    // 3. Check if Fish is inside Green Bobber Zone
    final isInsideCatchZone =
        _fishY + 8.0 >= _bobberY && _fishY <= _bobberY + bobberHeight;

    if (isInsideCatchZone) {
      _catchProgress += 0.22 * dt;
    } else {
      _catchProgress -= 0.16 * dt;
    }

    // 4. Win / Loss Condition
    if (_catchProgress >= 1.0) {
      _catchProgress = 1.0;
      _isGameOver = true;
      _isVictory = true;
      _gameLoopTimer?.cancel();
      _onCatchSuccess();
    } else if (_catchProgress <= 0.0) {
      _catchProgress = 0.0;
      _isGameOver = true;
      _isVictory = false;
      _gameLoopTimer?.cancel();
      widget.game.playSFX('wood_click.ogg');
    }

    setState(() {});
  }

  void _onCatchSuccess() {
    widget.game.playSFX(GameConstants.sfxFishCaught);
    widget.game.inventory.addItem(widget.fish.gameItem, count: 1);
  }

  @override
  void dispose() {
    _gameLoopTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isInsideCatchZone =
        _fishY + 8.0 >= _bobberY && _fishY <= _bobberY + bobberHeight;

    return Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          width: 380,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: GameConstants.parchmentLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: GameConstants.rusticWood, width: 4),
            boxShadow: const [
              BoxShadow(
                color: Colors.black87,
                offset: Offset(3, 4),
                blurRadius: 8,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header: Fish Name & Location
              _buildHeader(),
              const SizedBox(height: 10),

              if (!_isGameOver) ...[
                // Main Minigame Track + Progress Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Vertical Fishing Track
                    _buildFishingTrack(isInsideCatchZone),
                    const SizedBox(width: 14),

                    // Vertical Catch Meter
                    _buildCatchMeter(),
                  ],
                ),
                const SizedBox(height: 12),

                // Tension Control Button (PUXAR)
                _buildControlButton(),
              ] else ...[
                // Game Over Screen (Victory or Escape)
                _buildResultView(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(widget.fish.icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.fish.name,
                  style: TextStyle(
                    fontFamily: GameConstants.fontPixel,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: widget.fish.isLegendary
                        ? Colors.amber[900]
                        : GameConstants.rusticWoodDark,
                  ),
                ),
                Text(
                  widget.fish.isLegendary ? '⭐ PEIXE LENDÁRIO' : 'Águas do Vale',
                  style: TextStyle(
                    fontFamily: GameConstants.fontPixel,
                    fontSize: 6,
                    color: widget.fish.isLegendary ? Colors.deepOrange : Colors.brown[600],
                  ),
                ),
              ],
            ),
          ],
        ),
        GestureDetector(
          onTap: widget.onClose,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: GameConstants.healthRed,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(Icons.close, size: 14, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildFishingTrack(bool isInside) {
    return Container(
      width: 48,
      height: trackHeight,
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A5F), // Deep river blue
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isInside ? GameConstants.energyGreen : GameConstants.rusticWood,
          width: 3,
        ),
        boxShadow: isInside
            ? [
                BoxShadow(
                  color: GameConstants.energyGreen.withValues(alpha: 0.6),
                  blurRadius: 8,
                ),
              ]
            : null,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Water ripples pattern
          Positioned.fill(
            child: Opacity(
              opacity: 0.15,
              child: Image.asset(
                'assets/images/tiles/water.png',
                repeat: ImageRepeat.repeat,
              ),
            ),
          ),

          // Green Bobber (Catch Zone)
          Positioned(
            top: _bobberY,
            left: 2,
            right: 2,
            height: bobberHeight,
            child: Container(
              decoration: BoxDecoration(
                color: GameConstants.energyGreen.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.greenAccent, width: 2),
              ),
            ),
          ),

          // Fish Sprite Icon moving
          Positioned(
            top: _fishY,
            left: 12,
            child: Text(
              widget.fish.icon,
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCatchMeter() {
    return Container(
      width: 18,
      height: trackHeight,
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: GameConstants.rusticWood, width: 2),
      ),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          FractionallySizedBox(
            heightFactor: _catchProgress.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: _catchProgress > 0.7
                    ? Colors.green
                    : _catchProgress > 0.3
                        ? Colors.amber
                        : GameConstants.healthRed,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton() {
    return Listener(
      onPointerDown: (_) {
        setState(() => _isPulling = true);
        widget.game.playSFX('wood_click.ogg');
      },
      onPointerUp: (_) => setState(() => _isPulling = false),
      onPointerCancel: (_) => setState(() => _isPulling = false),
      child: Container(
        width: 140,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: _isPulling ? GameConstants.rusticWoodDark : GameConstants.rusticWood,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: GameConstants.parchmentDark, width: 2.5),
          boxShadow: const [
            BoxShadow(
              color: Colors.black45,
              offset: Offset(2, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'SEGURE: PUXAR 🎣',
            style: TextStyle(
              fontFamily: GameConstants.fontPixel,
              fontSize: 7.5,
              fontWeight: FontWeight.bold,
              color: GameConstants.parchmentLight,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultView() {
    if (_isVictory) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white70,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green[800]!, width: 2),
        ),
        child: Column(
          children: [
            const Text('✨ PEIXE FISGADO! ✨',
                style: TextStyle(
                  fontFamily: GameConstants.fontPixel,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                )),
            const SizedBox(height: 8),
            Text(widget.fish.icon, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 6),
            Text(
              widget.fish.name,
              style: const TextStyle(
                fontFamily: GameConstants.fontPixel,
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: GameConstants.rusticWoodDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tamanho: $_fishSizeCm cm • Valor: ${widget.fish.gameItem.sellPrice} Ouro',
              style: TextStyle(fontSize: 10, color: Colors.brown[800]),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: GameConstants.rusticWood,
              ),
              onPressed: widget.onClose,
              child: const Text(
                'Guardar na Mochila',
                style: TextStyle(
                  fontFamily: GameConstants.fontPixel,
                  fontSize: 8,
                  color: GameConstants.parchmentLight,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white70,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: GameConstants.healthRed, width: 2),
        ),
        child: Column(
          children: [
            const Text('O peixe escapou...',
                style: TextStyle(
                  fontFamily: GameConstants.fontPixel,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: GameConstants.healthRed,
                )),
            const SizedBox(height: 8),
            const Text('💨', style: TextStyle(fontSize: 28)),
            const SizedBox(height: 6),
            Text(
              'A linha arrebentou! Tente manter o peixe dentro da zona verde.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 9, color: Colors.brown[800]),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: GameConstants.rusticWood,
              ),
              onPressed: widget.onClose,
              child: const Text(
                'Tentar Novamente',
                style: TextStyle(
                  fontFamily: GameConstants.fontPixel,
                  fontSize: 8,
                  color: GameConstants.parchmentLight,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}
