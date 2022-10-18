import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:scanning_world/data/remote/http/http_exception.dart';
import 'package:scanning_world/data/remote/models/coupon.dart';
import 'package:scanning_world/widgets/common/custom_progress_indicator.dart';
import 'package:scanning_world/widgets/common/error_dialog.dart';

import '../data/remote/providers/auth_provider.dart';
import '../theme/theme.dart';

class OrderCouponScreen extends StatefulWidget {
  static const routeName = '/order-coupon';

  const OrderCouponScreen({Key? key}) : super(key: key);

  @override
  State<OrderCouponScreen> createState() => _OrderCouponScreenState();
}

enum OrderState { order, active, loading }

class _OrderCouponScreenState extends State<OrderCouponScreen> {
  var _orderState = OrderState.order;
  ActiveCoupon? _activeCoupon;

  late Timer _timer;
  int secondsLeft= 0;


  void startTimer() {
    secondsLeft = _activeCoupon!.durationInSeconds;
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec,
          (Timer timer) {
        if (_activeCoupon?.durationInSeconds == 0) {
          _timer.cancel();
        } else {
          setState(() {
            secondsLeft--;
          });
        }
      },
    );
  }

  Future<void> _orderCoupon(String couponId, StateSetter setAppState) async {
    final authProvider = context.read<AuthProvider>();
    try {
      setAppState(() => _orderState = OrderState.loading);
      final activeCoupon = await authProvider.orderCoupon(couponId);
      if (!mounted) return;
      Navigator.of(context).pop();
      setAppState(() {
        _activeCoupon = activeCoupon;
      });
      startTimer();
      setState(() {
        _orderState = OrderState.active;
      });
    } on HttpError catch (e) {
      showPlatformDialog(
          context: context, builder: (c) => ErrorDialog(message: e.message));
      setState(() {
        _orderState = OrderState.order;
      });
    }
  }

  void _showConfirmBottomSheet(String couponId) {
    showPlatformModalSheet(
      context: context,
      builder: (context) =>
          StatefulBuilder(builder: (context, StateSetter setState) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(),
              const Text(
                'Zlealizuj kupon',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const Text(
                'Ważny 15 minut',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              AnimatedScale(
                scale: _orderState == OrderState.loading ||
                        _orderState == OrderState.active
                    ? 1.2
                    : 1,
                duration: const Duration(milliseconds: 300),
                child: AnimatedRotation(
                  turns: _orderState == OrderState.loading ? 1 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    context.platformIcon(
                        material: Icons.check_circle_outline,
                        cupertino: _orderState == OrderState.loading ||
                                _orderState == OrderState.active
                            ? CupertinoIcons.check_mark_circled_solid
                            : CupertinoIcons.check_mark_circled),
                    color: Colors.green,
                    size: 64,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: PlatformElevatedButton(
                    onPressed: _orderState == OrderState.loading
                        ? null
                        : () => _orderCoupon(couponId, setState),
                    child: _orderState == OrderState.loading
                        ? const CustomProgressIndicator()
                        : const Text(
                            'Odbierz',
                            style: TextStyle(color: Colors.white),
                          )),
              ),
              SizedBox(
                width: double.infinity,
                child: PlatformTextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Anuluj'),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // var _isInit = false;
  //
  // @override
  // void didChangeDependencies() {
  //   //check if coupon is active
  //   if (!_isInit) {
  //     final couponId = ModalRoute.of(context)!.settings.arguments as String;
  //     _isInit = true;
  //   }
  //   super.didChangeDependencies();
  // }

  @override
  Widget build(BuildContext context) {
    final data =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final coupon = data['coupon'] as Coupon;
    final heroPrefix = data['heroPrefix'] as String;

    final timeLeft = Duration(seconds: secondsLeft);
    final min = timeLeft.inMinutes < 10
        ? '0${timeLeft.inMinutes}'
        : '${timeLeft.inMinutes}';

    final sec = (timeLeft.inSeconds%60) < 10
        ? '0${timeLeft.inSeconds % 60}'
        : '${timeLeft.inSeconds % 60}';


    final String timeLeftString = _activeCoupon !=null ? '$min:$sec' : "15:00";

    return PlatformScaffold(
        appBar: PlatformAppBar(
          title: _orderState == OrderState.active
              ? const Text("Kupon")
              : const Text('Odbierz kupon'),
          cupertino: (_, __) => CupertinoNavigationBarData(
              transitionBetweenRoutes: false, previousPageTitle: 'Kupony'),
        ),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 40),
              child: Hero(
                  tag: '$heroPrefix-${coupon.id}',
                  child: Image.network(
                    coupon.imageUri,
                    width: 200,
                    fit: BoxFit.fill,
                  )),
            ),
            const SizedBox(
              height: 40,
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(
                    left: 20, right: 20, top: 32, bottom: 32),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      coupon.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Ofertę można zrealizować na terenie gminy/miasta ${coupon.region.name}. Wystarczy, że pokazasz zeskanowany kupon osobie obsługującej punkt.",
                      style: const TextStyle(fontSize: 15),
                      textAlign: TextAlign.start,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      "Warunki realizacji:",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      textAlign: TextAlign.start,
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    const Text(
                      "• Oferta jednokrotnego użytku",
                      style: TextStyle(fontSize: 15),
                      textAlign: TextAlign.start,
                    ),
                    const Text(
                      "• Oferta ważna 15 minut od odebrania",
                      style: TextStyle(fontSize: 15),
                      textAlign: TextAlign.start,
                    ),
                    const Text(
                      "• Korzystając z oferty akceptujesz regulamin",
                      style: TextStyle(fontSize: 15),
                      textAlign: TextAlign.start,
                    ),
                    if (_orderState == OrderState.order) const Spacer(),
                    if (_orderState == OrderState.order)
                      SizedBox(
                        width: double.infinity,
                        child: PlatformElevatedButton(
                          child: Text(
                            'Odbierz za ${coupon.points} punktów',
                            style: const TextStyle(color: Colors.white),
                          ),
                          onPressed: () => _showConfirmBottomSheet(coupon.id),
                        ),
                      )
                    else if (_orderState == OrderState.active)
                      Column(
                        children: [
                          const SizedBox(height: 32,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(context.platformIcon(
                                  material: Icons.timer,
                                  cupertino: CupertinoIcons.timer),color: Colors.black,size: 40,),
                              const SizedBox(width: 8,),
                              const Text(
                                'Zrealizuj w ',
                                style: TextStyle(
                                     fontSize: 20),
                                textAlign: TextAlign.center,
                              ),
                              Spacer(),
                              Text(
                                timeLeftString,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                                textAlign: TextAlign.center,
                              ),


                            ],
                          ),
                          const SizedBox(height: 8,),
                          TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 1000),
                            curve: Curves.easeInOut,
                            tween: Tween<double>(
                                begin: 0,
                                end: secondsLeft/ 900,
                            ),
                            builder: (context, value, _) =>
                                LinearProgressIndicator(
                                  value: value,
                                  backgroundColor: primary[100],
                                  valueColor:
                                  AlwaysStoppedAnimation<Color>(primary[700]!),
                                ),
                          ),
                        ],
                      )
                  ],
                ),
              ),
            )
          ],
        ));
  }
}
