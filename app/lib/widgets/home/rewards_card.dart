import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:scanning_world/data/remote/models/coupon.dart';
import 'package:scanning_world/data/remote/providers/auth_provider.dart';
import 'package:scanning_world/screens/order_coupon_screen.dart';
import 'package:scanning_world/widgets/common/white_wrapper.dart';

class RewardCard extends StatelessWidget {
  final Coupon coupon;

  final String heroPrefix;

  const RewardCard({Key? key, required this.coupon, required this.heroPrefix})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userPoints = context.select(
        (AuthProvider authProvider) => authProvider.user?.pointsInRegion ?? 0);
    final canOrder = userPoints >= coupon.points;
    return WhiteWrapper(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Hero(
              tag: '$heroPrefix-${coupon.id}',
              child: Image.network(
                coupon.imageUri,
                height: 30,
                fit: BoxFit.scaleDown,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              coupon.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                  color: Colors.grey.shade900),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: PlatformElevatedButton(
                padding: const EdgeInsets.only(left: 8, right: 8),
                onPressed: canOrder
                    ? () => Navigator.of(context)
                            .pushNamed(OrderCouponScreen.routeName, arguments: {
                          'coupon': coupon,
                          'heroPrefix': heroPrefix,
                        })
                    : null,
                child: FittedBox(
                  child: Text(
                    '${coupon.points} punktów',
                    style: TextStyle(
                        color: canOrder ? Colors.white : Colors.grey.shade700),
                  ),
                ),
              ),
            )
          ],
        ));
  }
}
