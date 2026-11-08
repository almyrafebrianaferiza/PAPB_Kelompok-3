import 'package:flutter/material.dart';
import '../theme/zenvora_warna.dart';

class PenandaHabis extends StatelessWidget {
  const PenandaHabis({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: ZWarna.galat,
        borderRadius: BorderRadius.circular(ZRadius.kecil),
        boxShadow: [
          BoxShadow(
            color: ZWarna.galat.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.remove_circle_outline, size: 12, color: ZWarna.putih),
          SizedBox(width: 4),
          Text(
            'STOK HABIS',
            style: TextStyle(
              color: ZWarna.putih,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
